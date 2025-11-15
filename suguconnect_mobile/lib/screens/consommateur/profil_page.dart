import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/widgets/bouton_principale.dart';
import 'package:suguconnect_mobile/widgets/champs_motDePass_profil.dart';
import 'package:suguconnect_mobile/widgets/champs_profil.dart';
import 'package:suguconnect_mobile/widgets/champs_tel_profil.dart';
import 'package:suguconnect_mobile/widgets/entete_profil.dart';

const Color couleurFondClair = Color(0x1AFB662F);
const Color grisClair = Color(0xFFD9D9D9);

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: couleurFondClair,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              children: [
                const EnteteProfil(nomComplet: 'Aïssatou Coulibaly'),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: grisClair),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChampProfil(label: 'Nom', valeur: 'Coulibaly'),
                        ChampProfil(label: 'Prénom', valeur: 'Aïssatou'),
                        ChampTelephoneProfil(
                            label: 'Téléphone', codePays: '223', numero: '60153483'),
                        ChampProfil(
                            label: 'Mail', valeur: 'coulibalyïssatou37@gmail.com'),
                        SizedBox(height: 20),
                        ChampsMotDePasseProfil(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BoutonPrincipal(texte: "Confirmer",onPressed: () {},),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
