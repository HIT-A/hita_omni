import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const webFontFamily = 'HitaOmniLatin';
const webFontFamilyCjk = 'HitaOmniCJK';
const webFontFallback = <String>[webFontFamilyCjk];

bool webFontsAvailable = false;

/// Web uses CanvasKit's font fallback service for glyphs missing from the
/// bundled fonts. That service downloads Noto fonts from fonts.gstatic.com,
/// which is unreachable in some networks and leaves the canvas blank.
///
/// Loading a local Latin font and a local CJK fallback before `runApp` keeps
/// text rendering fully self-hosted. Native platforms keep using system fonts.
Future<void> loadWebFonts() async {
  if (!kIsWeb) {
    return;
  }
  try {
    final latin = FontLoader(webFontFamily)
      ..addFont(rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    final cjk = FontLoader(webFontFamilyCjk)
      ..addFont(rootBundle.load('assets/fonts/DroidSansFallbackFull.ttf'));
    await Future.wait<void>(<Future<void>>[latin.load(), cjk.load()]);
    webFontsAvailable = true;
  } catch (error) {
    debugPrint('Failed to load bundled web fonts: $error');
  }
}
