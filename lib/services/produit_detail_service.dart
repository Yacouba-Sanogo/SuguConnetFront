import '../models/produit_detail.dart';
import 'api_service.dart';

class ProduitDetailService {
  final ApiService _apiService = ApiService();

  /// Récupérer les détails d'un produit par ID
  Future<ProduitDetail> getProduitDetailById(int id) async {
    try {
      final response =
          await _apiService.get<Map<String, dynamic>>('/api/produits/$id');

      if (response.statusCode == 200) {
        return ProduitDetail.fromJson(response.data!);
      } else {
        throw Exception('Produit non trouvé');
      }
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des détails du produit: $e');
    }
  }
}
