import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'login_screen.dart';
import '../consumer/main_screen.dart';
import '../../services/auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../constantes.dart';

// Écran d'inscription pour les consommateurs avec design conforme à l'image
class ConsumerRegisterScreen extends StatefulWidget {
  const ConsumerRegisterScreen({super.key});

  @override
  State<ConsumerRegisterScreen> createState() => _ConsumerRegisterScreenState();
}

class _ConsumerRegisterScreenState extends State<ConsumerRegisterScreen> {
  // Clé pour la validation du formulaire
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de saisie
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _adresseController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // États pour la visibilité des mots de passe et le chargement
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Numéro de téléphone complet (avec code pays)
  String _completePhoneNumber = '';

  // Index du segment sélectionné (0 = Connexion, 1 = Inscription)
  int _selectedSegment = 1;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _adresseController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Test de connexion à l'API
      final isConnected = await AuthService.testConnection();
      if (!isConnected) {
        throw Exception(
          'Impossible de se connecter au serveur. Vérifiez que le backend est démarré.',
        );
      }

      // Appel de l'AuthProvider
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).registerConsommateur(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        motDePasse: _passwordController.text,
        telephone: _completePhoneNumber,
        adresse: _adresseController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie ! Bienvenue sur SuguConnect'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 3),
          ),
        );

        // Redirection vers le dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur d\'inscription: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFEE8E3,
      ), // Même couleur que producer_register_screen
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Header avec bouton retour, logo et slogan
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 5.0), // Padding réduit en haut
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Prend seulement l'espace nécessaire
                  children: [
                    // Bouton retour en haut à gauche
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    // Logo SUGUConnect centré
                    Container(
                      width: 140,
                      height: 140,
                      child: Image.asset(
                        Constantes.logoPath,
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Slogan avec icône de feuille - aligné à gauche
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Rejoins l\'aventure locale 🌿',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Conteneur blanc avec le formulaire - couvre tout le bas
            Positioned(
              left: 0,
              right: 0,
              top:
                  MediaQuery.of(context).size.height *
                  0.28, // Carte blanche agrandie - commence plus tôt pour laisser respirer (28%)
              bottom: 0,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    // Contenu scrollable
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 100), // Espace pour le bouton fixe
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // Contrôle segmenté Connexion/Inscription
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedSegment = 0;
                                          });
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const LoginScreen(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _selectedSegment == 1
                                                ? Colors.grey[200] // Fond gris clair quand Inscription est sélectionné
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Connexion',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: _selectedSegment == 0
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedSegment = 1;
                                          });
                                        },
                                        child: Container(
                                          margin: _selectedSegment == 1
                                              ? const EdgeInsets.all(2) // Marge pour réduire la taille du bouton blanc
                                              : EdgeInsets.zero,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10, // Padding réduit de 12 à 10
                                          ),
                                          decoration: BoxDecoration(
                                            color: _selectedSegment == 1
                                                ? Colors.white // Fond blanc quand Inscription est sélectionné
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                            boxShadow: _selectedSegment == 1
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.grey.withValues(alpha: 0.2),
                                                      spreadRadius: 1,
                                                      blurRadius: 3,
                                                      offset: const Offset(0, 1),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Text(
                                            'Inscription',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: _selectedSegment == 1
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Formulaire d'inscription
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                // Champ Nom
                                TextFormField(
                                  controller: _nomController,
                                  decoration: InputDecoration(
                                    hintText: 'Nom',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nom requis';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Champ Prénom
                                TextFormField(
                                  controller: _prenomController,
                                  decoration: InputDecoration(
                                    hintText: 'Prénom',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Prénom requis';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Champ Téléphone avec IntlPhoneField
                                IntlPhoneField(
                                  initialCountryCode: 'ML', // Mali
                                  decoration: InputDecoration(
                                    hintText: 'Numéro de téléphone',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  onChanged: (phone) {
                                    setState(() {
                                      _completePhoneNumber = phone.completeNumber;
                                    });
                                  },
                                  validator: (phone) {
                                    if (phone == null || phone.number.isEmpty) {
                                      return 'Numéro requis';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Champ E-mail
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'E-mail',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email requis';
                                    }
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Email invalide';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Champ Adresse
                                TextFormField(
                                  controller: _adresseController,
                                  decoration: InputDecoration(
                                    hintText: 'Adresse',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Adresse requise';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Champ Mot de passe
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    hintText: 'Mot de passe',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Mot de passe requis';
                                    }
                                    if (value.length < 6) {
                                      return 'Minimum 6 caractères';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Champ Confirmer le mot de passe
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: !_isConfirmPasswordVisible,
                                  decoration: InputDecoration(
                                    hintText: 'Confirmer le mot de passe',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[500],
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isConfirmPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isConfirmPasswordVisible =
                                              !_isConfirmPasswordVisible;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Confirmation requise';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Les mots de passe ne correspondent pas';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ),
                          ],
                        ),
                      ),
                    ),

                    // Gradient pour l'effet de masquage au-dessus du bouton
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 80,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 1.0),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bouton fixe en bas
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Constantes.primaryOrange, // Orange
                            foregroundColor: Constantes.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                  ),
                                )
                              : const Text(
                                  'S\'inscrire',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
