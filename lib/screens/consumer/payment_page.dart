import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suguconnect_mobile/services/payment_service.dart';
import 'package:suguconnect_mobile/providers/auth_provider.dart';
import 'package:suguconnect_mobile/screens/auth/login_screen.dart';
import 'package:suguconnect_mobile/services/order_service.dart';
import 'package:suguconnect_mobile/services/api_service.dart';

// La page de paiement
class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const PaymentPage({super.key, required this.orderData});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

// Enum pour les méthodes de paiement
enum PaymentMethod { card, mobile, paypal }

class _PaymentPageState extends State<PaymentPage> {
  PaymentMethod _selectedMethod = PaymentMethod.mobile;
  String? _selectedOperator = 'Orange money';
  final List<String> _operators = ['Orange money', 'Moov money', 'Wave'];
  final TextEditingController _phoneController = TextEditingController();
  final PaymentService _paymentService = PaymentService();
  final ApiService _apiService = ApiService(); // Ajout du service API
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    // Vérifier si l'utilisateur est authentifié
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      // Rediriger vers l'écran de connexion si l'utilisateur n'est pas authentifié
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });

      // Afficher un indicateur de chargement pendant la redirection
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
            _buildOrderSummary(),
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

  // Widget pour le résumé de la commande
  Widget _buildOrderSummary() {
    // S'assurer que orderAmount est un nombre
    final orderAmountValue = widget.orderData['amount'] is num
        ? widget.orderData['amount']
        : double.tryParse(widget.orderData['amount']?.toString() ?? '0.0') ??
            0.0;

    final orderItems = widget.orderData['items'] as List<dynamic>? ?? [];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Commande',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  // TODO: Navigation vers la page de détails de commande
                },
                child: const Row(
                  children: [
                    Text('Voir tout', style: TextStyle(color: Colors.grey)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down,
                        color: Colors.grey, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Affichage des produits
          if (orderItems.isNotEmpty) ...[
            Column(
              children: orderItems.map((item) {
                return _buildOrderItem(item);
              }).toList(),
            )
          ] else ...[
            const Text('Aucun produit dans la commande'),
          ],
          const SizedBox(height: 12),
          // Total de la commande
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFB662F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total de la commande',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${orderAmountValue.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFB662F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour un élément de commande
  Widget _buildOrderItem(dynamic item) {
    final itemName = item['name'] ?? 'Produit';
    final itemImage = item['image'] ?? '';
    final itemPrice = item['price'] ?? 0.0;
    final itemQuantity = item['quantity'] ?? 1;

    // S'assurer que itemPrice est un nombre
    final itemPriceValue = itemPrice is num
        ? itemPrice
        : double.tryParse(itemPrice.toString()) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Image du produit
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: itemImage.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(itemImage),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: Colors.grey.shade200,
            ),
            child: itemImage.isEmpty
                ? const Icon(Icons.image, size: 20, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          // Détails du produit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${itemPriceValue.toStringAsFixed(0)} FCFA x $itemQuantity'),
              ],
            ),
          ),
          Text('${(itemPriceValue * itemQuantity).toStringAsFixed(0)} FCFA'),
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
          const Text('Choisir la méthode de paiement',
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
            const Text('Numéro de téléphone',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildPhoneInput(),
          ] else if (_selectedMethod == PaymentMethod.card) ...[
            const Text('Informations de la carte',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildCardInputs(),
          ] else ...[
            const Text('Compte PayPal',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildPayPalInput(),
          ],
        ],
      ),
    );
  }

  // Dropdown pour choisir l'opérateur
  Widget _buildOperatorDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedOperator,
          items: _operators.map((String operator) {
            return DropdownMenuItem<String>(
              value: operator,
              child: Text(operator),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedOperator = newValue;
            });
          },
        ),
      ),
    );
  }

  // Champ pour le numéro de téléphone
  Widget _buildPhoneInput() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        hintText: 'Entrez votre numéro de téléphone',
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
    );
  }

  // Champs pour les informations de carte
  Widget _buildCardInputs() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Numéro de carte',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.orange),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'MM/YY',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'CVV',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: 'Nom du titulaire',
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.orange),
            ),
          ),
        ),
      ],
    );
  }

  // Champ pour PayPal
  Widget _buildPayPalInput() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Adresse e-mail PayPal',
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
    );
  }

  // Bouton de confirmation
  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFB662F),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Confirmer le paiement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // Traitement du paiement
  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Vérifier que l'utilisateur est authentifié
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        throw Exception('Utilisateur non authentifié');
      }

      final userId = authProvider.currentUser?.id;
      if (userId == null) {
        throw Exception('ID utilisateur non disponible');
      }

      // Valider les données selon la méthode de paiement
      if (_selectedMethod == PaymentMethod.mobile) {
        if (_phoneController.text.isEmpty) {
          throw Exception('Veuillez entrer votre numéro de téléphone');
        }
      }

      // TODO: Implémenter la logique de paiement réelle
      // Pour l'instant, on simule un succès
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paiement effectué avec succès!'),
            backgroundColor: Colors.green,
          ),
        );

        // Rediriger vers la page de confirmation
        Navigator.pop(context); // Fermer la page de paiement
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du paiement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}