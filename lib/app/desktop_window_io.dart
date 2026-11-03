import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:window_manager/window_manager.dart';

import 'desktop_title_bar.dart';

bool _enabled = false;

bool get desktopTitleBarEnabled => _enabled;

Future<void> configureDesktopWindow() async {
  if (defaultTargetPlatform != TargetPlatform.linux) {
    return;
  }
  // nativeapi 0.5.x leaves the GTK header bar's input region above the
  // Flutter view on Wayland, which swallows the custom title-bar buttons.
  // Use the native title bar there until that native bug is fixed.
  if (Platform.environment['WAYLAND_DISPLAY']?.isNotEmpty ?? false) {
    _enabled = false;
    return;
  }
  try {
    final window = WindowManager.instance.getCurrent();
    if (window == null) {
      _enabled = false;
      return;
    }
    _enabled = window.setFrameless(true);
    window.dispose();
  } catch (_) {
    // Keep the native title bar if the desktop window API is unavailable.
    _enabled = false;
  }
}

Widget buildDesktopTitleBar() => const DesktopTitleBar();

Widget buildDesktopShell(Widget child) => DragToResizeArea(child: child);
