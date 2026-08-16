import 'profile_model.dart';

class NotificationModel {
  final String id;
  final String recipientId;
  final String? senderId;
  final String type; // follow, like, comment, etc.
  final String title;
  final String body;
  final String? referenceId;
  final String? referenceType;
  final bool isRead;
  final DateTime createdAt;
  final ProfileModel? senderProfile;

  NotificationModel({
    required this.id,
    required this.recipientId,
    this.senderId,
    required this.type,
    required this.title,
    required this.body,
    this.referenceId,
    this.referenceType,
    required this.isRead,
    required this.createdAt,
    this.senderProfile,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    ProfileModel? senderProfileObj;
    if (json['sender'] != null) {
      senderProfileObj = ProfileModel.fromJson(json['sender']);
    } else if (json['profiles'] != null) {
      senderProfileObj = ProfileModel.fromJson(json['profiles']);
    }

    return NotificationModel(
      id: json['id'] ?? '',
      recipientId: json['recipient_id'] ?? '',
      senderId: json['sender_id'],
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      referenceId: json['reference_id']?.toString(),
      referenceType: json['reference_type'],
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      senderProfile: senderProfileObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'sender_id': senderId,
      'type': type,
      'title': title,
      'body': body,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
