import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/phone_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/card_container.dart';
import '../constantes.dart' as screen_constants;

class ProducerProfileScreen extends StatefulWidget {
  const ProducerProfileScreen({super.key});

  @override
  State<ProducerProfileScreen> createState() => _ProducerProfileScreenState();
}

class _ProducerProfileScreenState extends State<ProducerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();
  final _nouveauMotDePasseController = TextEditingController();
  final _confirmerMotDePasseController = TextEditingController();

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

  void _showLogoutDialog() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ProducerProfilePageBody(
        formKey: _formKey,
        nomController: _nomController,
        prenomController: _prenomController,
        telephoneController: _telephoneController,
        emailController: _emailController,
        motDePasseController: _motDePasseController,
        nouveauMotDePasseController: _nouveauMotDePasseController,
        confirmerMotDePasseController: _confirmerMotDePasseController,
        selectedCountryCode: _selectedCountryCode,
        onCountryCodeChanged: (value) => setState(() => _selectedCountryCode = value),
        onLogout: _showLogoutDialog,
      ),
    );
  }
}

class ProducerProfilePageBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nomController;
  final TextEditingController prenomController;
  final TextEditingController telephoneController;
  final TextEditingController emailController;
  final TextEditingController motDePasseController;
  final TextEditingController nouveauMotDePasseController;
  final TextEditingController confirmerMotDePasseController;
  final String selectedCountryCode;
  final ValueChanged<String> onCountryCodeChanged;
  final VoidCallback onLogout;

  const ProducerProfilePageBody({
    super.key,
    required this.formKey,
    required this.nomController,
    required this.prenomController,
    required this.telephoneController,
    required this.emailController,
    required this.motDePasseController,
    required this.nouveauMotDePasseController,
    required this.confirmerMotDePasseController,
    required this.selectedCountryCode,
    required this.onCountryCodeChanged,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final u = auth.currentUser;
    final displayName = u == null ? '' : (u.prenom + ' ' + u.nom).trim();

    return Column(
      children: [
        // Header avec fond pêche
        Container(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 50.0, bottom: 20.0),
          color: const Color(0xFFFEE8E3), // Light peach background
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 70), // Space to balance title
                  const Text(
                    'Profil',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  GestureDetector(
                    onTap: onLogout,
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
              const SizedBox(height: 40),
              Row(
                children: [
                  // Photo de profil avec icône d'édition
                  Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: screen_constants.orangeVif.withValues(alpha: 0.30),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/improfil.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.account_circle,
                                color: screen_constants.orangePrincipal.withValues(alpha: 0.31),
                                size: 80,
                              );
                            },
                          ),
                        ),
                      ),
                      // Icône d'édition
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFFFB662F),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
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
        ),
        // Formulaire scrollable
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CardContainer(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(label: 'Nom', controller: nomController),
                        const SizedBox(height: 16),
                        CustomTextField(label: 'Prénom', controller: prenomController),
                        const SizedBox(height: 16),
                        PhoneField(
                          label: 'Téléphone',
                          phoneController: telephoneController,
                          selectedCountryCode: selectedCountryCode,
                          onCountryCodeChanged: onCountryCodeChanged,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(label: 'Mail', controller: emailController),
                        const SizedBox(height: 16),
                        CustomTextField(label: 'Mot de passe', controller: motDePasseController, isPassword: true),
                        const SizedBox(height: 16),
                        CustomTextField(label: 'Nouveau mot de passe', controller: nouveauMotDePasseController, isPassword: true),
                        const SizedBox(height: 16),
                        CustomTextField(label: 'Confirmer le nouveau mot de passe', controller: confirmerMotDePasseController, isPassword: true),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PrimaryButton(
                    text: 'Confirmer',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profil mis à jour avec succès')),
                        );
                      }
                    },
                    height: 45,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
