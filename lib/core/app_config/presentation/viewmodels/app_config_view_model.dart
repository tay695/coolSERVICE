import 'package:coolservice/core/app_config/data/preferences_services.dart';
import 'package:flutter/material.dart';

class AppConfigViewModel extends ChangeNotifier {
  final PreferencesService _service;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _isFirstTime = true;
  bool get isFirstTime => _isFirstTime;

  AppConfigViewModel(this._service) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _isDarkMode = await _service.getThemeMode();
    _isFirstTime = await _service.isFirstTime();
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    await _service.saveThemeMode(isDark);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isFirstTime = false;
    await _service.disableFirstTime();
    notifyListeners();
  }
}
