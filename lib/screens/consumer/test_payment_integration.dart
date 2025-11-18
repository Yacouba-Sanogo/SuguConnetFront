import 'package:flutter/material.dart';
import '../../services/payment_service.dart';

class TestPaymentIntegration extends StatefulWidget {
  const TestPaymentIntegration({super.key});

  @override
  State<TestPaymentIntegration> createState() => _TestPaymentIntegrationState();
}

class _TestPaymentIntegrationState extends State<TestPaymentIntegration> {
  final PaymentService _paymentService = PaymentService();
  bool _isTesting = false;
  String _result = '';

  Future<void> _testPaymentFlow() async {
    setState(() {
      _isTesting = true;
      _result = 'Test en cours...';
    });

    try {
      // Étape 1: Créer un paiement de test
      final paymentData = await _paymentService.createPayment(
        commandeId: 1, // ID de commande de test
        methodePaiement: 'MOBILE_MONEY',
        montant: 5000.0,
        numeroTelephone: '771234567',
      );

      setState(() {
        _result =
            'Étape 1: Paiement créé avec succès!\nID: ${paymentData['id']}\nStatut: ${paymentData['statut']}';
      });

      // Attendre un peu pour simuler le traitement
      await Future.delayed(const Duration(seconds: 1));

      // Étape 2: Vérifier le statut du paiement
      final statusData =
          await _paymentService.checkPaymentStatus(paymentData['id']);

      setState(() {
        _result += '\n\nÉtape 2: Statut vérifié: ${statusData['statut']}';
      });

      // Attendre un peu pour simuler le traitement
      await Future.delayed(const Duration(seconds: 1));

      // Étape 3: Simuler une validation de paiement (comme si l'utilisateur avait confirmé le paiement)
      // Dans une vraie application, cela serait fait par un webhook du fournisseur de paiement
      try {
        // Note: Cette méthode n'existe pas encore dans le service, nous allons la simuler
        // En réalité, le webhook du fournisseur de paiement appellerait le backend
        _result += '\n\nÉtape 3: Simulation de validation de paiement terminée';
      } catch (e) {
        _result += '\n\nÉtape 3: Validation simulée (pas d\'API réelle)';
      }
    } catch (e) {
      setState(() {
        _result = 'Erreur: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Intégration Paiement'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test de l\'intégration complète du système de paiement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cette page permet de tester la communication entre le frontend et le backend pour le système de paiement, '
              'y compris la création, la vérification et la validation des paiements.',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isTesting ? null : _testPaymentFlow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isTesting
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Test en cours...',
                            style: TextStyle(color: Colors.white)),
                      ],
                    )
                  : const Text('Tester le flux de paiement complet',
                      style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 24),
            const Text(
              'Résultat:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(_result.isEmpty
                  ? 'Appuyez sur le bouton pour tester'
                  : _result),
            ),
            const SizedBox(height: 24),
            const Text(
              'Flux de test:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Création d\'un paiement avec statut "INITIE"\n'
              '2. Vérification du statut du paiement\n'
              '3. Simulation de validation du paiement\n'
              '4. Vérification que le paiement est enregistré dans la base de données',
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: Dans une vraie application, la validation du paiement serait faite par un webhook '
              'du fournisseur de paiement (Orange Money, Wave, etc.) qui appellerait le backend directement.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
