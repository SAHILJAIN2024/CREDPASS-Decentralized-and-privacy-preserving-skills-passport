import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nits/university.dart';

// 1. IMPORT VAULT SCREEN
import 'vaultscreen.dart';

class PortalSelectionPage extends StatelessWidget {
  // 2. Accept Wallet Address (So we can pass it forward)
  final String walletAddress;

  const PortalSelectionPage({super.key, required this.walletAddress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Hides back button
        title: Text(
          "Select Role",
          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F2027), Color(0xFF050505)],
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Tailored for You",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Dedicated portals for every user in the ecosystem.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // --- 1. STUDENT CARD -> GOES TO VAULT ---
                _buildPortalCard(
                  context: context,
                  icon: Icons.person_outline_rounded,
                  title: "For Students",
                  description:
                      "Your secure, digital wallet to store, manage, and share all your verified achievements.",
                  onTap: () {
                    // 3. NAVIGATE TO VAULT
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MyVaultScreen(walletAddress: walletAddress),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // --- 2. UNIVERSITY CARD ---
                _buildPortalCard(
                  context: context,
                  icon: Icons.apartment_rounded,
                  title: "For Universities",
                  description:
                      "Efficiently issue tamper-proof digital certificates and manage alumni records on chain.",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UniversityDashboard(walletAddress: walletAddress),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // --- 3. EMPLOYER CARD ---
                _buildPortalCard(
                  context: context,
                  icon: Icons.manage_search_rounded,
                  title: "For Employers",
                  description:
                      "Verify candidate credentials instantly, assess talent with confidence, and streamline hiring.",
                  onTap: () {},
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortalCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1014),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.cyanAccent.withOpacity(0.1),
                  Colors.blueAccent.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, color: Colors.cyanAccent, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white60,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Access Portal",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.cyanAccent,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
