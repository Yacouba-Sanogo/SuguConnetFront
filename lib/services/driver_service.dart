import '../models/driver.dart';
import 'api_service.dart';
import 'package:dio/dio.dart';

class DriverService {
  final ApiService _apiService = ApiService();
  final Dio _dio = Dio();

  /// Récupérer tous les livreurs
  Future<List<Driver>> getAllDrivers() async {
    try {
      // Utilisation de l'endpoint public avec l'adresse IP correcte
      final response = await _dio.get<List<dynamic>>(
        'http://10.175.47.42:8080/suguconnect/public/livreurs/all',
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => Driver.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        // En attendant que le backend soit corrigé, retourner des données temporaires
        return _getTemporaryDrivers();
      }
    } catch (e) {
      // En attendant que le backend soit corrigé, retourner des données temporaires
      print('Erreur lors de la récupération des livreurs: $e');
      return _getTemporaryDrivers();
    }
  }

  /// Récupérer les livreurs disponibles
  Future<List<Driver>> getAvailableDrivers() async {
    try {
      // Utilisation de l'endpoint public avec l'adresse IP correcte
      final response = await _dio.get<List<dynamic>>(
        'http://10.175.47.42:8080/suguconnect/public/livreurs/disponibles',
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => Driver.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        // En attendant que le backend soit corrigé, retourner des données temporaires
        return _getTemporaryDrivers()
            .where((d) => d.status == 'available')
            .toList();
      }
    } catch (e) {
      // En attendant que le backend soit corrigé, retourner des données temporaires
      print('Erreur lors de la récupération des livreurs disponibles: $e');
      return _getTemporaryDrivers()
          .where((d) => d.status == 'available')
          .toList();
    }
  }

  /// Récupérer un livreur par son ID
  Future<Driver> getDriverById(String id) async {
    try {
      // Endpoint à adapter selon votre backend
      final response = await _dio.get<Map<String, dynamic>>(
        'http://10.175.47.42:8080/suguconnect/admin/livreurs/$id',
      );

      if (response.statusCode == 200) {
        return Driver.fromJson(response.data!);
      } else {
        throw Exception(
            'Erreur lors de la récupération du livreur: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération du livreur: $e');
    }
  }

  /// Données temporaires en attendant que le backend soit corrigé
  List<Driver> _getTemporaryDrivers() {
    return [
      Driver(
        id: '1',
        name: 'Diallo Ousmane',
        phone: '+225 07 00 00 00 01',
        vehicle: 'Moto-Yamaha',
        plateNumber: 'AB 123 CD',
        status: 'available',
        rating: 4.8,
        totalDeliveries: 150,
      ),
      Driver(
        id: '2',
        name: 'Kone Amadou',
        phone: '+225 07 00 00 00 02',
        vehicle: 'Voiture-Toyota',
        plateNumber: 'EF 456 GH',
        status: 'busy',
        rating: 4.5,
        totalDeliveries: 89,
      ),
      Driver(
        id: '3',
        name: 'Traoré Mamadou',
        phone: '+225 07 00 00 00 03',
        vehicle: 'Moto-Honda',
        plateNumber: 'IJ 789 KL',
        status: 'available',
        rating: 4.9,
        totalDeliveries: 203,
      ),
    ];
  }
}
