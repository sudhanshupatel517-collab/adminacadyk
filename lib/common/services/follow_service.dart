import '../../core/network/api_client.dart';

class FollowService {
  static Future<bool> isFollowing(String targetUserId) async {
    try {
      final response = await ApiClient.get('/profiles/$targetUserId/followers');
      if (response.statusCode == 200) {
        return false;
      }
    } catch (_) {}
    return false;
  }

  static Future<bool> toggleFollow(String targetUserId, bool currentFollowState) async {
    try {
      final response = await ApiClient.post('/profiles/$targetUserId/follow');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return resData['data']?['isFollowing'] ?? !currentFollowState;
        }
        if (resData is Map) {
          return resData['isFollowing'] ?? !currentFollowState;
        }
      }
    } catch (e) {
      print('Error toggling follow: $e');
    }
    return !currentFollowState;
  }

  static Future<List<Map<String, dynamic>>> getFollowers(String userId) async {
    try {
      final response = await ApiClient.get('/profiles/$userId/followers');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is List) return List<Map<String, dynamic>>.from(payload);
        } else if (resData is List) {
          return List<Map<String, dynamic>>.from(resData);
        }
      }
    } catch (e) {
      print('Error getting followers: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getFollowing(String userId) async {
    try {
      final response = await ApiClient.get('/profiles/$userId/following');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is List) return List<Map<String, dynamic>>.from(payload);
        } else if (resData is List) {
          return List<Map<String, dynamic>>.from(resData);
        }
      }
    } catch (e) {
      print('Error getting following: $e');
    }
    return [];
  }
}
