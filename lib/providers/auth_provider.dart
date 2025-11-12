import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// Modèle utilisateur simple pour l'authentification
class User {
  final int? id; // Identifiant unique de l'utilisateur
  final String nom; // Nom de famille
  final String prenom; // Prénom
  final String email; // Adresse email
  final String telephone; // Téléphone
  final String role; // Rôle (producteur ou consommateur)

  User({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.role,
  });
}

// Gestionnaire d'état pour l'authentification des utilisateurs
class AuthProvider with ChangeNotifier {
  // Utilisateur actuellement connecté
  User? _currentUser;
  // Token d'authentification
  String? _token;
  // État de chargement
  bool _isLoading = false;
  // Message d'erreur
  String? _error;

  // Getters pour accéder aux propriétés privées
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  String get userRole => _currentUser?.role ?? '';

  // Méthode de connexion simplifiée (avec numéro de téléphone)
  Future<void> login(String telephone, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Test de connexion à l'API
      final isConnected = await AuthService.testConnection();
      if (!isConnected) {
        throw Exception('Impossible de se connecter au serveur. Vérifiez que le backend est démarré.');
      }

      // Appel de l'API de connexion avec le numéro de téléphone
      final result = await AuthService.login(telephone, password);

      // Renseigner l'utilisateur et le token avec la réponse backend
      _currentUser = User(
        id: result['userId'],
        nom: result['nom'] ?? '',
        prenom: result['prenom'] ?? '',
        email: result['email'] ?? '',
        telephone: result['telephone'] ?? '',
        role: (result['role'] ?? '').toString(),
      );

      _token = result['token'];
      notifyListeners();
    } catch (e) {
      _setError('Erreur de connexion: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Méthode d'inscription producteur
  Future<void> registerProducteur({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String telephone,
    required String adresse,
    required String nomEntreprise,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Test de connexion à l'API
      final isConnected = await AuthService.testConnection();
      if (!isConnected) {
        throw Exception('Impossible de se connecter au serveur. Vérifiez que le backend est démarré.');
      }

      // Appel de l'API d'inscription producteur (ProducteurRequestDTO)
      await AuthService.registerProducer(
        nom: nom,
        prenom: prenom,
        email: email,
        motDePasse: motDePasse,
        telephone: telephone,
        localisation: adresse, // mappe adresse -> localisation
        latitude: 0, // TODO: remplacer par géolocalisation réelle
        longitude: 0, // TODO: remplacer par géolocalisation réelle
        nomFerme: nomEntreprise, // mappe nomEntreprise -> nomFerme
        description: '',
      );
      
      // Pour la démo, on simule un utilisateur inscrit
      _currentUser = User(
        id: 1,
        nom: nom,
        prenom: prenom,
        email: email,
        telephone: telephone,
        role: 'PRODUCTEUR',
      );
      
      _token = 'token_simulé';
      notifyListeners();
    } catch (e) {
      _setError('Erreur d\'inscription: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Méthode d'inscription consommateur simplifiée
  Future<void> registerConsommateur({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String telephone,
    required String adresse,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Test de connexion à l'API
      final isConnected = await AuthService.testConnection();
      if (!isConnected) {
        throw Exception('Impossible de se connecter au serveur. Vérifiez que le backend est démarré.');
      }

      // Appel de l'API d'inscription
      await AuthService.registerConsumer(
        nom: nom,
        prenom: prenom,
        email: email,
        motDePasse: motDePasse,
        telephone: telephone,
        adresse: adresse,
      );
      
      // Pour la démo, on simule un utilisateur inscrit
      _currentUser = User(
        id: 1,
        nom: nom,
        prenom: prenom,
        email: email,
        telephone: telephone,
        role: 'CONSOMMATEUR',
      );
      
      _token = 'token_simulé';
      notifyListeners();
    } catch (e) {
      _setError('Erreur d\'inscription: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Méthode de déconnexion simplifiée
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
