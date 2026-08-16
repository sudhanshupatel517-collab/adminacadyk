import 'profile_model.dart';

class ConversationModel {
  final String id;
  final bool isGroup;
  final String? groupName;
  final String? groupAvatarUrl;
  final String? lastMessageText;
  final DateTime lastMessageAt;
  final DateTime createdAt;
  final List<ProfileModel> participants;

  ConversationModel({
    required this.id,
    required this.isGroup,
    this.groupName,
    this.groupAvatarUrl,
    this.lastMessageText,
    required this.lastMessageAt,
    required this.createdAt,
    required this.participants,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    List<ProfileModel> participantsList = [];
    if (json['conversation_participants'] != null) {
      final participantsData = json['conversation_participants'] as List;
      for (var participant in participantsData) {
        if (participant['profiles'] != null) {
          participantsList.add(ProfileModel.fromJson(participant['profiles']));
        }
      }
    }

    return ConversationModel(
      id: json['id'] ?? '',
      isGroup: json['is_group'] ?? false,
      groupName: json['group_name'],
      groupAvatarUrl: json['group_avatar_url'],
      lastMessageText: json['last_message_text'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : DateTime.now(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      participants: participantsList,
    );
  }

  /// Helper to get the display name of the conversation for the current user
  String getDisplayName(String currentUserId) {
    if (isGroup) return groupName ?? 'Group Chat';
    final otherParticipants = participants.where((p) => p.id != currentUserId).toList();
    if (otherParticipants.isNotEmpty) {
      return otherParticipants.first.fullName;
    }
    return 'Chat';
  }

  /// Helper to get the display avatar of the conversation for the current user
  String getDisplayAvatar(String currentUserId) {
    if (isGroup) return groupAvatarUrl ?? '';
    final otherParticipants = participants.where((p) => p.id != currentUserId).toList();
    if (otherParticipants.isNotEmpty) {
      return otherParticipants.first.profilePhotoUrl;
    }
    return '';
  }
}

class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String? content;
  final String messageType; // text, image, file
  final String? attachmentUrl;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.content,
    required this.messageType,
    this.attachmentUrl,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      conversationId: json['conversation_id'] ?? '',
      senderId: json['sender_id'] ?? '',
      content: json['content'],
      messageType: json['message_type'] ?? 'text',
      attachmentUrl: json['attachment_url'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'attachment_url': attachmentUrl,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
