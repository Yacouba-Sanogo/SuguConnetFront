import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  String _selectedFilter = 'Tous'; // Tous, Disponibles, Occupés
  
  final List<Map<String, dynamic>> _allDrivers = [
    {
      'id': '1',
      'name': 'Diallo Ousmane',
      'phone': '+225 07 00 00 00 01',
      'vehicle': 'Moto-Yamaha',
      'plateNumber': 'AB 123 CD',
      'status': 'available',
      'rating': 4.8,
      'totalDeliveries': 150,
    },
    {
      'id': '2',
      'name': 'Kone Amadou',
      'phone': '+225 07 00 00 00 02',
      'vehicle': 'Voiture-Toyota',
      'plateNumber': 'EF 456 GH',
      'status': 'busy',
      'rating': 4.5,
      'totalDeliveries': 89,
    },
    {
      'id': '3',
      'name': 'Traoré Mamadou',
      'phone': '+225 07 00 00 00 03',
      'vehicle': 'Moto-Honda',
      'plateNumber': 'IJ 789 KL',
      'status': 'available',
      'rating': 4.9,
      'totalDeliveries': 203,
    },
  ];

  List<Map<String, dynamic>> get _filteredDrivers {
    if (_selectedFilter == 'Tous') {
      return _allDrivers;
    } else if (_selectedFilter == 'Disponibles') {
      return _allDrivers.where((d) => d['status'] == 'available').toList();
    } else {
      return _allDrivers.where((d) => d['status'] == 'busy').toList();
    }
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
          'Livreurs',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildFilterChip('Tous'),
                _buildFilterChip('Disponibles'),
                _buildFilterChip('Occupés'),
              ],
            ),
          ),

          // Liste des livreurs
          Expanded(
            child: _filteredDrivers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredDrivers.length,
                    itemBuilder: (context, index) {
                      return _buildDriverCard(_filteredDrivers[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedFilter = label;
            });
          },
          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryColor : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_shipping, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucun livreur ${_selectedFilter.toLowerCase()}',
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

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    Color statusColor = driver['status'] == 'available' ? Colors.green : Colors.orange;
    
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
        onTap: () => _showDriverDetails(driver),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Photo du livreur
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            driver['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            driver['status'] == 'available' ? 'Disponible' : 'Occupé',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          driver['rating'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.delivery_dining, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${driver['totalDeliveries']} livraisons',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      driver['vehicle'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bouton contact
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.phone,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDriverDetails(Map<String, dynamic> driver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.person, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Expanded(child: Text('Informations du livreur')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Nom', driver['name']),
              _buildInfoRow('Téléphone', driver['phone']),
              _buildInfoRow('Véhicule', driver['vehicle']),
              _buildInfoRow('Plaque', driver['plateNumber']),
              _buildInfoRow('Note', '${driver['rating']} ⭐'),
              _buildInfoRow('Livraisons', '${driver['totalDeliveries']}'),
              _buildInfoRow('Statut', driver['status'] == 'available' ? 'Disponible' : 'Occupé'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Le contact du livreur est hors du système'),
                  backgroundColor: Colors.blue,
                ),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.phone),
            label: const Text('Contacter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
}
