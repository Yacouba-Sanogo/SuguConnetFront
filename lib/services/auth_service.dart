import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

// Service d'authentification pour les appels API
class AuthService {
  // URL de base résolue dynamiquement (mise en cache)
  static String? _baseUrl; // ex: http://10.0.2.2:8080/suguconnect
  static String? get resolvedBaseUrl => _baseUrl;

  // Génère la liste des hôtes candidats selon l'environnement
  static List<String> _candidateHosts() {
    const lanIp = '10.175.47.42'; // Utilisation de votre adresse IP réelle
    const port = 8080;
    const contextPath = 'suguconnect';

    String build(String host) => 'http://$host:$port/$contextPath';

    if (kIsWeb) {
      return [build(lanIp)];
    }

    if (Platform.isAndroid) {
      return [
        build('10.0.2.2'), // Émulateur Android -> host machine
        build(lanIp),
        build('127.0.0.1'),
      ];
    }

    return [
      build('127.0.0.1'),
      build(lanIp),
    ];
  }

  static Future<void> _ensureBaseUrl() async {
    if (_baseUrl != null) return;
    final candidates = _candidateHosts();
    for (final base in candidates) {
      if (await _ping(base)) {
        _baseUrl = base;
        break;
      }
    }
    _baseUrl ??= candidates.first;
  }

  static Future<bool> _ping(String base) async {
    try {
      final resp = await http
          .get(Uri.parse('$base/v3/api-docs'))
          .timeout(const Duration(seconds: 2));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      await _ensureBaseUrl();
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ' + token,
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final body = response.body.isNotEmpty ? response.body : '';
        throw Exception('HTTP ' +
            response.statusCode.toString() +
            ' ' +
            (response.reasonPhrase ?? '') +
            ' ' +
            body);
      }
    } catch (e) {
      throw Exception('Erreur réseau: ' + e.toString());
    }
  }

  // Headers communs pour toutes les requêtes
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json', // Type de contenu JSON
        'Accept': 'application/json', // Acceptation du JSON
      };

  // Méthode de connexion utilisateur (avec numéro de téléphone)
  static Future<Map<String, dynamic>> login(
      String telephone, String password) async {
    try {
      await _ensureBaseUrl();
      // Envoi de la requête POST vers l'endpoint de connexion
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'telephone': telephone,
          'motDePasse': password,
        }),
      );

      // Vérification du statut de la réponse
      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retour des données JSON
      } else {
        final body = response.body.isNotEmpty ? response.body : '';
        throw Exception(
            'HTTP ${response.statusCode} ${response.reasonPhrase ?? ''} ${body}'
                .trim());
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
      await _ensureBaseUrl();
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register/consommateur'),
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

  // Inscription Producteur (conforme à ProducteurRequestDTO et /producteur/inscription)
  static Future<Map<String, dynamic>> registerProducer({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String telephone,
    required String localisation,
    required int latitude,
    required int longitude,
    required String nomFerme,
    required String description,
  }) async {
    try {
      await _ensureBaseUrl();
      final uri = Uri.parse('$_baseUrl/producteur/inscription');
      final payload = {
        'nom': nom,
        'prenom': prenom,
        'telephone': telephone,
        'email': email,
        'localisation': localisation,
        'latitude': latitude,
        'longitude': longitude,
        'motDePasse': motDePasse,
        'description': description,
        'nomFerme': nomFerme,
      };
      final headers = {
        ..._headers,
        'Accept': 'application/json,text/plain,*/*',
      };
      assert(() {
        // Debug log en mode dev
        // ignore: avoid_print
        print('[AuthService] POST ' +
            uri.toString() +
            ' payload=' +
            payload.toString());
        return true;
      }());
      final response =
          await http.post(uri, headers: headers, body: jsonEncode(payload));

      // Backend renvoie 201 et un texte (pas JSON)
      if (response.statusCode == 201 || response.statusCode == 200) {
        final msg =
            response.body.isNotEmpty ? response.body : 'Inscription réussie';
        return {'message': msg};
      } else {
        final body = response.body;
        if (response.statusCode == 403) {
          throw Exception(
              'HTTP 403: Accès interdit à /producteur/inscription. Vérifiez la configuration de sécurité backend. Détails: ' +
                  body);
        }
        throw Exception('HTTP ' +
            response.statusCode.toString() +
            ' ' +
            (response.reasonPhrase ?? '') +
            ' ' +
            body);
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  // Test de connexion à l'API
  static Future<bool> testConnection() async {
    try {
      await _ensureBaseUrl();
      final response = await http.get(
        Uri.parse('$_baseUrl/v3/api-docs'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
