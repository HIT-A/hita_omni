{{flutter_js}}
{{flutter_build_config}}
_flutter.loader.load({
  config: {
    // Chinese networks often cannot reach the CanvasKit CDN on gstatic.
    // Keep the engine assets beside the app. Build with
    // `flutter build web --no-web-resources-cdn`.
    canvasKitBaseUrl: 'canvaskit/',
    // The engine otherwise downloads Roboto (and missing Noto glyphs) from
    // fonts.gstatic.com, which can leave the canvas blank on restricted
    // networks. Bundled fonts cover the app's Latin and CJK text.
    fontFallbackBaseUrl: 'assets/assets/fonts/',
  },
});
