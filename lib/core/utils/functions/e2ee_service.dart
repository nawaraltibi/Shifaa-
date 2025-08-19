import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart' as pc;
import 'package:shifaa/core/utils/shared_prefs_helper.dart';
import 'package:asn1lib/asn1lib.dart';

// ... (كل كود توليد المفاتيح في الأعلى يبقى كما هو)
const _secureStorage = FlutterSecureStorage();

Future<void> generateAndSaveKeys() async {
  // ... (محتوى الدالة يبقى كما هو)
  final sharedPrefs = SharedPrefsHelper.instance;
  if (await sharedPrefs.hasKeys() &&
      await _secureStorage.containsKey(key: 'private_key')) {
    print('✅ Keys already exist. No new keys generated.');
    return;
  }
  final keyPair = _generateRSAKeyPair();
  final publicKey = keyPair.publicKey;
  final privateKey = keyPair.privateKey;
  final publicKeyPem = _encodePublicKeyToPem(publicKey);
  final privateKeyPem = _encodePrivateKeyToPem(privateKey);
  await sharedPrefs.savePublicKey(publicKeyPem);
  await _secureStorage.write(key: 'private_key', value: privateKeyPem);
  print('✅ New keys generated and saved successfully.');
}

pc.AsymmetricKeyPair<pc.RSAPublicKey, pc.RSAPrivateKey> _generateRSAKeyPair() {
  // ... (محتوى الدالة يبقى كما هو)
  final secureRandom = pc.FortunaRandom()
    ..seed(
      pc.KeyParameter(
        Uint8List.fromList(
          List.generate(32, (i) => (DateTime.now().microsecond + i) % 256),
        ),
      ),
    );
  final keyGen = pc.RSAKeyGenerator()
    ..init(
      pc.ParametersWithRandom(
        pc.RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        secureRandom,
      ),
    );
  return keyGen.generateKeyPair()
      as pc.AsymmetricKeyPair<pc.RSAPublicKey, pc.RSAPrivateKey>;
}

String _encodePublicKeyToPem(pc.RSAPublicKey publicKey) {
  // ... (محتوى الدالة يبقى كما هو)
  final topLevelSeq = ASN1Sequence();
  topLevelSeq.add(ASN1Integer(publicKey.modulus!));
  topLevelSeq.add(ASN1Integer(publicKey.exponent!));
  final dataBase64 = base64.encode(topLevelSeq.encodedBytes);
  return '-----BEGIN RSA PUBLIC KEY-----\n${_chunk64(dataBase64)}\n-----END RSA PUBLIC KEY-----';
}

String _encodePrivateKeyToPem(pc.RSAPrivateKey privateKey) {
  // ... (محتوى الدالة يبقى كما هو)
  final topLevel = ASN1Sequence();
  topLevel.add(ASN1Integer(BigInt.from(0)));
  topLevel.add(ASN1Integer(privateKey.n!));
  topLevel.add(ASN1Integer(privateKey.exponent!));
  topLevel.add(ASN1Integer(privateKey.p!));
  topLevel.add(ASN1Integer(privateKey.q!));
  topLevel.add(ASN1Integer(privateKey.d! % (privateKey.p! - BigInt.one)));
  topLevel.add(ASN1Integer(privateKey.d! % (privateKey.q! - BigInt.one)));
  topLevel.add(ASN1Integer(privateKey.q!.modInverse(privateKey.p!)));
  final dataBase64 = base64.encode(topLevel.encodedBytes);
  return '-----BEGIN RSA PRIVATE KEY-----\n${_chunk64(dataBase64)}\n-----END RSA PRIVATE KEY-----';
}

String _chunk64(String str) =>
    RegExp('.{1,64}').allMatches(str).map((m) => m.group(0)).join('\n');

// ===================================================================
// 🔐 قسم التشفير وفك التشفير (E2EE Service)
// ===================================================================

class E2EE {
  static final _rng = pc.SecureRandom('Fortuna')
    ..seed(
      pc.KeyParameter(
        Uint8List.fromList(
          List.generate(32, (i) => DateTime.now().microsecond % 256),
        ),
      ),
    );

  // ... (دوال AES تبقى كما هي)
  static Uint8List generateAESKey([int length = 32]) =>
      Uint8List.fromList(List.generate(length, (_) => _rng.nextUint8()));

  static String aesGcmEncryptToBase64(Uint8List key, String plainText) {
    final iv = _rng.nextBytes(12);
    final cipher = pc.GCMBlockCipher(pc.AESEngine());
    final params = pc.AEADParameters(
      pc.KeyParameter(key),
      128,
      iv,
      Uint8List(0),
    );
    cipher.init(true, params);
    final output = cipher.process(utf8.encode(plainText));
    final combined = Uint8List(iv.length + output.length)
      ..setAll(0, iv)
      ..setAll(iv.length, output);
    return base64.encode(combined);
  }

