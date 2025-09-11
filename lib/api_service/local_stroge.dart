// local_stroge.dart
import 'package:get_storage/get_storage.dart';

class LocalStorage {
  static final _storage = GetStorage();

  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';
  static const _rememberMeKey = 'remember_me';
  static const _credentialsKey = 'user_credentials';
  // static const _miningEndTimeKey = 'mining_end_time';
  // static const _miningRewardKey = 'mining_reward';

  static const _tokenExpiryKey = 'token_expiry';



  // Save token with expiry (30 days from now)
  static Future<void> saveToken(String token) async {
    await _storage.write(_tokenKey, token);

  }

  // Get token if it's not expired
  static String? getToken() {
    final token = _storage.read(_tokenKey);
    if (token == null) return null;



    return token;
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(_userKey, user);
  }

  static Map<String, dynamic>? getUser() {
    return _storage.read(_userKey);
  }

  static Future<void> setRememberMe(bool value) async {
    await _storage.write(_rememberMeKey, value);
  }

  static bool getRememberMe() {
    return _storage.read(_rememberMeKey) ?? false;
  }

  static Future<void> saveCredentials(String email, String password) async {
    if (getRememberMe()) {
      await _storage.write(_credentialsKey, {
        'email': email,
        'password': password,
      });
    } else {
      await _storage.remove(_credentialsKey);
    }
  }

  static Map<String, dynamic>? getCredentials() {
    return _storage.read(_credentialsKey);
  }

  static Future<void> clear() async {
    await _storage.remove(_tokenKey);
    await _storage.remove(_tokenExpiryKey);
    await _storage.remove(_userKey);
    await _storage.remove(_rememberMeKey);
    await _storage.remove(_credentialsKey);
  }


// Add this method to clear all mining data when user logs out
  static Future<void> clearAllMiningData() async {
    // final keys = _storage.getKeys();
    // for (var key in keys) {
    //   if (key.startsWith('mining_')) {
    //     await _storage.remove(key);
    //   }
    // }
  }
}