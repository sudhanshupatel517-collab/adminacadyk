import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';
import '../data/admin_mock_data.dart';

enum SettingsLoadState { initial, loading, loaded, saving, error }

class AdminSettingsProvider extends ChangeNotifier {
  AppSettingsModel _settings = AdminMockData.defaultSettings;
  SettingsLoadState _state = SettingsLoadState.initial;
  String? _error;
  String? _successMessage;

  AppSettingsModel get settings => _settings;
  SettingsLoadState get state => _state;
  String? get error => _error;
  String? get successMessage => _successMessage;

  Future<void> loadSettings() async {
    _state = SettingsLoadState.loading;
    _error = null;
    notifyListeners();

    try {
      _settings = await AdminService.getSettings();
      _state = SettingsLoadState.loaded;
      notifyListeners();
    } catch (e) {
      _state = SettingsLoadState.error;
      _error = 'Failed to load settings: $e';
      notifyListeners();
    }
  }

  void updateSettings(AppSettingsModel updated) {
    _settings = updated;
    notifyListeners();
  }

  Future<bool> saveSettings() async {
    _state = SettingsLoadState.saving;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await AdminService.saveSettings(_settings);
      _state = SettingsLoadState.loaded;
      _successMessage = 'System settings saved successfully.';
      notifyListeners();
      return true;
    } catch (e) {
      _state = SettingsLoadState.error;
      _error = 'Failed to save settings: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> resetDefaults() async {
    _settings = AdminMockData.defaultSettings;
    await saveSettings();
    _successMessage = 'Default configurations restored.';
    notifyListeners();
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}