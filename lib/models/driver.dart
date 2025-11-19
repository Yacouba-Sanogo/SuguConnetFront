class Driver {
  final String id;
  final String name;
  final String phone;
  final String vehicle;
  final String plateNumber;
  final String status; // 'available' ou 'busy'
  final double rating;
  final int totalDeliveries;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicle,
    required this.plateNumber,
    required this.status,
    required this.rating,
    required this.totalDeliveries,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    // Extraire nom et prénom du backend
    final nom = json['nom'] as String? ?? '';
    final prenom = json['prenom'] as String? ?? '';
    final fullName = '$prenom $nom'.trim();

    return Driver(
      id: (json['id'] as int).toString(),
      name: fullName.isNotEmpty ? fullName : 'Nom inconnu',
      phone: json['telephone'] as String? ?? '',
      vehicle: json['vehicule'] as String? ?? '',
      plateNumber: json['matricule'] as String? ?? '',
      status: (json['disponible'] as bool? ?? false) ? 'available' : 'busy',
      rating: 0.0, // Le backend ne fournit pas de rating
      totalDeliveries: 0, // Le backend ne fournit pas le nombre de livraisons
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'vehicle': vehicle,
      'plateNumber': plateNumber,
      'status': status,
      'rating': rating,
      'totalDeliveries': totalDeliveries,
    };
  }
}
