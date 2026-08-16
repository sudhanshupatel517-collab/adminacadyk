import '../../core/network/api_client.dart';

class PostService {
  static Future<List<Map<String, dynamic>>> getFeedPosts({int limit = 20, int offset = 0}) async {
    try {
      final page = offset ~/ (limit > 0 ? limit : 20);
      final response = await ApiClient.get('/posts', queryParameters: {
        'page': page,
        'size': limit,
      });
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
      print('Error getting feed posts: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> createPost(String content, {String? postType, String? imageUrl}) async {
    try {
      final response = await ApiClient.post('/posts', data: {
        'content': content,
        'postType': postType ?? 'text',
        'imageUrl': imageUrl,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return resData['data'] as Map<String, dynamic>?;
        }
        return response.data as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error creating post: $e');
    }
    return null;
  }

  static Future<void> deletePost(String postId) async {
    try {
      await ApiClient.delete('/posts/$postId');
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  static Future<bool> toggleLike(String postId, bool currentLikeState) async {
    try {
      final response = await ApiClient.post('/posts/$postId/like');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return resData['data']?['isReacted'] ?? resData['data']?['liked'] ?? !currentLikeState;
        }
        if (resData is Map) {
          return resData['liked'] ?? !currentLikeState;
        }
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
    return !currentLikeState;
  }

  static Future<List<Map<String, dynamic>>> getComments(String postId) async {
    try {
      final response = await ApiClient.get('/posts/$postId/comments');
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
      print('Error getting comments: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> addComment(String postId, String content, {String? parentId}) async {
    try {
      final response = await ApiClient.post('/posts/$postId/comments', data: {
        'content': content,
        'parentId': parentId,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return resData['data'] as Map<String, dynamic>?;
        }
        return response.data as Map<String, dynamic>?;
      }
    } catch (e) {
      print('Error adding comment: $e');
    }
    return null;
  }

  static Future<bool> toggleBookmark(String postId, bool currentBookmarkState) async {
    try {
      final response = await ApiClient.post('/posts/$postId/bookmark');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return resData['data']?['isBookmarked'] ?? !currentBookmarkState;
        }
        if (resData is Map) {
          return resData['bookmarked'] ?? !currentBookmarkState;
        }
      }
    } catch (e) {
      print('Error toggling bookmark: $e');
    }
    return !currentBookmarkState;
  }

  static Future<bool> isBookmarked(String postId) async {
    try {
      final response = await ApiClient.get('/posts/$postId');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return resData['data']?['isBookmarked'] ?? false;
        }
      }
    } catch (_) {}
    return false;
  }
}
