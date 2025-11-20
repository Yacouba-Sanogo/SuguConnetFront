import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_product.dart';
import 'api_service.dart';

class StockService {
  final ApiService _apiService = ApiService();

  /// Récupérer tous les produits avec leurs informations de stock
  Future<List<StockProduct>> getAllStockProducts(int producteurId) async {
    try {
      print('Récupération des produits pour le producteur ID: $producteurId');
      final response = await _apiService.get<List<dynamic>>(
        '/producteur/$producteurId/stocks/produits',
      );

      print('Statut de la réponse: ${response.statusCode}');
      print('Données brutes reçues: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final List<dynamic> rawData = response.data as List;
          print('Nombre de produits reçus: ${rawData.length}');

          // Filtrer les éléments null et convertir
          final List<StockProduct> products = rawData
              .where((item) => item != null)
              .map((item) {
                try {
                  print('Conversion de l\'élément: $item');
                  return StockProduct.fromJson(item as Map<String, dynamic>);
                } catch (e) {
                  print('Erreur lors de la conversion d\'un produit: $e');
                  print('Données problématiques: $item');
                  return null;
                }
              })
              .where((product) => product != null)
              .cast<StockProduct>()
              .toList();

          print('Nombre de produits convertis: ${products.length}');
          return products;
        } else {
          print('Réponse inattendue: ${response.data.runtimeType}');
          print('Contenu de la réponse: ${response.data}');
          return [];
        }
      } else {
        print('Erreur HTTP: ${response.statusCode}');
        print('Message d\'erreur: ${response.statusMessage}');
        throw Exception(
            'Erreur lors de la récupération des produits: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la récupération des produits en stock: $e');
      rethrow;
    }
  }

  /// Mettre à jour la quantité d'un produit
  Future<StockProduct> updateProductQuantity(
      int producteurId, int produitId, int newQuantity) async {
    try {
      print(
          'Mise à jour de la quantité du produit ID: $produitId à $newQuantity');
      final response = await _apiService.put<Map<String, dynamic>>(
        '/producteur/$producteurId/stocks/produits/$produitId/quantite',
        queryParameters: {'nouvelleQuantite': newQuantity},
      );

      if (response.statusCode == 200) {
        print('Réponse de mise à jour: ${response.data}');
        return StockProduct.fromJson(response.data!);
      } else {
        throw Exception(
            'Erreur lors de la mise à jour de la quantité: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la quantité: $e');
      rethrow;
    }
  }

  /// Mettre à jour le seuil d'alerte d'un produit
  Future<StockProduct> updateMinStockAlert(
      int producteurId, int produitId, int minStockAlert) async {
    try {
      print(
          'Mise à jour du seuil d\'alerte du produit ID: $produitId à $minStockAlert');
      final response = await _apiService.put<Map<String, dynamic>>(
        '/producteur/$producteurId/stocks/produits/$produitId/alerte',
        queryParameters: {'seuilAlerte': minStockAlert},
      );

      if (response.statusCode == 200) {
        print('Réponse de mise à jour du seuil: ${response.data}');
        return StockProduct.fromJson(response.data!);
      } else {
        throw Exception(
            'Erreur lors de la mise à jour du seuil d\'alerte: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la mise à jour du seuil d\'alerte: $e');
      rethrow;
    }
  }

  /// Calculer la valeur totale de tous les produits en stock
  Future<double> getTotalStockValue(int producteurId) async {
    try {
      final products = await getAllStockProducts(producteurId);
      double total = 0.0;
      for (var product in products) {
        total += product.totalValue;
      }
      print('Valeur totale du stock: $total');
      return total;
    } catch (e) {
      print('Erreur lors du calcul de la valeur totale: $e');
      return 0.0;
    }
  }

  /// Compter les produits avec stock faible
  Future<int> getLowStockCount(int producteurId) async {
    try {
      final products = await getAllStockProducts(producteurId);
      final count =
          products.where((product) => product.status == 'stock_faible').length;
      print('Nombre de produits avec stock faible: $count');
      return count;
    } catch (e) {
      print('Erreur lors du comptage des produits avec stock faible: $e');
      return 0;
    }
  }

  /// Compter les produits épuisés
  Future<int> getOutOfStockCount(int producteurId) async {
    try {
      final products = await getAllStockProducts(producteurId);
      final count =
          products.where((product) => product.status == 'epuise').length;
      print('Nombre de produits épuisés: $count');
      return count;
    } catch (e) {
      print('Erreur lors du comptage des produits épuisés: $e');
      return 0;
    }
  }

  /// Filtrer les produits par statut
  Future<List<StockProduct>> filterProductsByStatus(
      int producteurId, String status) async {
    try {
      final allProducts = await getAllStockProducts(producteurId);

      if (status == 'all') {
        return allProducts;
      }

      final filtered =
          allProducts.where((product) => product.status == status).toList();
      print(
          'Nombre de produits filtrés par statut "$status": ${filtered.length}');
      return filtered;
    } catch (e) {
      print('Erreur lors du filtrage des produits: $e');
      return [];
    }
  }

  /// Rechercher des produits par nom
  Future<List<StockProduct>> searchProducts(
      int producteurId, String query) async {
    try {
      final allProducts = await getAllStockProducts(producteurId);
      if (query.isEmpty) return allProducts;

      final filtered = allProducts
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      print(
          'Nombre de produits trouvés pour la recherche "$query": ${filtered.length}');
      return filtered;
    } catch (e) {
      print('Erreur lors de la recherche de produits: $e');
      return [];
    }
  }
}
