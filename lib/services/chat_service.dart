import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';

class ChatService {
  final ApiService _apiService = ApiService();

  /// Envoyer un message texte
  Future<Map<String, dynamic>> sendMessage({
    required int senderId,
    required int receiverId,
    required String content,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/messages',
        data: {
          'senderId': senderId,
          'receiverId': receiverId,
          'content': content,
          'type': 'TEXT',
        },
      );

      if (response.statusCode == 201) {
        return response.data!;
      } else {
        throw Exception(
            'Erreur lors de l\'envoi du message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message: $e');
    }
  }

  /// Envoyer un message vocal
  Future<Map<String, dynamic>> sendVoiceMessage({
    required int senderId,
    required int receiverId,
    required File audioFile,
  }) async {
    try {
      // Implémenter l'upload de fichier audio
      final baseUrl = await _apiService.getBaseUrl();
      final url = '$baseUrl/suguconnect/messages/voice';

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['senderId'] = senderId.toString();
      request.fields['receiverId'] = receiverId.toString();

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
        filename: 'voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a',
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception(
            'Erreur lors de l\'envoi du message vocal: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du message vocal: $e');
    }
  }

  /// Envoyer une image
  Future<Map<String, dynamic>> sendImage({
    required int senderId,
    required int receiverId,
    required File imageFile,
  }) async {
    try {
      // Implémenter l'upload de fichier image
      final baseUrl = await _apiService.getBaseUrl();
      final url = '$baseUrl/suguconnect/messages/image';

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['senderId'] = senderId.toString();
      request.fields['receiverId'] = receiverId.toString();

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception(
            'Erreur lors de l\'envoi de l\'image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi de l\'image: $e');
    }
  }

  /// Envoyer un fichier
  Future<Map<String, dynamic>> sendFile({
    required int senderId,
    required int receiverId,
    required File file,
  }) async {
    try {
      // Implémenter l'upload de fichier
      final baseUrl = await _apiService.getBaseUrl();
      final url = '$baseUrl/suguconnect/messages/file';

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['senderId'] = senderId.toString();
      request.fields['receiverId'] = receiverId.toString();

      final fileName = file.path.split('/').last;
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: fileName,
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception(
            'Erreur lors de l\'envoi du fichier: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du fichier: $e');
    }
  }

  /// Récupérer l'historique des messages
  Future<List<Map<String, dynamic>>> getMessages({
    required int userId1,
    required int userId2,
  }) async {
    try {
      print('=== getMessages appelé ===');
      print('userId1: $userId1');
      print('userId2: $userId2');

      final response = await _apiService.get<List<dynamic>>(
        '/messages/conversation',
        queryParameters: {
          'userId1': userId1.toString(),
          'userId2': userId2.toString(),
        },
      );

      print('Réponse du backend - Status: ${response.statusCode}');
      print('Réponse du backend - Headers: ${response.headers}');
      print('Réponse du backend - Data: ${response.data}');

      if (response.statusCode == 200) {
        return response.data!
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else if (response.statusCode == 400) {
        print('ERREUR 400: Paramètres invalides');
        // Solution de contournement : retourner une liste vide au lieu de lancer une exception
        return [];
      } else if (response.statusCode == 404) {
        print('ERREUR 404: Conversation non trouvée');
        return []; // Retourner une liste vide au lieu de lancer une exception
      } else {
        print('ERREUR: Backend a renvoyé le statut ${response.statusCode}');
        // Solution de contournement : retourner une liste vide au lieu de lancer une exception
        return [];
      }
    } catch (e, stackTrace) {
      print('=== ERREUR DANS getMessages ===');
      print('Erreur: $e');
      print('Stack trace: $stackTrace');

      // Dans tous les cas d'erreur, retourner une liste vide pour permettre à l'application de continuer
      return [];
    }
  }

  /// Marquer un message comme lu
  Future<void> markMessageAsRead(int messageId) async {
    try {
      final response = await _apiService.put(
        '/messages/$messageId/read',
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur lors du marquage du message comme lu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors du marquage du message comme lu: $e');
    }
  }
}