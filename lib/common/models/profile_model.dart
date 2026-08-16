class ProfileModel {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String bio;
  final String profilePhotoUrl;
  final String coverPhotoUrl;
  final String college;
  final List<String> skills;
  final String location;
  final String website;
  final Map<String, dynamic> socialLinks;
  final bool isVerified;
  final bool isPremium;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActive;

  ProfileModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.bio,
    required this.profilePhotoUrl,
    required this.coverPhotoUrl,
    required this.college,
    required this.skills,
    required this.location,
    required this.website,
    required this.socialLinks,
    required this.isVerified,
    required this.isPremium,
    required this.followersCount,
    required this.followingCount,
    required this.postsCount,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActive,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      profilePhotoUrl: json['profile_photo_url'] ?? '',
      coverPhotoUrl: json['cover_photo_url'] ?? '',
      college: json['college'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      location: json['location'] ?? '',
      website: json['website'] ?? '',
      socialLinks: Map<String, dynamic>.from(json['social_links'] ?? {}),
      isVerified: json['is_verified'] ?? false,
      isPremium: json['is_premium'] ?? false,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      postsCount: json['posts_count'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      lastActive: json['last_active'] != null ? DateTime.parse(json['last_active']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'bio': bio,
      'profile_photo_url': profilePhotoUrl,
      'cover_photo_url': coverPhotoUrl,
      'college': college,
      'skills': skills,
      'location': location,
      'website': website,
      'social_links': socialLinks,
      'is_verified': isVerified,
      'is_premium': isPremium,
      'followers_count': followersCount,
      'following_count': followingCount,
      'posts_count': postsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_active': lastActive.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    String? bio,
    String? profilePhotoUrl,
    String? coverPhotoUrl,
    String? college,
    List<String>? skills,
    String? location,
    String? website,
    Map<String, dynamic>? socialLinks,
    bool? isVerified,
    bool? isPremium,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActive,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      college: college ?? this.college,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      website: website ?? this.website,
      socialLinks: socialLinks ?? this.socialLinks,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
