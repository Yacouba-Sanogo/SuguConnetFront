import 'package:flutter/material.dart';

// La page de paiement
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

// Enum pour les méthodes de paiement
enum PaymentMethod { card, mobile, paypal }

class _PaymentPageState extends State<PaymentPage> {
  PaymentMethod _selectedMethod = PaymentMethod.mobile;
  String? _selectedOperator = 'Orange money';
  final List<String> _operators = ['Orange money', 'Moov money', 'Wave'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Effectuer un paiement',
              style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildBeneficiaryCard(),
            const SizedBox(height: 24),
            _buildPaymentMethodSelector(),
            const SizedBox(height: 24),
            _buildPaymentDetails(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(),
    );
  }

  // Construit la barre d'application
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black54, size: 20),
        ),
      ),
      title: const Text(
        'Confirmation de payement',
        style: TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      centerTitle: true,
    );
  }

  // Widget pour la carte du bénéficiaire
  Widget _buildBeneficiaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Amadou Dembélé',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('Homme', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              const Text('7ans', style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Fournitures scolaires, cantine',
                    style: TextStyle(color: Colors.grey),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('30.000 fcfa',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('(Par mois)',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  // Widget pour le sélecteur de méthode de paiement
  Widget _buildPaymentMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choisir la methode de paiement',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildPaymentOption(
                      method: PaymentMethod.card,
                      icon: Icons.credit_card,
                      title: 'Carte bancaire',
                      subtitle: 'Visa, Mastercard, American Express')),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildPaymentOption(
                      method: PaymentMethod.mobile,
                      icon: Icons.phone_android,
                      title: 'Mobile money',
                      subtitle: 'Orange Money, Moov money, Wave')),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildPaymentOption(
                      method: PaymentMethod.paypal,
                      icon: Icons.paypal,
                      title: 'Paypal',
                      subtitle: '')),
            ],
          )
        ],
      ),
    );
  }

  // Widget pour une option de paiement
  Widget _buildPaymentOption(
      {required PaymentMethod method,
      required IconData icon,
      required String title,
      required String subtitle}) {
    bool isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.orange, width: 2)
              : Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon,
                    color: isSelected ? Colors.orange : Colors.black54,
                    size: 20),
                Icon(Icons.shield_outlined,
                    color: isSelected ? Colors.orange : Colors.grey, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            if (subtitle.isNotEmpty)
              Text(subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 8),
                  textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // Widget pour les détails du paiement (change en fonction de la méthode)
  Widget _buildPaymentDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Détails du paiement',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          // Affiche les champs en fonction de la méthode sélectionnée
          if (_selectedMethod == PaymentMethod.mobile) ...[
            const Text('Choisir l\'opérateur',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildOperatorDropdown(),
            const SizedBox(height: 16),
            const Text('Votre numéro de téléphone',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildPhoneNumberInput(),
          ] else if (_selectedMethod == PaymentMethod.card) ...[
            const Center(child: Text("Formulaire de carte bancaire à implémenter"))
          ] else ...[
             const Center(child: Text("Formulaire Paypal à implémenter"))
          ],
          const SizedBox(height: 20),
          _buildSecurePaymentBanner(),
          const SizedBox(height: 20),
          _buildCostSummary(),
        ],
      ),
    );
  }

  // Widget pour le dropdown des opérateurs
  Widget _buildOperatorDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedOperator,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: _operators.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedOperator = newValue;
            });
          },
        ),
      ),
    );
  }

  // Widget pour l'input du numéro de téléphone
  Widget _buildPhoneNumberInput() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: const [
              Text('+223'),
              Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8)),
            ),
            child: const TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '12345678',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget pour la bannière de paiement sécurisé
  Widget _buildSecurePaymentBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shield_outlined, color: Colors.orange),
          SizedBox(width: 8),
          Text('Paiement 100% sécurisé',
              style: TextStyle(
                  color: Colors.orange, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Widget pour le résumé des coûts
  Widget _buildCostSummary() {
    return Column(
      children: [
        _buildCostRow('Montant', '30.000 fcfa'),
        const SizedBox(height: 8),
        _buildCostRow('Frais de traitement', '0 fcfa'),
        const Divider(height: 24),
        _buildCostRow('Total', '30.000 fcfa', isTotal: true),
      ],
    );
  }

  // Widget pour une ligne du résumé des coûts
  Widget _buildCostRow(String title, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                color: isTotal ? Colors.black : Colors.grey,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(amount,
            style: TextStyle(
                color: Colors.black,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 18 : 16)),
      ],
    );
  }

  // Widget pour le bouton de confirmation
  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.check_circle, color: Colors.white),
        label: const Text('Confirmer le paiement',
            style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