  static Uint8List aesGcmEncryptToBytes(Uint8List key, Uint8List plainBytes) {
    final iv = _rng.nextBytes(12);
    final cipher = pc.GCMBlockCipher(pc.AESEngine());
    final params = pc.AEADParameters(
      pc.KeyParameter(key),
      128,
      iv,
      Uint8List(0),
    );
    cipher.init(true, params);
    final output = cipher.process(plainBytes);
    final combined = Uint8List(iv.length + output.length)
      ..setAll(0, iv)
      ..setAll(iv.length, output);
    return combined;
  }

  static String? aesGcmDecryptFromBase64(Uint8List key, String base64Combined) {
    try {
      final bytes = base64.decode(base64Combined);
      if (bytes.length < 13) return null;
      final iv = bytes.sublist(0, 12);
      final cipherBytes = bytes.sublist(12);
      final cipher = pc.GCMBlockCipher(pc.AESEngine());
      final params = pc.AEADParameters(
        pc.KeyParameter(key),
        128,
        iv,
        Uint8List(0),
      );
      cipher.init(false, params);
      return utf8.decode(cipher.process(cipherBytes));
    } catch (e) {
      print("AES decrypt failed: $e");
      return null;
    }
  }

  // --- دوال RSA ---

  static pc.RSAPublicKey parsePublicKeyFromPem(String pem) {
    String cleanPem = pem.trim();
    if (!cleanPem.startsWith('-----BEGIN')) {
      // ✅✅✅ --- الإصلاح هنا --- ✅✅✅
      // نستدعي الدالة العامة _chunk64 التي هي خارج الكلاس
      cleanPem =
          '-----BEGIN PUBLIC KEY-----\n${_chunk64(cleanPem)}\n-----END PUBLIC KEY-----';
    }
    try {
      final parser = encrypt.RSAKeyParser();
      return parser.parse(cleanPem) as pc.RSAPublicKey;
    } catch (e) {
      print("🔥🔥🔥 FAILED TO PARSE PUBLIC KEY. Error: $e");
      print("   --- Offending Key PEM: ---\n$cleanPem\n--------------------");
      throw Exception('Failed to parse public key.');
    }
  }

  static Future<pc.RSAPrivateKey?> loadPrivateKeyFromSecureStorage() async {
    // ... (محتوى الدالة يبقى كما هو)
    final pem = await _secureStorage.read(key: 'private_key');
    if (pem == null) return null;
    final bytes = base64.decode(
      pem
          .replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
          .replaceAll('-----END RSA PRIVATE KEY-----', '')
          .replaceAll('\n', '')
          .trim(),
    );
    final asn1Parser = ASN1Parser(bytes);
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
    final modulus = (topLevelSeq.elements[1] as ASN1Integer).valueAsBigInteger;
    final privateExponent =
        (topLevelSeq.elements[3] as ASN1Integer).valueAsBigInteger;
    final p = (topLevelSeq.elements[4] as ASN1Integer).valueAsBigInteger;
    final q = (topLevelSeq.elements[5] as ASN1Integer).valueAsBigInteger;
    return pc.RSAPrivateKey(modulus, privateExponent, p, q);
  }

  static Uint8List rsaEncryptForPublic(pc.RSAPublicKey pub, Uint8List data) {
    // ... (محتوى الدالة يبقى كما هو)
    final encrypter = encrypt.Encrypter(
      encrypt.RSA(publicKey: pub, encoding: encrypt.RSAEncoding.OAEP),
    );
    return encrypter.encryptBytes(data).bytes;
  }

  static Uint8List rsaDecryptWithPrivate(
    pc.RSAPrivateKey priv,
    Uint8List cipher,
  ) {
    // ... (محتوى الدالة يبقى كما هو)
    final decrypter = encrypt.Encrypter(
      encrypt.RSA(privateKey: priv, encoding: encrypt.RSAEncoding.OAEP),
    );
    return Uint8List.fromList(
      decrypter.decryptBytes(encrypt.Encrypted(cipher)),
    );
  }

  static List<Map<String, String>> buildEncryptedKeysPayload({
    required Map<int, String> targets,
    required Uint8List aesKey,
  }) {
    // ... (محتوى الدالة يبقى كما هو)
    final List<Map<String, String>> list = [];
    targets.forEach((deviceId, pubPem) {
      try {
        final pub = parsePublicKeyFromPem(pubPem);
        final enc = rsaEncryptForPublic(pub, aesKey);
        list.add({
          'device_id': deviceId.toString(),
          'encrypted_key': base64.encode(enc),
        });
      } catch (e) {
        print(
          "⚠️ Could not encrypt for device ID $deviceId. Skipping. Error: $e",
        );
      }
    });
    return list;
  }
}
