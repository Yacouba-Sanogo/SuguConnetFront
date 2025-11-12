import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';

// Page de paiement pour les consommateurs
class PaymentScreen extends StatefulWidget {
  // Données de la commande passées depuis la page précédente
  final Map<String, dynamic> order;
  
  const PaymentScreen({super.key, required this.order});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Variable pour stocker la méthode de paiement sélectionnée
  String _selectedPaymentMethod = '';
  
  // Contrôleur pour le champ de saisie du numéro de téléphone
  final TextEditingController _phoneController = TextEditingController();
  
  // Liste des méthodes de paiement disponibles
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'mobile_money',
      'name': 'Mobile Money',
      'icon': Icons.phone_android,
      'color': Colors.orange,
      'description': 'Orange Money, MTN Money, Moov Money',
    },
    {
      'id': 'bank_transfer',
      'name': 'Virement bancaire',
      'icon': Icons.account_balance,
      'color': Colors.blue,
      'description': 'Transfert vers compte bancaire',
    },
    {
      'id': 'cash_on_delivery',
      'name': 'Paiement à la livraison',
      'icon': Icons.local_shipping,
      'color': Colors.green,
      'description': 'Payer en espèces à la réception',
    },
  ];

  // Fonction appelée quand on sélectionne une méthode de paiement
  void _selectPaymentMethod(String methodId) {
    setState(() {
      _selectedPaymentMethod = methodId;
    });
  }

  // Fonction pour traiter le paiement
  void _processPayment() {
    // Vérifier qu'une méthode de paiement est sélectionnée
    if (_selectedPaymentMethod.isEmpty) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une méthode de paiement'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifier le numéro de téléphone pour Mobile Money
    if (_selectedPaymentMethod == 'mobile_money' && _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre numéro de téléphone'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Afficher un dialogue de confirmation
    _showPaymentConfirmation();
  }

  // Fonction pour afficher le dialogue de confirmation
  void _showPaymentConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.payment, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Confirmer le paiement'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Montant: ${widget.order['amount']} fcfa'),
            const SizedBox(height: 8),
            Text('Méthode: ${_getPaymentMethodName()}'),
            if (_selectedPaymentMethod == 'mobile_money') ...[
              const SizedBox(height: 8),
              Text('Téléphone: ${_phoneController.text}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialogue
              _completePayment(); // Traiter le paiement
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  // Fonction pour finaliser le paiement
  void _completePayment() {
    // Simuler le traitement du paiement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Traitement du paiement...'),
          ],
        ),
      ),
    );

    // Simuler un délai de traitement
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Fermer le dialogue de chargement
      Navigator.pop(context); // Retourner à la page précédente
      
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paiement effectué avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  // Fonction pour obtenir le nom de la méthode de paiement
  String _getPaymentMethodName() {
    final method = _paymentMethods.firstWhere(
      (method) => method['id'] == _selectedPaymentMethod,
    );
    return method['name'];
  }

  // Fonction pour nettoyer les ressources
  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Paiement',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section des informations de la commande
            _buildOrderSummary(),
            
            const SizedBox(height: 24),
            
            // Section de sélection de la méthode de paiement
            _buildPaymentMethodsSection(),
            
            const SizedBox(height: 24),
            
            // Section du numéro de téléphone (si Mobile Money)
            if (_selectedPaymentMethod == 'mobile_money') ...[
              _buildPhoneNumberSection(),
              const SizedBox(height: 24),
            ],
            
            // Bouton de paiement
            _buildPaymentButton(),
          ],
        ),
      ),
    );
  }

  // Widget pour afficher le résumé de la commande
  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Résumé de la commande',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_cart,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.order['product'] ?? 'Produit non spécifié',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Commande #${widget.order['number'] ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${widget.order['amount'] ?? '0'} fcfa',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget pour la section des méthodes de paiement
  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Méthode de paiement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        // Liste des méthodes de paiement
        ..._paymentMethods.map((method) => _buildPaymentMethodCard(method)).toList(),
      ],
    );
  }

  // Widget pour une carte de méthode de paiement
  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['id'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectPaymentMethod(method['id']),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? method['color'].withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? method['color']
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Icône de la méthode de paiement
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: method['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    method['icon'],
                    color: method['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Informations de la méthode
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: isSelected ? method['color'] : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        method['description'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Indicateur de sélection
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? method['color'] : Colors.grey,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour la section du numéro de téléphone
  Widget _buildPhoneNumberSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Numéro de téléphone',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Ex: +225 07 00 00 00 00',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour le bouton de paiement
  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Effectuer le paiement',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
