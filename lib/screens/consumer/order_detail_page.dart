import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constantes.dart';
import '../../services/api_service.dart';
import '../../services/order_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';

// Page de détail d'une commande spécifique
class OrderDetailPage extends StatefulWidget {
  final String orderId;
  final String client;
  final String status;
  final double total;
  final String date;

  const OrderDetailPage({
    super.key,
    required this.orderId,
    required this.client,
    required this.status,
    required this.total,
    required this.date,
  });

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  // Variable pour suivre l'état de la commande
  late String _currentStatus;
  bool _receptionValidee = false;
  bool _isLoading = false;
  String? _error;
  Commande? _orderDetails;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
    _loadOrderDetails();
  }

  // Charger les détails complets de la commande
  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orderService = OrderService();
      final order = await orderService.getOrderById(int.parse(widget.orderId));

      setState(() {
        _orderDetails = order;
        _currentStatus = order.statut;
        _receptionValidee = order.receptionValidee;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des détails: $e';
        _isLoading = false;
      });
    }
  }

  // Détermine l'étape actuelle basée sur le statut
  int _getCurrentStep() {
    final statusUpper = _currentStatus.toUpperCase();
    if (statusUpper.contains('EN ATTENTE') ||
        statusUpper.contains('ATTENTE') ||
        statusUpper.contains('VALIDEE')) {
      return 0; // En attente (paiement validé)
    }
    if (statusUpper.contains('EXPEDIE') ||
        statusUpper.contains('EXPÉDIÉ') ||
        statusUpper.contains('EN COURS') ||
        statusUpper.contains('EN_COURS')) {
      return 1; // Expédition
    }
    if (statusUpper.contains('LIVREE') || statusUpper.contains('LIVRÉE')) {
      return 2; // Réception
    }
    if (statusUpper.contains('NOTE') ||
        statusUpper.contains('EVALUE') ||
        statusUpper.contains('ÉVALUÉ')) {
      return 3; // Note
    }
    // Par défaut, on considère que le paiement est validé
    return 0; // En attente par défaut
  }

  // Confirmer l'expédition de la commande
  Future<void> _confirmExpedition() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Implémenter la confirmation d'expédition côté backend
      await Future.delayed(const Duration(seconds: 1)); // Simulation
      setState(() {
        _currentStatus = 'Expédié';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expédition confirmée')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la confirmation: $e';
        _isLoading = false;
      });
    }
  }

  // Confirmer la réception de la commande
  Future<void> _confirmReception() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderService = OrderService();

      await orderService.validateOrderReception(
        orderId: int.parse(widget.orderId),
        consumerId: authProvider.currentUser!.id!,
      );

      setState(() {
        _currentStatus = 'Livrée';
        _receptionValidee = true;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réception confirmée')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la confirmation: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _getCurrentStep();
    final steps = ['En attente', 'Expédition', 'Réception', 'Note'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFE0E0E0),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Détails de la commande',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicateur de progression
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEE8E3), // Light peach background
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(steps.length, (index) {
                        final isActive = index == currentStep;
                        final isCompleted = index < currentStep;

                        return Expanded(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Ligne avant (sauf pour le premier)
                                  if (index > 0)
                                    Expanded(
                                      child: Container(
                                        height: 2,
                                        color: isCompleted
                                            ? const Color(0xFFFB662F)
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                  // Cercle de l'étape
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isActive || isCompleted
                                          ? const Color(0xFFFB662F)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isActive || isCompleted
                                            ? const Color(0xFFFB662F)
                                            : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  // Ligne après (sauf pour le dernier)
                                  if (index < steps.length - 1)
                                    Expanded(
                                      child: Container(
                                        height: 2,
                                        color: isCompleted
                                            ? const Color(0xFFFB662F)
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                steps[index],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isActive
                                      ? const Color(0xFFFB662F)
                                      : Colors.grey.shade600,
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),

                  // Afficher les erreurs s'il y en a
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Boutons d'action selon l'étape
                  if (currentStep == 0 &&
                      !_isLoading) // En attente - afficher bouton confirmer expédition
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _confirmExpedition,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFB662F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Confirmer l'expédition de la commande",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (currentStep == 1 &&
                      !_isLoading) // Expédition - afficher bouton confirmer réception
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _confirmReception,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFB662F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Confirmer la réception de la commande",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // Carte de détails de la commande
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Numéro de commande
                        Text(
                          'Commande n°${widget.orderId}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Afficher tous les produits de la commande
                        if (_orderDetails != null) ...[
                          ..._orderDetails!.detailsCommande.map((detail) {
                            return _buildProductItem(detail);
                          }).toList(),
                        ] else ...[
                          // Affichage par défaut si les détails ne sont pas encore chargés
                          _buildDefaultProductItem(),
                        ],

                        const SizedBox(height: 16),

                        // Prix total
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Prix total : ${_formatPrice(_orderDetails?.montantTotal ?? widget.total)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFB662F),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Statut de la commande
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                                _currentStatus, _receptionValidee),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Statut:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getStatusText(
                                    _currentStatus, _receptionValidee),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Construit un élément de produit
  Widget _buildProductItem(DetailCommande detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit (affichage générique pour l'instant)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: const Icon(
                Icons.image,
                color: Colors.grey,
                size: 40,
              ),
            ),
            const SizedBox(width: 16),

            // Détails du produit
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Producteur : ${_orderDetails?.consommateur.nom ?? "N/A"}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Produit : ${detail.produit.nom}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quantité : ${detail.quantite}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prix unitaire : ${_formatPrice(detail.prixUnitaire)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),
      ],
    );
  }

  // Construit l'élément de produit par défaut (utilisé avant le chargement des détails)
  Widget _buildDefaultProductItem() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image du produit
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade200,
          ),
          child: const Icon(
            Icons.image,
            color: Colors.grey,
            size: 40,
          ),
        ),
        const SizedBox(width: 16),

        // Détails du produit
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Producteur : N/A',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Produit : N/A',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Quantité : 0',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Prix unitaire : 0 fcfa',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Détermine la couleur du statut
  Color _getStatusColor(String status, bool receptionValidee) {
    if (status == 'LIVREE' && receptionValidee) {
      return const Color(0xFF4CAF50); // Vert pour livré et réception confirmée
    } else if (status == 'VALIDEE' || status == 'EN_ATTENTE') {
      return Colors.orange; // Orange pour en attente
    } else if (status == 'LIVREE') {
      return const Color(
          0xFFFB662F); // Orange foncé pour livré mais pas confirmé
    } else {
      return Colors.grey; // Gris pour les autres statuts
    }
  }

  // Détermine le texte du statut
  String _getStatusText(String status, bool receptionValidee) {
    if (status == 'LIVREE' && receptionValidee) {
      return 'Livrée et réception confirmée';
    } else if (status == 'VALIDEE' || status == 'EN_ATTENTE') {
      return 'En attente d\'expédition';
    } else if (status == 'LIVREE') {
      return 'Livrée (à confirmer)';
    } else {
      return status;
    }
  }

  String _formatPrice(double price) {
    final priceStr = price.toStringAsFixed(0);
    // Format avec points pour les milliers (ex: 40.000)
    if (priceStr.length > 3) {
      String formatted = '';
      for (int i = priceStr.length - 1; i >= 0; i--) {
        formatted = priceStr[i] + formatted;
        if ((priceStr.length - i) % 3 == 0 && i > 0) {
          formatted = '.' + formatted;
        }
      }
      return '$formatted fcfa';
    }
    return '$priceStr fcfa';
  }
}
