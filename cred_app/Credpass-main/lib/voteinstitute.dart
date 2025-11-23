import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoteInstitutePage extends StatelessWidget {
  const VoteInstitutePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample list of institutes
    final List<Map<String, dynamic>> institutes = [
      {
        "name": "Tech Institute of Innovation",
        "branch": "Computer Science",
        "location": "Bangalore, India",
        "isVerified": true,
        "votes": 120,
      },
      {
        "name": "Global Business School",
        "branch": "Management",
        "location": "London, UK",
        "isVerified": false, // Pending verification
        "votes": 45,
      },
      {
        "name": "Quantum Research University",
        "branch": "Physics",
        "location": "Berlin, Germany",
        "isVerified": false,
        "votes": 88,
      },
      {
        "name": "MedTech Academy",
        "branch": "Medical Sciences",
        "location": "Boston, USA",
        "isVerified": true,
        "votes": 310,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Vote for Institute",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F2027), Color(0xFF050505)],
              ),
            ),
          ),

          ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: institutes.length,
            itemBuilder: (context, index) {
              final institute = institutes[index];
              return _buildInstituteCard(
                context: context,
                name: institute['name'],
                branch: institute['branch'],
                location: institute['location'],
                isVerified: institute['isVerified'],
                votes: institute['votes'],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInstituteCard({
    required BuildContext context,
    required String name,
    required String branch,
    required String location,
    required bool isVerified,
    required int votes,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified
              ? Colors.greenAccent.withOpacity(0.3) // Verified Border
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name & Verified Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  color: isVerified ? Colors.greenAccent : Colors.white54,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified,
                              size: 12,
                              color: Colors.greenAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Verified",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Pending Verification",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.orangeAccent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Details: Branch & Location
          _buildDetailRow(Icons.school_outlined, branch),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.location_on_outlined, location),

          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          const SizedBox(height: 16),

          // Footer: Vote Button & Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$votes Votes",
                style: GoogleFonts.firaCode(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
              // Only show vote button for non-verified institutes (assuming DAO votes to verify them)
              // Or allow voting on verified ones for ranking? Let's assume voting is for verification.
              if (!isVerified)
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle Vote Logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Vote cast successfully!"),
                        backgroundColor: Colors.purpleAccent,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.how_to_vote, size: 16),
                  label: Text(
                    "VOTE",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              else
                // If already verified, maybe show a 'Details' or 'Endorse' button, or just nothing
                Text(
                  "Accredited",
                  style: GoogleFonts.inter(
                    color: Colors.white30,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
        ),
      ],
    );
  }
}
