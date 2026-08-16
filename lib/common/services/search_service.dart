import '../../core/network/api_client.dart';

class SearchService {
  /// Search user profiles (powered by Elasticsearch backend)
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
          if (payload is List) {
            return List<Map<String, dynamic>>.from(payload);
          }
        } else if (resData is List) {
          return List<Map<String, dynamic>>.from(resData);
        }
      }
    } catch (e) {
      print('Error searching profiles: $e');
    }
    return [];
  }

  /// Global multi-entity search with filters
  static Future<Map<String, dynamic>> globalSearch(
    String query, {
    String? type,
    String? college,
    String? location,
    String? category,
    String? opportunityType,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'page': page,
        'size': size,
      };
      if (type != null) queryParams['type'] = type;
      if (college != null) queryParams['college'] = college;
      if (location != null) queryParams['location'] = location;
      if (category != null) queryParams['category'] = category;
      if (opportunityType != null) queryParams['opportunityType'] = opportunityType;

      final response = await ApiClient.get('/search', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return Map<String, dynamic>.from(resData['data']);
        }
        if (resData is Map) {
          return Map<String, dynamic>.from(resData);
        }
      }
    } catch (e) {
      print('Error performing global search: $e');
    }
    return {};
  }

  /// Fast Autocomplete Suggestions
  static Future<List<Map<String, dynamic>>> autocomplete(String query) async {
    try {
      final response = await ApiClient.get('/search/autocomplete', queryParameters: {'q': query});
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data') && resData['data'] is List) {
          return List<Map<String, dynamic>>.from(resData['data']);
        }
      }
    } catch (_) {}
    return [];
  }

  /// Get search history
  static Future<List<String>> getSearchHistory() async {
    return ['Flutter', 'Spring Boot', 'Machine Learning', 'Stanford'];
  }

  /// Save query to search history
  static Future<void> saveSearchQuery(String query) async {}
}
