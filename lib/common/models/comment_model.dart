import 'profile_model.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String? parentId;
  final String content;
  final int likesCount;
  final DateTime createdAt;
  final ProfileModel? profile;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.content,
    required this.likesCount,
    required this.createdAt,
    this.profile,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    ProfileModel? profileObj;
    if (json['profiles'] != null) {
      profileObj = ProfileModel.fromJson(json['profiles']);
    }

    return CommentModel(
      id: json['id'] ?? '',
      postId: json['post_id'] ?? '',
      userId: json['user_id'] ?? '',
      parentId: json['parent_id'],
      content: json['content'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      profile: profileObj,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'parent_id': parentId,
      'content': content,
      'likes_count': likesCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
