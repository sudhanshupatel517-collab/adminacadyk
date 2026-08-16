import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';

class AdminSettingsProvider extends ChangeNotifier {
  AppSettingsModel? _settings;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _successMessage;

  AppSettingsModel? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  String? get successMessage => _successMessage;

  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _settings = await AdminService.getSettings();
      _isLoading = false;
    } catch (e) {
      _error = 'Failed to load settings: $e';
      _isLoading = false;
    }
    notifyListeners();
  }

  void updateSettings(AppSettingsModel updated) {
    _settings = updated;
    notifyListeners();
  }

  Future<void> saveSettings() async {
    if (_settings == null) return;
    _isSaving = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await AdminService.saveSettings(_settings!);
      _successMessage = 'Settings saved successfully.';
      _isSaving = false;
    } catch (e) {
      _error = 'Failed to save: $e';
      _isSaving = false;
    }
    notifyListeners();
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}