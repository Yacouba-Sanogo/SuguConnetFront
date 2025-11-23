import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constantes.dart';
import 'auth/login_screen.dart';
import 'auth/role_selection_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/landing_women.png'),
            fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              // Logo SUGUConnect centré en haut
                Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  width: 300,
                  height: 300,
                  child: Image.asset(
                    Constantes.logoPath,
                    width: 260,
                    height: 260,
                    fit: BoxFit.contain,
                    ),
                  ),
                ),

              // Boutons en bas
                Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(role: null),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 8,
                            shadowColor:
                            const Color(0xFFFF6B35).withOpacity(0.3),
                          ),
                          child: Text(
                            'Connexion',
                            style: GoogleFonts.inter(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RoleSelectionScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Inscription',
                            style: GoogleFonts.inter(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ],
          ),
        ),
      ),
    );
  }
}
