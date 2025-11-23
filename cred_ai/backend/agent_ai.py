# backend/agent_ai.py  (Windows/local-friendly version)
import os, joblib, json, datetime, tempfile
from typing import Dict, Any, Optional
from urllib.parse import urlparse
from pathlib import Path

import pandas as pd
import numpy as np
import requests
from PIL import Image, ImageChops, ImageOps
import pytesseract
from pdf2image import convert_from_path
from fuzzywuzzy import fuzz
import dns.resolver
import whois

# ---------------------------
# Local-path configuration (no /mnt)
# ---------------------------
# Candidate CSV locations (relative to backend/ or absolute)
CANDIDATE_CSV_PATHS = [
    Path("data/NIT_SILCHAR Dataset.csv"),
    Path("data/NIT_SILCHAR_Dataset.csv"),
    Path("NIT_SILCHAR Dataset.csv"),
    Path("NIT_SILCHAR_Dataset.csv"),
    Path("../data/NIT_SILCHAR Dataset.csv"),
    Path("../data/NIT_SILCHAR_Dataset.csv"),
]

LOCAL_TRUSTED_CSV = None
for p in CANDIDATE_CSV_PATHS:
    if p.exists():
        LOCAL_TRUSTED_CSV = str(p.resolve())
        break

# If still None, try to find any CSV with "NIT" in name inside data/
if LOCAL_TRUSTED_CSV is None:
    data_dir = Path("data")
    if data_dir.exists() and data_dir.is_dir():
        for f in data_dir.iterdir():
            if f.is_file() and "nit" in f.name.lower() and f.suffix.lower() == ".csv":
                LOCAL_TRUSTED_CSV = str(f.resolve())
                break

# Models directory (local)
_MODEL_DIR = Path("models")
_MODEL_DIR.mkdir(parents=True, exist_ok=True)

_CLASSIFIER_P = _MODEL_DIR / "classifier_model.joblib"
_ANOMALY_P = _MODEL_DIR / "anomaly_model.joblib"

print("agent_ai starting. Trusted CSV:", LOCAL_TRUSTED_CSV or "(not found)")
print("Model dir:", str(_MODEL_DIR.resolve()))
print("Classifier file:", str(_CLASSIFIER_P.resolve()))
print("Anomaly file:", str(_ANOMALY_P.resolve()))

# ---------------------------
# Load trusted CSV if available
# ---------------------------
_TRUST_DF = None
if LOCAL_TRUSTED_CSV and os.path.exists(LOCAL_TRUSTED_CSV):
    try:
        _TRUST_DF = pd.read_csv(LOCAL_TRUSTED_CSV)
        print("Loaded trusted CSV, rows:", len(_TRUST_DF))
    except Exception as e:
        print("Failed to load trusted CSV:", e)
        _TRUST_DF = None
else:
    print("No trusted CSV loaded. Place your CSV into backend/data/ and restart.")

# ---------------------------
# Load ML models if available
# ---------------------------
_classifier = None
_iso_model = None
try:
    if _CLASSIFIER_P.exists():
        _classifier = joblib.load(_CLASSIFIER_P)
        print("Loaded classifier model.")
    else:
        print("Classifier model not found at", _CLASSIFIER_P)
except Exception as e:
    print("Error loading classifier:", e)
    _classifier = None

try:
    if _ANOMALY_P.exists():
        _iso_model = joblib.load(_ANOMALY_P)
        print("Loaded anomaly model.")
    else:
        print("Anomaly model not found at", _ANOMALY_P)
except Exception as e:
    print("Error loading anomaly model:", e)
    _iso_model = None

# ---------------------------
# Features list (same as training)
# ---------------------------
FEATURES = [
    "marks_percent","num_subjects","signed_hash_present","ocr_vs_meta_name_match",
    "ocr_vs_meta_institute_match","ela_score","image_complexity_kb","marks_removed_flag","marks_missing"
]

# ---------- small helpers ----------
def ocr_image(pil_img: Image.Image) -> str:
    gray = ImageOps.grayscale(pil_img)
    return pytesseract.image_to_string(gray, lang='eng')

def ela_score_from_image(pil_img: Image.Image) -> float:
    with tempfile.NamedTemporaryFile(suffix=".jpg", delete=False) as f:
        pil_img.convert("RGB").save(f.name, "JPEG", quality=90)
        saved = Image.open(f.name)
    diff = ImageChops.difference(pil_img.convert("RGB"), saved)
    score = float(np.mean(np.array(diff.convert("L"))))
    try: os.remove(f.name)
    except: pass
    return score

