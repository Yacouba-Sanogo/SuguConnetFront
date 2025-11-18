import '../models/product.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  /// Récupérer tous les produits (endpoint public consommateur)
  Future<List<Produit>> getAllProducts() async {
    try {
      final response = await _apiService.get<List<dynamic>>('/consommateur/produits');
      
      if (response.statusCode == 200) {
        return response.data!
            .map((json) => Produit.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération des produits');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des produits: $e');
    }
  }

  /// Récupérer un produit par ID
  Future<Produit> getProductById(int id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/produits/$id');
      
      if (response.statusCode == 200) {
        return Produit.fromJson(response.data!);
      } else {
        throw Exception('Produit non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du produit: $e');
    }
  }

  /// Récupérer les produits d'un producteur
  Future<List<Produit>> getProductsByProducer(int producteurId) async {
    try {
      final response = await _apiService.get<List<dynamic>>('/produits/producteur/$producteurId');
      
      if (response.statusCode == 200) {
        return response.data!
            .map((json) => Produit.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération des produits du producteur');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des produits: $e');
    }
  }

  /// Créer un nouveau produit
  Future<Produit> createProduct(Produit produit, int producteurId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/produits/producteur/$producteurId',
        data: produit.toJson(),
      );
      
      if (response.statusCode == 201) {
        return Produit.fromJson(response.data!);
      } else {
        throw Exception('Erreur lors de la création du produit');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du produit: $e');
    }
  }

  /// Mettre à jour un produit
  Future<Produit> updateProduct(int id, Produit produit) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/produits/$id',
        data: produit.toJson(),
      );
      
      if (response.statusCode == 200) {
        return Produit.fromJson(response.data!);
      } else {
        throw Exception('Erreur lors de la mise à jour du produit');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du produit: $e');
    }
  }

  /// Supprimer un produit
  Future<void> deleteProduct(int id) async {
    try {
      final response = await _apiService.delete('/produits/$id');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression du produit');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression du produit: $e');
    }
  }

  /// Récupérer toutes les catégories
  Future<List<Categorie>> getAllCategories() async {
    try {
      final response = await _apiService.get<List<dynamic>>('/categories');
      
      if (response.statusCode == 200) {
        return response.data!
            .map((json) => Categorie.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération des catégories');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des catégories: $e');
    }
  }

  /// Récupérer les évaluations d'un producteur
  Future<List<Evaluation>> getEvaluationsByProducer(int producteurId) async {
    try {
      final response = await _apiService.get<List<dynamic>>('/evaluations/producteur/$producteurId');
      
      if (response.statusCode == 200) {
        return response.data!
            .map((json) => Evaluation.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération des évaluations');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des évaluations: $e');
    }
  }

  /// Créer une évaluation
  Future<Evaluation> createEvaluation(Evaluation evaluation) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/evaluations',
        data: evaluation.toJson(),
      );
      
      if (response.statusCode == 201) {
        return Evaluation.fromJson(response.data!);
      } else {
        throw Exception('Erreur lors de la création de l\'évaluation');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'évaluation: $e');
    }
  }
}
