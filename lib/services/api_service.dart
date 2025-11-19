import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

// URL de base de l'API - à modifier selon l'environnement
<<<<<<< HEAD
const String BASE_API_URL = 'http://10.175.47.42:8080';
=======
const String BASE_API_URL = 'http://10.175.47.34:8080';
>>>>>>> f8cdcc2 (commit pour le premier)

const String BASE_URL = '$BASE_API_URL/suguconnect';

// URL de base pour les fichiers uploadés
const String UPLOADS_BASE_URL = '$BASE_URL/uploads';

class ApiService {
  Dio? _dio;
  String? _token;

  ApiService();

  Future<void> _ensureClient() async {
    if (_dio != null) return;
    print('=== Résolution de l\'URL de base ===');
    // Resolve base URL dynamically via AuthService (handles 10.0.2.2, LAN IP, etc.)
    await AuthService
        .testConnection(); // Cela appelle _ensureBaseUrl en interne
    final base =
        AuthService.resolvedBaseUrl ?? 'http://10.0.2.2:8080/suguconnect';
    print('URL de base résolue: $base');
    _dio = Dio(BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print(
            'Requête envoyée: ${options.method} ${options.baseUrl}${options.path}');
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        print('Erreur de requête: ${error.toString()}');
        if (error.response?.statusCode == 401) {
          _clearToken();
        }
        handler.next(error);
      },
    ));
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _ensureClient();
    await _loadToken();
<<<<<<< HEAD

    // Log pour le débogage
    print('=== Requête GET ===');
    print('Path: $path');
    print('Query parameters: $queryParameters');

=======
>>>>>>> f8cdcc2 (commit pour le premier)
    return _dio!.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _ensureClient();
    await _loadToken();
    return _dio!.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _ensureClient();
    await _loadToken();
    return _dio!.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _ensureClient();
    await _loadToken();
    return _dio!.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<void> setAuthToken(String token) async {
    await _saveToken(token);
  }

  Future<void> clearAuthToken() async {
    await _clearToken();
  }

  bool get isAuthenticated => _token != null;

  // Méthode utilitaire pour obtenir l'URL de base
  Future<String> getBaseUrl() async {
    await _ensureClient();
    final base = _dio?.options.baseUrl ?? 'http://10.0.2.2:8080/suguconnect';
    return base.replaceAll('/suguconnect', '');
  }

  // Méthode utilitaire pour charger une image depuis le serveur
  Future<String> buildImageUrl(String imagePath) async {
    await _ensureClient();
    final base = _dio?.options.baseUrl ?? 'http://10.0.2.2:8080/suguconnect';

    // Si l'URL est déjà absolue, la retourner directement
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // Si le chemin commence par /files/download/, le convertir en /uploads/
    if (imagePath.startsWith('/files/download/')) {
      final fileName = imagePath.split('/').last;
      return '$base/uploads/$fileName';
    }

    // Si le chemin commence par /suguconnect/files/download/, le convertir en /uploads/
    if (imagePath.startsWith('/suguconnect/files/download/')) {
      final fileName = imagePath.split('/').last;
      return '$base/uploads/$fileName';
    }

    // Si le chemin commence par /uploads/, l'utiliser directement
    if (imagePath.startsWith('/uploads/')) {
      return '$base$imagePath';
    }

    // Sinon, construire l'URL complète
    return '$base/uploads/$imagePath';
  }
<<<<<<< HEAD

  // Méthodes pour récupérer les listes d'utilisateurs
  Future<List<dynamic>> getConsumers() async {
    await _ensureClient();
    await _loadToken();
    final response =
        await _dio!.get<List<dynamic>>('/consommateur/consommateurs');
    return response.data ?? [];
  }

  Future<List<dynamic>> getProducers() async {
    await _ensureClient();
    await _loadToken();
    final response = await _dio!.get<List<dynamic>>('/producteur/producteurs');
    return response.data ?? [];
  }
=======
>>>>>>> f8cdcc2 (commit pour le premier)
}
