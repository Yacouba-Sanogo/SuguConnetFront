import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';

// Page de gestion des paiements pour le producteur
class ProducerPaymentsScreen extends StatefulWidget {
  const ProducerPaymentsScreen({super.key});

  @override
  State<ProducerPaymentsScreen> createState() => _ProducerPaymentsScreenState();
}

class _ProducerPaymentsScreenState extends State<ProducerPaymentsScreen> with SingleTickerProviderStateMixin {
  // Contrôleur pour les onglets
  late TabController _tabController;
  
  // Liste des paiements reçus des consommateurs
  final List<Map<String, dynamic>> _receivedPayments = [
    {
      'id': '1',
      'orderNumber': 'CMD-001',
      'customer': 'Kone Mamadou',
      'product': 'Tomates fraîches',
      'amount': '5000',
      'paymentMethod': 'Mobile Money',
      'status': 'completed',
      'date': '2024-01-15',
      'time': '14:30',
    },
    {
      'id': '2',
      'orderNumber': 'CMD-003',
      'customer': 'Diallo Fatou',
      'product': 'Carottes bio',
      'amount': '3500',
      'paymentMethod': 'Virement bancaire',
      'status': 'completed',
      'date': '2024-01-14',
      'time': '10:15',
    },
    {
      'id': '3',
      'orderNumber': 'CMD-005',
      'customer': 'Traoré Ahmed',
      'product': 'Mangues',
      'amount': '8000',
      'paymentMethod': 'Paiement à la livraison',
      'status': 'pending',
      'date': '2024-01-13',
      'time': '16:45',
    },
  ];

  // Liste des remboursements à effectuer (approuvés par l'admin)
  final List<Map<String, dynamic>> _refundPayments = [
    {
      'id': '1',
      'orderNumber': 'CMD-002',
      'customer': 'Ouattara Mariam',
      'product': 'Oignons',
      'amount': '2500',
      'reason': 'Produit défectueux',
      'status': 'approved',
      'date': '2024-01-12',
      'adminApproval': 'Admin SuguConnect',
    },
    {
      'id': '2',
      'orderNumber': 'CMD-004',
      'customer': 'Cissé Ibrahim',
      'product': 'Pommes',
      'amount': '6000',
      'reason': 'Commande non reçue',
      'status': 'approved',
      'date': '2024-01-11',
      'adminApproval': 'Admin SuguConnect',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialiser le contrôleur des onglets (2 onglets)
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fonction pour effectuer un remboursement
  void _processRefund(Map<String, dynamic> refund) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.money_off, color: Colors.red),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Confirmer le remboursement',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRefundDetailRow('Client', refund['customer']),
              _buildRefundDetailRow('Commande', refund['orderNumber']),
              _buildRefundDetailRow('Montant', '${refund['amount']} fcfa'),
              _buildRefundDetailRow('Raison', refund['reason']),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ce remboursement a été approuvé par l\'administrateur.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeRefund(refund);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Effectuer le remboursement',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher les détails du remboursement
  Widget _buildRefundDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour finaliser le remboursement
  void _completeRefund(Map<String, dynamic> refund) {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Traitement du remboursement...',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );

    // Simuler le traitement du remboursement
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Fermer le dialogue de chargement
      
      // Mettre à jour le statut du remboursement
      setState(() {
        refund['status'] = 'completed';
      });
      
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Remboursement effectué avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  // Fonction pour obtenir la couleur du statut
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Fonction pour obtenir le texte du statut
  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Terminé';
      case 'pending':
        return 'En attente';
      case 'approved':
        return 'Approuvé';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // AppBar avec onglets
          Container(
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Gestion des Paiements',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Onglets
                TabBar(
                  controller: _tabController,
                  onTap: (index) => setState(() {}),
                  indicatorColor: AppTheme.primaryColor,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Paiements Reçus'),
                    Tab(text: 'Remboursements'),
                  ],
                ),
              ],
            ),
          ),

          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Onglet 1: Paiements reçus
                _buildReceivedPaymentsTab(),
                // Onglet 2: Remboursements
                _buildRefundPaymentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour l'onglet des paiements reçus
  Widget _buildReceivedPaymentsTab() {
    return Column(
      children: [
        // Statistiques
        Container(
          margin: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Reçu',
                  '${_receivedPayments.where((p) => p['status'] == 'completed').fold(0, (sum, p) => sum + int.parse(p['amount']))} fcfa',
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              Expanded(
                child: _buildStatItem(
                  'En Attente',
                  '${_receivedPayments.where((p) => p['status'] == 'pending').length}',
                  Icons.schedule,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ),

        // Liste des paiements
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _receivedPayments.length,
            itemBuilder: (context, index) {
              return _buildReceivedPaymentCard(_receivedPayments[index]);
            },
          ),
        ),
      ],
    );
  }

  // Widget pour l'onglet des remboursements
  Widget _buildRefundPaymentsTab() {
    return Column(
      children: [
        // Statistiques
        Container(
          margin: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'À Rembourser',
                  '${_refundPayments.where((r) => r['status'] == 'approved').fold(0, (sum, r) => sum + int.parse(r['amount']))} fcfa',
                  Icons.money_off,
                  Colors.red,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              Expanded(
                child: _buildStatItem(
                  'Effectués',
                  '${_refundPayments.where((r) => r['status'] == 'completed').length}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
        ),

        // Liste des remboursements
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _refundPayments.length,
            itemBuilder: (context, index) {
              return _buildRefundPaymentCard(_refundPayments[index]);
            },
          ),
        ),
      ],
    );
  }

  // Widget pour les statistiques
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // Widget pour une carte de paiement reçu
  Widget _buildReceivedPaymentCard(Map<String, dynamic> payment) {
    Color statusColor = _getStatusColor(payment['status']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${payment['amount']} fcfa',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        payment['orderNumber'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(payment['status']),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment['product'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        payment['customer'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      payment['paymentMethod'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${payment['date']} ${payment['time']}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour une carte de remboursement
  Widget _buildRefundPaymentCard(Map<String, dynamic> refund) {
    Color statusColor = _getStatusColor(refund['status']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.money_off,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${refund['amount']} fcfa',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        refund['orderNumber'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(refund['status']),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        refund['product'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        refund['customer'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Raison: ${refund['reason']}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      refund['date'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    if (refund['status'] == 'approved') ...[
                      const SizedBox(height: 4),
                      ElevatedButton(
                        onPressed: () => _processRefund(refund),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: const Text(
                          'Rembourser',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
