import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';

class RefundRequestScreen extends StatefulWidget {
  final Map<String, dynamic> order;

  const RefundRequestScreen({super.key, required this.order});

  @override
  State<RefundRequestScreen> createState() => _RefundRequestScreenState();
}

class _RefundRequestScreenState extends State<RefundRequestScreen> {
  String? _selectedReason;
  String _description = '';
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _refundReasons = [
    'Produit défectueux',
    'Produit non conforme',
    'Produit abîmé à la réception',
    'Produit expiré',
    'Commande non reçue',
    'Autre raison',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitRefundRequest() {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une raison'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez décrire votre demande'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Afficher une confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Confirmer la demande'),
          ],
        ),
        content: const Text(
          'Votre demande de remboursement sera envoyée au producteur pour traitement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialog
              Navigator.pop(context); // Retour à la page précédente
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demande de remboursement envoyée avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Demande de remboursement',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations de la commande
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.receipt_long,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Commande',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '#${widget.order['number'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${widget.order['amount'] ?? '0'} fcfa',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Text(
                    widget.order['product'] ?? 'Produit non spécifié',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Raison du remboursement
            const Text(
              'Raison du remboursement',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ..._refundReasons.map((reason) => _buildReasonOption(reason)).toList(),

            const SizedBox(height: 24),

            // Description
            const Text(
              'Description détaillée',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              onChanged: (value) => setState(() => _description = value),
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Décrivez votre demande de remboursement...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 32),

            // Bouton de soumission
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRefundRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Envoyer la demande',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonOption(String reason) {
    final isSelected = _selectedReason == reason;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedReason = reason),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppTheme.primaryColor.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.primaryColor
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    reason,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryColor : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
