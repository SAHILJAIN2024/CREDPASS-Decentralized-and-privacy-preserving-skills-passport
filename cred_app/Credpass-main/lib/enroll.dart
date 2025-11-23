import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnrollVerificationPage extends StatefulWidget {
  // 1. Accept walletAddress
  final String walletAddress;

  const EnrollVerificationPage({super.key, required this.walletAddress});

  @override
  State<EnrollVerificationPage> createState() => _EnrollVerificationPageState();
}

class _EnrollVerificationPageState extends State<EnrollVerificationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505), // Deep Black Background
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
          "Enrollment Application",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        // Optional: Show wallet address in AppBar like other screens
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
                ),
                child: Text(
                  // Truncate address for display
                  "${widget.walletAddress.substring(0, 6)}...${widget.walletAddress.substring(widget.walletAddress.length - 4)}",
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    color: Colors.cyanAccent,
                  ),
                ),
              ),
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
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F2027), Color(0xFF050505)],
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER CARD (Propose New Issuer) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A1014), // Dark card bg
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Propose New Issuer",
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Propose a new institution to be added to the registry. Requires DAO vote to be approved.",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white60,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // --- FORM FIELDS ---

                      // Institution Name Field
                      _buildLabel("Institution Name"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hint: "e.g., MIT",
                      ),

                      const SizedBox(height: 24),

                      _buildLabel("Degree Providing"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _degreeController,
                        hint: "B.Tech.",
                      ),

                      const SizedBox(height: 24),

                      _buildLabel("Country"),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _countryController,
                        hint: "India",
                      ),

                      const SizedBox(height: 24),

                      _buildLabel("State"),
                      const SizedBox(height: 8),
                      _buildTextField(controller: _stateController, hint: "MP"),

                      const SizedBox(height: 40),

                      // --- SUBMIT BUTTON ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Submit Logic Here
                            // You can access widget.walletAddress here to associate the proposal with the wallet
                            debugPrint(
                              "Submitting proposal for wallet: ${widget.walletAddress}",
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.post_add_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Submit Proposal",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
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

  // --- HELPER WIDGETS ---

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF050505), // Inner input bg (darker)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.white24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
