import dotenv from "dotenv";
dotenv.config();
import express from "express";
import multer from "multer";
import { uploadFileToIPFS, uploadMetadataToIPFS } from "../utils/ipfs.js";
import path from "path";
const router = express.Router();

// Multer setup
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "uploads/"); // temporary storage
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});
const upload = multer({ storage });

// ------------------------------
// POST /api/mint/repo
// ------------------------------
router.post("/mint/repo", upload.single("file"), async (req, res) => {
  try {
    const { to, name, desc, tech, contributor } = req.body;
    const file = req.file;

    // Validate inputs
    if (!file) return res.status(400).json({ message: "⚠️ No file uploaded" });
    if (!to || !name || !desc || !tech || !contributor)
      return res.status(400).json({ message: "⚠️ Missing required fields" });

    // 1️⃣ Upload repo file to Pinata
    const fileUri = await uploadFileToIPFS(file.path);

    // 2️⃣ Build metadata JSON
    const metadata = {
      to,
      name,
      description: desc,
      tech,
      contributor,
      file: fileUri,
    };

    // 3️⃣ Upload metadata to Pinata
    const metadataUri = await uploadMetadataToIPFS(metadata);

    console.log("✅ Repo metadata ready:", metadataUri);

    // 4️⃣ Return metadata URI to frontend
    res.json({ message: "✅ Repo ready for minting", metadataUri });
  } catch (err) {
    console.error("❌ Upload error:", err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

export default router;
