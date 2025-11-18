import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Classe de configuration du thème de l'application SuguConnect
class AppTheme {
  // Couleurs principales de l'application
  static const Color primaryColor = Color(0xFFFF6B35); // Orange principal
  static const Color secondaryColor = Color(0xFF4CAF50); // Vert secondaire
  static const Color backgroundColor = Color(0xFFF5F5F5); // Fond gris clair
  static const Color textColor = Color(0xFF333333); // Texte principal
  static const Color lightTextColor = Color(0xFF757575); // Texte secondaire
  static const Color errorColor = Color(0xFFE53935); // Rouge d'erreur

  // Helper pour obtenir un TextStyle avec la police Itim
  static TextStyle itimTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.itim(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  // Configuration du thème clair de l'application
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor, // Couleur principale
      scaffoldBackgroundColor: backgroundColor, // Fond de l'application
      // Configuration de la barre d'application
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor, // Fond orange
        foregroundColor: Colors.white, // Texte blanc
        elevation: 0, // Pas d'ombre
        titleTextStyle: GoogleFonts.itim(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      // Configuration des boutons élevés
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, // Fond orange
          foregroundColor: Colors.white, // Texte blanc
          textStyle: GoogleFonts.itim(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Coins arrondis
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), // Espacement
        ),
      ),
      // Configuration des boutons de texte
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.itim(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Configuration des boutons avec contour
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GoogleFonts.itim(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
      textTheme: GoogleFonts.itimTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
    );
  }
}