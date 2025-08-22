import 'dart:convert';
import 'package:pointycastle/export.dart' as pc;

String decryptLaravel(String encrypted, String appKey) {
  final decoded = jsonDecode(utf8.decode(base64.decode(encrypted)));
  final key = base64.decode(appKey.replaceFirst('base64:', ''));
  final iv = base64.decode(decoded['iv']);
  final value = base64.decode(decoded['value']);

  final cipher = pc.PaddedBlockCipherImpl(
    pc.PKCS7Padding(),
    pc.CBCBlockCipher(pc.AESEngine()),
  );

  cipher.init(
    false,
    pc.PaddedBlockCipherParameters(
      pc.ParametersWithIV(pc.KeyParameter(key), iv),
      null,
    ),
  );

  final decrypted = cipher.process(value);
  return utf8.decode(decrypted);
}
