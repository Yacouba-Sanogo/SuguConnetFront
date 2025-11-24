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
      await orderService.updateOrderStatusByProducer(
        commandeId: widget.order.id,
        producteurId: userId,
        nouveauStatut: 'EN_LIVRAISON',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit expédié avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        // Revenir à l'écran précédent avec un indicateur de succès pour rafraîchir la liste
        Navigator.pop(context, true);
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
      await orderService.updateOrderStatusByProducer(
        commandeId: widget.order.id,
        producteurId: userId,
        nouveauStatut: 'VALIDEE',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expédition annulée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        // Revenir à l'écran précédent avec un indicateur de succès pour rafraîchir la liste
        Navigator.pop(context, true);
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
    final order = widget.order;
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
                            FutureBuilder<String>(
                              future: _getImageUrl(detail.produit),
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
                                      image: NetworkImage(snapshot.data!),
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

            // Bouton d'expédition (uniquement si la commande est payée et en attente)
            if (order.statut == 'EN_ATTENTE' &&
                order.paiement != null &&
                order.paiement!.estPaye) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _expedierCommande,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB662F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Expédier',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ] else if (order.statut == 'EN_LIVRAISON') ...[
              const Center(
                child: Chip(
                  label: Text('En cours de livraison'),
                  backgroundColor: Colors.orange,
                  labelStyle: TextStyle(color: Colors.white),
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
            ],
          ],
        ),
      ),
    );
  }

  // Méthode pour obtenir l'URL de l'image du produit
  Future<String> _getImageUrl(ProduitCommande produit) async {
    try {
      // Utiliser une image placeholder qui fonctionne avec Flutter
      return 'https://via.placeholder.com/100x100/FFA500/FFFFFF?text=Produit';
    } catch (e) {
      // En cas d'erreur, retourner une URL par défaut qui fonctionne
      return 'https://via.placeholder.com/100x100/CCCCCC/FFFFFF?text=Image';
    }
  }
}
