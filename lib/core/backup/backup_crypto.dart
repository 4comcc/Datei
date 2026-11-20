import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Password encryption for backup files (ADR-019, ADR-064).
///
/// Layout: `DATEIENC1` (9 bytes) · header length (4 bytes, big-endian) ·
/// header JSON {kdf, memoryKiB, iterations, salt, nonce} · AES-256-GCM
/// ciphertext followed by its 16-byte MAC.
class BackupCrypto {
  static const magic = 'DATEIENC1';
  static const _memoryKiB = 19 * 1024; // OWASP minimum for Argon2id
  static const _iterations = 2;

  static bool isEncrypted(Uint8List bytes) =>
      bytes.length > magic.length && ascii.decode(bytes.sublist(0, magic.length), allowInvalid: true) == magic;

  static Future<SecretKey> _deriveKey(String password, List<int> salt, int memoryKiB, int iterations) {
    final kdf = Argon2id(memory: memoryKiB, iterations: iterations, parallelism: 1, hashLength: 32);
    return kdf.deriveKeyFromPassword(password: password, nonce: salt);
  }

  /// Encrypts in a background isolate (key derivation is deliberately slow).
  static Future<Uint8List> encrypt(Uint8List plain, String password) => Isolate.run(() async {
        final salt = SecretKeyData.random(length: 16).bytes;
        final key = await _deriveKey(password, salt, _memoryKiB, _iterations);
        final aes = AesGcm.with256bits();
        final nonce = aes.newNonce();
        final box = await aes.encrypt(plain, secretKey: key, nonce: nonce);
        final header = utf8.encode(jsonEncode({
          'kdf': 'argon2id',
          'memoryKiB': _memoryKiB,
          'iterations': _iterations,
          'salt': base64Encode(salt),
          'nonce': base64Encode(nonce),
        }));
        final out = BytesBuilder(copy: false)
          ..add(ascii.encode(magic))
          ..add((ByteData(4)..setUint32(0, header.length)).buffer.asUint8List())
          ..add(header)
          ..add(box.cipherText)
          ..add(box.mac.bytes);
        return out.toBytes();
      });

  /// Throws [BackupPasswordException] for a wrong password or tampered file.
  static Future<Uint8List> decrypt(Uint8List data, String password) => Isolate.run(() async {
        try {
          var o = magic.length;
          final headerLen = ByteData.sublistView(data, o, o + 4).getUint32(0);
          o += 4;
          final header = jsonDecode(utf8.decode(data.sublist(o, o + headerLen))) as Map<String, dynamic>;
          o += headerLen;
          if (header['kdf'] != 'argon2id') throw const FormatException('Unknown KDF');
          final key = await _deriveKey(
            password,
            base64Decode(header['salt'] as String),
            header['memoryKiB'] as int,
            header['iterations'] as int,
          );
          final body = data.sublist(o);
          final box = SecretBox(
            body.sublist(0, body.length - 16),
            nonce: base64Decode(header['nonce'] as String),
            mac: Mac(body.sublist(body.length - 16)),
          );
          return Uint8List.fromList(await AesGcm.with256bits().decrypt(box, secretKey: key));
        } on SecretBoxAuthenticationError {
          throw const BackupPasswordException();
        } on RangeError {
          throw const BackupFormatException('truncated');
        }
      });
}

class BackupPasswordException implements Exception {
  const BackupPasswordException();
}

class BackupFormatException implements Exception {
  const BackupFormatException(this.reason);
  final String reason;
  @override
  String toString() => 'BackupFormatException($reason)';
}
