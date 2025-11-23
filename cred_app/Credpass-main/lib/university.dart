import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// IMPORT THE ENROLLMENT PAGE
import 'package:nits/enroll.dart';
import 'package:nits/voteinstitute.dart';

class UniversityDashboard extends StatelessWidget {
  // 1. Accept walletAddress from Portal Page
  final String walletAddress;

  const UniversityDashboard({super.key, required this.walletAddress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Institution Portal",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.cyanAccent,
                  radius: 4,
                ),
                const SizedBox(width: 8),
                Text(
                  "DAO Member",
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    color: Colors.cyanAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F2027), // Navy Top
                  Color(0xFF050505), // Black Bottom
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
                Text(
                  "Governance",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Vote on new institutes & manage status.",
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
                ),
                const SizedBox(height: 20),

                // Status Chips
                Row(
                  children: [
                    _buildStatusChip(
                      "Verified Issuer",
                      Colors.green.withOpacity(0.2),
                      textColor: Colors.greenAccent,
                    ),
                    const SizedBox(width: 12),
                  ],
                ),

                const SizedBox(height: 30),

                // --- GRID SECTION ---
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      // Option 1: Vote for Institute
                      _buildDashboardCard(
                        title: "Vote for\nInstitute",
                        subtitle: "DAO Governance",
                        actionText: "Active Polls",
                        icon: Icons.how_to_vote_outlined,
                        accentColor: Colors.purpleAccent,
                        iconBgColor: Colors.purpleAccent.withOpacity(0.1),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VoteInstitutePage(),
                            ),
                          );
                        },
                      ),

                      // Option 2: Enroll for Verification
                      _buildDashboardCard(
                        title: "Enroll for\nVerification",
                        subtitle: "Apply for Status",
                        actionText: "Application",
                        icon: Icons.verified_user_outlined,
                        accentColor: Colors.cyanAccent,
                        iconBgColor: Colors.cyanAccent.withOpacity(0.1),
                        onTap: () {
                          // Navigate to Enrollment Page passing address
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EnrollVerificationPage(
                                walletAddress: walletAddress,
                              ),
                            ),
                          );
                        },
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

  Widget _buildDashboardCard({
    required String title,
    required String subtitle,
    required String actionText,
    required IconData icon,
    required Color accentColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    actionText,
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
      ),
    );
  }
}
