import 'package:flutter/material.dart';
import '../../services/payment_service.dart';

class TestPaymentScreen extends StatefulWidget {
  const TestPaymentScreen({super.key});

  @override
  State<TestPaymentScreen> createState() => _TestPaymentScreenState();
}

class _TestPaymentScreenState extends State<TestPaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isTesting = false;
  String _result = '';

  Future<void> _testCreatePayment() async {
    setState(() {
      _isTesting = true;
      _result = 'Test en cours...';
    });

    try {
      // Créer un paiement de test
      final paymentData = await _paymentService.createPayment(
        commandeId: 1, // ID de commande de test
        methodePaiement: 'MOBILE_MONEY',
        montant: 5000.0,
        numeroTelephone: '771234567',
      );

      setState(() {
        _result =
            'Paiement créé avec succès!\nID: ${paymentData['id']}\nStatut: ${paymentData['statut']}';
      });

      // Vérifier le statut du paiement
      await Future.delayed(const Duration(seconds: 1));

      final statusData =
          await _paymentService.checkPaymentStatus(paymentData['id']);

      setState(() {
        _result += '\n\nStatut vérifié: ${statusData['statut']}';
      });
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
        title: const Text('Test Paiement'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test de l\'intégration des paiements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cette page permet de tester la communication entre le frontend et le backend pour le système de paiement.',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isTesting ? null : _testCreatePayment,
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
                  : const Text('Tester la création de paiement',
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
              'Instructions:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Assurez-vous que le backend est en cours d\'exécution\n'
              '2. Appuyez sur le bouton pour créer un paiement de test\n'
              '3. Vérifiez dans la base de données que le paiement a été enregistré\n'
              '4. Le paiement devrait avoir le statut "INITIE"',
            ),
          ],
        ),
      ),
    );
  }
}
