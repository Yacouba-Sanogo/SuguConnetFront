import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class ProductCard extends StatelessWidget {
  final Produit product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  // Charger une image avec authentification si nécessaire
  Future<Widget> _loadImage(BuildContext context, String imageUrl) async {
    try {
      // S'assurer que l'URL de base est résolue
      if (AuthService.resolvedBaseUrl == null) {
        await AuthService.testConnection();
      }

      final baseUrl = AuthService.resolvedBaseUrl;
      Uri imageUri = Uri.parse(imageUrl);

      // Si l'URL est relative ou complète mais avec un autre hôte, normaliser
      if (baseUrl != null) {
        final baseUri = Uri.parse(baseUrl);
        imageUri = imageUri.replace(
          scheme: baseUri.scheme,
          host: baseUri.host,
          port: baseUri.port,
        );
      }

      // Récupérer le token d'authentification
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      // Télécharger l'image avec le token si disponible
      var response = await http.get(
        imageUri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'image/*,application/octet-stream',
        },
      );

      // Si échec avec auth, réessayer sans token (endpoint public)
      if (response.statusCode == 401 || response.statusCode == 403) {
        response = await http.get(imageUri);
      }

      if (response.statusCode == 200) {
        return Image.memory(
          response.bodyBytes,
          fit: BoxFit.cover,
        );
      }

      throw Exception('HTTP ${response.statusCode}');
    } catch (e) {
      // Retourner une icône en cas d'erreur
      return const Icon(Icons.broken_image, size: 32, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: FutureBuilder<Widget>(
                          future: _loadImage(context, product.imageUrl!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              );
                            }
                            if (snapshot.hasError || !snapshot.hasData) {
                              return const Icon(Icons.broken_image,
                                  size: 32, color: Colors.grey);
                            }
                            return snapshot.data!;
                          },
                        ),
                      )
                    : const Icon(Icons.image, size: 32, color: Colors.grey),
              ),
            ),

            // Contenu de la carte
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du produit
                    Text(
                      product.nom,
                      style: GoogleFonts.itim(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Prix
                    Text(
                      product.prixFormate,
                      style: GoogleFonts.itim(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const Spacer(),

                    // Informations supplémentaires
                    Row(
                      children: [
                        // Stock
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: product.enStock
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.enStock ? 'En stock' : 'Rupture',
                            style: GoogleFonts.itim(
                              color: product.enStock
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Bio
                        if (product.bio)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'BIO',
                              style: GoogleFonts.itim(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
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
