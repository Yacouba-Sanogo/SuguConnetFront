import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/constantes/constantes.dart';
import 'package:suguconnect_mobile/models/commandes.dart';

class ElementCommande extends StatelessWidget {
  final Commande commande;
  final VoidCallback onVoir;
  final VoidCallback onSupprimer;

  const ElementCommande({
    super.key,
    required this.commande,
    required this.onVoir,
    required this.onSupprimer,
  });

  @override
  Widget build(BuildContext context) {
    //  Définition des couleurs selon le statut
    Color fond;
    Color texte;

    switch (commande.statut) {
      case 'Livrée':
        fond = orangePrincipal;
        texte = Colors.white;
        break;
      case 'Annuler':
      case 'Demande de remboursement':
        fond = statutAnnuler;
        texte = Colors.white;
        break;
      case 'En attente':
        fond = statutAttenteFond;
        texte = statutAttenteTexte;
        break;
      default:
        fond = grisClair;
        texte = Colors.black;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: grisClair.withValues(alpha: 0.4),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),

      //  Structure de la carte
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne principale : infos + icônes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Informations sur la commande
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Commande ${commande.numero}',
                    style: GoogleFonts.itim(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Producteur : ${commande.producteur}',
                    style: GoogleFonts.itim(
                      fontSize: 14,
                      color: grisTexte,
                    ),
                  ),
                ],
              ),

              // Icônes d’action 
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.remove_red_eye_outlined,
                      color: grisTexte,
                      size: 24,
                    ),
                    onPressed: onVoir,
                    tooltip: 'Voir les détails',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: grisTexte,
                      size: 24,
                    ),
                    onPressed: onSupprimer,
                    tooltip: 'Supprimer la commande',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8), 

          // Statut coloré (livrée, en attente, etc.)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: fond,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              commande.statut,
              style: GoogleFonts.itim(
                fontSize: 14,
                color: texte,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
