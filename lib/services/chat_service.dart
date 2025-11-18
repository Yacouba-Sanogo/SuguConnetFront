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
      // TODO: Implémenter l'upload de fichier audio
      // Pour l'instant, on simule l'envoi
      await Future.delayed(const Duration(seconds: 1));

      return {
        'id': DateTime.now().millisecondsSinceEpoch,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': 'Message vocal',
        'type': 'VOICE',
        'timestamp': DateTime.now().toIso8601String(),
      };
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
      // TODO: Implémenter l'upload de fichier image
      // Pour l'instant, on simule l'envoi
      await Future.delayed(const Duration(seconds: 1));

      return {
        'id': DateTime.now().millisecondsSinceEpoch,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': 'Image',
        'type': 'IMAGE',
        'timestamp': DateTime.now().toIso8601String(),
      };
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
      // TODO: Implémenter l'upload de fichier
      // Pour l'instant, on simule l'envoi
      await Future.delayed(const Duration(seconds: 1));

      return {
        'id': DateTime.now().millisecondsSinceEpoch,
        'senderId': senderId,
        'receiverId': receiverId,
        'content': 'Fichier',
        'type': 'FILE',
        'timestamp': DateTime.now().toIso8601String(),
      };
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
      final response = await _apiService.get<List<dynamic>>(
        '/messages/conversation',
        queryParameters: {
          'userId1': userId1.toString(),
          'userId2': userId2.toString(),
        },
      );

      if (response.statusCode == 200) {
        return response.data!
            .map((item) => item as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception(
            'Erreur lors de la récupération des messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des messages: $e');
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
