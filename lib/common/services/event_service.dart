import '../../core/network/api_client.dart';

class EventService {
  /// Fetch all events
  static Future<List<Map<String, dynamic>>> getEvents() async {
    try {
      final response = await ApiClient.get('/events');
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
      print('Error fetching events: $e');
    }
    return [];
  }

  /// Register for an event
  static Future<bool> registerForEvent(String eventId, Map<String, dynamic> registrationDetails) async {
    try {
      final response = await ApiClient.post('/events/$eventId/register', data: {
        'registrationDetails': registrationDetails,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error registering for event: $e');
      return false;
    }
  }

  /// Check if user is registered for an event
  static Future<bool> hasRegistered(String eventId) async {
    try {
      final response = await ApiClient.get('/events/$eventId');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return resData['data']?['isRegistered'] ?? false;
        }
        if (resData is Map) {
          return resData['isRegistered'] ?? false;
        }
      }
    } catch (_) {}
    return false;
  }
}
