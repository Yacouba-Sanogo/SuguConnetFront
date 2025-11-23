import 'package:flutter/material.dart';
import 'order_detail_page.dart';
import '../../widgets/entete_widget.dart';

// Page des commandes avec design moderne et onglets de filtrage
class CommandesPage extends StatefulWidget {
  const CommandesPage({super.key, this.showAppBar = true});
  
  final bool showAppBar;
  
  @override
  _CommandesPageState createState() => _CommandesPageState();
}

class _CommandesPageState extends State<CommandesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Tous'; // Filtre sélectionné

  // Données fictives des commandes
  final List<Map<String, dynamic>> _orders = [
    {
      'id': '12345',
      'client': 'Ali Touré',
      'status': 'Expédié',
      'date': '2024-01-15',
      'total': 120000.0,
      'producerName': 'Ali Touré',
      'productName': 'Orange',
      'productImage': null,
      'quantity': 3,
      'unitPrice': 40000.0,
    },
    {
      'id': '12346',
      'client': 'Fatou Diallo',
      'status': 'En attente',
      'date': '2024-01-16',
      'total': 8500.0,
      'producerName': 'Fatou Diallo',
      'productName': 'Tomate',
      'productImage': null,
      'quantity': 2,
      'unitPrice': 4250.0,
    },
    {
      'id': '12347',
      'client': 'Moussa Keita',
      'status': 'Livrée',
      'date': '2024-01-17',
      'total': 15200.0,
      'producerName': 'Moussa Keita',
      'productName': 'Riz',
      'productImage': null,
      'quantity': 1,
      'unitPrice': 15200.0,
    },
    {
      'id': '12348',
      'client': 'Aminata Traoré',
      'status': 'Livrée',
      'date': '2024-01-18',
      'total': 9800.0,
      'producerName': 'Aminata Traoré',
      'productName': 'Mangue',
      'productImage': null,
      'quantity': 5,
      'unitPrice': 1960.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const EnteteWidget(),
        body: Column(
          children: [
            _buildFilterTabs(),
            Expanded(
              child: _buildOrdersList(),
            ),
          ],
        ),
      );
    } else {
      return Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildFilterTabs(),
            Expanded(
              child: _buildOrdersList(),
            ),
          ],
        ),
      );
    }
  }

  // Construit les onglets de filtrage
  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildFilterTab('Tous', _selectedFilter == 'Tous'),
          const SizedBox(width: 8),
          _buildFilterTab('En attente', _selectedFilter == 'En attente'),
          const SizedBox(width: 8),
          _buildFilterTab('Livrées', _selectedFilter == 'Livrées'),
        ],
      ),
    );
  }

  // Construit un onglet de filtre
  Widget _buildFilterTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFB662F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFB662F) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Construit la liste des commandes
  Widget _buildOrdersList() {
    // Filtrer les commandes selon le filtre sélectionné
    List<Map<String, dynamic>> filteredOrders = _orders.where((order) {
      if (_selectedFilter == 'Tous') return true;
      if (_selectedFilter == 'En attente') return order['status'] == 'En attente';
      if (_selectedFilter == 'Livrées') return order['status'] == 'Livrée';
      return true;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  // Construit une carte de commande
  Widget _buildOrderCard(Map<String, dynamic> order) {
    return GestureDetector(
      onTap: () {
        // Navigation vers la page de détail de la commande
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailPage(
              orderId: order['id'],
              client: order['client'],
              status: order['status'],
              total: order['total'],
              date: order['date'],
              producerName: order['producerName'],
              productName: order['productName'],
              productImage: order['productImage'],
              quantity: order['quantity'],
              unitPrice: order['unitPrice'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Commande n°${order['id']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility, color: Colors.grey),
                        onPressed: () {
                          // Navigation vers la page de détail de la commande
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailPage(
                                orderId: order['id'],
                                client: order['client'],
                                status: order['status'],
                                total: order['total'],
                                date: order['date'],
                                producerName: order['producerName'],
                                productName: order['productName'],
                                productImage: order['productImage'],
                                quantity: order['quantity'],
                                unitPrice: order['unitPrice'],
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () {
                          // Supprimer la commande
                          _showDeleteDialog(order['id']);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Client: ${order['client']}',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: order['status'] == 'Livrée' 
                          ? const Color(0xFFFB662F) 
                          : Colors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      order['status'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '${order['total'].toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Affiche une boîte de dialogue de confirmation de suppression
  void _showDeleteDialog(String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer la commande'),
          content: const Text('Êtes-vous sûr de vouloir supprimer cette commande ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _orders.removeWhere((order) => order['id'] == orderId);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Commande supprimée')),
                );
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Construit la barre de navigation inférieure
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 2, // Index pour "Commandes"
      selectedItemColor: const Color(0xFFFB662F),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Produits',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Commandes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      onTap: (index) {
        // Navigation vers les différentes pages
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/consumer');
            break;
          case 1:
            Navigator.pushNamed(context, '/consumer/catalog');
            break;
          case 2:
            // Déjà sur la page des commandes
            break;
          case 3:
            // Navigation vers le profil
            break;
        }
      },
    );
  }
}