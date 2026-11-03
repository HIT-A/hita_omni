import 'package:flutter/foundation.dart';

abstract final class CorePageIds {
  static const today = 'core.today';
  static const timetable = 'core.timetable';
  static const account = 'core.account';
}

class NavigationController extends ChangeNotifier {
  String _pageId = CorePageIds.today;

  String get pageId => _pageId;

  void go(String pageId) {
    if (_pageId == pageId) {
      return;
    }
    _pageId = pageId;
    notifyListeners();
  }
}
