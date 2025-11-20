import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';
import 'producer_register_screen.dart';
import 'consumer_register_screen.dart';
import '../consumer/main_screen.dart';
import '../producer/producer_main_screen.dart';
import '../../services/auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../constantes.dart';

// Écran de connexion pour les utilisateurs existants
class LoginScreen extends StatefulWidget {
  final String? role; // 'producteur' ou 'consommateur' pour déterminer la redirection
  const LoginScreen({super.key, this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Clé pour la validation du formulaire
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs pour les champs de connexion
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // États pour la visibilité du mot de passe et le chargement
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  // Plus d'indicatif pays dans l'UI de connexion (maquette minimaliste)

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Texte d'aide simple pour le numéro
  String _getPhoneHint() => 'Numéro de téléphone';

  // Normalise pour le backend: on envoie uniquement le numéro local (chiffres)
  String _normalizePhoneNumber(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Test de connexion à l'API
      final isConnected = await AuthService.testConnection();
      if (!isConnected) {
        throw Exception('Impossible de se connecter au serveur. Vérifiez que le backend est démarré.');
      }

      // Normalise le numéro de téléphone avant l'envoi
      final normalizedPhone = _normalizePhoneNumber(_phoneController.text.trim());

      // Appel de l'AuthProvider
      await Provider.of<AuthProvider>(context, listen: false).login(
        normalizedPhone,
        _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion réussie ! Bienvenue sur SuguConnect'),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );

        // Redirection selon le rôle
        final role = Provider.of<AuthProvider>(context, listen: false).userRole.toUpperCase();
        Widget destination;
        if (role == 'PRODUCTEUR') {
          destination = const ProducerMainScreen();
        } else {
          // Par défaut CONSOMMATEUR ou ADMIN redirigés vers l'interface consommateur
          destination = MainScreen();
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => destination,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: $e'),
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
      backgroundColor: const Color(0xFFFEE8E3),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 5.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
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
                            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                            onPressed: () => Navigator.pop(context),
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
                    // Slogan - aligné à gauche
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Heureux de vous revoir 🌻',
                            style: GoogleFonts.itim(fontSize: 18, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // Tabs header
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('Connexion', style: GoogleFonts.itim(fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // Rediriger vers producer_register_screen si on vient du producteur, sinon consumer_register_screen
                                    if (widget.role == 'producteur') {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (_) => const ProducerRegisterScreen()),
                                      );
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (_) => const ConsumerRegisterScreen()),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text('Inscription', style: GoogleFonts.itim(fontWeight: FontWeight.w600, color: Colors.black87)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Champ Numéro
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: _getPhoneHint(),
                            hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre numéro';
                            }
                            final cleanedPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                            if (cleanedPhone.length < 8 || !RegExp(r'^[0-9]+$').hasMatch(cleanedPhone)) {
                              return 'Numéro invalide (min 8 chiffres)';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Champ Mot de passe
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Mot de passe',
                            hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Veuillez saisir votre mot de passe';
                            if (value.length < 6) return 'Au moins 6 caractères';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Bouton Se connecter
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B35),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Text('Se connecter', style: GoogleFonts.itim(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}