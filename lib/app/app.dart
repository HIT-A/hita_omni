import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import '../l10n/app_localizations.dart';
import 'app_info.dart';
import 'app_shell.dart';
import 'web_fonts.dart';

class HitaOmniApp extends StatelessWidget {
  const HitaOmniApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final useWebFonts = kIsWeb && webFontsAvailable;
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(
        Brightness.light,
        fontFamily: useWebFonts ? webFontFamily : null,
        fontFamilyFallback: useWebFonts ? webFontFallback : null,
      ),
      darkTheme: buildAppTheme(
        Brightness.dark,
        fontFamily: useWebFonts ? webFontFamily : null,
        fontFamilyFallback: useWebFonts ? webFontFallback : null,
      ),
      themeMode: themeController.mode,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const AppShell(),
    );
  }
}
