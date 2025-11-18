import 'package:dio/dio.dart';
import '../models/produit_populaire.dart';
import 'api_service.dart';

class ProduitPopulaireService {
  final ApiService _apiService;

  ProduitPopulaireService(this._apiService);

  /// Récupère les produits les plus populaires
  Future<List<ProduitPopulaire>> getProduitsPopulaires() async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/api/produits/populaires',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> produitsData = response.data!;
        return produitsData
            .map((json) =>
                ProduitPopulaire.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Échec de la récupération des produits populaires');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }

  /// Récupère les N produits les plus populaires
  Future<List<ProduitPopulaire>> getTopProduitsPopulaires(int limit) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/api/produits/populaires/top/$limit',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> produitsData = response.data!;
        return produitsData
            .map((json) =>
                ProduitPopulaire.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Échec de la récupération des produits populaires');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      throw Exception('Erreur inattendue: $e');
    }
  }
}
