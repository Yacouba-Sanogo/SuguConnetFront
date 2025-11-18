import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';

class StockManagementScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const StockManagementScreen({super.key, this.initialTabIndex = 0});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  
  // Données de démonstration
  final List<Map<String, dynamic>> _allProducts = [
    {
      'name': 'Tomates fraîches',
      'price': '5000',
      'stock': 150,
      'minStock': 50,
      'unit': 'Kg',
      'category': 'Légumes',
      'status': 'stock_normal',
      'image': 'assets/images/carottes.png',
      'lastUpdated': 'Aujourd\'hui',
      'isBio': true,
    },
    {
      'name': 'Carottes bio',
      'price': '3500',
      'stock': 8,
      'minStock': 50,
      'unit': 'Kg',
      'category': 'Légumes',
      'status': 'stock_low',
      'image': 'assets/images/carottes.png',
      'lastUpdated': 'Hier',
      'isBio': true,
    },
    {
      'name': 'Oignons',
      'price': '2000',
      'stock': 0,
      'minStock': 30,
      'unit': 'Kg',
      'category': 'Légumes',
      'status': 'stock_empty',
      'image': 'assets/images/Oignons.png',
      'lastUpdated': 'Il y a 2 jours',
      'isBio': false,
    },
    {
      'name': 'Mangues',
      'price': '8000',
      'stock': 200,
      'minStock': 30,
      'unit': 'Carton',
      'category': 'Fruits',
      'status': 'stock_normal',
      'image': 'assets/images/pommes.png',
      'lastUpdated': 'Aujourd\'hui',
      'isBio': true,
    },
    {
      'name': 'Riz local',
      'price': '12000',
      'stock': 75,
      'minStock': 25,
      'unit': 'Sac',
      'category': 'Céréales',
      'status': 'stock_normal',
      'image': 'assets/images/Cereales.svg',
      'lastUpdated': 'Aujourd\'hui',
      'isBio': false,
    },
    {
      'name': 'Piment rouge',
      'price': '6000',
      'stock': 12,
      'minStock': 20,
      'unit': 'Kg',
      'category': 'Epices',
      'status': 'stock_low',
      'image': 'assets/images/Oignons.png',
      'lastUpdated': 'Hier',
      'isBio': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    String selectedStatus = _getStatusForTab(_tabController.index);
    
    return _allProducts.where((product) {
      final matchesStatus = selectedStatus == 'all' || product['status'] == selectedStatus;
      final matchesSearch = _searchQuery.isEmpty || 
          product['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  String _getStatusForTab(int index) {
    switch (index) {
      case 0: return 'all';
      case 1: return 'stock_normal';
      case 2: return 'stock_low';
      case 3: return 'stock_empty';
      default: return 'all';
    }
  }

  int get _totalStockValue => _allProducts.fold<int>(0, (sum, p) => sum + (p['stock'] as int) * int.parse(p['price']));
  int get _lowStockCount => _allProducts.where((p) => p['status'] == 'stock_low').length;
  int get _emptyStockCount => _allProducts.where((p) => p['status'] == 'stock_empty').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              floating: true,
              pinned: true,
              backgroundColor: AppTheme.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.inventory_2,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Gestion des Stocks',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${_allProducts.length} produits',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Statistiques rapides
            _buildStatisticsBar(),
            
            // Barre de recherche
            _buildSearchBar(),
            
            // Onglets
            _buildTabs(),
            
            // Liste des produits
            Expanded(
              child: _filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(_filteredProducts[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStockDialog,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter Stock',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatisticsBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total',
              '${_totalStockValue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} fcfa',
              Icons.attach_money,
              Colors.blue,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildStatItem(
              'Stock faible',
              _lowStockCount.toString(),
              Icons.warning,
              Colors.orange,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          Expanded(
            child: _buildStatItem(
              'Épuisé',
              _emptyStockCount.toString(),
              Icons.error,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Rechercher un produit...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: TabBar(
        controller: _tabController,
        onTap: (index) => setState(() {}),
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 3,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        tabs: const [
          Tab(text: 'Tous'),
          Tab(text: 'En stock'),
          Tab(text: 'Stock faible'),
          Tab(text: 'Épuisé'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucun produit',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, int index) {
    Color statusColor = _getStatusColor(product['status']);
    IconData statusIcon = _getStatusIcon(product['status']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showProductDetails(product),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Statut
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              
              // Icône de statut
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),
              const SizedBox(width: 12),
              
              // Informations
              Expanded(
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
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.eco, size: 12, color: Colors.green.shade700),
                                const SizedBox(width: 2),
                                Text(
                                  'Bio',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stock: ${product['stock']} ${product['unit']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      'Min: ${product['minStock']} ${product['unit']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Prix et actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product['price']} fcfa',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.add,
                        color: AppTheme.primaryColor,
                        onTap: () => _showAddStockDialog(product),
                      ),
                      const SizedBox(width: 4),
                      _buildActionButton(
                        icon: Icons.remove,
                        color: Colors.grey.shade600,
                        onTap: () => _showRemoveStockDialog(product),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'stock_normal':
        return const Color(0xFF4CAF50);
      case 'stock_low':
        return Colors.orange;
      case 'stock_empty':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'stock_normal':
        return Icons.check_circle;
      case 'stock_low':
        return Icons.warning;
      case 'stock_empty':
        return Icons.error;
      default:
        return Icons.help;
    }
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

  void _showProductDetails(Map<String, dynamic> product) {
    final minStockController = TextEditingController(text: product['minStock'].toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Expanded(child: Text('Détails du produit')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Nom', product['name']),
              _buildDetailRow('Prix', '${product['price']} fcfa'),
              _buildDetailRow('Stock actuel', '${product['stock']} ${product['unit']}'),
              const SizedBox(height: 8),
              Text(
                'Stock minimum d\'alerte',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: minStockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Quantité minimum',
                  prefixIcon: const Icon(Icons.warning_amber, color: Colors.orange),
                  suffix: Text(product['unit'], style: TextStyle(color: Colors.grey.shade600)),
                  border: const OutlineInputBorder(),
                  helperText: 'Alerte quand le stock atteint cette quantité',
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Catégorie', product['category']),
              _buildDetailRow('Type', product['isBio'] ? 'Bio' : 'Conventionnel'),
              _buildDetailRow('Dernière mise à jour', product['lastUpdated']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              final newMinStock = int.tryParse(minStockController.text);
              if (newMinStock != null && newMinStock >= 0) {
                setState(() {
                  product['minStock'] = newMinStock;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Stock minimum mis à jour à ${newMinStock} ${product['unit']}'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer un nombre valide'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStockDialog([Map<String, dynamic>? product]) {
    final qtyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ajouter au stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (product != null)
              Text('Produit: ${product['name']}'),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantité à ajouter',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Stock ajouté avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _showRemoveStockDialog(Map<String, dynamic> product) {
    final qtyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Retirer du stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Produit: ${product['name']}'),
            Text('Stock actuel: ${product['stock']} ${product['unit']}'),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantité à retirer',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Stock retiré avec succès'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }
}
