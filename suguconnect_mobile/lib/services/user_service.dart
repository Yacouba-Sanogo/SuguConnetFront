import '../models/user.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  /// Récupérer tous les producteurs
  Future<List<Producteur>> getAllProducers() async {
    try {
      final response = await _apiService.get<List<dynamic>>('/producteurs');
      
      if (response.statusCode == 200) {
        return response.data!
            .map((json) => Producteur.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération des producteurs');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des producteurs: $e');
    }
  }

  /// Récupérer un producteur par ID
  Future<Producteur> getProducerById(int id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/producteurs/$id');
      
      if (response.statusCode == 200) {
        return Producteur.fromJson(response.data!);
      } else {
        throw Exception('Producteur non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du producteur: $e');
    }
  }

  /// Récupérer tous les consommateurs
  Future<List<Consommateur>> getAllConsumers() async {
    try {
      final response = await _apiService.get<List<dynamic>>('/consommateurs');
      
      if (response.statusCode == 200) {
        return response.data!
            .map((json) => Consommateur.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération des consommateurs');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des consommateurs: $e');
    }
  }

  /// Récupérer un consommateur par ID
  Future<Consommateur> getConsumerById(int id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/consommateurs/$id');
      
      if (response.statusCode == 200) {
        return Consommateur.fromJson(response.data!);
      } else {
        throw Exception('Consommateur non trouvé');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du consommateur: $e');
    }
  }

  /// Mettre à jour un producteur
  Future<Producteur> updateProducer(int id, Producteur producteur) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/producteurs/$id',
        data: producteur.toJson(),
      );
      
      if (response.statusCode == 200) {
        return Producteur.fromJson(response.data!);
      } else {
        throw Exception('Erreur lors de la mise à jour du producteur');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du producteur: $e');
    }
  }

  /// Mettre à jour un consommateur
  Future<Consommateur> updateConsumer(int id, Consommateur consommateur) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/consommateurs/$id',
        data: consommateur.toJson(),
      );
      
      if (response.statusCode == 200) {
        return Consommateur.fromJson(response.data!);
      } else {
        throw Exception('Erreur lors de la mise à jour du consommateur');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du consommateur: $e');
    }
  }

  /// Désactiver un utilisateur
  Future<void> deactivateUser(int id, String userType) async {
    try {
      final response = await _apiService.put('/$userType/$id/desactiver');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la désactivation de l\'utilisateur');
      }
    } catch (e) {
      throw Exception('Erreur lors de la désactivation de l\'utilisateur: $e');
    }
  }

  /// Activer un utilisateur
  Future<void> activateUser(int id, String userType) async {
    try {
      final response = await _apiService.put('/$userType/$id/activer');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de l\'activation de l\'utilisateur');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'activation de l\'utilisateur: $e');
    }
  }
}
