import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reown_appkit/reown_appkit.dart';

// IMPORT THE NEXT PAGE (Role Selection)
import 'roleselection.dart';

class MetamaskScreen extends StatefulWidget {
  const MetamaskScreen({Key? key}) : super(key: key);

  @override
  State<MetamaskScreen> createState() => _MetamaskScreenState();
}

class _MetamaskScreenState extends State<MetamaskScreen>
    with WidgetsBindingObserver {
  ReownAppKitModal? _appKitModal;
  String? _walletAddress;
  bool _isInitializing = true;
  bool _showSuccessScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWalletConnect();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appKitModal?.onModalConnect.unsubscribe(_onSessionConnect);
    _appKitModal?.onModalDisconnect.unsubscribe(_onSessionDisconnect);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConnectionStatus();
    }
  }

  Future<void> _initializeWalletConnect() async {
    try {
      _appKitModal = ReownAppKitModal(
        context: context,
        projectId: '8b63bfccbc11ad651693d6d913d67632',
        metadata: const PairingMetadata(
          name: 'VerifyKey',
          description: 'Decentralized Academic Credentials',
          url: 'https://walletconnect.org',
          icons: ['https://walletconnect.org/walletconnect-logo.png'],
          redirect: Redirect(
            native: 'nits://',
            universal: 'https://walletconnect.org',
          ),
        ),
      );

      _appKitModal!.onModalConnect.subscribe(_onSessionConnect);
      _appKitModal!.onModalDisconnect.subscribe(_onSessionDisconnect);

      await _appKitModal!.init();
      _checkConnectionStatus();
    } catch (e) {
      debugPrint("WalletConnect Init Failed: $e");
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  // --- FIXED EVENT HANDLER (Null Safety Added) ---
  void _onSessionConnect(ModalConnect? event) {
    if (event == null) return;

    final session = event.session;
    // FIX: Check if namespaces is not null AND not empty
    if (session.namespaces != null && session.namespaces!.isNotEmpty) {
      final namespace = session.namespaces!.values.first;
      if (namespace.accounts.isNotEmpty) {
        final addr = namespace.accounts.first.split(':').last;
        _handleSuccessfulConnection(addr);
      }
    }
  }

  void _onSessionDisconnect(ModalDisconnect? event) {
    setState(() {
      _walletAddress = null;
      _showSuccessScreen = false;
    });
  }

  // --- FIXED STATUS CHECK (Null Safety Added) ---
  void _checkConnectionStatus() {
    if (_appKitModal?.appKit == null) return;

    final sessionList = _appKitModal!.appKit!.getActiveSessions();
    if (sessionList.isEmpty) return;

    final session = sessionList.values.first;

    // FIX: Check if namespaces is null before accessing
    if (session.namespaces.isEmpty) return;

    final namespace = session.namespaces!.values.first;
    final accounts = namespace.accounts;
    if (accounts.isEmpty) return;

    final addr = accounts.first.split(':').last;
    _handleSuccessfulConnection(addr);
  }

  void _handleSuccessfulConnection(String address) {
    if (!mounted) return;
    if (_showSuccessScreen) return;

    setState(() {
      _walletAddress = address;
      _showSuccessScreen = true;
    });

    // Redirect to Portal Page after 1.2 seconds
    Future.delayed(const Duration(milliseconds: 1200), _navigateToPortal);
  }

  void _connectWallet() async {
    try {
      await _appKitModal?.openModalView();
    } catch (e) {
      debugPrint("Open Wallet Modal Failed: $e");
    }
  }

  void _navigateToPortal() {
    if (_walletAddress == null || !mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PortalSelectionPage(walletAddress: _walletAddress!),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
      );
    }

    if (_showSuccessScreen) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.greenAccent,
              ),
              const SizedBox(height: 20),
              Text(
                "Connected!",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Redirecting...",
                style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _navigateToPortal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                ),
                child: const Text(
                  "Tap to Continue",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.wallet, color: Colors.cyanAccent, size: 50),
            const SizedBox(height: 20),
            Text(
              "Connect Wallet",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Link your MetaMask to proceed.",
              style: GoogleFonts.inter(fontSize: 16, color: Colors.white60),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _connectWallet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "CONNECT METAMASK",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => _handleSuccessfulConnection("0x71C...9A2"),
                child: const Text(
                  "Debug: Skip Connection",
                  style: TextStyle(color: Colors.white24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
