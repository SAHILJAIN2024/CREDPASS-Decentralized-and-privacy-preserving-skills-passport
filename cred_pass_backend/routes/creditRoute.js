import { uploadMetadataToIPFS,uploadFileToIPFS, fetchIPFS } from "../utils/ipfs.js";
import express from "express";
import multer from "multer";
import path from "path";
import fs from "fs/promises";

const router = express.Router();

// ✅ Backend handles ONLY IPFS upload, not blockchain

const storage = multer.diskStorage({
  destination: "./uploads",
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 }, // 2MB max
  fileFilter: (req, file, cb) => {
    const allowed = [".png", ".jpg", ".jpeg", ".svg",".zip", ".gif", ".pdf"];
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, allowed.includes(ext));
  },
});

// 🎯 Route: Upload repo metadata & return IPFS URIs
router.post("/repo", upload.single("file"), async (req, res) => {
  const { name, description, ownerAddress, tech, contributor } = req.body;
  const file = req.file;

  try {
    let fileIpfsUri = "";
    let fileHttpUri = "";

    // ✅ Step 1: Upload file to IPFS
    if (file) {
      fileIpfsUri = await uploadFileToIPFS(file.path);
      await fs.unlink(file.path);
      console.log(`🧹 Temp file deleted: ${file.path}`);

      // Convert IPFS URI → HTTP gateway
      fileHttpUri = fileIpfsUri.replace("ipfs://", "https://ipfs.io/ipfs/");
    }

    // ✅ Step 2: Create metadata JSON for ERC-1155
    const metadata = {
      name,
      description,
      image: fileHttpUri, // use http gateway link
      attributes: [
        { trait_type: "Created By", value: ownerAddress },
        { trait_type: "Tech", value: tech },
        { trait_type: "Contributor", value: contributor },
        { trait_type: "Created At", value: new Date().toISOString() },
      ],
    };

    // ✅ Step 3: Upload metadata JSON to IPFS
    const metadataUri = await uploadMetadataToIPFS(metadata);

    // ✅ Step 4: Convert to HTTP
    const metadataHttpUri = metadataUri.replace("ipfs://", "https://ipfs.io/ipfs/");

    // ✅ Return both URIs
    res.json({
      success: true,
      metadataUri: metadataHttpUri
    });
  } catch (error) {
    console.error("❌ Upload failed:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});


export default router;
