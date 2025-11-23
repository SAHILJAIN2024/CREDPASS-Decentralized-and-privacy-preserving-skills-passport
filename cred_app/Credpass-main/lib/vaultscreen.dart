import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nits/request.dart';

class MyVaultScreen extends StatelessWidget {
  final String walletAddress; // 1. Added variable to hold address

  // 2. Updated constructor to require the address
  const MyVaultScreen({super.key, required this.walletAddress});

  // Helper to shorten the address for the UI (e.g., 0x123...456)
  String _shortenAddress(String address) {
    if (address.length < 10) return address;
    return "${address.substring(0, 6)}...${address.substring(address.length - 4)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Student Portal",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          // Wallet Address Chip
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const CircleAvatar(backgroundColor: Colors.blue, radius: 4),
                const SizedBox(width: 8),
                // 3. Using the real shortened wallet address here
                Text(
                  _shortenAddress(walletAddress),
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient (Subtle)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027), // Deep Navy
                  Color(0xFF050505), // Black
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // --- Header Section ---
                Text(
                  "My Vault",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Manage your credentials.",
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
                ),

                const SizedBox(height: 20),

                // --- Status Chips ---
                Row(
                  children: [
                    _buildStatusChip("4 Total Assets", Colors.white24),
                    const SizedBox(width: 12),
                  ],
                ),

                const SizedBox(height: 30),

                // --- Grid Section ---
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildVaultCard(
                        title: "Degrees &\nDiplomas",
                        subtitle: "University Credentials",
                        count: "2 Items",
                        icon: Icons.school_outlined,
                        accentColor: Colors.amber,
                        iconBgColor: Colors.amber.withOpacity(0.1),
                      ),
                      _buildVaultCard(
                        title: "Hackathon\nMastery",
                        subtitle: "Competitions & Wins",
                        count: "5 Items",
                        icon: Icons.code,
                        accentColor: Colors.purpleAccent,
                        iconBgColor: Colors.purpleAccent.withOpacity(0.1),
                      ),
                      _buildVaultCard(
                        title: "Internships",
                        subtitle: "Work Experience",
                        count: "1 Item",
                        icon: Icons.business_center_outlined,
                        accentColor: Colors.blueAccent,
                        iconBgColor: Colors.blueAccent.withOpacity(0.1),
                      ),
                      _buildVaultCard(
                        title: "NPTEL &\nCourses",
                        subtitle: "Certifications",
                        count: "4 Items",
                        icon: Icons.menu_book_rounded,
                        accentColor: Colors.greenAccent,
                        iconBgColor: Colors.greenAccent.withOpacity(0.1),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RequestPage(walletAddress: walletAddress),
                            ),
                          );
                        },
                        child: _buildVaultCard(
                          title: "REQUEST\nVERIFICATION",
                          subtitle: "Certifications",
                          count: "4 Items",
                          icon: Icons.menu_book_rounded,
                          accentColor: const Color.fromARGB(255, 240, 105, 159),
                          iconBgColor: const Color.fromARGB(
                            255,
                            240,
                            105,
                            159,
                          ).withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    String label,
    Color bgColor, {
    Color textColor = Colors.white70,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildVaultCard({
    required String title,
    required String subtitle,
    required String count,
    required IconData icon,
    required Color accentColor,
    required Color iconBgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.white.withOpacity(0.1), height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  count,
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
                Icon(Icons.arrow_forward, size: 14, color: Colors.white30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
