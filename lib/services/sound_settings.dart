import 'package:shared_preferences/shared_preferences.dart';

class SoundSettings {
  static const focusEnd = "focus_end";
  static const breakEnd = "break_end";
  static const cycleComplete = "cycle_complete";

  static Future<void> setSound(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String> getSound(String key, String defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? defaultValue;
  }
}
