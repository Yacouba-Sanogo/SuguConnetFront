import 'package:flutter/material.dart';
import 'notifications_page.dart';

class ProfilPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mon Profil',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Modifier le profil')),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Section profil utilisateur
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.orange,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Nom et email
                    Text(
                      'Yacouba Sanogo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: 8),
                    
                    Text(
                      'yacouba.sanogo@email.com',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Statut membre
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.green[700], size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Membre vérifié',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Section statistiques
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes Statistiques',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Commandes',
                            '24',
                            Icons.shopping_bag_outlined,
                            Colors.blue,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Favoris',
                            '12',
                            Icons.favorite_outline,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Points',
                            '1,250',
                            Icons.stars_outlined,
                            Colors.orange,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Économies',
                            '45€',
                            Icons.savings_outlined,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Section menu
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    _buildMenuItem(
                      'Mes Commandes',
                      Icons.receipt_long_outlined,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Navigation vers Mes Commandes')),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      'Mes Favoris',
                      Icons.favorite_outline,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Navigation vers Mes Favoris')),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      'Adresses',
                      Icons.location_on_outlined,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gestion des adresses')),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      'Moyens de Paiement',
                      Icons.credit_card_outlined,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gestion des paiements')),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      'Notifications',
                      Icons.notifications_outlined,
                      () {
                        // Navigation vers la page des notifications
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsPage(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      'Centre d\'Aide',
                      Icons.help_outline,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Centre d\'aide')),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      'Paramètres',
                      Icons.settings_outlined,
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Paramètres de l\'application')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              // Bouton de déconnexion
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Déconnexion'),
                        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Annuler'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Déconnexion réussie')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Déconnexion'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Se déconnecter',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey[200],
      indent: 56,
    );
  }
}
