import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color orangePrincipal = Color(0xFFFB662F);
const Color couleurFondTimeline = Color(0x33FB662F);
const Color couleurTexteGris = Color(0xFFD9D9D9);

class TimelineCommande extends StatelessWidget {
  final int currentStep;

  const TimelineCommande({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = ['Paiement', 'Expédition', 'Réception', 'Note'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      decoration: const BoxDecoration(color: couleurFondTimeline),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          final isCompleted = index + 1 <= currentStep;
          final isCurrent = index + 1 == currentStep;

          return Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent ? orangePrincipal : Colors.white,
                      border: Border.all(color: orangePrincipal, width: 0.5),
                    ),
                  ),
                  if (index < steps.length - 1)
                    Container(
                      width: 80,
                      height: 1,
                      color: isCompleted ? orangePrincipal : couleurTexteGris,
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                steps[index],
                style: GoogleFonts.itim(fontSize: 15, color: Colors.black),
              ),
            ],
          );
        }),
      ),
    );
  }
}
