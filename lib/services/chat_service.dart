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
      print('=== Envoi de message ===');
      print('senderId: $senderId');
      print('receiverId: $receiverId');
      print('content: $content');
      
      final response = await _apiService.post<dynamic>(
        '/messages',
        data: {
          'senderId': senderId,
          'receiverId': receiverId,
          'content': content,
          'type': 'TEXT',
        },
      );

      print('Réponse - Status: ${response.statusCode}');
      print('Réponse - Data type: ${response.data.runtimeType}');
      print('Réponse - Data: ${response.data}');

      if (response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return response.data as Map<String, dynamic>;
        } else {
          // Si la réponse n'est pas un Map, créer un Map avec les données
          return {'success': true, 'data': response.data};
        }
      } else {
        // Extraire le message d'erreur du backend si disponible
        String errorMessage = 'Erreur lors de l\'envoi du message';
        if (response.data != null) {
          if (response.data is Map<String, dynamic>) {
            final errorData = response.data as Map<String, dynamic>;
            errorMessage = errorData['error']?.toString() ?? 
                         errorData['message']?.toString() ?? 
                         errorMessage;
          } else {
            errorMessage = response.data.toString();
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('=== ERREUR sendMessage ===');
      print('Erreur: $e');
      // Si c'est une DioException, essayer d'extraire le message d'erreur
      if (e.toString().contains('DioException')) {
        final errorStr = e.toString();
        if (errorStr.contains('400')) {
          throw Exception('Données invalides. Vérifiez que tous les champs sont corrects.');
        } else if (errorStr.contains('401')) {
          throw Exception('Non autorisé. Veuillez vous reconnecter.');
        } else if (errorStr.contains('403')) {
          throw Exception('Accès refusé.');
        } else if (errorStr.contains('404')) {
          throw Exception('Endpoint non trouvé.');
        }
      }
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

  /// Récupérer les conversations d'un producteur
  Future<List<Map<String, dynamic>>> getProducerConversations(int producteurId) async {
    try {
      print('=== getProducerConversations appelé ===');
      print('producteurId: $producteurId');

      // Essayer d'abord avec le nouvel endpoint basé sur les messages (inclut tous les messages)
      try {
        final response = await _apiService.get<List<dynamic>>(
          '/api/chat/conversations/producteur/$producteurId/messages',
        );

        print('Réponse du backend (messages) - Status: ${response.statusCode}');
        print('Réponse du backend (messages) - Data: ${response.data}');

        if (response.statusCode == 200 && response.data != null) {
          return response.data!
              .map((item) => item as Map<String, dynamic>)
              .toList();
        }
      } catch (e) {
        print('Erreur avec /api/chat/conversations/producteur/$producteurId/messages: $e');
        // Essayer avec l'endpoint classique si le nouvel endpoint échoue
        try {
          final response = await _apiService.get<List<dynamic>>(
            '/api/chat/conversations/producteur/$producteurId',
          );

          print('Réponse du backend (classique) - Status: ${response.statusCode}');
          print('Réponse du backend (classique) - Data: ${response.data}');

          if (response.statusCode == 200 && response.data != null) {
            return response.data!
                .map((item) => item as Map<String, dynamic>)
                .toList();
          }
        } catch (e2) {
          print('Erreur avec /api/chat/conversations/producteur/$producteurId: $e2');
          // Essayer avec /chat si /api/chat échoue
          try {
            final response = await _apiService.get<List<dynamic>>(
              '/chat/conversations/producteur/$producteurId',
            );

            if (response.statusCode == 200 && response.data != null) {
              return response.data!
                  .map((item) => item as Map<String, dynamic>)
                  .toList();
            }
          } catch (e3) {
            print('Erreur avec /chat/conversations/producteur/$producteurId: $e3');
          }
        }
      }
      
      print('ERREUR: Aucune conversation trouvée');
      return [];
    } catch (e, stackTrace) {
      print('=== ERREUR DANS getProducerConversations ===');
      print('Erreur: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Récupérer les messages reçus par un producteur (alternative simple)
  /// Cette méthode récupère tous les messages où le producteur est le destinataire
  Future<List<Map<String, dynamic>>> getReceivedMessages(int producteurId) async {
    try {
      // Pour l'instant, on retourne une liste vide
      // Cette méthode peut être implémentée si un endpoint existe
      return [];
    } catch (e) {
      print('Erreur lors de la récupération des messages reçus: $e');
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