# Trusted CSV lookup (exact column names)
def find_in_trusted(institute_name: str, institute_code: Optional[str]=None):
    if _TRUST_DF is None:
        return False, None, 0
    name_cols = [c for c in _TRUST_DF.columns if "institute" in c.lower() or "name" in c.lower()]
    if not name_cols:
        name_cols = _TRUST_DF.columns.tolist()
    best_score = 0; best_row = None
    for _, r in _TRUST_DF.iterrows():
        for nc in name_cols:
            try:
                cand = str(r.get(nc,""))
                s = fuzz.token_set_ratio(institute_name.lower(), cand.lower())
                if s > best_score:
                    best_score = s; best_row = r
            except:
                continue
    # code match if csv has certificate_serial_number column or code
    if institute_code and "code" in _TRUST_DF.columns:
        matched = _TRUST_DF[_TRUST_DF["code"].astype(str).str.lower()==str(institute_code).lower()]
        if len(matched):
            best_score = 100; best_row = matched.iloc[0]
    return (best_score>=75), (best_row.to_dict() if best_row is not None else None), int(best_score)

# Web checks
def webpage_check(url, timeout=6):
    out={"ok":False}
    if not url: return {"ok":False,"error":"no-url"}
    if not url.startswith("http"): url = "http://"+url
    try:
        r = requests.get(url, timeout=timeout, allow_redirects=True)
        out["ok"]=True; out["status_code"]=r.status_code
        html = r.text
        s = html.lower().find("<title>")
        if s!=-1:
            e = html.lower().find("</title>", s)
            out["title"]=html[s+7:e].strip() if e!=-1 else ""
        else:
            out["title"]=""
        out["text_snippet"]=html[:1000]
    except Exception as e:
        out["ok"]=False; out["error"]=str(e)
    return out

def whois_age_days(domain):
    try:
        w = whois.whois(domain)
        cd = w.creation_date
        if isinstance(cd, list): cd = cd[0]
        if not cd: return None
        return (datetime.datetime.now()-cd).days
    except:
        return None

def mx_check(domain):
    try:
        answers = dns.resolver.resolve(domain, 'MX')
        return len(answers) > 0
    except:
        return False

def semantic_sim(a,b):
    try:
        # fallback to fuzzy
        return float(fuzz.token_set_ratio(a,b))
    except:
        return 0.0

def institution_authenticator(institute_name, institute_website=None, institute_code=None):
    evidence={"checks":{}}
    score=0
    found, row, row_score = find_in_trusted(institute_name, institute_code)
    evidence["checks"]["trusted_csv"] = {"found":found,"match_score":row_score,"row":row}
    if found: score+=60
    if institute_website:
        wc = webpage_check(institute_website)
        evidence["checks"]["website"]=wc
        if wc.get("ok"):
            sim = semantic_sim(institute_name, (wc.get("title","") + " " + wc.get("text_snippet","")[:300]))
            evidence["checks"]["website"]["semantic_score"]=sim
            if wc.get("status_code") in (200,301,302): score+=10
            if sim>=70: score+=20
            elif sim>=50: score+=10
        # whois + mx
        try:
            domain = urlparse(institute_website).netloc or institute_website
            if domain.startswith("www."): domain=domain.split("www.")[-1]
            age = whois_age_days(domain)
            evidence["checks"]["whois_age_days"]=age
            if age and age>365: score+=5
            mx = mx_check(domain)
            evidence["checks"]["mx_ok"]=mx
            if mx: score+=5
        except Exception as e:
            evidence["checks"]["whois_mx_err"]=str(e)
    else:
        evidence["checks"]["website"]={"ok":False,"note":"no-website"}
    if institute_code and isinstance(institute_code,str) and len(institute_code)>2:
        score+=3
    evidence["institution_score"]=int(max(0,min(100,score)))
    return evidence

# Extract fields from OCR text
def extract_fields(ocr_text):
    out={"name":None,"degree":None,"marks":None,"issuance_date":None,"institute":None,"serial":None}
    lines = [l.strip() for l in str(ocr_text).splitlines() if l.strip()]
    for l in lines:
        low=l.lower()
        if ("name" in low and ":" in l) or ("student" in low and ":" in l):
            out["name"]=l.split(":",1)[1].strip()
        if ("degree" in low or "course" in low) and ":" in l:
            out["degree"]=l.split(":",1)[1].strip()
        if ("marks" in low or "percentage" in low or "gpa" in low) and ":" in l:
            out["marks"]=l.split(":",1)[1].strip()
        if ("issued on" in low or "issuance" in low or ("date" in low and ":" in l)):
            out["issuance_date"]=l.split(":",1)[1].strip() if ":" in l else l.strip()
        if ("institute" in low or "university" in low or "college" in low) and ":" in l:
            out["institute"]=l.split(":",1)[1].strip()
        if ("serial" in low or "certificate no" in low or "certificate no." in low) and ":" in l:
            out["serial"]=l.split(":",1)[1].strip()
    if not out["marks"]:
        import re
        m = re.search(r"(\d{1,3}\.\d+|\d{1,3})\s*%", ocr_text or "")
        if m: out["marks"]=m.group(1)+"%"
    return out

