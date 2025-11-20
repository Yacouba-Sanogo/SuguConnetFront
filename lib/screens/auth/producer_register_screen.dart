import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../constantes.dart';
import '../auth/login_screen.dart';
import '../producer/producer_main_screen.dart';

class ProducerRegisterScreen extends StatefulWidget {
  const ProducerRegisterScreen({super.key});

  @override
  State<ProducerRegisterScreen> createState() => _ProducerRegisterScreenState();
}

class _ProducerRegisterScreenState extends State<ProducerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _adresseCtrl = TextEditingController();
  final _farmNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String _countryCode = '223';
  bool _isSubmitting = false;
  bool _showPassword = false;
  bool _showConfirm = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();
  int _selectedSegment = 1; // 0 = Connexion, 1 = Inscription (par défaut sur Inscription)

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _adresseCtrl.dispose();
    _farmNameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // S'assurer que la base URL est résolue
      await AuthService.testConnection();

      await Provider.of<AuthProvider>(context, listen: false).registerProducteur(
        nom: _nomCtrl.text.trim(),
        prenom: _prenomCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        motDePasse: _passwordCtrl.text,
        telephone: '+$_countryCode${_phoneCtrl.text.trim()}',
        adresse: _adresseCtrl.text.trim(),
        nomEntreprise: _farmNameCtrl.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription producteur réussie'), backgroundColor: Color(0xFF4CAF50)),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProducerMainScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      String msg = e.toString();
      if (msg.contains('HTTP 403')) {
        msg = "Accès interdit (403) à l'inscription producteur. Vérifiez que le serveur autorise l'accès public à /producteur/inscription.";
      } else if (msg.contains('HTTP')) {
        msg = msg.replaceFirst('Exception: ', '');
      } else if (msg.contains('FormatException')) {
        msg = "Réponse inattendue du serveur. Réessayez ou contactez l'administrateur.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur d'inscription: $msg"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEE8E3),
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

            // Carte (bas) - couvre tout le bas
            Positioned(
              left: 0,
              right: 0,
              top: MediaQuery.of(context).size.height * 0.28, // Carte blanche commence à 28% de la hauteur
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
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 100), // Espace pour le bouton fixe
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Tabs header
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (_) => const LoginScreen(role: 'producteur')),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: _selectedSegment == 1
                                                ? Colors.grey[200] // Fond gris clair quand Inscription est sélectionné
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Connexion',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.itim(
                                              fontWeight: _selectedSegment == 0
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          // On est déjà sur la page d'inscription, donc on ne fait rien
                                        },
                                        child: Container(
                                          margin: _selectedSegment == 1
                                              ? const EdgeInsets.all(2) // Marge pour réduire la taille du bouton blanc
                                              : EdgeInsets.zero,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10, // Padding réduit
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
                                            border: _selectedSegment == 1
                                                ? Border.all(color: Colors.grey[300]!, width: 0.5)
                                                : null,
                                          ),
                                          child: Text(
                                            'Inscription',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.itim(
                                              fontWeight: _selectedSegment == 1
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),

                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _field(label: 'Nom', controller: _nomCtrl, icon: Icons.person_outline),
                                    const SizedBox(height: 12),
                                    _field(label: 'Prénom', controller: _prenomCtrl, icon: Icons.person_outline),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Container(
                                          width: 90,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _countryCode,
                                              isExpanded: true,
                                              items: const [
                                                DropdownMenuItem(value: '223', child: Center(child: Text('223'))),
                                                DropdownMenuItem(value: '221', child: Center(child: Text('221'))),
                                                DropdownMenuItem(value: '225', child: Center(child: Text('225'))),
                                                DropdownMenuItem(value: '226', child: Center(child: Text('226'))),
                                                DropdownMenuItem(value: '227', child: Center(child: Text('227'))),
                                                DropdownMenuItem(value: '228', child: Center(child: Text('228'))),
                                              ],
                                              onChanged: (v) => setState(() => _countryCode = v ?? '223'),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _field(
                                            label: 'Numéro de téléphone',
                                            controller: _phoneCtrl,
                                            icon: Icons.phone_outlined,
                                            keyboardType: TextInputType.phone,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _field(label: 'E-mail', controller: _emailCtrl, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                                    const SizedBox(height: 12),
                                    _field(label: 'Adresse', controller: _adresseCtrl, icon: Icons.location_on_outlined),
                                    const SizedBox(height: 12),
                                    _field(label: 'Nom de votre ferme', controller: _farmNameCtrl, icon: Icons.store_mall_directory_outlined),
                                    const SizedBox(height: 12),
                                    _field(
                                      label: 'Mot de passe',
                                      controller: _passwordCtrl,
                                      icon: Icons.lock_outline,
                                      obscure: !_showPassword,
                                      suffix: IconButton(
                                        icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                                        onPressed: () => setState(() => _showPassword = !_showPassword),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _field(
                                      label: 'Confirmer le mot de passe',
                                      controller: _confirmCtrl,
                                      icon: Icons.lock_outline,
                                      obscure: !_showConfirm,
                                      suffix: IconButton(
                                        icon: Icon(_showConfirm ? Icons.visibility : Icons.visibility_off),
                                        onPressed: () => setState(() => _showConfirm = !_showConfirm),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Champ Photo du produit
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            final XFile? image = await _imagePicker.pickImage(
                                              source: ImageSource.gallery,
                                              imageQuality: 80,
                                            );
                                            if (image != null) {
                                              setState(() {
                                                _selectedImage = File(image.path);
                                              });
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: 200,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Stack(
                                              children: [
                                                // Contenu (image ou placeholder)
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: _selectedImage != null
                                                      ? Image.file(
                                                          _selectedImage!,
                                                          fit: BoxFit.cover,
                                                          width: double.infinity,
                                                          height: double.infinity,
                                                        )
                                                      : Center(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Icon(
                                                                Icons.camera_alt_outlined,
                                                                size: 60,
                                                                color: Colors.grey[600],
                                                              ),
                                                              const SizedBox(height: 16),
                                                              Text(
                                                                'Ajouter une image de profil',
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors.grey[600],
                                                                ),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                              const SizedBox(height: 20),
                                                              Center(
                                                                child: Container(
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal: 24,
                                                                    vertical: 12,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    gradient: LinearGradient(
                                                                      colors: [
                                                                        const Color(0xFFFF6B35).withValues(alpha: 0.15),
                                                                        const Color(0xFFFF6B35).withValues(alpha: 0.1),
                                                                      ],
                                                                    ),
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                  child: const Text(
                                                                    'Choisir une image',
                                                                    style: TextStyle(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w600,
                                                                      color: Color(0xFFFF6B35),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                ),
                                                // Bordure pointillée
                                                CustomPaint(
                                                  size: Size.infinite,
                                                  painter: _DashedBorderPainter(
                                                    color: Colors.grey[400]!,
                                                    strokeWidth: 2,
                                                    dashLength: 8,
                                                    dashSpace: 4,
                                                    radius: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B35),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        suffixIcon: suffix,
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
      validator: (v) {
        if (v == null || v.trim().isEmpty) return '$label requis';
        if (label == 'E-mail' && !RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) return 'Email invalide';
        return null;
      },
    );
  }
}

// Painter pour dessiner une bordure pointillée
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashSpace;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashSpace,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    final dashPath = _dashPath(path, dashLength, dashSpace);
    canvas.drawPath(dashPath, paint);
  }

  Path _dashPath(Path path, double dashLength, double dashSpace) {
    final dashPath = Path();
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + dashSpace;
      }
    }
    return dashPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
