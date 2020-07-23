
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesUtil {

  Future<SharedPreferences> _prefs;

  static final PreferencesUtil _preferencesUtil = PreferencesUtil._internal();

  factory PreferencesUtil() => _preferencesUtil;

  PreferencesUtil._internal() {
    _prefs = SharedPreferences.getInstance();
  }

  Future<String> getPrefString(String key) async {
    SharedPreferences prefs = await _prefs;
    return prefs.getString(key);
  }

  setPrefsString(String key, String value) async {
    SharedPreferences prefs = await _prefs;
    prefs.setString(key, value);
  }
}
