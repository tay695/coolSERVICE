import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyDarkMode = 'is_dark_mode';
  static const _keyFirstTime = 'is_first_time';

  //modo escuro e se não for definido nada o modo padrão é o modo claro
  Future<void> saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDark);
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> disableFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstTime, false);
  }

  Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstTime) ?? true;
  }
}
