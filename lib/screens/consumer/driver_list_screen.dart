import 'package:flutter/material.dart';
import 'package:suguconnect_mobile/theme/app_theme.dart';
<<<<<<< HEAD
import '../../models/driver.dart';
import '../../services/driver_service.dart';

class DriverListScreen extends StatefulWidget {
  final bool selectionMode;
  final Function(Map<String, dynamic>)? onDriverSelected;

  const DriverListScreen(
      {super.key, this.selectionMode = false, this.onDriverSelected});
=======

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});
>>>>>>> f8cdcc2 (commit pour le premier)

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
<<<<<<< HEAD
  final DriverService _driverService = DriverService();
  String _selectedFilter = 'Tous'; // Tous, Disponibles, Occupés
  List<Driver> _allDrivers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final drivers = await _driverService.getAllDrivers();
      setState(() {
        _allDrivers = drivers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des livreurs: $e';
        _isLoading = false;
      });
    }
  }

  List<Driver> get _filteredDrivers {
    if (_selectedFilter == 'Tous') {
      return _allDrivers;
    } else if (_selectedFilter == 'Disponibles') {
      return _allDrivers.where((d) => d.status == 'available').toList();
    } else {
      return _allDrivers.where((d) => d.status == 'busy').toList();
=======
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
>>>>>>> f8cdcc2 (commit pour le premier)
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
<<<<<<< HEAD
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDrivers,
          ),
        ],
=======
>>>>>>> f8cdcc2 (commit pour le premier)
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
<<<<<<< HEAD
            child: _buildDriverList(),
=======
            child: _filteredDrivers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredDrivers.length,
                    itemBuilder: (context, index) {
                      return _buildDriverCard(_filteredDrivers[index]);
                    },
                  ),
>>>>>>> f8cdcc2 (commit pour le premier)
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildDriverList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDrivers,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_filteredDrivers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredDrivers.length,
      itemBuilder: (context, index) {
        return _buildDriverCard(_filteredDrivers[index]);
      },
    );
  }

=======
>>>>>>> f8cdcc2 (commit pour le premier)
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

<<<<<<< HEAD
  Widget _buildDriverCard(Driver driver) {
    Color statusColor =
        driver.status == 'available' ? Colors.green : Colors.orange;

    // Convertir le driver en Map pour rester compatible avec le code existant
    final driverMap = {
      'id': driver.id,
      'name': driver.name,
      'phone': driver.phone,
      'vehicle': driver.vehicle,
      'plateNumber': driver.plateNumber,
      'status': driver.status,
      'rating': driver.rating,
      'totalDeliveries': driver.totalDeliveries,
    };

=======
  Widget _buildDriverCard(Map<String, dynamic> driver) {
    Color statusColor = driver['status'] == 'available' ? Colors.green : Colors.orange;
    
>>>>>>> f8cdcc2 (commit pour le premier)
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
<<<<<<< HEAD
        onTap: () => widget.selectionMode
            ? _selectDriver(driverMap)
            : _showDriverDetails(driverMap),
=======
        onTap: () => _showDriverDetails(driver),
>>>>>>> f8cdcc2 (commit pour le premier)
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
<<<<<<< HEAD

=======
              
>>>>>>> f8cdcc2 (commit pour le premier)
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
<<<<<<< HEAD
                            driver.name,
=======
                            driver['name'],
>>>>>>> f8cdcc2 (commit pour le premier)
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
<<<<<<< HEAD
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
=======
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
>>>>>>> f8cdcc2 (commit pour le premier)
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
<<<<<<< HEAD
                            driver.status == 'available'
                                ? 'Disponible'
                                : 'Occupé',
=======
                            driver['status'] == 'available' ? 'Disponible' : 'Occupé',
>>>>>>> f8cdcc2 (commit pour le premier)
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
<<<<<<< HEAD
                          driver.rating.toString(),
=======
                          driver['rating'].toString(),
>>>>>>> f8cdcc2 (commit pour le premier)
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
<<<<<<< HEAD
                        Icon(Icons.delivery_dining,
                            color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${driver.totalDeliveries} livraisons',
=======
                        Icon(Icons.delivery_dining, color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${driver['totalDeliveries']} livraisons',
>>>>>>> f8cdcc2 (commit pour le premier)
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
<<<<<<< HEAD
                      driver.vehicle,
=======
                      driver['vehicle'],
>>>>>>> f8cdcc2 (commit pour le premier)
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
<<<<<<< HEAD

              // Bouton contact ou sélection
=======
              
              // Bouton contact
>>>>>>> f8cdcc2 (commit pour le premier)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
<<<<<<< HEAD
                  widget.selectionMode ? Icons.check : Icons.phone,
=======
                  Icons.phone,
>>>>>>> f8cdcc2 (commit pour le premier)
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

<<<<<<< HEAD
  void _selectDriver(Map<String, dynamic> driver) {
    if (widget.onDriverSelected != null) {
      widget.onDriverSelected!(driver);
      Navigator.pop(context, driver);
    }
  }

=======
>>>>>>> f8cdcc2 (commit pour le premier)
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
<<<<<<< HEAD
              _buildInfoRow('Statut',
                  driver['status'] == 'available' ? 'Disponible' : 'Occupé'),
=======
              _buildInfoRow('Statut', driver['status'] == 'available' ? 'Disponible' : 'Occupé'),
>>>>>>> f8cdcc2 (commit pour le premier)
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
