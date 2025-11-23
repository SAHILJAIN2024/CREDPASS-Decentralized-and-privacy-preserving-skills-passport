document.addEventListener('DOMContentLoaded', () => {
    const form = document.getElementById('verifyForm');
    const resultPre = document.getElementById('result');

    form.addEventListener('submit', async (e) => {
        e.preventDefault();
        resultPre.textContent = "Verifying...";

        // --- STEP 1: FRONTEND OVERRIDE LOGIC ---
        // We check the text area *before* sending to the server
        const metadataRaw = document.getElementById('metadata_json').value;
        let isMagicMatch = false;

        try {
            const meta = JSON.parse(metadataRaw);

            // The specific criteria you requested
            const targetSerial = "MITSDU/CS/2025/0001";
            const targetName = "Dr. Saurabh Agarwal";
            
            // Safe access to fields (handles if they are undefined)
            const inputSerial = (meta.certificate_serial_number || "").trim();
            const inputName = (meta.recipient_name || "").trim();
            const inputInstitute = (meta.institute_name || "").toLowerCase();

            // LOGIC: Check if it matches
            if (inputSerial === targetSerial || 
               (inputName === targetName && inputInstitute.includes("madhav"))) {
                isMagicMatch = true;
            }

        } catch (err) {
            console.warn("JSON Parse error in frontend override check:", err);
        }

        // If it matches your specific case, STOP here and show success immediately.
        if (isMagicMatch) {
            const fakeSuccessResponse = {
                "status": "success",
                "institute_verified": true,
                "degree_verified": true,
                "decision": {
                    "verdict": "VERIFIED",
                    "score": 99,
                    "reasons": [
                        "Matched Trusted MITS Signature",
                        "Recipient: Dr. Saurabh Agarwal",
                        "Frontend Auto-Verification"
                    ]
                },
                "institution_evidence": {
                    "institution_score": 98,
                    "verified": true
                }
            };

            // Mimic a slight network delay for realism (optional, set to 0 for instant)
            setTimeout(() => {
                resultPre.textContent = JSON.stringify(fakeSuccessResponse, null, 2);
            }, 500);
            
            return; // EXIT FUNCTION - Do not call backend
        }

        // --- STEP 2: NORMAL BACKEND CALL (Fallback) ---
        // If it's not the magic JSON, we try to call the backend normally
        try {
            const formData = new FormData(form);
            
            // Ensure the fetch points to your correct backend URL
            // If your python is running on port 8000, use http://127.0.0.1:8000/agent_ai
            const response = await fetch('http://127.0.0.1:8000/agent_ai', {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`Server Error: ${response.status} ${response.statusText}`);
            }

            const data = await response.json();
            resultPre.textContent = JSON.stringify(data, null, 2);

        } catch (error) {
            console.error(error);
            resultPre.textContent = "Error: " + error.message + "\n(Ensure Backend is running on port 8000)";
        }
    });
});