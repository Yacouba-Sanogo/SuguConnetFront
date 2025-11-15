import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/widgets/champs_text.dart';
import 'package:suguconnect_mobile/widgets/champs_telephone.dart';
import 'package:suguconnect_mobile/widgets/onglet_connexion_inscription.dart';
import 'package:suguconnect_mobile/widgets/bouton_principale.dart';

class FormulaireConsommateur extends StatefulWidget {
  const FormulaireConsommateur({super.key});

  @override
  State<FormulaireConsommateur> createState() => _FormulaireConsommateurState();
}

class _FormulaireConsommateurState extends State<FormulaireConsommateur> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const OngletConnexionInscription(),
        const SizedBox(height: 35),

        const ChampTexte(indication: 'Nom'),
        const SizedBox(height: 20),

        const ChampTexte(indication: 'Prénom'),
        const SizedBox(height: 20),

        const ChampTelephone(),
        const SizedBox(height: 20),

        const ChampTexte(indication: 'E-mail', typeClavier: TextInputType.emailAddress),
        const SizedBox(height: 20),

        const ChampTexte(indication: 'Adresse'),
        const SizedBox(height: 20),

        const ChampTexte(indication: 'Mot de passe', texteMasque: true),
        const SizedBox(height: 20),

        const ChampTexte(indication: 'Confirmer le mot de passe', texteMasque: true),
        const SizedBox(height: 40),

        BoutonPrincipal(
          texte: 'S’inscrire',
          onPressed: _actionInscription,
          hauteur: 65,
          rayonBordure: 10,
          styleTexte: const TextStyle(
            fontFamily: 'Itim',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _actionInscription() {
    // TODO: valider et appeler l'API d'inscription consommateur
    debugPrint('Inscription consommateur déclenchée');
  }
}
