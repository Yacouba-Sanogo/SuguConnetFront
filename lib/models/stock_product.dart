class StockProduct {
  final int id;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final int minStockAlert;
  final String unit;
  final String category;
  final bool isBio;
  final String imageUrl;
  final String lastUpdated;
  final String status; // 'en_stock', 'stock_faible', 'epuise'
  final double totalValue;

  StockProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.minStockAlert,
    required this.unit,
    required this.category,
    required this.isBio,
    required this.imageUrl,
    required this.lastUpdated,
    required this.status,
    required this.totalValue,
  });

  factory StockProduct.fromJson(Map<String, dynamic> json) {
    // Afficher les données brutes pour le débogage
    print('Données brutes reçues: $json');

    return StockProduct(
      id: json['id'] as int? ?? 0,
      name: _getStringValue(json, 'name', 'nom') ?? 'Produit sans nom',
      description: _getStringValue(json, 'description') ?? '',
      price: _getNumericValue(json, 'prix', 'price') ?? 0.0,
      quantity: _getIntValue(json, 'quantite', 'quantity') ?? 0,
      minStockAlert: _getIntValue(json, 'seuilAlerte', 'minStockAlert') ?? 0,
      unit: _getStringValue(json, 'unite', 'unit') ?? '',
      category:
          _getStringValue(json, 'categorie', 'category') ?? 'Non catégorisé',
      isBio: json['bio'] as bool? ?? json['isBio'] as bool? ?? false,
      imageUrl: _getStringValue(json, 'imageUrl', 'image') ?? '',
      lastUpdated: _getStringValue(json, 'dateMiseAJour', 'lastUpdated') ?? '',
      status: _getStringValue(json, 'statut', 'status') ?? 'en_stock',
      totalValue: _getNumericValue(json, 'valeurTotale', 'totalValue') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nom': name, // Pour compatibilité avec le backend
      'description': description,
      'prix': price,
      'price': price, // Pour compatibilité avec différentes conventions
      'quantite': quantity,
      'quantity': quantity, // Pour compatibilité avec différentes conventions
      'seuilAlerte': minStockAlert,
      'minStockAlert':
          minStockAlert, // Pour compatibilité avec différentes conventions
      'unite': unit,
      'unit': unit, // Pour compatibilité avec différentes conventions
      'categorie': category,
      'category': category, // Pour compatibilité avec différentes conventions
      'bio': isBio,
      'isBio': isBio, // Pour compatibilité avec différentes conventions
      'imageUrl': imageUrl,
      'image': imageUrl, // Pour compatibilité avec différentes conventions
      'dateMiseAJour': lastUpdated,
      'lastUpdated':
          lastUpdated, // Pour compatibilité avec différentes conventions
      'statut': status,
      'status': status, // Pour compatibilité avec différentes conventions
      'valeurTotale': totalValue,
      'totalValue':
          totalValue, // Pour compatibilité avec différentes conventions
    };
  }

  // Méthode pour déterminer la couleur selon le statut
  String get statusColor {
    switch (status) {
      case 'en_stock':
        return 'green';
      case 'stock_faible':
        return 'orange';
      case 'epuise':
        return 'red';
      default:
        return 'grey';
    }
  }

  // Méthodes utilitaires pour gérer les différentes conventions de nommage
  static String? _getStringValue(Map<String, dynamic> json, String key1,
      [String? key2]) {
    // Essayer la première clé
    if (json.containsKey(key1)) {
      final value = json[key1];
      if (value != null) {
        return value.toString();
      }
    }

    // Essayer la deuxième clé si elle existe
    if (key2 != null && json.containsKey(key2)) {
      final value = json[key2];
      if (value != null) {
        return value.toString();
      }
    }

    return null;
  }

  static int? _getIntValue(Map<String, dynamic> json, String key1,
      [String? key2]) {
    // Essayer la première clé
    if (json.containsKey(key1)) {
      final value = json[key1];
      if (value != null) {
        if (value is int) return value;
        if (value is num) return value.toInt();
        try {
          return int.parse(value.toString());
        } catch (e) {
          // Ignorer et essayer la deuxième clé
        }
      }
    }

    // Essayer la deuxième clé si elle existe
    if (key2 != null && json.containsKey(key2)) {
      final value = json[key2];
      if (value != null) {
        if (value is int) return value;
        if (value is num) return value.toInt();
        try {
          return int.parse(value.toString());
        } catch (e) {
          // Ignorer
        }
      }
    }

    return null;
  }

  static double? _getNumericValue(Map<String, dynamic> json, String key1,
      [String? key2]) {
    // Essayer la première clé
    if (json.containsKey(key1)) {
      final value = json[key1];
      if (value != null) {
        if (value is double) return value;
        if (value is num) return value.toDouble();
        try {
          return double.parse(value.toString());
        } catch (e) {
          // Ignorer et essayer la deuxième clé
        }
      }
    }

    // Essayer la deuxième clé si elle existe
    if (key2 != null && json.containsKey(key2)) {
      final value = json[key2];
      if (value != null) {
        if (value is double) return value;
        if (value is num) return value.toDouble();
        try {
          return double.parse(value.toString());
        } catch (e) {
          // Ignorer
        }
      }
    }

    return null;
  }
}
