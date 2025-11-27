import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suguconnect_mobile/models/order.dart';
import 'package:suguconnect_mobile/providers/auth_provider.dart';
import 'package:suguconnect_mobile/services/order_service.dart';
import 'package:suguconnect_mobile/services/api_service.dart'; // Ajout de l'import manquant

class OrderDetailScreen extends StatefulWidget {
  final Commande order;

  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isProcessing = false;
  final ApiService _apiService = ApiService();
  late Commande _currentOrder; // État local de la commande pour suivre les mises à jour

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order; // Initialiser avec la commande passée en paramètre
  }

  // Détermine l'étape actuelle basée sur le statut
  int _getCurrentStep(String status) {
    final statusUpper = status.toUpperCase();
    if (statusUpper.contains('EN ATTENTE') ||
        statusUpper.contains('ATTENTE') ||
        statusUpper.contains('VALIDEE')) {
      return 0; // En attente (paiement validé)
    }
    if (statusUpper.contains('EXPEDIE') ||
        statusUpper.contains('EXPÉDIÉ') ||
        statusUpper.contains('EN COURS') ||
        statusUpper.contains('EN_COURS') ||
        statusUpper.contains('EN_LIVRAISON')) {
      return 1; // Expédition / En cours de livraison
    }
    if (statusUpper.contains('LIVREE') || statusUpper.contains('LIVRÉE')) {
      return 2; // Réception
    }
    // Par défaut, on considère que le paiement est validé
    return 0; // En attente par défaut
  }

  // Construit l'indicateur de progression
  Widget _buildProgressIndicator(String status) {
    final currentStep = _getCurrentStep(status);
    final steps = ['En attente', 'Expédition', 'Livrée'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _expedierCommande() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final orderService = OrderService();

      // Vérifier que l'utilisateur est connecté
      if (auth.currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Vérifier que l'ID utilisateur est valide
      if (auth.currentUser!.id == null) {
        throw Exception('ID utilisateur invalide');
      }

      // Convertir l'ID utilisateur en int non nullable
      final int userId = auth.currentUser!.id!;

      // Changer le statut de la commande à "EN_LIVRAISON" en utilisant la méthode correcte
      final updatedOrder = await orderService.updateOrderStatusByProducer(
        commandeId: widget.order.id,
        producteurId: userId,
        nouveauStatut: 'EN_LIVRAISON',
      );

      if (mounted) {
        // Mettre à jour l'état local de la commande
        setState(() {
          _currentOrder = updatedOrder;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit expédié avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'expédition: ${e.toString()}'),
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

  Future<void> _annulerExpedition() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final orderService = OrderService();

      // Vérifier que l'utilisateur est connecté
      if (auth.currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Vérifier que l'ID utilisateur est valide
      if (auth.currentUser!.id == null) {
        throw Exception('ID utilisateur invalide');
      }

      // Convertir l'ID utilisateur en int non nullable
      final int userId = auth.currentUser!.id!;

      // Changer le statut de la commande à "VALIDEE" (en attente) en utilisant la méthode correcte
      final updatedOrder = await orderService.updateOrderStatusByProducer(
        commandeId: widget.order.id,
        producteurId: userId,
        nouveauStatut: 'VALIDEE',
      );

      if (mounted) {
        // Mettre à jour l'état local de la commande
        setState(() {
          _currentOrder = updatedOrder;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expédition annulée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'annulation: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    final order = _currentOrder; // Utiliser l'état local mis à jour
    final client = order.consommateur;

    return Scaffold(
      appBar: AppBar(
        title: Text('Commande #${order.numeroCommande}'),
        backgroundColor: const Color(0xFFFB662F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Indicateur de progression
            _buildProgressIndicator(order.statut),

            const SizedBox(height: 20),

            // Informations du client
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations du client',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFB662F),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text('${client.prenom} ${client.nom}'),
                      subtitle: Text(client.telephone),
                    ),
                    if (client.email != null && client.email!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.email, size: 16),
                            const SizedBox(width: 8),
                            Text(client.email!),
                          ],
                        ),
                      ),
                    if (client.localisation != null &&
                        client.localisation!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 8),
                            Text(client.localisation!),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Détails de la commande
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Détails de la commande',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Date: ${order.dateCommande}'),
                    Text('Statut: ${order.statut}'),
                    if (order.paiement != null) ...[
                      const SizedBox(height: 8),
                      Text('Paiement: ${order.paiement!.methodePaiement}'),
                      Text(
                          'Montant: ${order.paiement!.montant.toStringAsFixed(0)} FCFA'),
                      Text('Statut paiement: ${order.paiement!.statut}'),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Produits:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...order.detailsCommande.map((detail) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            // Image du produit
                            FutureBuilder<ImageProvider>(
                              future: _getImageProvider(detail.produit),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  );
                                }
                                if (snapshot.hasError || !snapshot.hasData) {
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.image,
                                        size: 24, color: Colors.grey),
                                  );
                                }
                                return Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: snapshot.data!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    detail.produit.nom,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${detail.quantite} x ${detail.prixUnitaire.toStringAsFixed(0)} FCFA',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${(detail.quantite * detail.prixUnitaire).toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${order.montantTotal.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFB662F)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Bouton d'expédition (visible pour les commandes payées)
            if (order.paiement != null && order.paiement!.estPaye) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (order.statut == 'VALIDEE' || order.statut == 'EN_ATTENTE') && !_isProcessing
                      ? _expedierCommande
                      : null, // Désactiver si déjà expédié ou en cours de traitement
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (order.statut == 'VALIDEE' || order.statut == 'EN_ATTENTE')
                        ? const Color(0xFFFB662F)
                        : Colors.grey.shade400, // Griser si déjà expédié
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade400,
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          order.statut == 'EN_LIVRAISON'
                              ? 'En cours de livraison'
                              : 'Expédier',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ] else if (order.statut == 'LIVREE') ...[
              const Center(
                child: Chip(
                  label: Text('Livrée'),
                  backgroundColor: Colors.green,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Méthode pour récupérer l'image du produit avec fallback local
  Future<ImageProvider> _getImageProvider(ProduitCommande produit) async {
    try {
      if (produit.imageUrl != null && produit.imageUrl!.isNotEmpty) {
        final resolvedUrl =
            await _apiService.buildImageUrl(produit.imageUrl!);
        return NetworkImage(resolvedUrl);
      }
    } catch (e) {
      debugPrint('Impossible de charger l\'image distante: $e');
    }
    return const AssetImage('assets/images/pommes.png');
  }
}
