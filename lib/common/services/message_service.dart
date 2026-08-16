import '../../core/network/api_client.dart';
import '../../core/network/websocket_service.dart';

class MessageService {
  /// Fetch all conversations for the current user
  static Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final response = await ApiClient.get('/conversations');
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          final payload = resData['data'];
          if (payload is List) {
            return List<Map<String, dynamic>>.from(payload);
          }
          if (payload is Map && payload.containsKey('content') && payload['content'] is List) {
            return List<Map<String, dynamic>>.from(payload['content']);
          }
        } else if (resData is List) {
          return List<Map<String, dynamic>>.from(resData);
        }
      }
    } catch (e) {
      print('Error fetching conversations: $e');
    }
    return [];
  }

  /// Fetch messages for a specific conversation
  static Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    try {
      final response = await ApiClient.get('/conversations/$conversationId/messages');
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
      print('Error fetching messages: $e');
    }
    return [];
  }

  /// Send a message to a conversation (via REST API + broadcasted via WebSocket)
  static Future<Map<String, dynamic>?> sendMessage(String conversationId, String content) async {
    try {
      final response = await ApiClient.post('/conversations/$conversationId/messages', data: {
        'content': content,
        'messageType': 'TEXT',
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        final data = (resData is Map && resData.containsKey('data'))
            ? resData['data'] as Map<String, dynamic>?
            : response.data as Map<String, dynamic>?;

        WebSocketService.send({
          'action': 'message',
          'conversationId': conversationId,
          'content': content,
        });
        return data;
      }
    } catch (e) {
      print('Error sending message: $e');
    }
    return null;
  }

  /// Create or fetch an existing 1-to-1 conversation with another user
  static Future<String?> createConversation(String targetUserId) async {
    try {
      final response = await ApiClient.post('/conversations', data: {
        'recipientId': targetUserId,
        'isGroup': false,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return resData['data']?['id']?.toString();
        }
        return response.data['id']?.toString();
      }
    } catch (e) {
      print('Error creating conversation: $e');
    }
    return null;
  }
}
