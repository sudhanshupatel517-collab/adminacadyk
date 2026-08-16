import '../../core/network/api_client.dart';

class CommunityService {
  /// Fetch all communities
  static Future<List<Map<String, dynamic>>> getCommunities() async {
    try {
      final response = await ApiClient.get('/communities');
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
      print('Error fetching communities: $e');
    }
    return [];
  }

  /// Join / Toggle a community
  static Future<bool> joinCommunity(String communityId) async {
    try {
      final response = await ApiClient.post('/communities/$communityId/join');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error joining community: $e');
      return false;
    }
  }

  /// Leave a community
  static Future<bool> leaveCommunity(String communityId) async {
    try {
      final response = await ApiClient.post('/communities/$communityId/join');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error leaving community: $e');
      return false;
    }
  }
}
