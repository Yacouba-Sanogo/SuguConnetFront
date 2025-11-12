import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/composants_g%C3%A9n%C3%A9riques/boite_dialogue.dart';
import 'package:suguconnect_mobile/constantes/constantes.dart';
import 'package:suguconnect_mobile/models/commandes.dart';
import 'package:suguconnect_mobile/models/detail_commande.dart';
import 'package:suguconnect_mobile/widgets/element_commandes.dart';
import 'package:suguconnect_mobile/widgets/entete_widget.dart';
import 'package:suguconnect_mobile/screens/consommateur/detail_commande.dart' as detail;

class PageCommandes extends StatefulWidget {
  const PageCommandes({super.key});

  @override
  State<PageCommandes> createState() => _PageCommandesState();
}

class _PageCommandesState extends State<PageCommandes> {
  String filtreActuel = "Tout";

  final List<Commande> commandes = [
    const Commande(numero: "001", producteur: "Kaba Oumar", statut: "Livrée"),
    const Commande(numero: "002", producteur: "Sow Mariam", statut: "En attente"),
    const Commande(numero: "003", producteur: "Diallo Amadou", statut: "Annuler"),
    const Commande(numero: "004", producteur: "Diallo Amadou", statut: "Livrée"),
    const Commande(numero: "005", producteur: "Diallo Amadou", statut: "Annuler"),
  ];

  @override
  Widget build(BuildContext context) {
    final commandesFiltrees = filtreActuel == "Tout"
        ? commandes
        : commandes.where((c) => c.statut == filtreActuel).toList();

    return Scaffold(
      appBar: const EnteteWidget(),
      backgroundColor: grisClair.withValues(alpha : 0.2),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre principal
              Text(
                "Mes Commandes",
                style: GoogleFonts.itim(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Filtres de statut 
              SizedBox(
                height: 45,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ["Tout", "Livrée", "En attente", "Annuler"]
                      .map(
                        (statut) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            label: Text(
                              statut,
                            style: GoogleFonts.itim(
                              color: filtreActuel == statut
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          selected: filtreActuel == statut,
                          selectedColor: orangePrincipal,
                          onSelected: (_) {
                            setState(() => filtreActuel = statut);
                          },
                        ),
                      ),
                    )
                    .toList(),
                ),
              ),

              const SizedBox(height: 20),

              // Liste des commandes filtrées
              ...commandesFiltrees.map(
                (commande) {
                  return ElementCommande(
                    commande: commande,
                    onVoir: () {
                      // Navigation vers détails commande
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => detail.DetailsCommandePage(
                            commande: DetailCommande(
                              numero: commande.numero,
                              producteur: commande.producteur,
                              produit: "Produit Exemple",
                              quantite: 2,
                              prixUnitaire: 15000.0,
                              imagePath: 'assets/Images/deuxieme.png',
                            ),
                          ),
                        ),
                      );
                    },
                    onSupprimer: () {
                      afficherBoiteConfirmation(
                        context: context,
                        message:
                            "Voulez-vous vraiment supprimer la commande ${commande.numero} ?",
                        texteBouton: "Confirmer",
                        surConfirmer: () {
                          Navigator.of(context).pop();
                          setState(() {
                            commandes.remove(commande);
                          });
                        },
                      );
                    },
                  );
                },
              ).toList(),
            ],
          ),
        ),
      ),
    );
  }
}