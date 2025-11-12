import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/screens/auth/auth_widgets/entete_authetification.dart';
import 'package:suguconnect_mobile/screens/auth/auth_widgets/formulaire_consommateur.dart';
import 'package:suguconnect_mobile/screens/auth/auth_widgets/mise_en_page_auth.dart';


class AuthConsommateur extends StatelessWidget {
  const AuthConsommateur({super.key});

  @override
  Widget build(BuildContext context) {
    return const  MiseEnPageAuthentification(
      entete: EnteteAuthentification(titre: 'Rejoins l’aventure locale 🌿'),
      formulaire: FormulaireConsommateur(),
    );
  }
}
