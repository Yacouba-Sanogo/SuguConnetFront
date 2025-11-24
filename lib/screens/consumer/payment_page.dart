import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:suguconnect_mobile/services/payment_service.dart';
import 'package:suguconnect_mobile/providers/auth_provider.dart';
import 'package:suguconnect_mobile/screens/auth/login_screen.dart';
import 'package:suguconnect_mobile/services/order_service.dart';
import 'package:suguconnect_mobile/services/api_service.dart';
import '../../widgets/network_image_with_fallback.dart';

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
          MaterialPageRoute(builder: (context) => const LoginScreen(role: null)),
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
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildPaymentSection(),
            const SizedBox(height: 24),
            _buildOrderSection(),
            const SizedBox(height: 24),
            _buildTotalSection(),
            const SizedBox(height: 24),
            _buildPaymentDetails(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(),
    );
  }

  // Construit la barre d'application
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFB662F).withOpacity(0.1),
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE8E3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
        ),
      ),
      title: Text(
        'Confirmation de paiement',
        style: GoogleFonts.itim(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      centerTitle: true,
    );
  }

  // Widget pour la section Paiement
  Widget _buildPaymentSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paiement',
              style: GoogleFonts.itim(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone_android, color: Colors.black, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Orange money, Moov money, Wave',
                    style: GoogleFonts.itim(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour la section Commande
  Widget _buildOrderSection() {
    final orderItems = widget.orderData['items'] as List<dynamic>? ?? [];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Commande',
                  style: GoogleFonts.itim(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigation vers la page de détails de commande
                  },
                  child: Row(
                    children: [
                      Text(
                        'Voir tout',
                        style: GoogleFonts.itim(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Affichage des produits avec images et informations
            if (orderItems.isNotEmpty) ...[
              ...orderItems.map((item) {
                final itemName = item['name'] ?? 'Produit';
                final itemPriceValue = item['price'] is num
                    ? item['price']
                    : double.tryParse(item['price']?.toString() ?? '0.0') ?? 0.0;
                final itemQuantity = item['quantity'] ?? 1;
                final itemImage = item['image'] ?? '';
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      // Image du produit (plus petite)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: itemImage.isNotEmpty
                              ? FutureBuilder<String>(
                                  future: _apiService.buildImageUrl(itemImage),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Center(child: CircularProgressIndicator(strokeWidth: 2));
                                    }
                                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                      return Icon(Icons.image, size: 30, color: Colors.grey);
                                    }
                                    return Image.network(
                                      snapshot.data!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.image, size: 30, color: Colors.grey);
                                      },
                                    );
                                  },
                                )
                              : Icon(Icons.image, size: 30, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Informations du produit
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemName,
                              style: GoogleFonts.itim(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Qté: $itemQuantity • ${itemPriceValue.toStringAsFixed(0)} FCFA/unité',
                              style: GoogleFonts.itim(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ] else ...[
              Text(
                'Aucun produit dans la commande',
                style: GoogleFonts.itim(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget pour la section Total
  Widget _buildTotalSection() {
    final orderAmountValue = widget.orderData['amount'] is num
        ? widget.orderData['amount']
        : double.tryParse(widget.orderData['amount']?.toString() ?? '0.0') ?? 0.0;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFCBD99B).withOpacity(0.3), // CBD99B à 30%
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: GoogleFonts.itim(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            '${orderAmountValue.toStringAsFixed(0)} fcfa',
            style: GoogleFonts.itim(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour le résumé de la commande (ancien, à supprimer ou garder pour référence)
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails du paiement',
              style: GoogleFonts.itim(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // Affiche les champs en fonction de la méthode sélectionnée
            if (_selectedMethod == PaymentMethod.mobile) ...[
              Text(
                'Choisir l\'opérateur',
                style: GoogleFonts.itim(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _buildOperatorDropdown(),
              const SizedBox(height: 16),
              Text(
                'Numéro de téléphone',
                style: GoogleFonts.itim(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              _buildPhoneNumberInput(),
            ] else if (_selectedMethod == PaymentMethod.card) ...[
              const Center(child: Text("Paiement par carte bancaire")),
            ] else if (_selectedMethod == PaymentMethod.paypal) ...[
              const Center(child: Text("Paiement par PayPal")),
            ],
          ],
        ),
      ),
    );
  }

  // Widget pour le dropdown des opérateurs
  Widget _buildOperatorDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedOperator,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          style: GoogleFonts.itim(
            color: Colors.black,
            fontSize: 14,
          ),
          items: _operators.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: GoogleFonts.itim()),
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
          width: 80,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text(
                  '223',
                  style: GoogleFonts.itim(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8)),
            ),
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.itim(
                color: Colors.black,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: '12345678',
                hintStyle: GoogleFonts.itim(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
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

    return Column(
      children: [
        _buildCostRow('Total', '${orderAmountValue.toStringAsFixed(0)} fcfa',
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
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
              : Text(
                  'Confirmer le paiement',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
