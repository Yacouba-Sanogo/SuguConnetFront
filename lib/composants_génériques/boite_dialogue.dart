import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BoiteConfirmation extends StatelessWidget {
  final String message;
  final String texteBouton;
  final VoidCallback surConfirmer;
  final Color couleurBouton;

  const BoiteConfirmation({
    super.key,
    required this.message,
    required this.texteBouton,
    required this.surConfirmer,
    this.couleurBouton = const Color(0xFFFF0000),
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    message,
                    style: GoogleFonts.itim(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: surConfirmer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: couleurBouton,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        texteBouton,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0x33000000),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///  Fonction pratique pour afficher la boîte
void afficherBoiteConfirmation({
  required BuildContext context,
  required String message,
  required String texteBouton,
  required VoidCallback surConfirmer,
  Color couleurBouton = const Color(0xFFFF0000),
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.2),
    builder: (_) => BoiteConfirmation(
      message: message,
      texteBouton: texteBouton,
      surConfirmer: surConfirmer,
      couleurBouton: couleurBouton,
    ),
  );
}
