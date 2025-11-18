import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _apiService = ApiService();

  /// Créer un paiement
  Future<Map<String, dynamic>> createPayment({
    required int commandeId,
    required String methodePaiement,
    required double montant,
    String? numeroTelephone,
    String? referenceTransaction,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/paiement',
        data: {
          'commandeId': commandeId,
          'methodePaiement': methodePaiement,
          'montant': montant,
          'numeroTelephone': numeroTelephone,
          'referenceTransaction': referenceTransaction,
        },
      );

      if (response.statusCode == 201) {
        return response.data!;
      } else {
        throw Exception(
            'Erreur lors de la création du paiement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création du paiement: $e');
    }
  }

  /// Vérifier le statut d'un paiement
  Future<Map<String, dynamic>> checkPaymentStatus(int paiementId) async {
    try {
      final response =
          await _apiService.get<Map<String, dynamic>>('/paiement/$paiementId');

      if (response.statusCode == 200) {
        return response.data!;
      } else {
        throw Exception(
            'Erreur lors de la vérification du paiement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la vérification du paiement: $e');
    }
  }

  /// Mettre à jour le statut d'un paiement
  Future<Map<String, dynamic>> updatePaymentStatus({
    required int paiementId,
    required String statut,
  }) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/paiement/$paiementId/statut',
        data: {
          'statut': statut,
        },
      );

      if (response.statusCode == 200) {
        return response.data!;
      } else {
        throw Exception(
            'Erreur lors de la mise à jour du paiement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du paiement: $e');
    }
  }

  /// Valider un paiement (marquer comme VALIDE)
  Future<Map<String, dynamic>> validatePayment(
      int paiementId, String referenceTransaction) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/paiement/$paiementId/valider',
        queryParameters: {
          'referenceTransaction': referenceTransaction,
        },
      );

      if (response.statusCode == 200) {
        return response.data!;
      } else {
        throw Exception(
            'Erreur lors de la validation du paiement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la validation du paiement: $e');
    }
  }

  /// Marquer un paiement comme échoué
  Future<Map<String, dynamic>> markPaymentFailed(
      int paiementId, String motifEchec) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/paiement/$paiementId/echouer',
        queryParameters: {
          'motifEchec': motifEchec,
        },
      );

      if (response.statusCode == 200) {
        return response.data!;
      } else {
        throw Exception(
            'Erreur lors de la mise à jour du paiement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du paiement: $e');
    }
  }

  /// Obtenir l'historique des paiements d'un utilisateur
  Future<List<Map<String, dynamic>>> getPaymentHistory(
      int utilisateurId) async {
    try {
      final response = await _apiService
          .get<List<dynamic>>('/paiement/utilisateur/$utilisateurId');

      if (response.statusCode == 200) {
        return response.data!
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception(
            'Erreur lors de la récupération de l\'historique: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'historique: $e');
    }
  }

  /// Annuler un paiement
  Future<void> cancelPayment(int paiementId) async {
    try {
      final response = await _apiService.delete('/paiement/$paiementId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'Erreur lors de l\'annulation du paiement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation du paiement: $e');
    }
  }

  /// Simuler un paiement Mobile Money
  Future<Map<String, dynamic>> simulateMobileMoneyPayment({
    required String operateur,
    required String numeroTelephone,
    required double montant,
    required String codeSecret,
  }) async {
    // Dans une vraie application, cela ferait appel à l'API de l'opérateur
    // Pour cette démonstration, nous simulons une réponse réussie

    await Future.delayed(
        Duration(seconds: 2)); // Simuler le temps de traitement

    // Simuler une réponse réussie
    return {
      'success': true,
      'transactionId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
      'date': DateTime.now().toIso8601String(),
      'montant': montant,
      'operateur': operateur,
      'numero': numeroTelephone,
    };
  }

  /// Simuler un paiement par carte bancaire
  Future<Map<String, dynamic>> simulateCardPayment({
    required String numeroCarte,
    required String dateExpiration,
    required String cvv,
    required double montant,
  }) async {
    // Dans une vraie application, cela ferait appel à un service de paiement comme Stripe
    // Pour cette démonstration, nous simulons une réponse réussie

    await Future.delayed(
        Duration(seconds: 2)); // Simuler le temps de traitement

    // Simuler une réponse réussie
    return {
      'success': true,
      'transactionId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
      'date': DateTime.now().toIso8601String(),
      'montant': montant,
      'type': 'CARTE_BANCAIRE',
    };
  }

  /// Simuler un paiement PayPal
  Future<Map<String, dynamic>> simulatePayPalPayment({
    required String email,
    required double montant,
  }) async {
    // Dans une vraie application, cela ferait appel à l'API PayPal
    // Pour cette démonstration, nous simulons une réponse réussie

    await Future.delayed(
        Duration(seconds: 2)); // Simuler le temps de traitement

    // Simuler une réponse réussie
    return {
      'success': true,
      'transactionId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
      'date': DateTime.now().toIso8601String(),
      'montant': montant,
      'type': 'PAYPAL',
    };
  }
}
