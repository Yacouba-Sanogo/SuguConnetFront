import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'detaille_produit.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/product.dart';

// Page pour afficher les produits d'une catégorie spécifique
class CategoryProductsPage extends StatefulWidget {
  final Categorie category;
  final String headerImage;

  const CategoryProductsPage({
    Key? key,
    required this.category,
    required this.headerImage,
  }) : super(key: key);

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  final ApiService _apiService = ApiService();

  List<_ConsumerProduct> _allProducts = [];
  List<_ConsumerProduct> _filteredProducts = [];
  bool _loading = true;
  String? _error;
  final Set<int> _favoriteIds = {};

  // Filtres
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
      final resp = await _apiService.get<List<dynamic>>(
          '/consommateur/produits/categorie/${widget.category.id}');

      // Log pour déboguer les données brutes
      print('Données brutes reçues: ${resp.data}');

      final list = resp.data ?? [];

      final mapped = list.map<_ConsumerProduct>((raw) {
        final m = raw as Map<String, dynamic>;

        // Log pour déboguer chaque produit
        print('Produit brut: $m');

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

        // Extraction améliorée de l'URL de l'image
        String imageUrl = '';

        // Vérifier d'abord le tableau photos
        final photos = m['photos'] as List?;
        if (photos != null && photos.isNotEmpty) {
          final firstPhoto = photos.first;
          if (firstPhoto is String) {
            imageUrl = firstPhoto;
          } else if (firstPhoto is Map<String, dynamic>) {
            imageUrl =
                (firstPhoto['url'] ?? firstPhoto['lien'] ?? '').toString();
          }
        }
        // Sinon vérifier les autres champs
        else {
          final imageField =
              m['imageUrl'] ?? m['image'] ?? m['photoUrl'] ?? m['photo'];
          if (imageField != null) {
            if (imageField is String) {
              imageUrl = imageField;
            } else if (imageField is Map<String, dynamic>) {
              imageUrl =
                  (imageField['url'] ?? imageField['lien'] ?? '').toString();
            }
          }
        }

        // Log pour déboguer l'URL de l'image
        print('URL image pour ${m['nom']}: $imageUrl');

        return _ConsumerProduct(
          id: (m['id'] ?? 0) is num ? (m['id'] as num).toInt() : 0,
          name: (m['nom'] ?? m['name'] ?? 'Produit').toString(),
          unit: (m['uniteMesure'] ?? m['unite'] ?? '').toString(),
          price: price,
          image: imageUrl,
          available: stock > 0 || (m['disponible'] ?? true) == true,
          category: cat,
          producerName: nomProd,
          description: (m['description'] ?? '').toString(),
          locality: localite,
        );
      }).toList();

      _allProducts = mapped;

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

  void _applyAllFilters() {
    Iterable<_ConsumerProduct> res = _allProducts;
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
          _buildProductGrid(),
        ],
      ),
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedLocality = null;
                          _selectedUnit = null;
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
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
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
                  widget.category.nom,
                  style: const TextStyle(
                    fontFamily: "inter",
                    color: Colors.white,
                    fontSize: 50,
                    fontWeight: FontWeight.normal,
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

  // Fonction pour ajouter un produit au panier
  void _addToCart(_ConsumerProduct product) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez vous connecter pour ajouter au panier'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Ajouter le produit au panier avec une quantité de 1
      final response = await _apiService.post(
        '/consommateur/$userId/panier/ajouter/${product.id}',
        queryParameters: {'quantite': 1},
      );


      print(
          'Réponse d\'ajout au panier: ${response.statusCode} - ${response.data}');
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} ajouté au panier'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(
            'Erreur lors de l\'ajout au panier: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de l\'ajout au panier: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    // Si l'URL est vide ou null, afficher l'image par défaut
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset('assets/images/pommes.png',
          width: double.infinity, fit: BoxFit.cover);
    }

    // Utiliser l'API service pour construire l'URL complète de l'image
    return FutureBuilder<String>(
      future: _apiService.buildImageUrl(imageUrl),
      builder: (context, snapshot) {
        // En cas d'erreur ou d'URL non disponible, afficher l'image par défaut
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Image.asset('assets/images/pommes.png',
              width: double.infinity, fit: BoxFit.cover);
        }

        final url = snapshot.data!;
        return Image.network(
          url,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/pommes.png',
              width: double.infinity,
              fit: BoxFit.cover),
        );
      },
    );
  }
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
    required this.description,
    required this.locality,
  });
}
