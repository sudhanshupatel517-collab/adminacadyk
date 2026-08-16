import '../../core/network/api_client.dart';

class ProfileService {
  static Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final response = await ApiClient.get('/profiles/$userId');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return resData['data'] as Map<String, dynamic>?;
        }
        return response.data as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error getting profile: $e');
    }
    return null;
  }

  static Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      await ApiClient.put('/me/profile', data: data);
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  static Future<void> createProfile(Map<String, dynamic> data) async {
    try {
      await ApiClient.put('/me/profile', data: data);
    } catch (e) {
      print('Error creating profile: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> searchProfiles(String query) async {
    try {
      final response = await ApiClient.get('/search/profiles', queryParameters: {'q': query});
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is Map && payload.containsKey('content') && payload['content'] is List) {
            return List<Map<String, dynamic>>.from(payload['content']);
          }
          if (payload is List) return List<Map<String, dynamic>>.from(payload);
        } else if (resData is List) {
          return List<Map<String, dynamic>>.from(resData);
        }
      }
    } catch (e) {
      print('Error searching profiles: $e');
    }
    return [];
  }
}
