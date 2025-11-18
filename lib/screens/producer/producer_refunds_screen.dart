import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';

class ProducerRefundsScreen extends StatefulWidget {
  const ProducerRefundsScreen({super.key});

  @override
  State<ProducerRefundsScreen> createState() => _ProducerRefundsScreenState();
}

class _ProducerRefundsScreenState extends State<ProducerRefundsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _refundRequests = [
    {
      'id': '1',
      'orderNumber': 'CMD-001',
      'product': 'Tomates fraîches',
      'amount': '5000',
      'reason': 'Produit défectueux',
      'description': 'Les tomates étaient toutes abîmées',
      'customer': 'Kone Mamadou',
      'date': '2024-01-15',
      'status': 'pending',
    },
    {
      'id': '2',
      'orderNumber': 'CMD-005',
      'product': 'Carottes bio',
      'amount': '3500',
      'reason': 'Produit non conforme',
      'description': 'La qualité ne correspond pas à la description',
      'customer': 'Diallo Fatou',
      'date': '2024-01-14',
      'status': 'approved',
    },
    {
      'id': '3',
      'orderNumber': 'CMD-008',
      'product': 'Mangues',
      'amount': '8000',
      'reason': 'Commande non reçue',
      'description': 'Je n\'ai pas reçu ma commande',
      'customer': 'Traoré Ahmed',
      'date': '2024-01-13',
      'status': 'rejected',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredRequests {
    String status = _getStatusForTab(_tabController.index);
    return _refundRequests.where((request) => request['status'] == status).toList();
  }

  String _getStatusForTab(int index) {
    switch (index) {
      case 0: return 'pending';
      case 1: return 'approved';
      case 2: return 'rejected';
      default: return 'pending';
    }
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Expanded(child: Text('Détails de la demande')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Commande', request['orderNumber']),
              _buildDetailRow('Produit', request['product']),
              _buildDetailRow('Client', request['customer']),
              _buildDetailRow('Montant', '${request['amount']} fcfa'),
              _buildDetailRow('Raison', request['reason']),
              _buildDetailRow('Description', request['description']),
              _buildDetailRow('Date', request['date']),
              _buildDetailRow('Statut', _getStatusText(request['status'])),
            ],
          ),
        ),
        actions: request['status'] == 'pending'
            ? [
                TextButton(
                  onPressed: () => _rejectRequest(request),
                  child: const Text('Rejeter'),
                ),
                ElevatedButton(
                  onPressed: () => _approveRequest(request),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Approuver'),
                ),
              ]
            : [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
      ),
    );
  }

  void _approveRequest(Map<String, dynamic> request) {
    setState(() {
      request['status'] = 'approved';
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Remboursement approuvé avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectRequest(Map<String, dynamic> request) {
    setState(() {
      request['status'] = 'rejected';
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demande de remboursement rejetée'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'approved':
        return 'Approuvé';
      case 'rejected':
        return 'Rejeté';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // AppBar
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
                        'Demandes de remboursement',
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
                    Tab(text: 'En attente'),
                    Tab(text: 'Approuvées'),
                    Tab(text: 'Rejetées'),
                  ],
                ),
              ],
            ),
          ),

          // Liste des demandes
          Expanded(
            child: _filteredRequests.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredRequests.length,
                    itemBuilder: (context, index) {
                      return _buildRefundCard(_filteredRequests[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.money_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucune demande',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundCard(Map<String, dynamic> request) {
    Color statusColor = _getStatusColor(request['status']);
    
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
      child: InkWell(
        onTap: () => _showRequestDetails(request),
        borderRadius: BorderRadius.circular(16),
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
                          '${request['amount']} fcfa',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: statusColor,
                          ),
                        ),
                        Text(
                          request['orderNumber'],
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
                      _getStatusText(request['status']),
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
                          request['product'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          request['customer'],
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    request['date'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
