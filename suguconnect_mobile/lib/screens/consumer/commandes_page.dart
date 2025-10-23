import 'package:flutter/material.dart';

class CommandesPage extends StatefulWidget {
  @override
  _CommandesPageState createState() => _CommandesPageState();
}

class _CommandesPageState extends State<CommandesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes Commandes',
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          labelColor: Colors.orange,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'En cours'),
            Tab(text: 'Livrées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[50],
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCommandesList('en_cours'),
            _buildCommandesList('livrees'),
            _buildCommandesList('annulees'),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandesList(String status) {
    List<Map<String, dynamic>> commandes = _getCommandesByStatus(status);

    if (commandes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'Aucune commande ${_getStatusText(status)}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Commencez vos achats maintenant !',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: commandes.length,
      itemBuilder: (context, index) {
        final commande = commandes[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header de la commande
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Commande #${commande['id']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getStatusColor(status)),
                      ),
                      child: Text(
                        _getStatusText(status),
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 8),
                
                Text(
                  'Date: ${commande['date']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                
                SizedBox(height: 12),
                
                // Liste des produits
                ...commande['produits'].map<Widget>((produit) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(Icons.image, color: Colors.grey, size: 24),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                produit['nom'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Quantité: ${produit['quantite']}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${produit['prix']} €',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                
                SizedBox(height: 12),
                
                Divider(),
                
                // Total et actions
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${commande['total']} €',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (status == 'en_cours') ...[
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Suivi de commande activé')),
                          );
                        },
                        child: Text('Suivre'),
                      ),
                      SizedBox(width: 8),
                    ],
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Commande ${commande['id']} sélectionnée')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Voir détails'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getCommandesByStatus(String status) {
    switch (status) {
      case 'en_cours':
        return [
          {
            'id': '12345',
            'date': '15 Jan 2024',
            'total': '45.50',
            'produits': [
              {'nom': 'Tomates fraîches', 'quantite': 2, 'prix': '8.50'},
              {'nom': 'Pommes', 'quantite': 3, 'prix': '6.00'},
              {'nom': 'Salade', 'quantite': 1, 'prix': '3.50'},
            ],
          },
          {
            'id': '12346',
            'date': '14 Jan 2024',
            'total': '32.75',
            'produits': [
              {'nom': 'Riz basmati', 'quantite': 1, 'prix': '12.75'},
              {'nom': 'Lentilles', 'quantite': 2, 'prix': '8.00'},
            ],
          },
        ];
      case 'livrees':
        return [
          {
            'id': '12340',
            'date': '10 Jan 2024',
            'total': '28.30',
            'produits': [
              {'nom': 'Carottes', 'quantite': 2, 'prix': '4.30'},
              {'nom': 'Oignons', 'quantite': 1, 'prix': '3.00'},
            ],
          },
        ];
      case 'annulees':
        return [];
      default:
        return [];
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'en_cours':
        return 'En cours';
      case 'livrees':
        return 'Livrée';
      case 'annulees':
        return 'Annulée';
      default:
        return '';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'en_cours':
        return Colors.orange;
      case 'livrees':
        return Colors.green;
      case 'annulees':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
