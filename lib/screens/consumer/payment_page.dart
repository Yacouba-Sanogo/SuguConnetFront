import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suguconnect_mobile/services/payment_service.dart';
import 'package:suguconnect_mobile/providers/auth_provider.dart';
import 'package:suguconnect_mobile/screens/auth/login_screen.dart';
import 'package:suguconnect_mobile/services/order_service.dart';
<<<<<<< HEAD
=======
import 'package:suguconnect_mobile/services/api_service.dart';
>>>>>>> 5e709d18c9d247014977c9e8dc9a3fd00642889a

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
<<<<<<< HEAD
=======
  final ApiService _apiService = ApiService(); // Ajout du service API
>>>>>>> 5e709d18c9d247014977c9e8dc9a3fd00642889a
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
    // S'assurer que itemPrice est un nombre
    final itemPriceValue = item['price'] is num
        ? item['price']
        : double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0;
    final itemQuantity = item['quantity'] ?? 1;
    // Récupérer l'URL de l'image du produit
    final itemImage = item['image'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          // Image du produit
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
<<<<<<< HEAD
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
=======
            ),
            child: FutureBuilder<String>(
              future: itemImage.isNotEmpty
                  ? _apiService.buildImageUrl(itemImage)
                  : Future.value(''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Container(
                    color: Colors.grey.shade200,
                    child:
                        const Icon(Icons.image, size: 20, color: Colors.grey),
                  );
                }

                final imageUrl = snapshot.data!;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image,
                            size: 20, color: Colors.grey),
                      );
                    },
                  ),
                );
              },
            ),
>>>>>>> 5e709d18c9d247014977c9e8dc9a3fd00642889a
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
                Text(
                    '${itemPriceValue.toStringAsFixed(0)} FCFA x $itemQuantity'),
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
            const Text('Votre numéro de téléphone',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            _buildPhoneNumberInput(),
          ] else if (_selectedMethod == PaymentMethod.card) ...[
            const Center(child: Text("Paiement par carte bancaire")),
          ] else if (_selectedMethod == PaymentMethod.paypal) ...[
            const Center(child: Text("Paiement par PayPal")),
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
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
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
              style:
                  TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Widget pour le résumé des coûts
  Widget _buildCostSummary() {
    // S'assurer que orderAmount est un nombre
    final orderAmountValue = widget.orderData['amount'] is num
        ? widget.orderData['amount']
        : double.tryParse(widget.orderData['amount']?.toString() ?? '0.0') ??
            0.0;
    final processingFee = 0.0; // Pour l'instant, pas de frais
    final totalAmount = orderAmountValue + processingFee;

    return Column(
      children: [
        _buildCostRow('Montant', '${orderAmountValue.toStringAsFixed(0)} fcfa'),
        const SizedBox(height: 8),
        _buildCostRow(
            'Frais de traitement', '${processingFee.toStringAsFixed(0)} fcfa'),
        const Divider(height: 24),
        _buildCostRow('Total', '${totalAmount.toStringAsFixed(0)} fcfa',
            isTotal: true),
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
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFB662F),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Confirmer le paiement',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
      ),
    );
  }

  // Fonction pour traiter le paiement
  void _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      print('=== _processPayment appelée ===');

      // Valider les champs selon la méthode de paiement
      if (_selectedMethod == PaymentMethod.mobile &&
          _phoneController.text.isEmpty) {
        print('ERREUR: Numéro de téléphone vide');
        _showError('Veuillez entrer votre numéro de téléphone');
        return;
      }

      // Afficher les données de débogage
      print('=== Début du processus de paiement ===');
      print('Order ID: ${widget.orderData['orderId']}');
      print('Montant: ${widget.orderData['amount']}');
      print('Numéro de téléphone: ${_phoneController.text}');
      print('Méthode de paiement: ${_getPaymentMethodName()}');

      // Créer un paiement
      final paymentService = PaymentService();
      print('Service de paiement instancié');

      // Créer le paiement
      print('Appel de createPayment...');
      final paymentData = await paymentService.createPayment(
        commandeId: widget.orderData['orderId'] ?? 1,
        methodePaiement: _getPaymentMethodName(),
        montant: double.tryParse(widget.orderData['amount'].toString()) ?? 0.0,
        numeroTelephone: _phoneController.text,
      );

      print('Paiement créé avec succès: $paymentData');

      // Fermer la page de paiement
      if (mounted) {
        Navigator.pop(context);
      }

      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paiement effectué avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('=== ERREUR DE PAIEMENT ===');
      print('Erreur: ${e.toString()}');
      print('Stack trace: $stackTrace');
      _showError('Erreur lors du paiement: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  // Méthode pour afficher les erreurs
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Méthode pour obtenir le nom de la méthode de paiement
  String _getPaymentMethodName() {
    switch (_selectedMethod) {
      case PaymentMethod.card:
        return 'ORANGE_MONEY'; // Pour le moment, utilisons ORANGE_MONEY comme valeur par défaut
      case PaymentMethod.mobile:
        return 'ORANGE_MONEY'; // Ou 'MOOV_MONEY' selon l'opérateur sélectionné
      case PaymentMethod.paypal:
        return 'ORANGE_MONEY'; // Pour le moment, utilisons ORANGE_MONEY comme valeur par défaut
      default:
        return 'ORANGE_MONEY';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
