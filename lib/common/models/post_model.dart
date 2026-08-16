import 'profile_model.dart';

class PostModel {
  final String id;
  final String userId;
  final String content;
  final String postType;
  final String visibility;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProfileModel? profile;
  final List<String> imageUrls;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.postType,
    required this.visibility,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.createdAt,
    required this.updatedAt,
    this.profile,
    required this.imageUrls,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Parse nested profile if it exists
    ProfileModel? profileObj;
    if (json['profiles'] != null) {
      profileObj = ProfileModel.fromJson(json['profiles']);
    }

    // Parse image URLs from post_images relation if available
    List<String> imagesList = [];
    if (json['post_images'] != null) {
      final imagesData = json['post_images'] as List;
      imagesList = imagesData.map((img) => img['image_url'] as String).toList();
    } else if (json['image_url'] != null) {
      imagesList = [json['image_url'] as String];
    }

    return PostModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      content: json['content'] ?? '',
      postType: json['post_type'] ?? 'text',
      visibility: json['visibility'] ?? 'public',
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      profile: profileObj,
      imageUrls: imagesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'post_type': postType,
      'visibility': visibility,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
