import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

class RsaPublicKey {
  const RsaPublicKey({required this.modulus, required this.exponent});

  final BigInt modulus;
  final BigInt exponent;

  int get byteLength => (modulus.bitLength + 7) ~/ 8;
}

/// Parses a Base64-encoded X.509 SubjectPublicKeyInfo RSA key.
///
/// The Shenzhen EAS `/c_raskey` endpoint currently returns the X.509 key in
/// `CLIENT_RSA_EXPONENT` and the exponent `10001` in `CLIENT_RSA_MODULUS`.
/// That is why the key cannot be recovered by treating the two fields as a
/// raw modulus/exponent pair.
RsaPublicKey? parseRsaPublicKeyBase64(String value) {
  final normalized = value.replaceAll(RegExp(r'\s+'), '');
  if (normalized.isEmpty) {
    return null;
  }
  try {
    return parseRsaPublicKeyDer(base64Decode(normalized));
  } on FormatException {
    return null;
  }
}

RsaPublicKey? parseRsaPublicKeyDer(Uint8List der) {
  try {
    final outer = _DerReader(der).readElement(0x30);
    final outerReader = _DerReader(outer);
    outerReader.readElement(0x30);
    final bitString = outerReader.readElement(0x03);
    if (bitString.isEmpty || bitString[0] != 0) {
      return null;
    }
    final keyReader = _DerReader(Uint8List.sublistView(bitString, 1))
        .readElement(0x30);
    return _rsaKeyFromSequence(keyReader);
  } catch (_) {
    try {
      return _rsaKeyFromSequence(der);
    } catch (_) {
      return null;
    }
  }
}

RsaPublicKey? _rsaKeyFromSequence(Uint8List sequence) {
  final reader = _DerReader(sequence);
  if (reader.peekTag() == 0x30) {
    return _rsaKeyFromSequence(reader.readElement(0x30));
  }
  final modulus = _unsignedBigInt(reader.readElement(0x02));
  final exponent = _unsignedBigInt(reader.readElement(0x02));
  if (modulus <= BigInt.zero || exponent <= BigInt.one) {
    return null;
  }
  return RsaPublicKey(modulus: modulus, exponent: exponent);
}

/// Encrypts [plaintext] with RSA PKCS#1 v1.5 and returns Base64 without wraps.
String? encryptRsaPkcs1(String plaintext, RsaPublicKey key) {
  try {
    final message = utf8.encode(plaintext);
    final keyLength = key.byteLength;
    if (keyLength <= 11) {
      return null;
    }
    final paddingLength = keyLength - message.length - 3;
    if (paddingLength < 8) {
      return null;
    }
    final block = Uint8List(keyLength);
    block[0] = 0x00;
    block[1] = 0x02;
    final random = Random.secure();
    var position = 2;
    final paddingEnd = 2 + paddingLength;
    while (position < paddingEnd) {
      final byte = random.nextInt(256);
      if (byte == 0) {
        continue;
      }
      block[position] = byte;
      position++;
    }
    block[position++] = 0x00;
    block.setRange(position, position + message.length, message);

    final value = _bytesToBigInt(block);
    final encrypted = value.modPow(key.exponent, key.modulus);
    final output = Uint8List(keyLength);
    var remaining = encrypted;
    for (var index = keyLength - 1; index >= 0; index--) {
      output[index] = (remaining & BigInt.from(0xff)).toInt();
      remaining = remaining >> 8;
    }
    return base64Encode(output);
  } catch (_) {
    return null;
  }
}

BigInt _bytesToBigInt(List<int> bytes) {
  var result = BigInt.zero;
  for (final byte in bytes) {
    result = (result << 8) | BigInt.from(byte);
  }
  return result;
}

BigInt _unsignedBigInt(Uint8List bytes) => _bytesToBigInt(bytes);

final class _DerReader {
  _DerReader(this._bytes);

  final Uint8List _bytes;
  int _offset = 0;

  int peekTag() {
    if (_offset >= _bytes.length) {
      throw const FormatException('Unexpected end of DER data');
    }
    return _bytes[_offset];
  }

  Uint8List readElement(int expectedTag) {
    final tag = _readByte();
    if (tag != expectedTag) {
      throw const FormatException('Unexpected DER tag');
    }
    final length = _readLength();
    final end = _offset + length;
    if (length < 0 || end > _bytes.length) {
      throw const FormatException('Invalid DER length');
    }
    final content = Uint8List.sublistView(_bytes, _offset, end);
    _offset = end;
    return content;
  }

  int _readByte() {
    if (_offset >= _bytes.length) {
      throw const FormatException('Unexpected end of DER data');
    }
    return _bytes[_offset++];
  }

  int _readLength() {
    final first = _readByte();
    if (first < 0x80) {
      return first;
    }
    final count = first & 0x7f;
    if (count == 0 || count > 4) {
      throw const FormatException('Unsupported DER length');
    }
    var length = 0;
    for (var index = 0; index < count; index++) {
      length = (length << 8) | _readByte();
    }
    return length;
  }
}
