import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../constantes.dart';

class ProducerProductFormScreen extends StatefulWidget {
  const ProducerProductFormScreen({super.key});

  @override
  State<ProducerProductFormScreen> createState() => _ProducerProductFormScreenState();
  
  static Future<Map<String, dynamic>?> show(BuildContext context) async {
    return await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const ProducerProductFormScreen(),
      ),
    );
  }
}

class _ProducerProductFormScreenState extends State<ProducerProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '0');
  String _unit = 'Kg';
  String _category = 'Légumes';
  final _descCtrl = TextEditingController();
  bool _isBio = false;
  List<File> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFEE8E3), // Couleur pêche de la maquette
        title: const Text(
          'Ajout d\'un produit',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom du produit avec design moderne
              _ModernSection(
                title: 'Nom du produit',
                child: TextFormField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'Mangue ...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Catégories avec design moderne
              _ModernSection(
                title: 'Catégorie',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final c in ['Légumes','Fruits','Epices','Céréales'])
                      _ModernChoiceChip(
                        label: c,
                        selected: _category == c,
                        onSelected: () => setState(() => _category = c),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Prix et Quantité avec design moderne
              Row(
                children: [
                  Expanded(
                    child: _ModernSection(
                      title: 'Prix',
                      child: TextFormField(
                        controller: _priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          prefixText: 'fcfa ',
                          hintText: '0.00',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        validator: (v) => (double.tryParse(v ?? '') == null) ? 'Prix invalide' : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ModernSection(
                      title: 'Quantité',
                      child: Row(
                        children: [
                          _ModernQtyBtn(icon: Icons.remove, onTap: () => _changeQty(-1)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: TextFormField(
                              controller: _qtyCtrl,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
                              ),
                              validator: (v) => (int.tryParse(v ?? '') == null) ? 'Invalide' : null,
                            ),
                          ),
                          const SizedBox(width: 4),
                          _ModernQtyBtn(icon: Icons.add, onTap: () => _changeQty(1)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Unité avec design moderne
              _ModernSection(
                title: 'Unité',
                child: DropdownButtonFormField<String>(
                  value: _unit,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Kg', child: Text('Kilogramme')),
                    DropdownMenuItem(value: 'Sac', child: Text('Sac')),
                    DropdownMenuItem(value: 'Carton', child: Text('Carton')),
                    DropdownMenuItem(value: 'Tonne', child: Text('Tonne')),
                  ],
                  onChanged: (v) => setState(() => _unit = v ?? 'Kg'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Photos du produit (jusqu'à 4)
              _ModernSection(
                title: 'Photo du produit',
                child: Column(
                  children: [
                    // Zone d'upload avec bordure pointillée
                    GestureDetector(
                      onTap: _selectedImages.length < 4 ? _pickImage : null,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Icône caméra
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 64,
                              color: Colors.black87,
                            ),
                            const SizedBox(height: 16),
                            // Texte d'instruction
                            Text(
                              'Ajouter des images pour votre produit(4 photos maximum)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Bouton "Choisir une image"
                            if (_selectedImages.length < 4)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: orangePrincipal.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Choisir une image',
                                  style: TextStyle(
                                    color: orangePrincipal,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Grille des images sélectionnées
                    if (_selectedImages.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImages[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Option Bio
              _ModernSection(
                title: 'Caractéristiques',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isBio ? Colors.green.shade300 : Colors.grey.shade300,
                      width: _isBio ? 2 : 1,
                    ),
                    boxShadow: _isBio ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isBio ? Colors.green.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.eco,
                          color: _isBio ? Colors.green.shade700 : Colors.grey.shade600,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Produit Bio',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _isBio ? Colors.green.shade700 : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Agriculture biologique certifiée',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isBio,
                        onChanged: (value) {
                          setState(() {
                            _isBio = value;
                          });
                        },
                        activeColor: Colors.green,
                        activeTrackColor: Colors.green.shade300,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Description avec design de la maquette
              _ModernSection(
                title: 'Description du produit',
                child: TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Ajouter une description pour votre produit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Bouton d'action moderne
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                  child: const Text(
                    'Ajouter produit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _changeQty(int delta) {
    final current = int.tryParse(_qtyCtrl.text) ?? 0;
    final next = (current + delta).clamp(0, 1000000);
    setState(() {
      _qtyCtrl.text = next.toString();
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    // Afficher un dialogue pour choisir entre galerie et appareil photo
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Choisir une source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              title: const Text('Appareil photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      try {
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 1200,
          maxHeight: 1200,
          imageQuality: 85,
        );
        
        if (image != null) {
          setState(() {
            _selectedImages.add(File(image.path));
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la sélection: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Vérifier si le nom correspond à la catégorie
  bool _validateNameCategory() {
    final name = _nameCtrl.text.toLowerCase();
    
    final categoryProducts = {
      'Légumes': ['tomate', 'carotte', 'oignon', 'poivron', 'concombre', 'aubergine', 'courgette', 'haricot', 'gombo', 'pomme de terre', 'patate', 'chou', 'salade', 'épinard', 'ail', 'échalote'],
      'Fruits': ['mangue', 'banane', 'orange', 'citron', 'avocat', 'ananas', 'papaye', 'goyave', 'pastèque', 'melon', 'raisin', 'pomme', 'poire', 'pêche', 'abricot'],
      'Epices': ['piment', 'poivre', 'gingembre', 'curry', 'cumin', 'coriandre', 'persil', 'basilic', 'thym', 'romarin', 'safran', 'cannelle', 'clou de girofle'],
      'Céréales': ['riz', 'maïs', 'mil', 'blé', 'sorgho', 'avoine', 'orge', 'quinoa'],
    };

    final validNames = categoryProducts[_category] ?? [];
    return validNames.any((valid) => name.contains(valid));
  }

  String _getCategoryHelp() {
    switch (_category) {
      case 'Légumes':
        return 'Légumes valides: Tomate, Carotte, Oignon, Poivron, Gombo, Chou, Ail...';
      case 'Fruits':
        return 'Fruits valides: Mangue, Banane, Orange, Avocat, Ananas, Papaye...';
      case 'Epices':
        return 'Epices valides: Piment, Poivre, Gingembre, Curry, Safran...';
      case 'Céréales':
        return 'Céréales valides: Riz, Maïs, Mil, Blé, Sorgho, Quinoa...';
      default:
        return '';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une image pour votre produit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_validateNameCategory()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange, size: 28),
              const SizedBox(width: 8),
              const Text('Nom invalide'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Le nom "${_nameCtrl.text}" ne correspond pas à la catégorie "${_category}".',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getCategoryHelp(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    final token = auth.token;
    if (user?.id == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // S'assurer que la base URL est résolue
      if (AuthService.resolvedBaseUrl == null) {
        await AuthService.testConnection();
      }
      final base = AuthService.resolvedBaseUrl ?? '';
      if (base.isEmpty) {
        throw Exception('URL du serveur introuvable');
      }

      final uri = Uri.parse('$base/producteur/${user!.id}/produit');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      // Mapping unités UI -> backend enum Unite
      String mapUnite(String u) {
        switch (u.toLowerCase()) {
          case 'kg':
            return 'KILOGRAMME';
          case 'sac':
            return 'SAC';
          case 'carton':
            return 'CARTON';
          case 'tonne':
            return 'TONNE';
          default:
            return 'KILOGRAMME';
        }
      }

      // Mapping catégories de démo -> ids dummy (à remplacer si API catégories disponible)
      int mapCategorieId(String c) {
        switch (c) {
          case 'Légumes':
            return 1;
          case 'Fruits':
            return 2;
          case 'Epices':
            return 3;
          case 'Céréales':
            return 4;
          default:
            return 1;
        }
      }

      request.fields['nom'] = _nameCtrl.text.trim();
      request.fields['description'] = _descCtrl.text.trim();
      request.fields['prixUnitaire'] = (_priceCtrl.text.trim().replaceAll(',', '.'));
      request.fields['unite'] = mapUnite(_unit);
      request.fields['quantite'] = (_qtyCtrl.text.trim().isEmpty ? '0' : _qtyCtrl.text.trim());
      request.fields['categorieId'] = mapCategorieId(_category).toString();

      // Photos (max 4)
      final images = _selectedImages.take(4).toList();
      for (final file in images) {
        final stream = http.ByteStream(Stream.castFrom(file.openRead()));
        final length = await file.length();
        final multipartFile = http.MultipartFile('photos', stream, length, filename: file.path.split('/').last);
        request.files.add(multipartFile);
      }

      final response = await request.send();
      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Produit ajouté avec succès'), backgroundColor: Colors.green),
          );
        }
        Navigator.of(context).pop({
          'name': _nameCtrl.text,
          'price': _priceCtrl.text,
          'stock': int.parse(_qtyCtrl.text),
          'category': _category,
          'unit': _unit,
          'description': _descCtrl.text,
          'images': images.map((f) => f.path).toList(),
          'isBio': _isBio,
        });
      } else {
        final body = await response.stream.bytesToString();
        throw Exception('HTTP ${response.statusCode}: $body');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _ModernSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _ModernSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _ModernChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;
  const _ModernChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.primaryColor : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: selected ? 2 : 0,
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.primaryColor : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModernQtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ModernQtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 48,
          decoration: BoxDecoration(
            color: icon == Icons.add ? AppTheme.primaryColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: icon == Icons.add ? AppTheme.primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Icon(
            icon,
            color: icon == Icons.add ? Colors.white : Colors.grey.shade600,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// Painter pour bordure pointillée
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.borderRadius = 12.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Dessiner les lignes pointillées pour les côtés
    _drawDashedLine(
      canvas,
      paint,
      Offset(0, borderRadius),
      Offset(0, size.height - borderRadius),
    );
    _drawDashedLine(
      canvas,
      paint,
      Offset(borderRadius, 0),
      Offset(size.width - borderRadius, 0),
    );
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width, borderRadius),
      Offset(size.width, size.height - borderRadius),
    );
    _drawDashedLine(
      canvas,
      paint,
      Offset(borderRadius, size.height),
      Offset(size.width - borderRadius, size.height),
    );

    // Dessiner les coins arrondis avec des arcs pointillés
    _drawDashedArc(canvas, paint, Offset(borderRadius, borderRadius), borderRadius, 1.5 * 3.14159, 3.14159 / 2);
    _drawDashedArc(canvas, paint, Offset(size.width - borderRadius, borderRadius), borderRadius, 0, 3.14159 / 2);
    _drawDashedArc(canvas, paint, Offset(size.width - borderRadius, size.height - borderRadius), borderRadius, 3.14159 / 2, 3.14159 / 2);
    _drawDashedArc(canvas, paint, Offset(borderRadius, size.height - borderRadius), borderRadius, 3.14159, 3.14159 / 2);
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end) {
    final path = Path();
    final distance = (end - start).distance;
    if (distance == 0) return;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();
    final unit = (end - start) / distance;

    for (int i = 0; i < dashCount; i++) {
      final dashStart = start + unit * (i * (dashWidth + dashSpace));
      final dashEnd = start + unit * (i * (dashWidth + dashSpace) + dashWidth);
      path.moveTo(dashStart.dx, dashStart.dy);
      path.lineTo(dashEnd.dx, dashEnd.dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawDashedArc(Canvas canvas, Paint paint, Offset center, double radius, double startAngle, double sweepAngle) {
    final path = Path();
    final circumference = radius * sweepAngle;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();
    if (dashCount == 0) return;
    final angleStep = sweepAngle / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final angle1 = startAngle + i * angleStep;
      final angle2 = startAngle + i * angleStep + (dashWidth / radius);
      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        angle1,
        (angle2 - angle1).clamp(0.0, sweepAngle - (i * angleStep)),
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


