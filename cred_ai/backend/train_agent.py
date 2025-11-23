# backend/train_agent.py
import os, joblib, json
from pathlib import Path
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier, IsolationForest
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_recall_fscore_support, confusion_matrix, roc_auc_score
import warnings
warnings.filterwarnings("ignore")

# Paths (edit if needed)
CSV_PATH = "D:/Documents/NIT_SILCHAR Dataset.csv"   # your uploaded CSV path
OUT_DIR = Path("models")
OUT_DIR.mkdir(parents=True, exist_ok=True)
CLASSIFIER_P = OUT_DIR / "classifier_model.joblib"
ANOMALY_P = OUT_DIR / "anomaly_model.joblib"
METRICS_P = OUT_DIR / "training_metrics.json"

# Required column names (exact from your CSV header)
expected_cols = [
 "unique_registration_roll_number","student_id","certificate_serial_number",
 "institute_type","institute_name","institute_website","accreditation_statement",
 "credential_category","credential_title","issuance_date","convocation_date","year",
 "marks_percent","marks_removed_flag","num_subjects","signed_hash_present",
 "ocr_vs_meta_name_match","ocr_vs_meta_institute_match","ela_score","image_complexity_kb",
 "label","tamper_type","image_file","meta_file","logo_file"
]

if not os.path.exists(CSV_PATH):
    raise FileNotFoundError(f"CSV not found: {CSV_PATH}")

df = pd.read_csv(CSV_PATH)
print("Loaded CSV rows:", len(df))

# Create/ensure numeric features used by model
# Feature list we will use (exact names)
FEATURES = [
    "marks_percent",
    "num_subjects",
    "signed_hash_present",
    "ocr_vs_meta_name_match",
    "ocr_vs_meta_institute_match",
    "ela_score",
    "image_complexity_kb",
    "marks_removed_flag",
    "marks_missing"   # derived
]

# Ensure columns exist (fill defaults)
df["marks_percent"] = pd.to_numeric(df.get("marks_percent", df.get("marks_percent")), errors="coerce")
df["num_subjects"] = pd.to_numeric(df.get("num_subjects", 0), errors="coerce").fillna(0)
df["signed_hash_present"] = pd.to_numeric(df.get("signed_hash_present", 0), errors="coerce").fillna(0)
df["ocr_vs_meta_name_match"] = pd.to_numeric(df.get("ocr_vs_meta_name_match", 50), errors="coerce").fillna(50)
df["ocr_vs_meta_institute_match"] = pd.to_numeric(df.get("ocr_vs_meta_institute_match", 50), errors="coerce").fillna(50)
df["ela_score"] = pd.to_numeric(df.get("ela_score", 5.0), errors="coerce").fillna(5.0)
df["image_complexity_kb"] = pd.to_numeric(df.get("image_complexity_kb", 200.0), errors="coerce").fillna(200.0)
df["marks_removed_flag"] = pd.to_numeric(df.get("marks_removed_flag", 0), errors="coerce").fillna(0).astype(int)
df["marks_missing"] = df["marks_percent"].isnull().astype(int)

# Label normalization: 'tampered' vs 'genuine' (safe mapping)
df["label_norm"] = df.get("label", "").astype(str).fillna("genuine").str.lower().apply(lambda x: 1 if "tam" in x else 0)

# Final numeric matrix
X = df[FEATURES].fillna(0).values
y = df["label_norm"].values
print("Features shape:", X.shape, "Positives:", int(y.sum()))

# If y has only one class, create tiny synthetic tamper samples to allow training
if len(np.unique(y)) == 1:
    print("Only one class found. Synthesizing few tampered examples for demo.")
    n_aug = max(1, int(0.03 * X.shape[0]))
    ix = np.random.choice(np.arange(X.shape[0]), size=n_aug, replace=False)
    X_aug = np.vstack([X, X[ix] + np.array([10,0,0,-20,-20,15,100,1,1])])  # crafted perturbation
    y_aug = np.concatenate([y, np.ones(n_aug)])
    X, y = X_aug, y_aug

# Train/test split
strat = y if len(np.unique(y))>1 else None
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=strat)

# Train RandomForest classifier
clf = RandomForestClassifier(n_estimators=300, class_weight="balanced", random_state=42)
clf.fit(X_train, y_train)
y_pred = clf.predict(X_test)
y_prob = clf.predict_proba(X_test)[:,1] if hasattr(clf, "predict_proba") else None

# Metrics
acc = accuracy_score(y_test, y_pred)
prec, rec, f1, _ = precision_recall_fscore_support(y_test, y_pred, average='binary', zero_division=0)
conf = confusion_matrix(y_test, y_pred).tolist()
roc = roc_auc_score(y_test, y_prob) if (y_prob is not None and len(np.unique(y_test))>1) else None

metrics = {
    "accuracy": float(acc),
    "precision": float(prec),
    "recall": float(rec),
    "f1": float(f1),
    "roc_auc": float(roc) if roc is not None else None,
    "confusion_matrix": conf,
    "n_rows": int(len(df)),
    "n_tampered": int(df["label_norm"].sum())
}

# Save classifier
joblib.dump(clf, CLASSIFIER_P)
print("Saved classifier to:", CLASSIFIER_P)

# Train IsolationForest on genuine examples
X_genuine = df[df["label_norm"]==0][FEATURES].fillna(0).values
if len(X_genuine) >= 20:
    iso = IsolationForest(n_estimators=200, contamination=max(0.01, df["label_norm"].mean()), random_state=42)
    iso.fit(X_genuine)
    joblib.dump(iso, ANOMALY_P)
    print("Saved IsolationForest to:", ANOMALY_P)
else:
    print("Not enough genuine rows to train IsolationForest; skipping.")

# Save metrics
with open(METRICS_P, "w") as f:
    json.dump(metrics, f, indent=2)
print("Saved training metrics to:", METRICS_P)
print("Training complete. Metrics:", metrics)
