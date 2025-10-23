import 'dart:convert';
import 'package:http/http.dart' as http;

// Service d'authentification pour les appels API
class AuthService {
  // URL de base de l'API backend
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Headers communs pour toutes les requêtes
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json', // Type de contenu JSON
    'Accept': 'application/json', // Acceptation du JSON
  };

  // Méthode de connexion utilisateur
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Envoi de la requête POST vers l'endpoint de connexion
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Vérification du statut de la réponse
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retour des données JSON
      } else {
        throw Exception('Erreur de connexion: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Inscription Consommateur
  static Future<Map<String, dynamic>> registerConsumer({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String telephone,
    required String adresse,
    String? preferencesAlimentaires,
    String? allergies,
    String? adresseLivraison,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/consommateur'),
        headers: _headers,
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'motDePasse': motDePasse,
          'telephone': telephone,
          'adresse': adresse,
          'preferencesAlimentaires': preferencesAlimentaires ?? '',
          'allergies': allergies ?? '',
          'adresseLivraison': adresseLivraison ?? adresse,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Erreur d\'inscription: ${errorBody.toString()}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Inscription Producteur
  static Future<Map<String, dynamic>> registerProducer({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String telephone,
    required String adresse,
    required String nomEntreprise,
    required String description,
    required String specialite,
    String? siteWeb,
    String? coordonneesGPS,
    bool certifieBio = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/producteur'),
        headers: _headers,
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'motDePasse': motDePasse,
          'telephone': telephone,
          'adresse': adresse,
          'nomEntreprise': nomEntreprise,
          'description': description,
          'specialite': specialite,
          'siteWeb': siteWeb ?? '',
          'coordonneesGPS': coordonneesGPS ?? '',
          'certifieBio': certifieBio,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception('Erreur d\'inscription: ${errorBody.toString()}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Test de connexion à l'API
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test/hello'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}