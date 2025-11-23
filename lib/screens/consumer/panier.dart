import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/order_service.dart'; // Ajout de l'import du service de commande
import 'notifications_page.dart';
import 'payment_page.dart';
import '../../widgets/entete_widget.dart';
import '../../widgets/bottom_navigation_bar_widget.dart';
import '../../widgets/quantity_selector.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/network_image_with_fallback.dart';
import 'main_screen.dart';
import 'dart:ui';

// La page du panier
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ApiService _apiService = ApiService();

  // Contenu du panier côté mobile (rempli depuis le backend)
  List<Map<String, dynamic>> _cartItems = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger le panier chaque fois que la page devient active
    _loadCart();
  }

  // Calcule le total des articles sélectionnés
  double _calculateTotal() {
    double total = 0;
    for (var item in _cartItems) {
      if (item['isSelected']) {
        total += item['price'] * item['quantity'];
      }
    }
    return total;
  }

  // Fonction pour mettre à jour la quantité d'un produit dans le panier
  void _updateQuantity(int index, int change) async {
    try {
      final item = _cartItems[index];
      final newQuantity = item['quantity'] + change;

      // Ne pas permettre une quantité négative ou nulle
      if (newQuantity <= 0) {
        // Retirer le produit du panier
        await _removeFromCart(index);
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez vous connecter'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Mettre à jour la quantité dans le backend
      final response = await _apiService.post(
        '/consommateur/$userId/panier/ajouter/${item['id']}',
        queryParameters: {'quantite': newQuantity},
      );

      if (response.statusCode == 200) {
        // Mettre à jour l'interface utilisateur
        setState(() {
          _cartItems[index]['quantity'] = newQuantity;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quantité mise à jour'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(
            'Erreur lors de la mise à jour: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la quantité: $e');
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

  // Fonction pour retirer un produit du panier
  Future<void> _removeFromCart(int index) async {
    try {
      final item = _cartItems[index];

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez vous connecter'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Retirer le produit du panier dans le backend
      final response = await _apiService.delete(
        '/consommateur/$userId/panier/retirer/${item['id']}',
      );

      if (response.statusCode == 200) {
        // Mettre à jour l'interface utilisateur
        setState(() {
          _cartItems.removeAt(index);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${item['name']} retiré du panier'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Erreur lors du retrait: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors du retrait du produit: $e');
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

  void _toggleSelection(int index) {
    setState(() {
      _cartItems[index]['isSelected'] = !_cartItems[index]['isSelected'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: const EnteteWidget(),
      body: _buildBody(),
      floatingActionButton: SizedBox(
        width: 72,
        height: 72,
        child: FloatingActionButton(
          onPressed: () {
            // Le panier est déjà ouvert, donc on peut fermer ou ne rien faire
            // Ou naviguer vers MainScreen
            Navigator.pop(context);
          },
          backgroundColor: const Color(0xFFFB662F),
          elevation: 8,
          shape: const CircleBorder(side: BorderSide(color: Colors.white, width: 6)),
          child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBarWidget(
        onTap: (index) {
          // Navigation vers MainScreen avec l'index approprié
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScreen(initialIndex: index),
            ),
          );
        },
      ),
    );
  }


  Future<void> _loadCart() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      print('ID utilisateur: $userId');

      if (userId == null) {
        print('Utilisateur non connecté');
        setState(() {
          _cartItems = [];
          _loading = false;
          _error = null;
        });
        return;
      }

      // Vérifier si le service API a un token
      final apiService = ApiService();
      print('API Service authentifié: ${apiService.isAuthenticated}');

      print('Chargement du panier pour l\'utilisateur: $userId');

      final response = await apiService.get<Map<String, dynamic>>(
        '/consommateur/$userId/panier',
      );

      print('Réponse du panier - Status: ${response.statusCode}');
      print('Réponse du panier - Data: ${response.data}');
      print('Réponse du panier - Type: ${response.data.runtimeType}');

      // Vérifier si la réponse est valide
      if (response.statusCode != 200 || response.data == null) {
        print('Réponse invalide du panier - Status: ${response.statusCode}');
        setState(() {
          _cartItems = [];
          _loading = false;
          _error = null;
        });
        return;
      }

      final data = response.data!;
      print('Données du panier: $data');

      // On s'attend à ce que le panier contienne une liste "panierProduits"
      final panierProduits = data['panierProduits'];
      print('PanierProduits: $panierProduits');
      print('Type de panierProduits: ${panierProduits.runtimeType}');

      if (panierProduits is! List) {
        print('panierProduits n\'est pas une liste');
        setState(() {
          _cartItems = [];
          _loading = false;
          _error = null;
        });
        return;
      }

      print('Nombre de produits dans le panier: ${panierProduits.length}');

      // Créer une liste pour stocker les éléments avec images
      List<Map<String, dynamic>> items = [];

      // Traiter chaque produit du panier
      for (int i = 0; i < panierProduits.length; i++) {
        final raw = panierProduits[i];
        print('Traitement du produit du panier: $raw');
        print('Type du produit du panier: ${raw.runtimeType}');

        if (raw is! Map<String, dynamic>) {
          print('Le produit du panier n\'est pas un Map<String, dynamic>');
          continue;
        }

        final pp = raw;
        final produit = (pp['produit'] ?? {}) as Map<String, dynamic>;
        print('Produit: $produit');

        // Correction: Vérifier le type avant le cast
        final producteurRaw = produit['producteur'] ?? {};
        final Map<String, dynamic> producteur =
            producteurRaw is Map<String, dynamic>
                ? producteurRaw
                : (producteurRaw is Map
                    ? Map<String, dynamic>.from(producteurRaw)
                    : <String, dynamic>{});
        print('Producteur: $producteur');

        // Normaliser prix et quantite (peuvent arriver en String ou num)
        final dynamic rawPrix =
            pp['prixUnitaire'] ?? produit['prixUnitaire'] ?? 0;
        double price;
        if (rawPrix is num) {
          price = rawPrix.toDouble();
        } else {
          price = double.tryParse(rawPrix.toString()) ?? 0.0;
        }
        print('Prix: $price');

        final dynamic rawQuantite = pp['quantite'] ?? 1;
        int quantity;
        if (rawQuantite is num) {
          quantity = rawQuantite.toInt();
        } else {
          quantity = int.tryParse(rawQuantite.toString()) ?? 1;
        }
        print('Quantité: $quantity');

        // Extraction améliorée de l'URL de l'image
        String imageUrl = '';
        try {
          print(
              'Recherche d\'images pour le produit: ${produit['nom']} (ID: ${produit['id']})');

          // Méthode 1: Vérifier le tableau photos dans le produit
          final photos = produit['photos'];
          print('Photos dans produit: $photos');

          if (photos != null) {
            if (photos is List && photos.isNotEmpty) {
              final firstPhoto = photos.first;
              print('Première photo: $firstPhoto');

              if (firstPhoto is String) {
                imageUrl = firstPhoto;
              } else if (firstPhoto is Map) {
                // Essayer différentes clés possibles
                imageUrl = (firstPhoto['url'] ??
                        firstPhoto['lien'] ??
                        firstPhoto['imageUrl'] ??
                        firstPhoto['image'] ??
                        '')
                    .toString();
              }
            }
            // Si photos n'est pas une liste mais une chaîne
            else if (photos is String) {
              imageUrl = photos;
            }
          }

          // Méthode 2: Vérifier si le produit lui-même contient des champs image
          if (imageUrl.isEmpty) {
            print('Recherche d\'images dans les champs du produit');
            final imageFields = [
              produit['imageUrl'],
              produit['image'],
              produit['photoUrl'],
              produit['photo']
            ];

            for (final field in imageFields) {
              if (field != null) {
                if (field is String && field.isNotEmpty) {
                  imageUrl = field;
                  print('Image trouvée dans champ: $field');
                  break;
                } else if (field is Map) {
                  imageUrl = (field['url'] ?? field['lien'] ?? '').toString();
                  print('Image trouvée dans map: $imageUrl');
                  break;
                }
              }
            }
          }

          // Méthode 3: Vérifier dans les données du panierProduit
          if (imageUrl.isEmpty) {
            print('Recherche d\'images dans panierProduit');
            final ppPhotos = pp['photos'];
            if (ppPhotos != null && ppPhotos is List && ppPhotos.isNotEmpty) {
              final firstPhoto = ppPhotos.first;
              if (firstPhoto is String) {
                imageUrl = firstPhoto;
              } else if (firstPhoto is Map) {
                imageUrl =
                    (firstPhoto['url'] ?? firstPhoto['lien'] ?? '').toString();
              }
            }
          }

          // Méthode 4: Vérifier les champs image dans panierProduit
          if (imageUrl.isEmpty) {
            final ppImageFields = [
              pp['imageUrl'],
              pp['image'],
              pp['photoUrl'],
              pp['photo']
            ];

            for (final field in ppImageFields) {
              if (field != null) {
                if (field is String && field.isNotEmpty) {
                  imageUrl = field;
                  break;
                } else if (field is Map) {
                  imageUrl = (field['url'] ?? field['lien'] ?? '').toString();
                  break;
                }
              }
            }
          }

          // Méthode 5 (solution de secours): Faire une requête pour obtenir les détails complets du produit
          if (imageUrl.isEmpty) {
            print(
                'Aucune image trouvée, tentative de récupération via API produit');
            try {
              final productId = produit['id'] as int?;
              if (productId != null) {
                final productResponse =
                    await apiService.get<Map<String, dynamic>>(
                  '/api/produits/$productId',
                );

                if (productResponse.statusCode == 200 &&
                    productResponse.data != null) {
                  final productData = productResponse.data!;
                  print('Détails du produit récupérés: $productData');

                  // Extraire les photos des détails du produit
                  final productPhotos = productData['photos'];
                  if (productPhotos != null &&
                      productPhotos is List &&
                      productPhotos.isNotEmpty) {
                    final firstPhoto = productPhotos.first;
                    if (firstPhoto is String) {
                      imageUrl = firstPhoto;
                    } else if (firstPhoto is Map) {
                      imageUrl = (firstPhoto['url'] ?? firstPhoto['lien'] ?? '')
                          .toString();
                    }
                  }

                  // Si toujours pas d'image, vérifier les autres champs
                  if (imageUrl.isEmpty) {
                    final productImageFields = [
                      productData['imageUrl'],
                      productData['image'],
                      productData['photoUrl'],
                      productData['photo']
                    ];

                    for (final field in productImageFields) {
                      if (field != null) {
                        if (field is String && field.isNotEmpty) {
                          imageUrl = field;
                          break;
                        } else if (field is Map) {
                          imageUrl =
                              (field['url'] ?? field['lien'] ?? '').toString();
                          break;
                        }
                      }
                    }
                  }

                  // Si toujours pas d'image, essayer de construire à partir du nom du produit
                  if (imageUrl.isEmpty) {
                    // Essayer de construire une URL à partir du nom du produit
                    final productName = productData['nom'] as String?;
                    if (productName != null) {
                      // Cette approche dépend de votre structure de stockage d'images
                      // Vous pouvez adapter cette logique selon votre backend
                      final sanitizedName = productName
                          .toLowerCase()
                          .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
                          .replaceAll(RegExp(r'\s+'), '_');
                      imageUrl = '$sanitizedName.jpg';
                    }
                  }
                }
              }
            } catch (e) {
              print(
                  'Erreur lors de la récupération des détails du produit: $e');
            }
          }
        } catch (e) {
          print('Erreur lors de l\'extraction de l\'image: $e');
          imageUrl = '';
        }

        print('Image URL finale pour ${produit['nom']}: $imageUrl');

        items.add(<String, dynamic>{
          'id': produit['id'] ?? pp['id'] ?? 0,
          'name': produit['nom'] ?? 'Produit',
          'producer': producteur['nomEntreprise'] ??
              ((producteur['prenom'] ?? '') + ' ' + (producteur['nom'] ?? '')),
          'price': price,
          'image': imageUrl,
          'quantity': quantity,
          'isSelected': true,
        });
      }

      print('Produits transformés: $items');

      setState(() {
        _cartItems = items;
        _loading = false;
        _error = null;
      });
    } catch (e, stackTrace) {
      print('Erreur lors du chargement du panier: $e');
      print('Stack trace: $stackTrace');

      // Si le backend renvoie 404 "Le panier est vide", on affiche simplement le panier vide
      setState(() {
        _cartItems = [];
        _loading = false;
        _error = null;
      });
    }
  }

  // Construit le corps de la page
  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    if (_cartItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Votre panier est vide',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              return _buildCartItem(_cartItems[index], index);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
        ),
        _buildTotalSection(),
        _buildCheckoutButton(),
        const SizedBox(height: 80), // Espace pour la barre de navigation
      ],
    );
  }

  // Widget pour un article du panier
  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleSelection(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    item['isSelected'] ? Colors.deepOrange : Colors.transparent,
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: item['isSelected']
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: NetworkImageWithFallback(
              imagePath: item['image'] as String?,
              width: 48,
              height: 48,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Producteur : ${item['producer']}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                    '${(item['price'] as num).toDouble().toStringAsFixed(0)} fcfa',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          QuantitySelector(
            quantity: _cartItems[index]['quantity'] as int,
            onDecrement: () => _updateQuantity(index, -1),
            onIncrement: () => _updateQuantity(index, 1),
            color: Colors.deepOrange,
          ),
        ],
      ),
    );
  }



  // Widget pour la section du total
  Widget _buildTotalSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('Total : ',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
              Text(
                '${_calculateTotal().toStringAsFixed(0)} fcfa',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget pour le bouton "Acheter"
  Widget _buildCheckoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: PrimaryButton(
        text: 'Passer la commande',
        onPressed: () {
          // Navigation vers la page de paiement
          print('Bouton de paiement cliqué'); // Debug

          // Créer une vraie commande avant de procéder au paiement
          _placeOrderAndProceedToPayment();
        },
        height: 50,
        fontSize: 18,
      ),
    );
  }

  // Fonction pour créer une commande et procéder au paiement
  Future<void> _placeOrderAndProceedToPayment() async {
    try {
      // Vérifier l'authentification
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez vous connecter pour passer une commande'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Vérifier qu'il y a des articles sélectionnés
      final selectedItems =
          _cartItems.where((item) => item['isSelected']).toList();
      if (selectedItems.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez sélectionner au moins un article'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Créer la commande
      final orderService = OrderService();

      // Préparer les données des produits
      final products = selectedItems.map((item) {
        return {
          'produitId': item['id'],
          'quantite': item['quantity'],
        };
      }).toList();

      print('Création de commande avec produits: $products');

      // Passer la commande
      final orderData = await orderService.placeDirectOrder(
        consumerId: authProvider.currentUser!.id!,
        products: products,
        paymentMethod:
            'ORANGE_MONEY', // Valeur par défaut, peut être changée dans la page de paiement
      );

      print('Commande créée avec succès: $orderData');

      // Préparer les données pour la page de paiement
      final paymentOrderData = {
        'orderId': int.tryParse(orderData['idCommande'].toString()) ?? 1,
        'amount': _calculateTotal(),
        'consumerId': authProvider.currentUser!.id!,
        'items': selectedItems.map((item) {
          return {
            'id': item['id'],
            'name': item['name'],
            'price': item['price'],
            'quantity': item['quantity'],
            'image': item['image'] ?? '', // Ajouter l'URL de l'image
          };
        }).toList(),
      };

      print('Données de paiement préparées: $paymentOrderData');

      // Naviguer vers la page de paiement
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentPage(orderData: paymentOrderData),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Erreur lors de la création de la commande: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erreur lors de la création de la commande: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
