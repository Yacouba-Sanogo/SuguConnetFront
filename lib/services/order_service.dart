import '../models/order.dart';
import '../models/user.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  /// Récupérer toutes les commandes d'un consommateur
  Future<List<Commande>> getOrdersByConsumer(int consommateurId) async {
    try {
      final response = await _apiService.get<List<dynamic>>('/commandes/consommateur/$consommateurId');
      
      if (response.statusCode == 200) {
        return response.data!
            .map((json) => Commande.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération des commandes');
      }

  /// Récupérer les commandes d'un producteur avec filtre de statut et recherche
  Future<List<Commande>> getOrdersByProducerFiltered(
    int producteurId, {
    String? statut, // ex: VALIDEE, EN_LIVRAISON, LIVREE
    String? search,
  }) async {
    try {
      final query = <String, String>{};
      if (statut != null && statut.isNotEmpty) query['statut'] = statut;
      if (search != null && search.isNotEmpty) query['search'] = search;

      final path = '/producteur/$producteurId/commandes';
      final qp = query.isEmpty
          ? ''
          : ('?' + query.entries.map((e) => Uri.encodeQueryComponent(e.key) + '=' + Uri.encodeQueryComponent(e.value)).join('&'));

      final response = await _apiService.get<List<dynamic>>(path + qp);

      if (response.statusCode == 200) {
        return response.data!
            .map((json) => Commande.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération des commandes producteur');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des commandes producteur: $e');
    }
  }

  /// Changer le statut d'une commande (côté producteur)
  Future<Commande> updateOrderStatusByProducer({
    required int commandeId,
    required int producteurId,
    required String nouveauStatut, // VALIDEE, REFUSEE, EN_LIVRAISON, LIVREE
    String? motifRejet,
  }) async {
    try {
      final qp = {
        'producteurId': producteurId.toString(),
        'nouveauStatut': nouveauStatut,
        if (motifRejet != null && motifRejet.isNotEmpty) 'motifRejet': motifRejet,
      };
      final query = '?' + qp.entries.map((e) => Uri.encodeQueryComponent(e.key) + '=' + Uri.encodeQueryComponent(e.value)).join('&');

      final response = await _apiService.put<Map<String, dynamic>>(
        '/producteur/commande/$commandeId/statut$query',
      );

      if (response.statusCode == 200) {
        return Commande.fromJson(response.data!);
      } else {
        throw Exception('Erreur lors du changement de statut');
      }
    } catch (e) {
      throw Exception('Erreur lors du changement de statut: $e');
    }
  }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des commandes: $e');
    }
  }

  /// Récupérer toutes les commandes d'un producteur
  Future<List<Commande>> getOrdersByProducer(int producteurId) async {
    try {
      final response = await _apiService.get<List<dynamic>>('/commandes/producteur/$producteurId');
      
      if (response.statusCode == 200) {
        return response.data!
            .map((json) => Commande.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération des commandes');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des commandes: $e');
    }
  }

  /// Récupérer une commande par ID
  Future<Commande> getOrderById(int id) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/commandes/$id');
      
      if (response.statusCode == 200) {
        return Commande.fromJson(response.data!);
      } else {
        throw Exception('Commande non trouvée');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la commande: $e');
    }
  }

  /// Créer une nouvelle commande
  Future<Commande> createOrder(Commande commande, int consommateurId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/commandes/consommateur/$consommateurId',
        data: commande.toJson(),
      );
      
      if (response.statusCode == 201) {
        return Commande.fromJson(response.data!);
      } else {
        throw Exception('Erreur lors de la création de la commande');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de la commande: $e');
    }
  }

  /// Mettre à jour le statut d'une commande
  Future<Commande> updateOrderStatus(int id, String statut) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/commandes/$id/statut',
        data: {'statut': statut},
      );
      
      if (response.statusCode == 200) {
        return Commande.fromJson(response.data!);
      } else {
        throw Exception('Erreur lors de la mise à jour du statut');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  /// Annuler une commande
  Future<void> cancelOrder(int id) async {
    try {
      final response = await _apiService.put('/commandes/$id/annuler');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de l\'annulation de la commande');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation de la commande: $e');
    }
  }

  /// Récupérer les paiements d'une commande
  Future<Paiement?> getPaymentByOrder(int commandeId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/paiements/commande/$commandeId');
      
      if (response.statusCode == 200) {
        return Paiement.fromJson(response.data!);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erreur lors de la récupération du paiement');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du paiement: $e');
    }
  }

  /// Créer un paiement
  Future<Paiement> createPayment(Paiement paiement, int commandeId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/paiements/commande/$commandeId',
        data: paiement.toJson(),
      );
      
      if (response.statusCode == 201) {
        return Paiement.fromJson(response.data!);
      } else {
        throw Exception('Erreur lors de la création du paiement');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du paiement: $e');
    }
  }

  /// Récupérer les livraisons d'une commande
  Future<Livraison?> getDeliveryByOrder(int commandeId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/livraisons/commande/$commandeId');
      
      if (response.statusCode == 200) {
        return Livraison.fromJson(response.data!);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erreur lors de la récupération de la livraison');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la livraison: $e');
    }
  }

  /// Créer une livraison
  Future<Livraison> createDelivery(Livraison livraison, int commandeId) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/livraisons/commande/$commandeId',
        data: livraison.toJson(),
      );
      
      if (response.statusCode == 201) {
        return Livraison.fromJson(response.data!);
      } else {
        throw Exception('Erreur lors de la création de la livraison');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de la livraison: $e');
    }
  }
}
