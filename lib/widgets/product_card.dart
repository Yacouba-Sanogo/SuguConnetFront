import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final Produit product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

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
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image, size: 32, color: Colors.grey);
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: product.enStock ? Colors.green.shade100 : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.enStock ? 'En stock' : 'Rupture',
                            style: GoogleFonts.itim(
                              color: product.enStock ? Colors.green.shade700 : Colors.red.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Bio
                        if (product.bio)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
