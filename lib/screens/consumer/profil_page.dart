import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/auth_provider.dart';
import '../constantes.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/card_container.dart';
import '../../widgets/phone_field.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key, this.showAppBar = true});
  
  final bool showAppBar;

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController(text: 'Coulibaly');
  final _prenomController = TextEditingController(text: 'Aïssatou');
  final _telephoneController = TextEditingController(text: '60153483');
  final _emailController = TextEditingController(text: 'coulibalyaïssatou37@gmail.com');
  final _motDePasseController = TextEditingController(text: '*******');
  final _nouveauMotDePasseController = TextEditingController(text: '*******');
  final _confirmerMotDePasseController = TextEditingController(text: '*******');

  String _selectedCountryCode = '223';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final u = auth.currentUser;
      if (u != null) {
        _nomController.text = u.nom;
        _prenomController.text = u.prenom;
        _telephoneController.text = u.telephone;
        _emailController.text = u.email;
      }
    });
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _motDePasseController.dispose();
    _nouveauMotDePasseController.dispose();
    _confirmerMotDePasseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          _buildProfileForm(),
          const SizedBox(height: 20),
        ],
      ),
    );

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: const Color(0xFFFEE8E3), // Fond pêche/clair
        body: content,
      );
    } else {
      return Container(
        color: const Color(0xFFFEE8E3), // Fond pêche/clair
        child: content,
      );
    }
  }

  // Header avec fond pêche, titre "Profil", icône profil, nom utilisateur et bouton déconnexion
  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final u = auth.currentUser;
        final displayName = u == null ? 'Aïssatou Coulibaly' : (u.prenom + ' ' + u.nom).trim();
        
        return Container(
          padding: const EdgeInsets.only(top: 50, bottom: 30, left: 20, right: 20),
          decoration: const BoxDecoration(
            color: Color(0xFFFEE8E3), // Fond pêche/clair
          ),
          child: Column(
            children: [
              // AppBar personnalisée avec titre "Profil" et bouton déconnexion
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Espace vide à gauche pour équilibrer
                  const SizedBox(width: 70),
                  // Titre "Profil" centré
                  const Text(
                    'Profil',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  // Bouton déconnexion à droite
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Déconnexion'),
                            content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Provider.of<AuthProvider>(context, listen: false).logout();
                                  Navigator.pushReplacementNamed(context, '/');
                                },
                                child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Symbols.chip_extraction,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Icône de profil et nom de l'utilisateur alignés
              Row(
                children: [
                  // Icône de profil à gauche (agrandie et alignée avec le nom)
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: orangeVif.withValues(alpha: 0.30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_circle,
                      color: orangePrincipal.withValues(alpha: 0.31),
                      size: 80,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Nom de l'utilisateur
                  Expanded(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Formulaire de profil dans une carte blanche
  Widget _buildProfileForm() {
    return CardContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: 'Nom',
              controller: _nomController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Prénom',
              controller: _prenomController,
            ),
            const SizedBox(height: 16),
            PhoneField(
              label: 'Téléphone',
              phoneController: _telephoneController,
              selectedCountryCode: _selectedCountryCode,
              onCountryCodeChanged: (value) {
                setState(() {
                  _selectedCountryCode = value;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Mail',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Mot de passe',
              controller: _motDePasseController,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Nouveau mot de passe',
              controller: _nouveauMotDePasseController,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Confirmer le nouveau mot de passe',
              controller: _confirmerMotDePasseController,
              isPassword: true,
            ),
            const SizedBox(height: 24),
            // Bouton Confirmer
            PrimaryButton(
              text: 'Confirmer',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil mis à jour avec succès')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

}
