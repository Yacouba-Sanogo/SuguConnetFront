import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
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
            // Header (haut)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Rejoins l'aventure locale 🌿",
                        style: GoogleFonts.itim(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Carte (bas)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  );
                                },
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
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Inscription',
                                  style: GoogleFonts.itim(color: Colors.white, fontWeight: FontWeight.w600),
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
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B35),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                      )
                                    : Text('S\'inscrire', style: GoogleFonts.itim(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
