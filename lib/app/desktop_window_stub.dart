import 'package:flutter/widgets.dart';

const bool desktopTitleBarEnabled = false;

Future<void> configureDesktopWindow() async {}

Widget buildDesktopTitleBar() => const SizedBox.shrink();

Widget buildDesktopShell(Widget child) => child;
