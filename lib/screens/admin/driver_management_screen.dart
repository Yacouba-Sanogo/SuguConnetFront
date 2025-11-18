import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';

class DriverManagementScreen extends StatefulWidget {
  const DriverManagementScreen({super.key});

  @override
  State<DriverManagementScreen> createState() => _DriverManagementScreenState();
}

class _DriverManagementScreenState extends State<DriverManagementScreen> {
  final List<Map<String, dynamic>> _drivers = [
    {
      'id': '1',
      'name': 'Diallo Ousmane',
      'phone': '+225 07 00 00 00 01',
      'vehicle': 'Moto-Yamaha',
      'plateNumber': 'AB 123 CD',
      'status': 'available',
      'rating': 4.8,
    },
    {
      'id': '2',
      'name': 'Kone Amadou',
      'phone': '+225 07 00 00 00 02',
      'vehicle': 'Voiture-Toyota',
      'plateNumber': 'EF 456 GH',
      'status': 'busy',
      'rating': 4.5,
    },
    {
      'id': '3',
      'name': 'Traoré Mamadou',
      'phone': '+225 07 00 00 00 03',
      'vehicle': 'Moto-Honda',
      'plateNumber': 'IJ 789 KL',
      'status': 'available',
      'rating': 4.9,
    },
  ];

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
          'Gestion des Livreurs',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
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
                    'Total',
                    _drivers.length.toString(),
                    Icons.local_shipping,
                    AppTheme.primaryColor,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                Expanded(
                  child: _buildStatItem(
                    'Disponibles',
                    _drivers.where((d) => d['status'] == 'available').length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                Expanded(
                  child: _buildStatItem(
                    'Occupés',
                    _drivers.where((d) => d['status'] == 'busy').length.toString(),
                    Icons.work,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Liste des livreurs
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _drivers.length,
              itemBuilder: (context, index) {
                return _buildDriverCard(_drivers[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDriverDialog,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter un livreur',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
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
                      ],
                    ),
                    const SizedBox(height: 4),
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
              
              // Informations supplémentaires
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    driver['plateNumber'],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.phone,
                      color: AppTheme.primaryColor,
                      size: 20,
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
              _buildInfoRow('Statut', driver['status'] == 'available' ? 'Disponible' : 'Occupé'),
              _buildInfoRow('Note', '${driver['rating']} ⭐'),
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

  void _showAddDriverDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final vehicleController = TextEditingController();
    final plateController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ajouter un livreur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: vehicleController,
                decoration: const InputDecoration(
                  labelText: 'Véhicule',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: plateController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de plaque',
                  border: OutlineInputBorder(),
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
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty &&
                  vehicleController.text.isNotEmpty &&
                  plateController.text.isNotEmpty) {
                setState(() {
                  _drivers.add({
                    'id': (_drivers.length + 1).toString(),
                    'name': nameController.text,
                    'phone': phoneController.text,
                    'vehicle': vehicleController.text,
                    'plateNumber': plateController.text,
                    'status': 'available',
                    'rating': 0.0,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Livreur ajouté avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
