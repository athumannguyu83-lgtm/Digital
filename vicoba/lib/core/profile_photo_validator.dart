 import 'dart:typed_data';
import 'dart:ui' as ui;

class ProfilePhotoValidator {
  static const int maxBytes = 5 * 1024 * 1024;

  static Future<String> validate(Uint8List bytes) async {
    if (bytes.isEmpty || bytes.length >= maxBytes) {
      throw const FormatException('Choose an image smaller than 5 MB.');
    }

    final contentType = _contentType(bytes);
    if (contentType == null) {
      throw const FormatException('Choose a JPEG, PNG, or WebP image.');
    }

    ui.Codec codec;
    try {
      codec = await ui.instantiateImageCodec(bytes);
    } catch (_) {
      throw const FormatException('The selected image is corrupted.');
    }

    try {
      final frame = await codec.getNextFrame();
      final isValid = frame.image.width > 0 && frame.image.height > 0;
      frame.image.dispose();
      if (!isValid) {
        throw const FormatException('The selected image is corrupted.');
      }
    } catch (_) {
      throw const FormatException('The selected image is corrupted.');
    } finally {
      codec.dispose();
    }

    return contentType;
  }

  static String? _contentType(Uint8List bytes) {
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return 'image/png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return 'image/webp';
    }
    return null;
  }
}
