import 'package:flutter/material.dart';
import 'producer_register_screen.dart';
import 'consumer_register_screen.dart';

// Écran de sélection de rôle (Producteur/Consommateur)
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Éléments décoratifs orange
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: Color(0xFFFB662F),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  color: Color(0xFFFB662F),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            // Contenu principal
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bouton retour
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 100),
                
                // Bannière de titre - collée aux bords
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5DC),
                  ),
                  child:const Column(
                    children: [
                      Text(
                        'Bienvenue chez SUGUConnect',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Veiller choisir votre rôle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Options de sélection de rôle
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Carte Producteur
                        _buildRoleCard(
                          context: context,
                          icon: Icons.people,
                          title: 'Producteur',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProducerRegisterScreen(),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Carte Consommateur
                        _buildRoleCard(
                          context: context,
                          icon: Icons.shopping_cart,
                          title: 'Consommateur',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ConsumerRegisterScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black,
              size: 40,
            ),
            const SizedBox(width: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
