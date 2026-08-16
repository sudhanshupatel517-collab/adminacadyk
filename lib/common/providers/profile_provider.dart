import 'dart:io';
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileModel? _profile;
  bool _isLoading = false;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;

  void setProfile(ProfileModel? profile) {
    _profile = profile;
    notifyListeners();
  }

  Future<void> loadProfile(String userId) async {
    _setLoading(true);
    try {
      final data = await ProfileService.getProfile(userId);
      if (data != null) {
        _profile = ProfileModel.fromJson(data);
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String username,
    required String bio,
    required String college,
    required String location,
    required String website,
    required List<String> skills,
  }) async {
    if (_profile == null) return;
    _setLoading(true);
    try {
      final updateData = {
        'full_name': fullName,
        'username': username,
        'bio': bio,
        'college': college,
        'location': location,
        'website': website,
        'skills': skills,
        'updated_at': DateTime.now().toIso8601String(),
      };
      await ProfileService.updateProfile(_profile!.id, updateData);
      
      _profile = _profile!.copyWith(
        fullName: fullName,
        username: username,
        bio: bio,
        college: college,
        location: location,
        website: website,
        skills: skills,
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> uploadAvatar(File file) async {
    if (_profile == null) return null;
    _setLoading(true);
    try {
      final url = await StorageService.uploadProfilePhoto(_profile!.id, file);
      if (url != null) {
        await ProfileService.updateProfile(_profile!.id, {'profile_photo_url': url});
        _profile = _profile!.copyWith(profilePhotoUrl: url);
        notifyListeners();
      }
      return url;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> uploadCover(File file) async {
    if (_profile == null) return null;
    _setLoading(true);
    try {
      final url = await StorageService.uploadCoverPhoto(_profile!.id, file);
      if (url != null) {
        await ProfileService.updateProfile(_profile!.id, {'cover_photo_url': url});
        _profile = _profile!.copyWith(coverPhotoUrl: url);
        notifyListeners();
      }
      return url;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
