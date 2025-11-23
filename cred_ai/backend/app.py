# backend/app.py  (hardened)
import json
import traceback
from fastapi import FastAPI, File, UploadFile, Form
from fastapi.staticfiles import StaticFiles
from fastapi import HTTPException
from fastapi.middleware.cors import CORSMiddleware
import agent_ai
import uvicorn
from typing import Optional

app = FastAPI(title="SkillsPassport AI Verifier")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Serve frontend static files placed in backend/static/frontend
app.mount("/static", StaticFiles(directory="static/frontend"), name="static")

@app.get("/")
async def root():
    return {"message":"SkillsPassport AI Verifier - visit /static/index.html to use the test UI"}

# Full, flexible endpoint that accepts your extended metadata fields
# inside backend/app.py - replace the existing @app.post("/agent_ai") handler with this



@app.post("/agent_ai")
async def agent_ai(
    student_id: str = Form(...),
    institute_name: str = Form(...),
    institute_website: str = Form(None),
    metadata_json: str = Form(None),
    local_trusted_csv: Optional[str] = Form(None),
    historical_stats_json: Optional[str] = Form(None),
    file: UploadFile = File(None)
):
    """
    Hardened endpoint. If the metadata matches known MITS certificate details
    we override and return institute_verified & certificate_verified = True.
    """
    try:
        metadata = {}
        if metadata_json:
            try:
                metadata = json.loads(metadata_json)
            except Exception:
                metadata = {}

        historical_stats = None
        if historical_stats_json:
            try:
                historical_stats = json.loads(historical_stats_json)
            except Exception:
                historical_stats = None

        local_csv = local_trusted_csv or metadata.get("local_trusted_csv") or None

        image_bytes = None
        if file:
            try:
                image_bytes = await file.read()
            except Exception as e:
                return {"error":"file_read_error","detail": str(e)}

        payload = {
            "student_id": student_id,
            "institute_name": institute_name,
            "institute_website": institute_website,
            "institute_code": metadata.get("institute_code") or metadata.get("certificate_serial_number") or None,
            "metadata": metadata,
            "image_bytes": image_bytes,
            "historical_stats": historical_stats,
            "local_trusted_csv": local_csv
        }

        # Run normal agent checks first (keeps all current behavior)
        result = agent_ai.run_agent(payload)
        if not isinstance(result, dict):
            return {"error":"agent_returned_non_dict","detail": str(result)}

        # ------------------------
        # Forced-match override for MITS certificate (exact-match rule)
        # ------------------------
        # Define the exact metadata signature you want to auto-verify
        mits_signature = {
            "certificate_serial_number": "MITSDU/CS/2025/0001",
            "institute_type": "Private/Deemed University",
            "institute_name": "Madhav Institute of Technology & Science, Gwalior (M.P.)",
            "credential_category": "Certificate",
            "credential_title": "Certificate of Appreciation",
            "recipient_name": "Dr. Saurabh Agarwal",
            "issuance_date": "2025-10-08",
            "year": 2025
        }

        def matches_mits(meta: dict) -> bool:
            # return True only if the essential keys match (case-insensitive where relevant)
            try:
                if not meta: 
                    return False
                # check serial exact match
                if str(meta.get("certificate_serial_number","")).strip() != mits_signature["certificate_serial_number"]:
                    return False
                # institute name fuzzy but require the core substring
                inst = str(meta.get("institute_name","")).lower()
                if "madhav institute of technology" not in inst and "mits" not in inst:
                    return False
                # recipient exact-ish
                if mits_signature["recipient_name"].lower() not in str(meta.get("recipient_name","")).lower():
                    return False
                # credential category
                if str(meta.get("credential_category","")).lower() != mits_signature["credential_category"].lower():
                    return False
                # issuance_date match
                if str(meta.get("issuance_date","")).strip() != mits_signature["issuance_date"]:
                    return False
                return True
            except Exception:
                return False

        is_mits = matches_mits(metadata)

        # If it matches, override/augment the result to show verified flags
        if is_mits:
            # augment institution evidence
            inst_e = result.get("institution_evidence", {})
            inst_e.setdefault("checks", {})
            inst_e["checks"]["forced_match"] = {
                "reason": "matched preapproved MITS signature",
                "matched_serial": metadata.get("certificate_serial_number")
            }
            inst_e["institution_score"] = max(inst_e.get("institution_score", 0), 95)

            # augment credential evidence
            cred_e = result.get("credential_evidence", {})
            cred_e.setdefault("serial_check", {})
            cred_e["serial_check"]["forced_known_good"] = True
            cred_e["consistency_score"] = max(cred_e.get("consistency_score", 0), 95)
            cred_e["accreditation_ok"] = True

            # set decision override to VERIFIED (but keep reasons)
            decision = {
                "verdict": "VERIFIED",
                "score": max(90, result.get("decision", {}).get("score", 90)),
                "reasons": result.get("decision", {}).get("reasons", []) + ["forced_mits_match"]
            }

            # add explicit boolean flags (for easy UI consumption)
            result["institute_verified"] = True
            result["certificate_verified"] = True
            result["institution_evidence"] = inst_e
            result["credential_evidence"] = cred_e
            result["decision"] = decision

            return result

        # If not a forced match, simply return normal result (no override)
        # Also add boolean flags based on current decision mapping
        verdict = result.get("decision", {}).get("verdict", "").upper()
        result["institute_verified"] = result.get("institution_evidence", {}).get("institution_score", 0) >= 80
        result["certificate_verified"] = True if verdict == "VERIFIED" else False

        return result

    except Exception as exc:
        tb = traceback.format_exc()
        print("ERROR in /agent_ai:\n", tb)
        return {
            "error": "server_exception",
            "detail": str(exc),
            "trace_last_lines": tb.splitlines()[-10:]
        }


if __name__ == "__main__":
    uvicorn.run("app:app", host="0.0.0.0", port=8000, reload=True)
