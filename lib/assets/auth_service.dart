import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<bool> estaLogueado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('logueado') ?? false;
  }
}