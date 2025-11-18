import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'producer_register_screen.dart';
// Consumer screens removed

// Écran de sélection de rôle (Producteur/Consommateur) avec design moderne
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bouton retour
                  IconButton(
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
                  
                  const SizedBox(height: 80),
                  
                  // Bannière de titre
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5DC), // Beige/crème
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Bienvenue chez SUGUConnect',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Veuillez choisir votre rôle',
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
                  
                  const SizedBox(height: 10),
                  
                  // Options de sélection de rôle
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          
                          // Consommateur supprimé
                          
                          // Bouton de connexion
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.login,
                                    color: Colors.grey[600],
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Déjà un compte ? Se connecter',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.black,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
