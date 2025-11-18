import 'package:dio/dio.dart';
import 'api_service.dart';

class ThumbnailService {
  final ApiService _apiService;

  ThumbnailService(this._apiService);

  /// Construit l'URL d'une vignette de produit
  Future<String> buildProductThumbnailUrl(String fileName) async {
    try {
      final baseUrl = await _apiService.getBaseUrl();
      return '$baseUrl/thumbnails/product/$fileName';
    } catch (e) {
      // En cas d'erreur, retourner l'URL de l'image originale
      final baseUrl = await _apiService.getBaseUrl();
      return '$baseUrl/uploads/$fileName';
    }
  }

  /// Construit l'URL d'une petite vignette
  Future<String> buildSmallThumbnailUrl(String fileName) async {
    try {
      final baseUrl = await _apiService.getBaseUrl();
      return '$baseUrl/thumbnails/small/$fileName';
    } catch (e) {
      // En cas d'erreur, retourner l'URL de l'image originale
      final baseUrl = await _apiService.getBaseUrl();
      return '$baseUrl/uploads/$fileName';
    }
  }

  /// Télécharge une vignette avec gestion d'erreurs
  Future<String?> downloadThumbnail(String fileName) async {
    try {
      final thumbnailUrl = await buildProductThumbnailUrl(fileName);

      // Vérifier si l'URL est valide
      if (thumbnailUrl.isEmpty) {
        return null;
      }

      // Essayer de télécharger la vignette
      final response = await Dio().get(
        thumbnailUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return thumbnailUrl;
      }

      return null;
    } catch (e) {
      // En cas d'erreur, retourner null
      return null;
    }
  }
}
