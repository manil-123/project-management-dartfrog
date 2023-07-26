import 'package:encrypt/encrypt.dart';
import '../constants/keys.dart';

class EncryptData {
//for AES Algorithms

  static final key = Key.fromUtf8(Keys.encrypt_key);
  static final iv = IV.fromLength(16);
  static final encrypter = Encrypter(AES(key));

  static encryptAES(String data) {
    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  static decryptAES(String encryptedData) {
    final encrypted = Encrypted.fromBase64(encryptedData);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);
    return decrypted;
  }
}
