import '../../core/network/api_client.dart';

class NotificationService {
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await ApiClient.get('/notifications');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is Map && payload.containsKey('content') && payload['content'] is List) {
            return List<Map<String, dynamic>>.from(payload['content']);
          }
          if (payload is List) {
            return List<Map<String, dynamic>>.from(payload);
          }
        } else if (resData is List) {
          return List<Map<String, dynamic>>.from(resData);
        }
      }
    } catch (e) {
      print('Error getting notifications: $e');
    }
    return [];
  }

  static Future<void> markAsRead(String notificationId) async {
    try {
      await ApiClient.post('/notifications/$notificationId/read');
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      await ApiClient.post('/notifications/read-all');
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  static Future<int> getUnreadCount() async {
    try {
      final response = await ApiClient.get('/notifications/unread-count');
      if (response.statusCode == 200 && response.data is Map) {
        final resData = response.data;
        if (resData.containsKey('data') && resData['data'] is Map) {
          return (resData['data']['unreadCount'] as num?)?.toInt() ?? 0;
        }
        return (resData['unreadCount'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {}
    return 0;
  }

  static Future<void> registerFcmToken(String fcmToken) async {
    try {
      await ApiClient.post('/notifications/fcm-token', data: {'fcmToken': fcmToken});
    } catch (e) {
      print('Error registering FCM token: $e');
    }
  }

  static Future<Map<String, dynamic>?> getPreferences() async {
    try {
      final response = await ApiClient.get('/notifications/preferences');
      if (response.statusCode == 200 && response.data is Map) {
        final resData = response.data;
        if (resData.containsKey('data')) {
          return resData['data'] as Map<String, dynamic>?;
        }
        return resData as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error getting preferences: $e');
    }
    return null;
  }

  static Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      await ApiClient.put('/notifications/preferences', data: preferences);
    } catch (e) {
      print('Error updating preferences: $e');
    }
  }
}
