import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/widgets/champs_text.dart';
import 'package:suguconnect_mobile/widgets/champs_telephone.dart';
import 'package:suguconnect_mobile/widgets/onglet_connexion_inscription.dart';
import 'package:suguconnect_mobile/widgets/bouton_principale.dart';

class FormulaireProducteur extends StatefulWidget {
  const FormulaireProducteur({super.key});

  @override
  State<FormulaireProducteur> createState() => _FormulaireProducteurState();
}

class _FormulaireProducteurState extends State<FormulaireProducteur> {
  ImageProvider? _imageProfil;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const OngletConnexionInscription(),
        const SizedBox(height: 25),

        const ChampTexte(indication: 'Nom'),
        const SizedBox(height: 20),

        const ChampTexte(indication: 'Prénom'),
        const SizedBox(height: 20),

        const ChampTexte(indication: 'Nom de la ferme'),
        const SizedBox(height: 20),

        const ChampTelephone(),
        const SizedBox(height: 20),

        const ChampTexte(
          indication: 'E-mail',
          typeClavier: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        // Description / présentation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Parlez de votre ferme, vos méthodes, produits...',
              hintStyle: GoogleFonts.itim(color: Colors.black45, fontSize: 16),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 20),

        const ChampTexte(indication: 'Mot de passe', texteMasque: true),
        const SizedBox(height: 20),

        const ChampTexte(indication: 'Confirmer le mot de passe', texteMasque: true),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
            color: const Color(0xFFFDFDFD),
          ),
          child: Column(
            children: [
              if (_imageProfil != null)
                CircleAvatar(radius: 40, backgroundImage: _imageProfil)
              else
                const Icon(Icons.camera_alt, size: 40, color: Colors.black54),
              const SizedBox(height: 8),
              Text(
                'Ajouter une image de profil (max : 1 image)',
                style: GoogleFonts.itim(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _choisirImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE4D6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                ),
                child: Text(
                  'Choisir une image',
                  style: GoogleFonts.itim(color: const Color(0xFFFB662F), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Bouton principal
        BoutonPrincipal(
          texte: "S’inscrire",
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

  void _choisirImage() {
    setState(() {
      _imageProfil = const AssetImage('assets/images/profil_exemple.png');
    });
  }

  void _actionInscription() {
    // TODO: valider les champs et appeler l'API d'inscription producteur
    debugPrint('Inscription producteur déclenchée');
  }
}
