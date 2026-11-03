import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hita_omni/app/app_info.dart';
import 'package:hita_omni/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generated Chinese localizations resolve', () async {
    expect(AppLocalizations.supportedLocales, hasLength(1));
    expect(AppLocalizations.supportedLocales.first.languageCode, 'zh');

    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    // MaterialApp loads this delegate alongside AppLocalizations; it also
    // initializes intl date symbols used by generated DateTime placeholders.
    await GlobalMaterialLocalizations.delegate.load(const Locale('zh'));
    expect(l10n.navToday, '今日');
    expect(l10n.commonWeek(2), '第 2 周');
    expect(l10n.timeMinutesAgo(5), '5 分钟前');
    expect(l10n.durationDays(1), '1 天');
    expect(l10n.datePatternMonthDay(DateTime(2026, 10, 24)), contains('10'));
    expect(appName, 'HITA Omni');
  });

  test('UI layers use generated strings only', () {
    final directories = <Directory>[
      Directory('lib/app'),
      Directory('lib/shared'),
      for (final feature in Directory(
        'lib/features',
      ).listSync().whereType<Directory>())
        if (Directory('${feature.path}/presentation').existsSync())
          Directory('${feature.path}/presentation'),
    ];
    final chinesePattern = RegExp("['\"][^'\"]*[\u4e00-\u9fff][^'\"]*['\"]");
    final offenders = <String>[];
    for (final directory in directories) {
      for (final file
          in directory
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'))) {
        final source = file.readAsStringSync();
        for (final line in source.split('\n')) {
          if (chinesePattern.hasMatch(line) ||
              line.contains('l10n.t(') ||
              line.contains('LanguageController') ||
              line.contains('file_selector') ||
              line.contains('assets/i18n')) {
            offenders.add('${file.path}: ${line.trim()}');
          }
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });

  test('course views do not expose login state or login navigation', () {
    final files = <File>[
      File('lib/features/dashboard/presentation/panels/next_class_panel.dart'),
      File(
        'lib/features/dashboard/presentation/panels/today_schedule_panel.dart',
      ),
      File('lib/features/timetable/presentation/timetable_page.dart'),
    ];
    for (final file in files) {
      final source = file.readAsStringSync();
      expect(source.contains('LoginPage'), isFalse, reason: file.path);
      expect(source.contains('isSignedIn'), isFalse, reason: file.path);
      expect(
        source.contains('CorePageIds.account'),
        isFalse,
        reason: file.path,
      );
      expect(source.contains('登录'), isFalse, reason: file.path);
    }
  });
}
