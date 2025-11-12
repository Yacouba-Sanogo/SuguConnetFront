import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suguconnect_mobile/screens/producer/producer_product_form_screen.dart';
import 'package:suguconnect_mobile/screens/producer/notifications_page.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class ProducerProductsScreen extends StatefulWidget {
  const ProducerProductsScreen({super.key});

  @override
  State<ProducerProductsScreen> createState() => _ProducerProductsScreenState();
}

class _ProducerProductsScreenState extends State<ProducerProductsScreen> {
  final List<Map<String, dynamic>> _products = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<Widget> _loadNetworkImage(String url) async {
    try {
      // Normaliser l'hôte de l'URL de la photo pour correspondre à la base résolue
      if (AuthService.resolvedBaseUrl == null) {
        await AuthService.testConnection();
      }
      final base = AuthService.resolvedBaseUrl;
      Uri imageUri = Uri.parse(url);
      if (base != null) {
        final baseUri = Uri.parse(base);
        imageUri = imageUri.replace(scheme: baseUri.scheme, host: baseUri.host, port: baseUri.port);
      }

      final auth = Provider.of<AuthProvider>(context, listen: false);
      final token = auth.token;
      // Tentative avec Authorization
      var resp = await http.get(imageUri, headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'image/*,application/octet-stream',
      });
      // Fallback sans Authorization
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        resp = await http.get(imageUri);
      }
      if (resp.statusCode == 200) {
        return Image.memory(
          resp.bodyBytes,
          fit: BoxFit.cover,
        );
      } else {
        throw Exception('HTTP ${resp.statusCode}');
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final user = auth.currentUser;
      final token = auth.token;
      if (user?.id == null) {
        throw Exception('Utilisateur non connecté');
      }
      // Ensure base URL
      if (AuthService.resolvedBaseUrl == null) {
        await AuthService.testConnection();
      }
      final base = AuthService.resolvedBaseUrl ?? '';
      if (base.isEmpty) throw Exception('URL serveur introuvable');

      final uri = Uri.parse('$base/producteur/${user!.id}/produit');
      final resp = await http.get(uri, headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      if (resp.statusCode == 200) {
        final List<dynamic> data = jsonDecode(resp.body);
        print('Produits reçus: $data');
        final list = data.map<Map<String, dynamic>>((item) {
          final rawPhotos = (item['photos'] as List?) ?? const [];
          String firstPhoto = '';
          if (rawPhotos.isNotEmpty) {
            final p0 = rawPhotos.first;
            if (p0 is String) {
              firstPhoto = p0;
            } else if (p0 is Map<String, dynamic>) {
              firstPhoto = (p0['url'] ?? p0['lien'] ?? '').toString();
            } else {
              firstPhoto = p0.toString();
            }
          }
          firstPhoto = _normalizeImagePath(firstPhoto);
          return {
            'id': item['id'] ?? 0,
            'name': item['nom'] ?? '',
            'price': (item['prixUnitaire'] ?? '').toString(),
            'stock': item['stockDisponible'] ?? item['quantite'] ?? 0,
            'image': firstPhoto,
            'category': (item['categorie'] != null ? (item['categorie']['nom'] ?? '') : ''),
            'description': item['description'] ?? '',
            'unite': item['unite'] ?? 'KILOGRAMME',
            'isBio': item['bio'] ?? false,
          };
        }).toList();
        setState(() {
          _products
            ..clear()
            ..addAll(list);
        });
      } else {
        throw Exception('HTTP ${resp.statusCode}: ${resp.reasonPhrase ?? ''}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                      ? Center(
                          child: _error != null
                              ? Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(_error!, textAlign: TextAlign.center),
                                )
                              : const Text('Aucun produit'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(_products[index], index);
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final product = await ProducerProductFormScreen.show(context);
          if (product != null) {
            // Après ajout réussi, recharger depuis le backend
            await _loadProducts();
          }
        },
        backgroundColor: const Color(0xFFFB662F),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFB662F), width: 2),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFFFB662F),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    size: 28,
                    color: Colors.black87,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFB662F),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image du produit
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Container(
              width: 100,
              height: 100,
              color: Colors.grey.shade100,
              child: _buildProductImage(product['image']),
            ),
          ),
          
          // Détails du produit
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (product['isBio'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.eco, color: Colors.green.shade700, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'Bio',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product['price']} fcfa',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${product['stock']} cartons',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Boutons d'action
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  color: const Color(0xFFFB662F),
                  onTap: () => _showEditProductDialog(context, product),
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  icon: Icons.delete_outline,
                  color: Colors.grey.shade600,
                  onTap: () => _showDeleteConfirmation(context, index),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imagePath) {
    if (imagePath.isEmpty) {
      return const Icon(Icons.image, size: 40);
    }
    // Chemin relatif serveur (ex: "/files/..."), traiter comme URL réseau
    if (imagePath.startsWith('/')) {
      return FutureBuilder<Widget>(
        future: _loadNetworkImage(imagePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
          }
          if (snapshot.hasError) {
            return const Icon(Icons.broken_image, size: 40);
          }
          return snapshot.data ?? const Icon(Icons.broken_image, size: 40);
        },
      );
    }
    // URL réseau absolue (http/https)
    if (imagePath.startsWith('http')) {
      final normalized = _normalizeImagePath(imagePath);
      return FutureBuilder<Widget>(
        future: _loadNetworkImage(normalized),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)));
          }
          if (snapshot.hasError) {
            return const Icon(Icons.broken_image, size: 40);
          }
          return snapshot.data ?? const Icon(Icons.broken_image, size: 40);
        },
      );
    }
    // Asset
    return Image.network(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 40),
    );
  }

  String _normalizeImagePath(String path) {
    if (path.isEmpty) return path;
    try {
      // Extraire le nom de fichier
      final uri = Uri.parse(path);
      final segments = uri.pathSegments;
      if (segments.isEmpty) return path;
      final fileName = segments.last;

      // Si l'URL pointe vers /files/download/... => utiliser /uploads/<file>
      if (uri.path.contains('/files/download/') || uri.path.contains('/suguconnect/files/download/')) {
        return '/uploads/$fileName';
      }

      // Si déjà dans /uploads, renvoyer chemin relatif normalisé
      if (uri.path.contains('/uploads/')) {
        return '/uploads/$fileName';
      }

      // Si URL absolue mais autre chemin, retourner tel quel
      if (uri.hasScheme) {
        return path;
      }

      // Sinon, retourner inchangé
      return path;
    } catch (_) {
      return path;
    }
  }

  void _showEditProductDialog(BuildContext context, Map<String, dynamic> product) {
    final nameController = TextEditingController(text: product['name'] ?? '');
    final priceController = TextEditingController(text: product['price']?.toString() ?? '');
    final stockController = TextEditingController(text: product['stock']?.toString() ?? '0');
    final descriptionController = TextEditingController(text: product['description'] ?? '');
    String selectedUnite = (product['unite'] ?? 'KILOGRAMME').toString().toUpperCase();
    bool isBio = product['isBio'] ?? false;
    bool isLoading = false;
    File? selectedImage;
    String? currentImageUrl = product['image']?.toString();
    final ImagePicker imagePicker = ImagePicker();
    
    final List<String> unites = ['KILOGRAMME', 'SAC', 'CARTON', 'TONNE'];
    final Map<String, String> uniteLabels = {
      'KILOGRAMME': 'Kilogramme',
      'SAC': 'Sac',
      'CARTON': 'Carton',
      'TONNE': 'Tonne',
    };

    Future<void> pickImage(StateSetter setDialogState) async {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
                ),
                title: const Text('Galerie'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
                ),
                title: const Text('Appareil photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        try {
          final XFile? image = await imagePicker.pickImage(
            source: source,
            maxWidth: 1200,
            maxHeight: 1200,
            imageQuality: 85,
          );
          
          if (image != null) {
            setDialogState(() {
              selectedImage = File(image.path);
              currentImageUrl = null;
            });
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // En-tête moderne
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Modifier le produit',
                              style: GoogleFonts.itim(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                            ),
                            onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                    ),

                    // Contenu
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Photo
                            Text(
                              'Photo du produit',
                              style: GoogleFonts.itim(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => pickImage(setDialogState),
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: selectedImage != null
                                    ? Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: Image.file(
                                              selectedImage!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.6),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                            ),
                                          ),
                                        ],
                                      )
                                    : currentImageUrl != null && currentImageUrl!.isNotEmpty
                                        ? Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(14),
                                                child: Image.network(
                                                  currentImageUrl!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return _buildEmptyPhotoPlaceholder();
                                                  },
                                                ),
                                              ),
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withOpacity(0.6),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                                ),
                                              ),
                                            ],
                                          )
                                        : _buildEmptyPhotoPlaceholder(),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Nom
                            _buildModernTextField(
                              controller: nameController,
                              label: 'Nom du produit',
                              icon: Icons.shopping_bag_rounded,
                            ),

                            const SizedBox(height: 20),

                            // Description
                            _buildModernTextField(
                              controller: descriptionController,
                              label: 'Description',
                              icon: Icons.description_rounded,
                              maxLines: 3,
                            ),

                            const SizedBox(height: 20),

                            // Prix et Stock
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: priceController,
                                    label: 'Prix (fcfa)',
                                    icon: Icons.euro_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: stockController,
                                    label: 'Stock',
                                    icon: Icons.inventory_2_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Unité
                            DropdownButtonFormField<String>(
                              value: selectedUnite,
                              decoration: InputDecoration(
                                labelText: 'Unité',
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(8),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.straighten_rounded, color: AppTheme.primaryColor, size: 20),
                                ),
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
                              items: unites.map((unite) {
                                return DropdownMenuItem(
                                  value: unite,
                                  child: Text(uniteLabels[unite] ?? unite),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setDialogState(() => selectedUnite = value);
                                }
                              },
                            ),

                            const SizedBox(height: 20),

                            // Bio
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isBio ? Colors.green.shade300 : Colors.grey.shade300,
                                  width: isBio ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isBio ? Colors.green.shade50 : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.eco_rounded,
                                      color: isBio ? Colors.green.shade700 : Colors.grey.shade600,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Produit bio',
                                          style: GoogleFonts.itim(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isBio ? Colors.green.shade700 : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isBio,
                                    onChanged: (value) => setDialogState(() => isBio = value),
                                    activeColor: Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Actions
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                'Annuler',
                                style: GoogleFonts.itim(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : () async {
                                setDialogState(() => isLoading = true);
                                try {
                                  final auth = Provider.of<AuthProvider>(context, listen: false);
                                  final user = auth.currentUser;
                                  final token = auth.token;
                                  if (user?.id == null || token == null) {
                                    throw Exception('Utilisateur non connecté');
                                  }

                                  if (AuthService.resolvedBaseUrl == null) {
                                    await AuthService.testConnection();
                                  }
                                  final base = AuthService.resolvedBaseUrl ?? '';
                                  if (base.isEmpty) throw Exception('URL serveur introuvable');

                                  final productId = product['id'];
                                  if (productId == null) {
                                    throw Exception('ID du produit introuvable');
                                  }

                                  // Toujours utiliser multipart pour coller au backend (/producteur/{producteurId}/produit/{produitId})
                                  final uri = Uri.parse('$base/producteur/${user!.id}/produit/$productId');
                                  final request = http.MultipartRequest('PUT', uri);
                                  request.headers['Authorization'] = 'Bearer $token';

                                  // Champs optionnels acceptés par le backend
                                  if (nameController.text.trim().isNotEmpty) {
                                    request.fields['nom'] = nameController.text.trim();
                                  }
                                  if (descriptionController.text.trim().isNotEmpty) {
                                    request.fields['description'] = descriptionController.text.trim();
                                  }
                                  if (priceController.text.trim().isNotEmpty) {
                                    request.fields['prixUnitaire'] = priceController.text.replaceAll(',', '.');
                                  }
                                  if (stockController.text.trim().isNotEmpty) {
                                    request.fields['quantite'] = stockController.text.trim();
                                  }
                                  if (selectedUnite.isNotEmpty) {
                                    request.fields['unite'] = selectedUnite;
                                  }

                                  // Ajouter la photo seulement si sélectionnée
                                  if (selectedImage != null) {
                                    final stream = http.ByteStream(Stream.castFrom(selectedImage!.openRead()));
                                    final length = await selectedImage!.length();
                                    final multipartFile = http.MultipartFile(
                                      'photos',
                                      stream,
                                      length,
                                      filename: selectedImage!.path.split('/').last,
                                    );
                                    request.files.add(multipartFile);
                                  }

                                  final response = await request.send();
                                  if (response.statusCode == 200) {
                                    if (context.mounted) {
                                      Navigator.pop(dialogContext);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Produit modifié avec succès'),
                                          backgroundColor: Color(0xFF4CAF50),
                                        ),
                                      );
                                      final state = context.findAncestorStateOfType<_ProducerProductsScreenState>();
                                      if (state != null) {
                                        state._loadProducts();
                                      }
                                    }
                                  } else {
                                    final body = await response.stream.bytesToString();
                                    throw Exception('HTTP ${response.statusCode}: $body');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erreur: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setDialogState(() => isLoading = false);
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.check_circle_rounded, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Enregistrer',
                                          style: GoogleFonts.itim(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyPhotoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_rounded,
          color: AppTheme.primaryColor,
          size: 48,
        ),
        const SizedBox(height: 8),
        Text(
          'Appuyez pour ajouter une photo',
          style: GoogleFonts.itim(
            color: AppTheme.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
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
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Supprimer le produit'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce produit ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  final user = auth.currentUser;
                  final token = auth.token;
                  final product = _products[index];
                  final productId = product['id'];
                  if (user?.id == null || token == null || productId == null) {
                    throw Exception('Contexte invalide');
                  }

                  // Résoudre base URL si nécessaire
                  if (AuthService.resolvedBaseUrl == null) {
                    await AuthService.testConnection();
                  }
                  final base = AuthService.resolvedBaseUrl ?? '';
                  if (base.isEmpty) throw Exception('URL serveur introuvable');

                  final uri = Uri.parse('$base/producteur/${user!.id}/produit/$productId');
                  final resp = await http.delete(uri, headers: {
                    'Authorization': 'Bearer $token',
                    'Accept': 'application/json',
                  });
                  if (resp.statusCode == 200) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Produit supprimé'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    await _loadProducts();
                  } else {
                    throw Exception('HTTP ${resp.statusCode}: ${resp.reasonPhrase ?? ''}');
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Échec de la suppression: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

}
