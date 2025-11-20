import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../../models/stock_product.dart';
import '../../services/stock_service.dart';
import '../../providers/auth_provider.dart';

class StockManagementScreen extends StatefulWidget {
  final int initialTabIndex;

  const StockManagementScreen({super.key, this.initialTabIndex = 0});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final StockService _stockService = StockService();

  List<StockProduct> _allProducts = [];
  bool _isLoading = true;
  String? _error;

  int? _producteurId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _loadStockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStockData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Récupérer l'ID du producteur depuis le provider d'authentification
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser != null && currentUser.id != null) {
        _producteurId = currentUser.id;
        final products =
            await _stockService.getAllStockProducts(_producteurId!);

        setState(() {
          _allProducts = products;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Utilisateur non authentifié';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des données: $e';
        _isLoading = false;
      });
    }
  }

  List<StockProduct> get _filteredProductsList {
    String selectedStatus = _getStatusForTab(_tabController.index);

    List<StockProduct> filtered = _allProducts;

    // Appliquer la recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Appliquer le filtre par statut
    if (selectedStatus != 'all') {
      filtered = filtered
          .where((product) => product.status == selectedStatus)
          .toList();
    }

    return filtered;
  }

  String _getStatusForTab(int index) {
    switch (index) {
      case 0:
        return 'all';
      case 1:
        return 'en_stock';
      case 2:
        return 'stock_faible';
      case 3:
        return 'epuise';
      default:
        return 'all';
    }
  }

  Future<double> _getTotalStockValue() async {
    if (_producteurId == null) return 0.0;
    try {
      return await _stockService.getTotalStockValue(_producteurId!);
    } catch (e) {
      print('Erreur lors de la récupération de la valeur totale: $e');
      return 0.0;
    }
  }

  Future<int> _getLowStockCount() async {
    if (_producteurId == null) return 0;
    try {
      return await _stockService.getLowStockCount(_producteurId!);
    } catch (e) {
      print('Erreur lors de la récupération du stock faible: $e');
      return 0;
    }
  }

  Future<int> _getEmptyStockCount() async {
    if (_producteurId == null) return 0;
    try {
      return await _stockService.getOutOfStockCount(_producteurId!);
    } catch (e) {
      print('Erreur lors de la récupération du stock épuisé: $e');
      return 0;
    }
  }

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
              child: _buildProductList(),
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
    return FutureBuilder(
      future: Future.wait([
        _getTotalStockValue(),
        _getLowStockCount(),
        _getEmptyStockCount()
      ]).timeout(const Duration(seconds: 10), onTimeout: () {
        return [0.0, 0, 0];
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text('Erreur: ${snapshot.error}'),
          );
        }

        final data = snapshot.data as List;
        final totalValue = data[0] as double;
        final lowStockCount = data[1] as int;
        final emptyStockCount = data[2] as int;

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
                  '${totalValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} ',
                  Icons.currency_franc,
                  Colors.blue,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              Expanded(
                child: _buildStatItem(
                  'Stock faible',
                  lowStockCount.toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              Expanded(
                child: _buildStatItem(
                  'Épuisé',
                  emptyStockCount.toString(),
                  Icons.error,
                  Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

  Widget _buildProductList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStockData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final filteredProducts = _filteredProductsList;

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: Colors.grey.shade400),
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(filteredProducts[index]);
      },
    );
  }

  Widget _buildProductCard(StockProduct product) {
    Color statusColor = _getStatusColor(product.statusColor);
    IconData statusIcon = _getStatusIcon(product.status);

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
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (product.isBio)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.eco,
                                    size: 12, color: Colors.green.shade700),
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
                      'Stock: ${product.quantity} ${product.unit}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      'Min: ${product.minStockAlert} ${product.unit}',
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
                    '${product.price.toStringAsFixed(0)} fcfa',
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
                        onTap: () => _updateProductQuantity(
                            product, product.quantity + 1),
                      ),
                      const SizedBox(width: 4),
                      _buildActionButton(
                        icon: Icons.remove,
                        color: Colors.grey.shade600,
                        onTap: () => product.quantity > 0
                            ? _updateProductQuantity(
                                product, product.quantity - 1)
                            : null,
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

  Color _getStatusColor(String color) {
    switch (color) {
      case 'green':
        return const Color(0xFF4CAF50);
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'en_stock':
        return Icons.check_circle;
      case 'stock_faible':
        return Icons.warning;
      case 'epuise':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
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

  Future<void> _updateProductQuantity(
      StockProduct product, int newQuantity) async {
    if (_producteurId == null) return;

    try {
      final updatedProduct = await _stockService.updateProductQuantity(
          _producteurId!, product.id, newQuantity);

      // Mettre à jour la liste des produits
      setState(() {
        for (int i = 0; i < _allProducts.length; i++) {
          if (_allProducts[i].id == product.id) {
            _allProducts[i] = updatedProduct;
            break;
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock mis à jour avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du stock: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showProductDetails(StockProduct product) {
    final minStockController =
        TextEditingController(text: product.minStockAlert.toString());

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
              _buildDetailRow('Nom', product.name),
              _buildDetailRow('Description', product.description),
              _buildDetailRow(
                  'Prix', '${product.price.toStringAsFixed(0)} fcfa'),
              _buildDetailRow(
                  'Stock actuel', '${product.quantity} ${product.unit}'),
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
                  prefixIcon:
                      const Icon(Icons.warning_amber, color: Colors.orange),
                  suffix: Text(product.unit,
                      style: TextStyle(color: Colors.grey.shade600)),
                  border: const OutlineInputBorder(),
                  helperText: 'Alerte quand le stock atteint cette quantité',
                ),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('Catégorie', product.category),
              _buildDetailRow('Type', product.isBio ? 'Bio' : 'Conventionnel'),
              _buildDetailRow('Dernière mise à jour', product.lastUpdated),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_producteurId == null) {
                Navigator.pop(context);
                return;
              }

              final newMinStock = int.tryParse(minStockController.text);
              if (newMinStock != null && newMinStock >= 0) {
                try {
                  final updatedProduct =
                      await _stockService.updateMinStockAlert(
                          _producteurId!, product.id, newMinStock);

                  // Mettre à jour la liste des produits
                  setState(() {
                    for (int i = 0; i < _allProducts.length; i++) {
                      if (_allProducts[i].id == product.id) {
                        _allProducts[i] = updatedProduct;
                        break;
                      }
                    }
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Stock minimum mis à jour à ${newMinStock} ${product.unit}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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

  void _showAddStockDialog() {
    // Pour l'instant, afficher un message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité d\'ajout de stock à implémenter'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }
}
