import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  Widget build(BuildContext context) {
    final availH = MediaQuery.of(context).size.height
        - MediaQuery.of(context).padding.top
        - MediaQuery.of(context).padding.bottom;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: availH),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    size: isLandscape ? 72 : 120,
                    color: AppColors.amber,
                  ),
                  SizedBox(height: isLandscape ? 12 : 32),
                  Text(
                    'DETEKTIF HOAKS',
                    style: GoogleFonts.bebasNeue(
                      fontSize: isLandscape ? 36 : 48,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'Asah Kritis, Lawan Hoaks',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isLandscape ? 14 : 18,
                    ),
                  ),
                  SizedBox(height: isLandscape ? 20 : 48),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      ),
                      child: const Text(
                        'MULAI MISI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
