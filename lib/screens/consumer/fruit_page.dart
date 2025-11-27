import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'detaille_produit.dart';
// We avoid strict Produit deserialization here because the public consumer
// endpoint may return different shapes. We'll map into a light view model.
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart'; // Ajout de l'import

// Page réutilisable pour une catégorie (Fruits, Céréales, Légumes, Épices...)
class FruitPage extends StatefulWidget {
  final String title;
  final String headerImage; // chemin local ou URL

  const FruitPage({Key? key, required this.title, required this.headerImage})
      : super(key: key);

  @override
  State<FruitPage> createState() => _FruitPageState();
}

class _FruitPageState extends State<FruitPage> {
  final ApiService _apiService = ApiService();
  final ProductService _productService =
      ProductService(); // Ajout du service produit

  List<_ConsumerProduct> _allProducts = [];
  List<_ConsumerProduct> _filteredProducts = [];
  String? _selectedFilter = 'Tous';
  List<String> _filters = ['Tous'];
  bool _loading = true;
  String? _error;
  final Set<int> _favoriteIds = {};
  // Advanced filters
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedLocality;
  String? _selectedUnit;
  double? _minPrice;
  double? _maxPrice;
  double? _dataMinPrice;
  double? _dataMaxPrice;
  Set<String> _allLocalities = {};
  Set<String> _allUnits = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _loading = true);

      // Récupérer les produits par catégorie depuis le backend
      final resp =
          await _apiService.get<List<dynamic>>('/consommateur/produits');
      dynamic rawData = resp.data;
      List<dynamic> list;
      if (rawData is List) {
        list = rawData;
      } else if (rawData is Map<String, dynamic>) {
        final m = rawData;
        final extracted = m['content'] ??
            m['items'] ??
            m['data'] ??
            m['results'] ??
            m['list'];
        if (extracted is List) {
          list = extracted;
        } else {
          list = [];
        }
      } else {
        list = [];
      }

      final mapped = list.map<_ConsumerProduct>((raw) {
        final m = raw as Map<String, dynamic>;
        final cat = m['categorie'] is Map
            ? (m['categorie']['nom'] ?? '').toString()
            : (m['categorie'] ?? '').toString();
        final producteur = m['producteur'] as Map<String, dynamic>?;
        final nomProd = producteur != null
            ? ((producteur['nomEntreprise'] ??
                    ((producteur['prenom'] ?? '') +
                        ' ' +
                        (producteur['nom'] ?? '')))
                .toString())
            : (m['nomProducteur'] ?? 'Producteur').toString();
        // Extraire l'ID du producteur
        int? producerId;
        if (producteur != null && producteur['id'] != null) {
          producerId = (producteur['id'] as num).toInt();
        } else if (m['producteurId'] != null) {
          producerId = (m['producteurId'] as num).toInt();
        }
        final localite = (m['localite'] ??
                m['localité'] ??
                producteur?[r'localite'] ??
                producteur?[r'localité'] ??
                'Local')
            .toString();
        double? price;
        final p = m['prix'] ?? m['prixUnitaire'];
        if (p is num) price = p.toDouble();
        int stock = 0;
        final qs = m['quantiteStock'] ?? m['quantite'] ?? m['stockDisponible'];
        if (qs is num) stock = qs.toInt();
        return _ConsumerProduct(
          id: (m['id'] ?? 0) is num ? (m['id'] as num).toInt() : 0,
          name: (m['nom'] ?? m['name'] ?? 'Produit').toString(),
          unit: (m['uniteMesure'] ?? m['unite'] ?? '').toString(),
          price: price,
          image:
              (m['imageUrl'] ?? m['image'] ?? m['photoUrl'] ?? m['photo'] ?? '')
                  .toString(),
          available: stock > 0 || (m['disponible'] ?? true) == true,
          category: cat,
          producerName: nomProd,
          producerId: producerId,
          description: (m['description'] ?? '').toString(),
          locality: localite,
        );
      }).toList();

      // Fonction utilitaire pour normaliser les chaînes (minuscules + enlever accents)
      String _normalize(String s) {
        final lower = s.toLowerCase();
        return lower
            .replaceAll(RegExp('[éèêë]'), 'e')
            .replaceAll(RegExp('[àâä]'), 'a')
            .replaceAll(RegExp('[îïìí]'), 'i')
            .replaceAll(RegExp('[ôöòó]'), 'o')
            .replaceAll(RegExp('[ûüùú]'), 'u');
      }

      // Filtrage strict par catégorie basée sur le titre de la page
      final titleNorm = _normalize(widget.title);
      bool matchGroup(_ConsumerProduct p) {
        final catNorm = _normalize(p.category);

        if (titleNorm.contains('fruit')) {
          return catNorm.contains('fruit');
        }
        if (titleNorm.contains('leg') || titleNorm.contains('legume')) {
          return catNorm.contains('leg') || catNorm.contains('legume');
        }
        if (titleNorm.contains('cere')) {
          return catNorm.contains('cere') || catNorm.contains('cereal');
        }
        if (titleNorm.contains('epic')) {
          return catNorm.contains('epic');
        }
        // Par défaut, si aucune catégorie spécifique trouvée, on accepte tout
        return true;
      }

      // Ne conserver que les produits correspondant à la catégorie de la page
      _allProducts = mapped.where(matchGroup).toList();

      // Créer les filtres dynamiques à partir des catégories de produits
      final cats = _allProducts.map((p) => p.category).toSet().toList()..sort();
      _filters = ['Tous', ...cats];

      // collect locality + units + price bounds
      _allLocalities = _allProducts
          .map((e) => e.locality)
          .where((e) => e != null && e.trim().isNotEmpty)
          .map((e) => e!.trim())
          .toSet();
      _allUnits = _allProducts
          .map((e) => e.unit ?? '')
          .where((e) => e.trim().isNotEmpty)
          .toSet();
      final prices =
          _allProducts.map((e) => e.price).whereType<double>().toList();
      prices.sort();
      _dataMinPrice = prices.isNotEmpty ? prices.first : null;
      _dataMaxPrice = prices.isNotEmpty ? prices.last : null;
      _minPrice = _dataMinPrice;
      _maxPrice = _dataMaxPrice;
      _applyAllFilters();
      setState(() {
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  // Fonction pour filtrer les produits
  void _filterProducts(String filter) {
    setState(() {
      _selectedFilter = filter;
      _applyAllFilters();
    });
  }

  void _applyAllFilters() {
    Iterable<_ConsumerProduct> res = _allProducts;
    // category chip
    if (_selectedFilter != null && _selectedFilter != 'Tous') {
      res = res.where((p) => p.category == _selectedFilter);
    }
    // search by name
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      res = res.where((p) => p.name.toLowerCase().contains(q));
    }
    // by locality
    if (_selectedLocality != null && _selectedLocality!.isNotEmpty) {
      res = res.where((p) =>
          (p.locality ?? '').toLowerCase() == _selectedLocality!.toLowerCase());
    }
    // by unit
    if (_selectedUnit != null && _selectedUnit!.isNotEmpty) {
      res = res.where(
          (p) => (p.unit ?? '').toLowerCase() == _selectedUnit!.toLowerCase());
    }
    // by price range (only if user changed from defaults)
    final bool priceFilterActive = _minPrice != null &&
        _maxPrice != null &&
        (_minPrice != _dataMinPrice || _maxPrice != _dataMaxPrice);
    if (priceFilterActive) {
      res = res.where((p) {
        final pr = p.price;
        if (pr == null) return false;
        if (_minPrice != null && pr < _minPrice!) return false;
        if (_maxPrice != null && pr > _maxPrice!) return false;
        return true;
      });
    }
    _filteredProducts = res.toList();
  }

  // Fonction pour basculer l'état de favori
  void _toggleFavorite(int id) {
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeaderImage()),
          SliverToBoxAdapter(child: _buildFilterChips()),
          _buildProductGrid(),
        ],
      ),
      // This page does not provide its own BottomNavigationBar: the app's main
      // BottomNavigationBar (in MainScreen) must remain the single primary one.
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        controller: _searchCtrl,
        onChanged: (v) {
          _searchQuery = v;
          setState(_applyAllFilters);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black54),
          onPressed: _openFilterDialog,
        ),
      ],
    );
  }

  void _openFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String? tempLocality = _selectedLocality;
        String? tempUnit = _selectedUnit;
        double tempMin = _minPrice ?? _dataMinPrice ?? 0;
        double tempMax = _maxPrice ?? _dataMaxPrice ?? 0;
        return StatefulBuilder(builder: (ctx, setSt) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filtres avancés',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                const Text('Localité'),
                DropdownButton<String>(
                  value: tempLocality,
                  isExpanded: true,
                  hint: const Text('Toutes'),
                  items: [
                    const DropdownMenuItem<String>(
                        value: null, child: Text('Toutes')),
                    ..._allLocalities.map((l) =>
                        DropdownMenuItem<String>(value: l, child: Text(l)))
                  ],
                  onChanged: (v) => setSt(() => tempLocality = v),
                ),
                const SizedBox(height: 8),
                const Text('Unité'),
                DropdownButton<String>(
                  value: tempUnit,
                  isExpanded: true,
                  hint: const Text('Toutes'),
                  items: [
                    const DropdownMenuItem<String>(
                        value: null, child: Text('Toutes')),
                    ..._allUnits.map((u) =>
                        DropdownMenuItem<String>(value: u, child: Text(u)))
                  ],
                  onChanged: (v) => setSt(() => tempUnit = v),
                ),
                const SizedBox(height: 8),
                const Text('Prix'),
                if ((_dataMinPrice ?? 0) < (_dataMaxPrice ?? 0))
                  RangeSlider(
                    values: RangeValues(tempMin, tempMax),
                    min: _dataMinPrice ?? 0,
                    max: _dataMaxPrice ?? 0,
                    divisions: 20,
                    labels: RangeLabels('${tempMin.toStringAsFixed(0)}',
                        '${tempMax.toStringAsFixed(0)}'),
                    onChanged: (vals) => setSt(() {
                      tempMin = vals.start;
                      tempMax = vals.end;
                    }),
                  )
                else
                  Text('Aucune borne de prix disponible'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedLocality = null;
                          _selectedUnit = null;
                          _minPrice = _dataMinPrice;
                          _maxPrice = _dataMaxPrice;
                          _applyAllFilters();
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Réinitialiser'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedLocality = tempLocality;
                          _selectedUnit = tempUnit;
                          _minPrice = tempMin;
                          _maxPrice = tempMax;
                          _applyAllFilters();
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text('Appliquer'),
                    ),
                  ],
                )
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildHeaderImage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 120,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // support SVG asset header, raster asset, or network image
              if (widget.headerImage.toLowerCase().endsWith('.svg'))
                Positioned.fill(
                  child: SvgPicture.asset(
                    widget.headerImage,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                  ),
                )
              else if (widget.headerImage.startsWith('http'))
                Positioned.fill(
                  child: Image.network(widget.headerImage, fit: BoxFit.cover),
                )
              else
                Positioned.fill(
                  child: Image.asset(widget.headerImage, fit: BoxFit.cover),
                ),
              // gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.35)
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black45,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addToCart(_ConsumerProduct product) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez vous connecter pour ajouter au panier'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await _apiService.post<String>(
        '/consommateur/$userId/panier/ajouter/${product.id}',
        queryParameters: {'quantite': 1},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} a été ajouté au panier'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout au panier: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: _selectedFilter == filter,
              onSelected: (selected) {
                if (selected) _filterProducts(filter);
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: Colors.deepOrange.shade100,
              labelStyle: TextStyle(
                color: _selectedFilter == filter
                    ? Colors.deepOrange
                    : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              shape:
                  StadiumBorder(side: BorderSide(color: Colors.grey.shade200)),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_loading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_error != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text('Erreur: $_error'),
              const SizedBox(height: 8),
              OutlinedButton(
                  onPressed: _loadData, child: const Text('Réessayer')),
            ],
          ),
        ),
      );
    }
    if (_filteredProducts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'Aucun produit disponible dans cette catégorie pour le moment.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _buildProductCard(_filteredProducts[index]);
          },
          childCount: _filteredProducts.length,
        ),
      ),
    );
  }

  Widget _buildProductCard(_ConsumerProduct product) {
    return InkWell(
      onTap: () {
        final productPayload = <String, String>{
          'id': '${product.id}',
          'name': product.name,
          'weight': product.unit ?? '',
          'price': product.price != null
              ? '${product.price!.toStringAsFixed(0)} fcfa'
              : '',
          'location': product.locality ?? 'Local',
          'image': product.image,
          'producerName': product.producerName,
          if (product.producerId != null) 'producerId': product.producerId.toString(),
          'producerAvatar': 'assets/images/improfil.png',
          'description': product.description ?? '',
        };
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: productPayload),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: _buildProductImage(product.image),
                  ),
                  // Bouton Favori
                  IconButton(
                    icon: Icon(
                      _favoriteIds.contains(product.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _favoriteIds.contains(product.id)
                          ? Colors.red
                          : Colors.white,
                    ),
                    onPressed: () => _toggleFavorite(product.id),
                  ),
                  // Bouton Ajouter
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.deepOrange),
                        onPressed: () => _addToCart(product),
                      ),
                    ),
                  ),
                  // Tag Indisponible
                  if (!product.available)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text('Indisponible',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('(${product.unit ?? ''})',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                      product.price != null
                          ? '${product.price!.toStringAsFixed(0)} fcfa'
                          : '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '📍 Local',
                      style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset('assets/images/pommes.png',
          width: double.infinity, fit: BoxFit.cover);
    }
    return FutureBuilder<String>(
      future: _apiService.buildImageUrl(imageUrl),
      builder: (context, snapshot) {
        final url = snapshot.data;
        if (url == null) {
          return Image.asset('assets/images/pommes.png',
              width: double.infinity, fit: BoxFit.cover);
        }
        return Image.network(
          url,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Image.asset('assets/images/pommes.png', fit: BoxFit.cover),
        );
      },
    );
  }

  // Note: this page intentionally does not provide a BottomNavigationBar so
  // the MainScreen's BottomNavigationBar remains the single source of truth.
}

class _ConsumerProduct {
  final int id;
  final String name;
  final String? unit;
  final double? price;
  final String image;
  final bool available;
  final String category;
  final String producerName;
  final int? producerId;
  final String? description;
  final String? locality;

  _ConsumerProduct({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.image,
    required this.available,
    required this.category,
    required this.producerName,
    this.producerId,
    required this.description,
    required this.locality,
  });
}
