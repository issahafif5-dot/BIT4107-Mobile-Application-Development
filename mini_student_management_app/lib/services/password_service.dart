import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordService {
  static const String _salt = 'student_app_salt_2024';

  static String hashPassword(String password) {
    return sha256.convert(utf8.encode('$password$_salt')).toString();
  }

  static bool verifyPassword(String plaintext, String hash) {
    return hashPassword(plaintext) == hash;
  }
}
