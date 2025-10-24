import 'package:flutter/material.dart';

// Page de détail d'une commande spécifique
class OrderDetailPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Commande n°$orderId',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFB662F).withOpacity(0.3),
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations de la commande
            _buildInfoCard(
              'Informations de la commande',
              [
                _buildInfoRow('Numéro de commande', orderId),
                _buildInfoRow('Client', client),
                _buildInfoRow('Statut', status),
                _buildInfoRow('Date', date),
                _buildInfoRow('Total', '${total.toStringAsFixed(0)} FCFA'),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Statut de la commande
            _buildStatusCard(),
            
            const SizedBox(height: 20),
            
            // Actions
            _buildActionsCard(context),
          ],
        ),
      ),
    );
  }

  // Construit une carte d'informations
  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // Construit une ligne d'information
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Construit la carte de statut
  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status == 'Livrée' ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status == 'Livrée' ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            status == 'Livrée' ? Icons.check_circle : Icons.schedule,
            color: status == 'Livrée' ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statut: $status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: status == 'Livrée' ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status == 'Livrée' 
                      ? 'Votre commande a été livrée avec succès'
                      : 'Votre commande est en cours de traitement',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Construit la carte d'actions
  Widget _buildActionsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Action pour suivre la commande
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Suivi de commande activé')),
                    );
                  },
                  icon: const Icon(Icons.track_changes),
                  label: const Text('Suivre'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB662F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Action pour contacter le support
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contact support activé')),
                    );
                  },
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Support'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFB662F),
                    side: const BorderSide(color: Color(0xFFFB662F)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
