import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/widgets/carte_details_produit.dart';
import 'package:suguconnect_mobile/widgets/timelineCommande.dart';
import 'package:suguconnect_mobile/models/detail_commande.dart';
import 'package:suguconnect_mobile/widgets/bouton_principale.dart';
import 'package:suguconnect_mobile/widgets/entete_detailCommande.dart';

const Color orangePrincipal = Color(0xFFFB662F);
const Color couleurFondTimeline = Color(0x33FB662F);

class DetailsCommandePage extends StatelessWidget {
  final DetailCommande commande;

  const DetailsCommandePage({super.key, required this.commande});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EnteteDetailsCommande(),
              const SizedBox(height: 15),
              TimelineCommande(currentStep: 3),
              const SizedBox(height: 20),
               BoutonPrincipal(
              texte: 'Confirmer',
              onPressed: () {
                // Show rating popup
                _showRatingPopup(context);
              },),
              const SizedBox(height: 20),
              CarteDetailsProduit(commande: commande),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int rating = 0;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Noter le producteur', style: GoogleFonts.itim(fontSize: 20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Veuillez noter votre expérience avec le producteur :', 
                       style: GoogleFonts.itim()),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border ,
                          color: orangePrincipal,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Commentaire (optionnel)',
                      hintStyle: GoogleFonts.itim(),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Annuler', style: GoogleFonts.itim(), selectionColor: Colors.black,),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangePrincipal,
                  ),
                  onPressed: () {
                 
                    Navigator.of(context).pop();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Merci pour votre notation !', 
                                     style: GoogleFonts.itim(color: Colors.white)),
                        backgroundColor: orangePrincipal,
                      ),
                    );
                  },
                  child: Text('Soumettre', style: GoogleFonts.itim(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}