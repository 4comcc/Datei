import 'dart:convert';
import 'dart:isolate';

import 'package:cryptography/cryptography.dart';

/// Hashes the app-lock PIN with PBKDF2-HMAC-SHA256 and a random salt.
/// Stored as `pbkdf2-sha256$<iterations>$<salt b64>$<hash b64>`; the PIN itself is never stored.
class PinHasher {
  const PinHasher({this.iterations = 30000});
  final int iterations;

  static bool isValidPin(String pin) => RegExp(r'^\d{4,8}$').hasMatch(pin);

  Future<String> hash(String pin) {
    final iters = iterations;
    return Isolate.run(() async {
      final salt = SecretKeyData.random(length: 16).bytes;
      final key = await Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iters, bits: 256)
          .deriveKeyFromPassword(password: pin, nonce: salt);
      return 'pbkdf2-sha256\$$iters\$${base64Encode(salt)}\$${base64Encode(await key.extractBytes())}';
    });
  }

  Future<bool> verify(String pin, String stored) => Isolate.run(() async {
        final parts = stored.split(r'$');
        if (parts.length != 4 || parts[0] != 'pbkdf2-sha256') return false;
        final iters = int.tryParse(parts[1]);
        if (iters == null || iters < 1) return false;
        final List<int> expected;
        final List<int> salt;
        try {
          salt = base64Decode(parts[2]);
          expected = base64Decode(parts[3]);
        } on FormatException {
          return false;
        }
        final key = await Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: iters, bits: 256)
            .deriveKeyFromPassword(password: pin, nonce: salt);
        final actual = await key.extractBytes();
        if (actual.length != expected.length) return false;
        var diff = 0; // constant-time comparison
        for (var i = 0; i < actual.length; i++) {
          diff |= actual[i] ^ expected[i];
        }
        return diff == 0;
      });
}