def serial_check(serial):
    if _TRUST_DF is None or serial is None: return {"found":False}
    matches = _TRUST_DF[_TRUST_DF.get("certificate_serial_number","").astype(str)==str(serial)]
    if matches.shape[0]==0: return {"found":False}
    return {"found":True,"count":int(matches.shape[0]),"rows":matches.to_dict(orient="records"), "reused": matches.shape[0]>1}

def credential_verifier(metadata, image_bytes=None):
    evidence={"ocr_text":"","fields":{},"consistency_score":0,"ela":None,"serial_check":None,"accreditation_ok":None,"date_check":None}
    ocr_text=""
    if image_bytes:
        from io import BytesIO
        img = Image.open(BytesIO(image_bytes)).convert("RGB")
        ocr_text = ocr_image(img)
        evidence["ela"] = ela_score_from_image(img)
    else:
        ocr_text = metadata.get("raw_text","") or ""
    evidence["ocr_text"]=ocr_text[:5000]
    fields = extract_fields(ocr_text)
    evidence["fields"]=fields

    total=0; match=0
    if metadata.get("recipient_name"):
        total+=1
        if fields.get("name") and fuzz.token_set_ratio(fields["name"].lower(), str(metadata["recipient_name"]).lower())>80:
            match+=1
    if metadata.get("issuer_name"):
        total+=1
        if fields.get("institute") and fuzz.token_set_ratio(fields["institute"].lower(), str(metadata["issuer_name"]).lower())>75:
            match+=1
    if metadata.get("marks") is not None or metadata.get("marks_percent") is not None or metadata.get("percentage") is not None:
        total+=1
        def num_from_str(s):
            if not s: return None
            import re
            m = re.search(r"\d+(\.\d+)?", str(s))
            return float(m.group(0)) if m else None
        meta_num = num_from_str(metadata.get("marks") or metadata.get("marks_percent") or metadata.get("percentage"))
        ocr_num = num_from_str(fields.get("marks"))
        if meta_num is not None and ocr_num is not None:
            # small numeric tolerance
            if abs(meta_num - ocr_num) <= 1.0:
                match += 1
        else:
            # fallback: fuzzy string match
            if fields.get("marks") and metadata.get("marks") and fuzz.token_set_ratio(str(fields.get("marks")), str(metadata.get("marks")))>80:
                match += 1

    # finalize consistency score
    evidence["consistency_score"] = int((match / total) * 100) if total > 0 else 0

    # serial checks (if metadata has certificate_serial_number)
    serial = metadata.get("certificate_serial_number") or fields.get("serial")
    if serial:
        evidence["serial_check"] = serial_check(serial)

    # accreditation check (if metadata/CSV has accreditation text, compare)
    accred_meta = metadata.get("accreditation_statement")
    accred_ok = None
    if accred_meta and _TRUST_DF is not None:
        inst_name = metadata.get("issuer_name", "")
        matches = _TRUST_DF[_TRUST_DF.get("institute_name", "").astype(str).str.lower().str.contains(str(inst_name).lower(), na=False)]
        accred_ok = False
        for _, r in matches.iterrows():
            combined = " ".join([str(r.get(c, "")) for c in r.index if isinstance(c, str)])
            if accred_meta.lower() in combined.lower() or any(k.lower() in combined.lower() for k in ["ugc", "aicte", "naac", "abet", "national importance", "ministry"]):
                accred_ok = True
                break
    evidence["accreditation_ok"] = accred_ok

    # issuance_date vs convocation_date logic
    try:
        iss = metadata.get("issuance_date")
        conv = metadata.get("convocation_date")
        if iss and conv:
            d_iss = datetime.datetime.fromisoformat(iss)
            d_conv = datetime.datetime.fromisoformat(conv)
            delta_days = (d_conv - d_iss).days
            evidence["date_check"] = {"issuance": iss, "convocation": conv, "delta_days": delta_days}
            if delta_days < 0:
                evidence["date_check"]["issue"] = "convocation_before_issuance"
    except Exception:
        evidence["date_check"] = None

    return evidence
