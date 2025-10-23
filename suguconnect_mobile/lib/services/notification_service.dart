import '../models/notification.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  /// Récupérer toutes les notifications d'un utilisateur
  Future<List<Notification>> getNotificationsByUser(int userId) async {
    try {
      final response = await _apiService.get<List<dynamic>>('/notifications/$userId');
      
      if (response.statusCode == 200) {
        return response.data!
            .map((json) => Notification.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération des notifications');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des notifications: $e');
    }
  }

  /// Récupérer les notifications non lues d'un utilisateur
  Future<List<Notification>> getUnreadNotificationsByUser(int userId) async {
    try {
      final response = await _apiService.get<List<dynamic>>('/notifications/$userId/non-lues');
      
      if (response.statusCode == 200) {
        return response.data!
            .map((json) => Notification.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Erreur lors de la récupération des notifications non lues');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des notifications non lues: $e');
    }
  }

  /// Compter les notifications non lues d'un utilisateur
  Future<int> getUnreadNotificationsCount(int userId) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>('/notifications/$userId/non-lues/count');
      
      if (response.statusCode == 200) {
        return response.data!['count'] as int;
      } else {
        throw Exception('Erreur lors du comptage des notifications');
      }
    } catch (e) {
      throw Exception('Erreur lors du comptage des notifications: $e');
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllNotificationsAsRead(int userId) async {
    try {
      final response = await _apiService.put('/notifications/$userId/marquer-lues');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors du marquage des notifications');
      }
    } catch (e) {
      throw Exception('Erreur lors du marquage des notifications: $e');
    }
  }

  /// Marquer une notification comme lue
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      final response = await _apiService.put('/notifications/$notificationId/marquer-lue');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur lors du marquage de la notification');
      }
    } catch (e) {
      throw Exception('Erreur lors du marquage de la notification: $e');
    }
  }

  /// Supprimer une notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      final response = await _apiService.delete('/notifications/$notificationId');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression de la notification');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la notification: $e');
    }
  }
}
