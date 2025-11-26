import '../models/order.dart';
import '../models/user.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import 'package:flutter/foundation.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  /// Passer une commande directe avec des produits spécifiques
  Future<Map<String, dynamic>> placeDirectOrder({
    required int consumerId,
    required List<Map<String, dynamic>> products,
    required String paymentMethod,
  }) async {
    try {
      // Afficher les informations de débogage
      print('=== Passer commande directe ===');
      print('Consumer ID: $consumerId');
      print('Products: $products');
      print('Payment Method: $paymentMethod');

      // Vérifier que les données sont valides
      if (products.isEmpty) {
        throw Exception('Aucun produit sélectionné');
      }

      for (var product in products) {
        if (product['produitId'] == null || product['quantite'] == null) {
          throw Exception('Données de produit invalides');
        }
      }

      // Vérifier que le mode de paiement est valide
      final validPaymentMethods = ['ORANGE_MONEY', 'MOOV_MONEY'];
      if (!validPaymentMethods.contains(paymentMethod)) {
        throw Exception('Mode de paiement invalide: $paymentMethod');
      }

      // Afficher les données envoyées
      final requestData = {
        'produits': products,
        'modePaiement': paymentMethod,
      };

      print('Request data: $requestData');
      print('Endpoint: /consommateur/$consumerId/commande/direct');

      final response = await _apiService.post<Map<String, dynamic>>(
        '/consommateur/$consumerId/commande/direct',
        data: requestData,
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        print('Commande créée avec succès');
        return response.data!;
      } else if (response.statusCode == 403) {
        throw Exception(
            'Vous n\'êtes pas autorisé à passer une commande pour ce consommateur. Veuillez vous déconnecter et vous reconnecter.');
      } else {
        throw Exception(
            'Erreur lors de la création de la commande: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la création de la commande: $e');
      throw Exception('Erreur lors de la création de la commande: $e');
    }
  }

  /// Passer une commande en utilisant le panier
  Future<Map<String, dynamic>> placeOrderFromCart({
    required int consumerId,
    required String paymentMethod,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/consommateur/$consumerId/commande',
        queryParameters: {
          'modePaiement': paymentMethod,
        },
      );

      if (response.statusCode == 200) {
        return response.data!;
      } else {
        throw Exception(
            'Erreur lors de la création de la commande: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de la commande: $e');
    }
  }

  /// Voir une commande spécifique
  Future<Map<String, dynamic>> getOrder(int orderId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '/consommateur/commande/$orderId',
      );

      if (response.statusCode == 200) {
        return response.data!;
      } else {
        throw Exception(
            'Erreur lors de la récupération de la commande: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la commande: $e');
    }
  }

  /// Voir toutes les commandes d'un consommateur
  Future<List<Map<String, dynamic>>> getConsumerOrders(int consumerId) async {
    try {
      final response = await _apiService.get<List<dynamic>>(
        '/consommateur/$consumerId/commandes',
      );

      if (response.statusCode == 200) {
        return response.data!
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception(
            'Erreur lors de la récupération des commandes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des commandes: $e');
    }
  }

  /// Valider la réception d'une commande
  Future<Map<String, dynamic>> validateOrderReception({
    required int orderId,
    required int consumerId,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/consommateur/commande/$orderId/valider-reception',
        queryParameters: {
          'consommateurId': consumerId,
        },
      );

      if (response.statusCode == 200) {
        return response.data!;
      } else {
        throw Exception(
            'Erreur lors de la validation de la commande: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la validation de la commande: $e');
    }
  }

  /// Récupérer toutes les commandes d'un consommateur
  Future<List<Commande>> getOrdersByConsumer(int consommateurId) async {
    try {
      final response = await _apiService
          .get<List<dynamic>>('/commandes/consommateur/$consommateurId');

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
          : ('?' +
              query.entries
                  .map((e) =>
                      Uri.encodeQueryComponent(e.key) +
                      '=' +
                      Uri.encodeQueryComponent(e.value))
                  .join('&'));

      print('=== Récupération des commandes filtrées ===');
      print('Path: $path');
      print('Query params: $qp');

      final response = await _apiService.get<List<dynamic>>(path + qp);

      print('Statut réponse: ${response.statusCode}');
      print('Données brutes: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final List<dynamic> rawData = response.data as List;
          print('Nombre de commandes reçues: ${rawData.length}');

          // Filtrer les éléments null et convertir avec gestion d'erreurs
          final List<Commande> orders = [];
          for (var item in rawData) {
            if (item != null) {
              try {
                print('Conversion de la commande: $item');
                final commande =
                    Commande.fromJson(item as Map<String, dynamic>);
                orders.add(commande);
              } catch (e) {
                print('Erreur lors de la conversion d\'une commande: $e');
                print('Données problématiques: $item');
                // Ignorer cette commande et continuer avec les autres
              }
            }
          }

          print('Nombre de commandes converties: ${orders.length}');
          return orders;
        } else {
          print('Réponse inattendue: ${response.data.runtimeType}');
          print('Contenu de la réponse: ${response.data}');
          return [];
        }
      } else {
        throw Exception(
            'Erreur lors de la récupération des commandes producteur');
      }
    } catch (e, stackTrace) {
      print('Erreur détaillée: $e');
      print('Stack trace: $stackTrace');
      throw Exception(
          'Erreur lors de la récupération des commandes producteur: $e');
    }
  }

  /// Récupérer les commandes payées d'un producteur avec recherche
  Future<List<Commande>> getOrdersByProducerPaid(
    int producteurId, {
    String? search,
  }) async {
    try {
      final query = <String, String>{};
      if (search != null && search.isNotEmpty) query['search'] = search;

      final path = '/producteur/$producteurId/commandes/payees';
      final qp = query.isEmpty
          ? ''
          : ('?' +
              query.entries
                  .map((e) =>
                      Uri.encodeQueryComponent(e.key) +
                      '=' +
                      Uri.encodeQueryComponent(e.value))
                  .join('&'));

      print('=== Récupération des commandes payées ===');
      print('Path: $path');
      print('Query params: $qp');

      final response = await _apiService.get<List<dynamic>>(path + qp);

      print('Statut réponse: ${response.statusCode}');
      print('Données brutes: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final List<dynamic> rawData = response.data as List;
          print('Nombre de commandes reçues: ${rawData.length}');

          // Filtrer les éléments null et convertir avec gestion d'erreurs
          final List<Commande> orders = [];
          for (var item in rawData) {
            if (item != null) {
              try {
                print('Conversion de la commande: $item');
                final commande =
                    Commande.fromJson(item as Map<String, dynamic>);
                orders.add(commande);
              } catch (e) {
                print('Erreur lors de la conversion d\'une commande: $e');
                print('Données problématiques: $item');
                // Ignorer cette commande et continuer avec les autres
              }
            }
          }

          print('Nombre de commandes converties: ${orders.length}');
          return orders;
        } else {
          print('Réponse inattendue: ${response.data.runtimeType}');
          print('Contenu de la réponse: ${response.data}');
          return [];
        }
      } else {
        throw Exception(
            'Erreur lors de la récupération des commandes payées producteur: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Erreur détaillée: $e');
      print('Stack trace: $stackTrace');
      throw Exception(
          'Erreur lors de la récupération des commandes payées producteur: $e');
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
        'nouveauStatut': nouveauStatut,
        if (motifRejet != null && motifRejet.isNotEmpty)
          'motifRejet': motifRejet,
      };
      final query = '?' +
          qp.entries
              .map((e) =>
                  Uri.encodeQueryComponent(e.key) +
                  '=' +
                  Uri.encodeQueryComponent(e.value))
              .join('&');

      final response = await _apiService.put<Map<String, dynamic>>(
        '/producteur/$producteurId/commande/$commandeId/statut$query',
      );

      if (response.statusCode == 200) {
        return Commande.fromJson(response.data!);
      } else {
        throw Exception(
            'Erreur lors du changement de statut: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du changement de statut: $e');
    }
  }

  /// Récupérer toutes les commandes d'un producteur
  Future<List<Commande>> getOrdersByProducer(int producteurId) async {
    try {
      final response = await _apiService
          .get<List<dynamic>>('/commandes/producteur/$producteurId');

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
      final response =
          await _apiService.get<Map<String, dynamic>>('/commandes/$id');

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
  Future<void> updateOrderStatus(
      int commandeId, int producteurId, String nouveauStatut) async {
    try {
      final response = await _apiService.put(
        '/commande/$commandeId/statut',
        queryParameters: {
          'producteurId': producteurId,
          'nouveauStatut': nouveauStatut,
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur lors de la mise à jour du statut: ${response.statusCode}');
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
      final response = await _apiService
          .get<Map<String, dynamic>>('/paiements/commande/$commandeId');

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
      final response = await _apiService
          .get<Map<String, dynamic>>('/livraisons/commande/$commandeId');

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
