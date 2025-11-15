import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/auth/auth_widgets/entete_authetification.dart';
import 'package:suguconnect_mobile/auth/auth_widgets/formulaire_producteur.dart';
import 'package:suguconnect_mobile/auth/auth_widgets/mise_en_page_auth.dart';


class AuthProducteur extends StatelessWidget {
  const AuthProducteur({super.key});

  @override
  Widget build(BuildContext context) {
    return const MiseEnPageAuthentification(
      entete: EnteteAuthentification(titre: 'Crée ton espace Producteur 🌾'),
      formulaire: FormulaireProducteur(),
    );
  }
}
