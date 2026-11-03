import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('zh')];

  /// No description provided for @navToday.
  ///
  /// In zh, this message translates to:
  /// **'今日'**
  String get navToday;

  /// No description provided for @navTimetable.
  ///
  /// In zh, this message translates to:
  /// **'时间表'**
  String get navTimetable;

  /// No description provided for @navAccount.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get navAccount;

  /// No description provided for @sidebarExpand.
  ///
  /// In zh, this message translates to:
  /// **'展开侧边栏'**
  String get sidebarExpand;

  /// No description provided for @sidebarCollapse.
  ///
  /// In zh, this message translates to:
  /// **'收起侧边栏'**
  String get sidebarCollapse;

  /// No description provided for @commonLogin.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get commonLogin;

  /// No description provided for @commonLogout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get commonLogout;

  /// No description provided for @commonCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonDone.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get commonDone;

  /// No description provided for @commonClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get commonClose;

  /// No description provided for @windowMinimize.
  ///
  /// In zh, this message translates to:
  /// **'最小化'**
  String get windowMinimize;

  /// No description provided for @windowMaximize.
  ///
  /// In zh, this message translates to:
  /// **'最大化'**
  String get windowMaximize;

  /// No description provided for @windowRestore.
  ///
  /// In zh, this message translates to:
  /// **'还原窗口'**
  String get windowRestore;

  /// No description provided for @commonRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get commonRetry;

  /// No description provided for @commonSync.
  ///
  /// In zh, this message translates to:
  /// **'同步课表'**
  String get commonSync;

  /// No description provided for @commonSyncing.
  ///
  /// In zh, this message translates to:
  /// **'同步中…'**
  String get commonSyncing;

  /// No description provided for @commonLoginAccount.
  ///
  /// In zh, this message translates to:
  /// **'登录账号'**
  String get commonLoginAccount;

  /// No description provided for @commonNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get commonNotSet;

  /// No description provided for @commonNotAvailable.
  ///
  /// In zh, this message translates to:
  /// **'未获取'**
  String get commonNotAvailable;

  /// No description provided for @commonWeek.
  ///
  /// In zh, this message translates to:
  /// **'第 {week} 周'**
  String commonWeek(int week);

  /// No description provided for @commonCurrentWeek.
  ///
  /// In zh, this message translates to:
  /// **'本周'**
  String get commonCurrentWeek;

  /// No description provided for @commonDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get commonDelete;

  /// No description provided for @commonRemove.
  ///
  /// In zh, this message translates to:
  /// **'移除'**
  String get commonRemove;

  /// No description provided for @commonAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get commonAdd;

  /// No description provided for @commonLoading.
  ///
  /// In zh, this message translates to:
  /// **'加载中…'**
  String get commonLoading;

  /// No description provided for @campusShenzhenLabel.
  ///
  /// In zh, this message translates to:
  /// **'深圳校区'**
  String get campusShenzhenLabel;

  /// No description provided for @campusShenzhenShort.
  ///
  /// In zh, this message translates to:
  /// **'深圳'**
  String get campusShenzhenShort;

  /// No description provided for @campusShenzhenNote.
  ///
  /// In zh, this message translates to:
  /// **'使用深圳校区新版教务账号登录，会话仅保存在本机。'**
  String get campusShenzhenNote;

  /// No description provided for @campusHarbinLabel.
  ///
  /// In zh, this message translates to:
  /// **'本部校区'**
  String get campusHarbinLabel;

  /// No description provided for @campusHarbinShort.
  ///
  /// In zh, this message translates to:
  /// **'本部'**
  String get campusHarbinShort;

  /// No description provided for @campusHarbinNote.
  ///
  /// In zh, this message translates to:
  /// **'本部教务使用 WebVPN 网页认证，当前版本暂未接入。'**
  String get campusHarbinNote;

  /// No description provided for @campusWeihaiLabel.
  ///
  /// In zh, this message translates to:
  /// **'威海校区'**
  String get campusWeihaiLabel;

  /// No description provided for @campusWeihaiShort.
  ///
  /// In zh, this message translates to:
  /// **'威海'**
  String get campusWeihaiShort;

  /// No description provided for @campusWeihaiNote.
  ///
  /// In zh, this message translates to:
  /// **'威海教务使用 WebVPN 网页认证，当前版本暂未接入。'**
  String get campusWeihaiNote;

  /// No description provided for @studentTypeUndergraduate.
  ///
  /// In zh, this message translates to:
  /// **'本科生'**
  String get studentTypeUndergraduate;

  /// No description provided for @studentTypeGraduate.
  ///
  /// In zh, this message translates to:
  /// **'研究生'**
  String get studentTypeGraduate;

  /// No description provided for @themeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeDark;

  /// No description provided for @greetingNight.
  ///
  /// In zh, this message translates to:
  /// **'夜深了'**
  String get greetingNight;

  /// No description provided for @greetingMorning.
  ///
  /// In zh, this message translates to:
  /// **'早上好'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In zh, this message translates to:
  /// **'下午好'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In zh, this message translates to:
  /// **'晚上好'**
  String get greetingEvening;

  /// No description provided for @dateWeekdayLong1.
  ///
  /// In zh, this message translates to:
  /// **'星期一'**
  String get dateWeekdayLong1;

  /// No description provided for @dateWeekdayLong2.
  ///
  /// In zh, this message translates to:
  /// **'星期二'**
  String get dateWeekdayLong2;

  /// No description provided for @dateWeekdayLong3.
  ///
  /// In zh, this message translates to:
  /// **'星期三'**
  String get dateWeekdayLong3;

  /// No description provided for @dateWeekdayLong4.
  ///
  /// In zh, this message translates to:
  /// **'星期四'**
  String get dateWeekdayLong4;

  /// No description provided for @dateWeekdayLong5.
  ///
  /// In zh, this message translates to:
  /// **'星期五'**
  String get dateWeekdayLong5;

  /// No description provided for @dateWeekdayLong6.
  ///
  /// In zh, this message translates to:
  /// **'星期六'**
  String get dateWeekdayLong6;

  /// No description provided for @dateWeekdayLong7.
  ///
  /// In zh, this message translates to:
  /// **'星期日'**
  String get dateWeekdayLong7;

  /// No description provided for @dateWeekdayShort1.
  ///
  /// In zh, this message translates to:
  /// **'一'**
  String get dateWeekdayShort1;

  /// No description provided for @dateWeekdayShort2.
  ///
  /// In zh, this message translates to:
  /// **'二'**
  String get dateWeekdayShort2;

  /// No description provided for @dateWeekdayShort3.
  ///
  /// In zh, this message translates to:
  /// **'三'**
  String get dateWeekdayShort3;

  /// No description provided for @dateWeekdayShort4.
  ///
  /// In zh, this message translates to:
  /// **'四'**
  String get dateWeekdayShort4;

  /// No description provided for @dateWeekdayShort5.
  ///
  /// In zh, this message translates to:
  /// **'五'**
  String get dateWeekdayShort5;

  /// No description provided for @dateWeekdayShort6.
  ///
  /// In zh, this message translates to:
  /// **'六'**
  String get dateWeekdayShort6;

  /// No description provided for @dateWeekdayShort7.
  ///
  /// In zh, this message translates to:
  /// **'日'**
  String get dateWeekdayShort7;

  /// No description provided for @timeJustNow.
  ///
  /// In zh, this message translates to:
  /// **'刚刚'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count} 分钟前'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In zh, this message translates to:
  /// **'{count} 小时前'**
  String timeHoursAgo(int count);

  /// No description provided for @timeTodayAt.
  ///
  /// In zh, this message translates to:
  /// **'今天 {time}'**
  String timeTodayAt(DateTime time);

  /// No description provided for @timeYesterdayAt.
  ///
  /// In zh, this message translates to:
  /// **'昨天 {time}'**
  String timeYesterdayAt(DateTime time);

  /// No description provided for @durationDays.
  ///
  /// In zh, this message translates to:
  /// **'{count} 天'**
  String durationDays(int count);

  /// No description provided for @durationHours.
  ///
  /// In zh, this message translates to:
  /// **'{count} 小时'**
  String durationHours(int count);

  /// No description provided for @durationMinutes.
  ///
  /// In zh, this message translates to:
  /// **'{count} 分钟'**
  String durationMinutes(int count);

  /// No description provided for @durationLessThanMinute.
  ///
  /// In zh, this message translates to:
  /// **'不到 1 分钟'**
  String get durationLessThanMinute;

  /// No description provided for @dashboardEditPanels.
  ///
  /// In zh, this message translates to:
  /// **'编辑面板'**
  String get dashboardEditPanels;

  /// No description provided for @dashboardWeekNotStarted.
  ///
  /// In zh, this message translates to:
  /// **'学期未开始'**
  String get dashboardWeekNotStarted;

  /// No description provided for @dashboardWeekEnded.
  ///
  /// In zh, this message translates to:
  /// **'学期已结束'**
  String get dashboardWeekEnded;

  /// No description provided for @dashboardSyncing.
  ///
  /// In zh, this message translates to:
  /// **'正在同步'**
  String get dashboardSyncing;

  /// No description provided for @dashboardSyncFailed.
  ///
  /// In zh, this message translates to:
  /// **'同步失败'**
  String get dashboardSyncFailed;

  /// No description provided for @dashboardEmptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日面板是空的'**
  String get dashboardEmptyTitle;

  /// No description provided for @dashboardEmptyMessage.
  ///
  /// In zh, this message translates to:
  /// **'添加需要的面板，或恢复默认布局。'**
  String get dashboardEmptyMessage;

  /// No description provided for @dashboardAddPanel.
  ///
  /// In zh, this message translates to:
  /// **'添加面板'**
  String get dashboardAddPanel;

  /// No description provided for @dashboardResetDefault.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认'**
  String get dashboardResetDefault;

  /// No description provided for @dashboardEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑今日面板'**
  String get dashboardEditTitle;

  /// No description provided for @dashboardEditSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'拖动排序，移除不需要的面板。'**
  String get dashboardEditSubtitle;

  /// No description provided for @dashboardAddPanelSection.
  ///
  /// In zh, this message translates to:
  /// **'添加面板'**
  String get dashboardAddPanelSection;

  /// No description provided for @dashboardAllPanelsAdded.
  ///
  /// In zh, this message translates to:
  /// **'所有面板都已添加。'**
  String get dashboardAllPanelsAdded;

  /// No description provided for @dashboardRemovePanel.
  ///
  /// In zh, this message translates to:
  /// **'移除面板'**
  String get dashboardRemovePanel;

  /// No description provided for @dashboardAddPanelTooltip.
  ///
  /// In zh, this message translates to:
  /// **'添加 {title}'**
  String dashboardAddPanelTooltip(String title);

  /// No description provided for @dashboardLoginRequired.
  ///
  /// In zh, this message translates to:
  /// **'请先登录教务账号'**
  String get dashboardLoginRequired;

  /// No description provided for @dashboardSynced.
  ///
  /// In zh, this message translates to:
  /// **'课表已更新'**
  String get dashboardSynced;

  /// No description provided for @panelNextClassTitle.
  ///
  /// In zh, this message translates to:
  /// **'下一节课'**
  String get panelNextClassTitle;

  /// No description provided for @panelNextClassOngoingTitle.
  ///
  /// In zh, this message translates to:
  /// **'正在上课'**
  String get panelNextClassOngoingTitle;

  /// No description provided for @panelNextClassDescription.
  ///
  /// In zh, this message translates to:
  /// **'正在上的课或接下来最近的一节课。'**
  String get panelNextClassDescription;

  /// No description provided for @panelNextClassSyncTooltip.
  ///
  /// In zh, this message translates to:
  /// **'同步课表'**
  String get panelNextClassSyncTooltip;

  /// No description provided for @panelNextClassNotLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'未登录'**
  String get panelNextClassNotLoggedIn;

  /// No description provided for @panelNextClassLoginPrompt.
  ///
  /// In zh, this message translates to:
  /// **'登录教务账号后，这里会显示今天的课程和下一节课。'**
  String get panelNextClassLoginPrompt;

  /// No description provided for @panelNextClassGoLogin.
  ///
  /// In zh, this message translates to:
  /// **'去登录'**
  String get panelNextClassGoLogin;

  /// No description provided for @panelNextClassNoCourses.
  ///
  /// In zh, this message translates to:
  /// **'接下来 14 天没有课程安排。'**
  String get panelNextClassNoCourses;

  /// No description provided for @panelNextClassNotSynced.
  ///
  /// In zh, this message translates to:
  /// **'还没有同步课表。'**
  String get panelNextClassNotSynced;

  /// No description provided for @panelNextClassPeriods.
  ///
  /// In zh, this message translates to:
  /// **'第 {start}-{end} 节'**
  String panelNextClassPeriods(int start, int end);

  /// No description provided for @panelNextClassWeeks.
  ///
  /// In zh, this message translates to:
  /// **'第 {weeks} 周'**
  String panelNextClassWeeks(String weeks);

  /// No description provided for @panelNextClassEndsIn.
  ///
  /// In zh, this message translates to:
  /// **'还有 {duration} 下课'**
  String panelNextClassEndsIn(String duration);

  /// No description provided for @panelNextClassStartsIn.
  ///
  /// In zh, this message translates to:
  /// **'还有 {duration} 开始'**
  String panelNextClassStartsIn(String duration);

  /// No description provided for @panelNextClassOngoing.
  ///
  /// In zh, this message translates to:
  /// **'进行中'**
  String get panelNextClassOngoing;

  /// No description provided for @panelNextClassUpcoming.
  ///
  /// In zh, this message translates to:
  /// **'即将开始'**
  String get panelNextClassUpcoming;

  /// No description provided for @panelNextClassSync.
  ///
  /// In zh, this message translates to:
  /// **'同步课表'**
  String get panelNextClassSync;

  /// No description provided for @panelTodayScheduleTitle.
  ///
  /// In zh, this message translates to:
  /// **'今日课程'**
  String get panelTodayScheduleTitle;

  /// No description provided for @panelTodayScheduleDescription.
  ///
  /// In zh, this message translates to:
  /// **'今天全部课程的紧凑时间线。'**
  String get panelTodayScheduleDescription;

  /// No description provided for @panelTodayScheduleCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 节'**
  String panelTodayScheduleCount(int count);

  /// No description provided for @panelTodayScheduleLoginTitle.
  ///
  /// In zh, this message translates to:
  /// **'登录后查看今日课程'**
  String get panelTodayScheduleLoginTitle;

  /// No description provided for @panelTodayScheduleLoginMessage.
  ///
  /// In zh, this message translates to:
  /// **'连接教务账号，自动同步课表与教学周。'**
  String get panelTodayScheduleLoginMessage;

  /// No description provided for @panelTodayScheduleLoginAction.
  ///
  /// In zh, this message translates to:
  /// **'登录账号'**
  String get panelTodayScheduleLoginAction;

  /// No description provided for @panelTodayScheduleSyncNow.
  ///
  /// In zh, this message translates to:
  /// **'立即同步'**
  String get panelTodayScheduleSyncNow;

  /// No description provided for @panelTodayScheduleNoCoursesTitle.
  ///
  /// In zh, this message translates to:
  /// **'今天没有课程'**
  String get panelTodayScheduleNoCoursesTitle;

  /// No description provided for @panelTodayScheduleNoCoursesMessage.
  ///
  /// In zh, this message translates to:
  /// **'享受空闲的一天，或者去完整课表看看这周安排。'**
  String get panelTodayScheduleNoCoursesMessage;

  /// No description provided for @panelTodayScheduleViewFull.
  ///
  /// In zh, this message translates to:
  /// **'查看完整课表'**
  String get panelTodayScheduleViewFull;

  /// No description provided for @panelTodayScheduleOngoing.
  ///
  /// In zh, this message translates to:
  /// **'进行中'**
  String get panelTodayScheduleOngoing;

  /// No description provided for @panelTodaySchedulePeriods.
  ///
  /// In zh, this message translates to:
  /// **'第 {start}-{end} 节'**
  String panelTodaySchedulePeriods(int start, int end);

  /// No description provided for @panelWeekProgressTitle.
  ///
  /// In zh, this message translates to:
  /// **'本周进度'**
  String get panelWeekProgressTitle;

  /// No description provided for @panelWeekProgressDescription.
  ///
  /// In zh, this message translates to:
  /// **'当前教学周、学期进度与剩余天数。'**
  String get panelWeekProgressDescription;

  /// No description provided for @panelWeekProgressWeek.
  ///
  /// In zh, this message translates to:
  /// **'第 {week} 周'**
  String panelWeekProgressWeek(int week);

  /// No description provided for @panelWeekProgressTotalWeeks.
  ///
  /// In zh, this message translates to:
  /// **'共 {count} 周'**
  String panelWeekProgressTotalWeeks(int count);

  /// No description provided for @panelWeekProgressTermEnded.
  ///
  /// In zh, this message translates to:
  /// **'本学期已结束。'**
  String get panelWeekProgressTermEnded;

  /// No description provided for @panelWeekProgressTermNotStarted.
  ///
  /// In zh, this message translates to:
  /// **'本学期尚未开始。'**
  String get panelWeekProgressTermNotStarted;

  /// No description provided for @panelWeekProgressDaysLeft.
  ///
  /// In zh, this message translates to:
  /// **'本周还剩 {count} 天'**
  String panelWeekProgressDaysLeft(int count);

  /// No description provided for @panelWeekProgressEstimated.
  ///
  /// In zh, this message translates to:
  /// **'教学周为估算值'**
  String get panelWeekProgressEstimated;

  /// No description provided for @panelWeekProgressEnded.
  ///
  /// In zh, this message translates to:
  /// **'已结束'**
  String get panelWeekProgressEnded;

  /// No description provided for @panelWeekProgressNotStarted.
  ///
  /// In zh, this message translates to:
  /// **'未开始'**
  String get panelWeekProgressNotStarted;

  /// No description provided for @panelAccountTitle.
  ///
  /// In zh, this message translates to:
  /// **'账户'**
  String get panelAccountTitle;

  /// No description provided for @panelAccountDescription.
  ///
  /// In zh, this message translates to:
  /// **'登录状态与最近一次课表同步时间。'**
  String get panelAccountDescription;

  /// No description provided for @panelAccountLoginTooltip.
  ///
  /// In zh, this message translates to:
  /// **'登录账号'**
  String get panelAccountLoginTooltip;

  /// No description provided for @panelAccountSyncTooltip.
  ///
  /// In zh, this message translates to:
  /// **'同步课表'**
  String get panelAccountSyncTooltip;

  /// No description provided for @panelAccountNotLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'未登录'**
  String get panelAccountNotLoggedIn;

  /// No description provided for @panelAccountConnectHint.
  ///
  /// In zh, this message translates to:
  /// **'连接教务账号以同步课表'**
  String get panelAccountConnectHint;

  /// No description provided for @panelAccountLogin.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get panelAccountLogin;

  /// No description provided for @panelAccountSyncing.
  ///
  /// In zh, this message translates to:
  /// **'正在同步课表…'**
  String get panelAccountSyncing;

  /// No description provided for @panelAccountNotSynced.
  ///
  /// In zh, this message translates to:
  /// **'尚未同步课表'**
  String get panelAccountNotSynced;

  /// No description provided for @panelAccountSyncedAt.
  ///
  /// In zh, this message translates to:
  /// **'课表同步于 {time}'**
  String panelAccountSyncedAt(String time);

  /// No description provided for @panelAccountSettings.
  ///
  /// In zh, this message translates to:
  /// **'账户与设置'**
  String get panelAccountSettings;

  /// No description provided for @panelQuickActionsTitle.
  ///
  /// In zh, this message translates to:
  /// **'快捷操作'**
  String get panelQuickActionsTitle;

  /// No description provided for @panelQuickActionsDescription.
  ///
  /// In zh, this message translates to:
  /// **'快速打开时间表、同步课表或切换外观。'**
  String get panelQuickActionsDescription;

  /// No description provided for @panelQuickActionsOpenTimetable.
  ///
  /// In zh, this message translates to:
  /// **'打开时间表'**
  String get panelQuickActionsOpenTimetable;

  /// No description provided for @panelQuickActionsSync.
  ///
  /// In zh, this message translates to:
  /// **'同步课表'**
  String get panelQuickActionsSync;

  /// No description provided for @panelQuickActionsLoginSync.
  ///
  /// In zh, this message translates to:
  /// **'登录并同步'**
  String get panelQuickActionsLoginSync;

  /// No description provided for @panelQuickActionsAccount.
  ///
  /// In zh, this message translates to:
  /// **'账户'**
  String get panelQuickActionsAccount;

  /// No description provided for @panelQuickActionsAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外观：{mode}'**
  String panelQuickActionsAppearance(String mode);

  /// No description provided for @panelQuickActionsSynced.
  ///
  /// In zh, this message translates to:
  /// **'课表已同步'**
  String get panelQuickActionsSynced;

  /// No description provided for @panelQuickActionsBusy.
  ///
  /// In zh, this message translates to:
  /// **'同步中…'**
  String get panelQuickActionsBusy;

  /// No description provided for @pluginCoreName.
  ///
  /// In zh, this message translates to:
  /// **'核心面板'**
  String get pluginCoreName;

  /// No description provided for @pluginCoreDescription.
  ///
  /// In zh, this message translates to:
  /// **'今日课程、下一节课、教学周与账户状态。'**
  String get pluginCoreDescription;

  /// No description provided for @timetableTitle.
  ///
  /// In zh, this message translates to:
  /// **'时间表'**
  String get timetableTitle;

  /// No description provided for @timetableSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'查看本地课表，按周浏览课程。'**
  String get timetableSubtitle;

  /// No description provided for @timetableSubtitleWithTerm.
  ///
  /// In zh, this message translates to:
  /// **'{term} · {campus}'**
  String timetableSubtitleWithTerm(String term, String campus);

  /// No description provided for @timetableSyncTooltip.
  ///
  /// In zh, this message translates to:
  /// **'同步课表'**
  String get timetableSyncTooltip;

  /// No description provided for @timetableLoginTooltip.
  ///
  /// In zh, this message translates to:
  /// **'登录账号'**
  String get timetableLoginTooltip;

  /// No description provided for @timetableLoginRequired.
  ///
  /// In zh, this message translates to:
  /// **'请先登录教务账号'**
  String get timetableLoginRequired;

  /// No description provided for @timetablePreviousWeek.
  ///
  /// In zh, this message translates to:
  /// **'上一周'**
  String get timetablePreviousWeek;

  /// No description provided for @timetableNextWeek.
  ///
  /// In zh, this message translates to:
  /// **'下一周'**
  String get timetableNextWeek;

  /// No description provided for @timetableThisWeek.
  ///
  /// In zh, this message translates to:
  /// **'本周'**
  String get timetableThisWeek;

  /// No description provided for @timetableSelectTerm.
  ///
  /// In zh, this message translates to:
  /// **'选择学期'**
  String get timetableSelectTerm;

  /// No description provided for @timetableTermPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'选择学期'**
  String get timetableTermPlaceholder;

  /// No description provided for @timetableWeekRange.
  ///
  /// In zh, this message translates to:
  /// **'{start} - {end}'**
  String timetableWeekRange(String start, String end);

  /// No description provided for @timetableCourseCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 门课'**
  String timetableCourseCount(int count);

  /// No description provided for @timetableEstimated.
  ///
  /// In zh, this message translates to:
  /// **'教学周为估算值'**
  String get timetableEstimated;

  /// No description provided for @timetableRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get timetableRetry;

  /// No description provided for @timetableLoginTitle.
  ///
  /// In zh, this message translates to:
  /// **'登录后同步课表'**
  String get timetableLoginTitle;

  /// No description provided for @timetableLoginMessage.
  ///
  /// In zh, this message translates to:
  /// **'连接深圳校区教务账号，课程会自动同步到今日和时间表。'**
  String get timetableLoginMessage;

  /// No description provided for @timetableSyncNow.
  ///
  /// In zh, this message translates to:
  /// **'同步课表'**
  String get timetableSyncNow;

  /// No description provided for @timetableSyncNowBusy.
  ///
  /// In zh, this message translates to:
  /// **'同步中…'**
  String get timetableSyncNowBusy;

  /// No description provided for @timetableLoginAction.
  ///
  /// In zh, this message translates to:
  /// **'登录账号'**
  String get timetableLoginAction;

  /// No description provided for @timetableMissingSlots.
  ///
  /// In zh, this message translates to:
  /// **'课表缺少节次信息'**
  String get timetableMissingSlots;

  /// No description provided for @timetableDetailTime.
  ///
  /// In zh, this message translates to:
  /// **'上课时间'**
  String get timetableDetailTime;

  /// No description provided for @timetableDetailWeeks.
  ///
  /// In zh, this message translates to:
  /// **'教学周'**
  String get timetableDetailWeeks;

  /// No description provided for @timetableDetailLocation.
  ///
  /// In zh, this message translates to:
  /// **'地点'**
  String get timetableDetailLocation;

  /// No description provided for @timetableDetailTeacher.
  ///
  /// In zh, this message translates to:
  /// **'教师'**
  String get timetableDetailTeacher;

  /// No description provided for @timetableDetailNotFilled.
  ///
  /// In zh, this message translates to:
  /// **'未填写'**
  String get timetableDetailNotFilled;

  /// No description provided for @timetableDetailClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get timetableDetailClose;

  /// No description provided for @timetableAddTooltip.
  ///
  /// In zh, this message translates to:
  /// **'添加课表'**
  String get timetableAddTooltip;

  /// No description provided for @timetableAddTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加课表'**
  String get timetableAddTitle;

  /// No description provided for @timetableAddImportTitle.
  ///
  /// In zh, this message translates to:
  /// **'导入课表'**
  String get timetableAddImportTitle;

  /// No description provided for @timetableAddImportSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'从教务导入指定学期'**
  String get timetableAddImportSubtitle;

  /// No description provided for @timetableAddIcsTitle.
  ///
  /// In zh, this message translates to:
  /// **'导入 ICS'**
  String get timetableAddIcsTitle;

  /// No description provided for @timetableAddIcsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'从 ICS 文件导入课表'**
  String get timetableAddIcsSubtitle;

  /// No description provided for @timetableAddBlankTitle.
  ///
  /// In zh, this message translates to:
  /// **'新建空白课表'**
  String get timetableAddBlankTitle;

  /// No description provided for @timetableAddBlankSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'手动创建一份本地课表'**
  String get timetableAddBlankSubtitle;

  /// No description provided for @timetableAddComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'即将支持'**
  String get timetableAddComingSoon;

  /// No description provided for @timetableImportSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'选择要导入的学期'**
  String get timetableImportSubtitle;

  /// No description provided for @timetableImportNoSession.
  ///
  /// In zh, this message translates to:
  /// **'需要登录教务账号'**
  String get timetableImportNoSession;

  /// No description provided for @timetableImportNoSessionMessage.
  ///
  /// In zh, this message translates to:
  /// **'登录后可在此导入教务课表。'**
  String get timetableImportNoSessionMessage;

  /// No description provided for @timetableImportFailed.
  ///
  /// In zh, this message translates to:
  /// **'导入失败'**
  String get timetableImportFailed;

  /// No description provided for @timetableImportRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get timetableImportRetry;

  /// No description provided for @timetableImportEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无可导入学期'**
  String get timetableImportEmpty;

  /// No description provided for @timetableImportEmptyMessage.
  ///
  /// In zh, this message translates to:
  /// **'教务系统未返回可选学期。'**
  String get timetableImportEmptyMessage;

  /// No description provided for @timetableImportExisting.
  ///
  /// In zh, this message translates to:
  /// **'已有本地课表，导入会更新'**
  String get timetableImportExisting;

  /// No description provided for @timetableImportSuccess.
  ///
  /// In zh, this message translates to:
  /// **'课表导入完成'**
  String get timetableImportSuccess;

  /// No description provided for @timetableManageTooltip.
  ///
  /// In zh, this message translates to:
  /// **'课表管理'**
  String get timetableManageTooltip;

  /// No description provided for @timetableManagerTitle.
  ///
  /// In zh, this message translates to:
  /// **'课表管理'**
  String get timetableManagerTitle;

  /// No description provided for @timetableManagerSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'{count} 份本地课表'**
  String timetableManagerSubtitle(int count);

  /// No description provided for @timetableManagerEmpty.
  ///
  /// In zh, this message translates to:
  /// **'还没有本地课表'**
  String get timetableManagerEmpty;

  /// No description provided for @timetableManagerEmptyMessage.
  ///
  /// In zh, this message translates to:
  /// **'同步教务后，每学期会生成一份本地课表，可在这里切换、重命名或删除。'**
  String get timetableManagerEmptyMessage;

  /// No description provided for @timetableManagerCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前'**
  String get timetableManagerCurrent;

  /// No description provided for @timetableManagerActions.
  ///
  /// In zh, this message translates to:
  /// **'课表操作'**
  String get timetableManagerActions;

  /// No description provided for @timetableManagerRename.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get timetableManagerRename;

  /// No description provided for @timetableManagerDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get timetableManagerDelete;

  /// No description provided for @timetableManagerSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败，请稍后重试'**
  String get timetableManagerSaveFailed;

  /// No description provided for @timetableRenameTitle.
  ///
  /// In zh, this message translates to:
  /// **'重命名课表'**
  String get timetableRenameTitle;

  /// No description provided for @timetableRenameLabel.
  ///
  /// In zh, this message translates to:
  /// **'课表名称'**
  String get timetableRenameLabel;

  /// No description provided for @timetableRenameEmpty.
  ///
  /// In zh, this message translates to:
  /// **'名称不能为空'**
  String get timetableRenameEmpty;

  /// No description provided for @timetableRenameCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get timetableRenameCancel;

  /// No description provided for @timetableRenameSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get timetableRenameSave;

  /// No description provided for @timetableDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除课表'**
  String get timetableDeleteTitle;

  /// No description provided for @timetableDeleteMessage.
  ///
  /// In zh, this message translates to:
  /// **'确定删除“{name}”？本地课程数据将一并移除。'**
  String timetableDeleteMessage(String name);

  /// No description provided for @timetableDeleteCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get timetableDeleteCancel;

  /// No description provided for @timetableDeleteConfirm.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get timetableDeleteConfirm;

  /// No description provided for @accountTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get accountTitle;

  /// No description provided for @accountSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'账号、同步和外观设置。'**
  String get accountSubtitle;

  /// No description provided for @accountConnectTitle.
  ///
  /// In zh, this message translates to:
  /// **'连接你的教务账号'**
  String get accountConnectTitle;

  /// No description provided for @accountConnectMessage.
  ///
  /// In zh, this message translates to:
  /// **'同步课表、教学周和今日课程。'**
  String get accountConnectMessage;

  /// No description provided for @accountLogin.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get accountLogin;

  /// No description provided for @accountErrorDismiss.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get accountErrorDismiss;

  /// No description provided for @accountSectionAccount.
  ///
  /// In zh, this message translates to:
  /// **'账号'**
  String get accountSectionAccount;

  /// No description provided for @accountNotLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'尚未登录'**
  String get accountNotLoggedIn;

  /// No description provided for @accountNotLoggedInMessage.
  ///
  /// In zh, this message translates to:
  /// **'当前版本已接入深圳校区教务。登录后即可同步课表。'**
  String get accountNotLoggedInMessage;

  /// No description provided for @accountLoginAccount.
  ///
  /// In zh, this message translates to:
  /// **'登录教务账号'**
  String get accountLoginAccount;

  /// No description provided for @accountCampus.
  ///
  /// In zh, this message translates to:
  /// **'校区'**
  String get accountCampus;

  /// No description provided for @accountStudentId.
  ///
  /// In zh, this message translates to:
  /// **'学号'**
  String get accountStudentId;

  /// No description provided for @accountSchool.
  ///
  /// In zh, this message translates to:
  /// **'学院'**
  String get accountSchool;

  /// No description provided for @accountLoginTime.
  ///
  /// In zh, this message translates to:
  /// **'登录时间'**
  String get accountLoginTime;

  /// No description provided for @accountSyncStatus.
  ///
  /// In zh, this message translates to:
  /// **'课表状态'**
  String get accountSyncStatus;

  /// No description provided for @accountSyncing.
  ///
  /// In zh, this message translates to:
  /// **'同步中…'**
  String get accountSyncing;

  /// No description provided for @accountNotSynced.
  ///
  /// In zh, this message translates to:
  /// **'尚未同步'**
  String get accountNotSynced;

  /// No description provided for @accountSynced.
  ///
  /// In zh, this message translates to:
  /// **'已同步'**
  String get accountSynced;

  /// No description provided for @accountSync.
  ///
  /// In zh, this message translates to:
  /// **'同步课表'**
  String get accountSync;

  /// No description provided for @accountRelogin.
  ///
  /// In zh, this message translates to:
  /// **'重新登录'**
  String get accountRelogin;

  /// No description provided for @accountLogout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get accountLogout;

  /// No description provided for @accountLogoutTitle.
  ///
  /// In zh, this message translates to:
  /// **'退出登录？'**
  String get accountLogoutTitle;

  /// No description provided for @accountLogoutMessage.
  ///
  /// In zh, this message translates to:
  /// **'本地课表会保留，但需要重新登录才能同步教务更新。'**
  String get accountLogoutMessage;

  /// No description provided for @accountLogoutAction.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get accountLogoutAction;

  /// No description provided for @accountLoggedOut.
  ///
  /// In zh, this message translates to:
  /// **'已退出登录'**
  String get accountLoggedOut;

  /// No description provided for @accountConnected.
  ///
  /// In zh, this message translates to:
  /// **'已连接'**
  String get accountConnected;

  /// No description provided for @accountSyncError.
  ///
  /// In zh, this message translates to:
  /// **'同步异常'**
  String get accountSyncError;

  /// No description provided for @accountLastSynced.
  ///
  /// In zh, this message translates to:
  /// **'上次同步 {time}'**
  String accountLastSynced(String time);

  /// No description provided for @accountAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get accountAppearance;

  /// No description provided for @accountPlugins.
  ///
  /// In zh, this message translates to:
  /// **'扩展'**
  String get accountPlugins;

  /// No description provided for @accountNoPlugins.
  ///
  /// In zh, this message translates to:
  /// **'没有注册扩展。'**
  String get accountNoPlugins;

  /// No description provided for @accountAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get accountAbout;

  /// No description provided for @accountAboutText.
  ///
  /// In zh, this message translates to:
  /// **'当前已接入深圳校区新版教务接口；本部与威海校区需要 WebVPN 网页认证，将在后续版本接入。'**
  String get accountAboutText;

  /// No description provided for @accountSettings.
  ///
  /// In zh, this message translates to:
  /// **'账户与设置'**
  String get accountSettings;

  /// No description provided for @accountPluginPanels.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个面板'**
  String accountPluginPanels(int count);

  /// No description provided for @accountPluginPages.
  ///
  /// In zh, this message translates to:
  /// **'{count} 个页面'**
  String accountPluginPages(int count);

  /// No description provided for @loginTitle.
  ///
  /// In zh, this message translates to:
  /// **'登录账号'**
  String get loginTitle;

  /// No description provided for @loginBrandTitle.
  ///
  /// In zh, this message translates to:
  /// **'连接教务系统'**
  String get loginBrandTitle;

  /// No description provided for @loginBrandSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'登录后自动同步课表与教学周。'**
  String get loginBrandSubtitle;

  /// No description provided for @loginCampus.
  ///
  /// In zh, this message translates to:
  /// **'校区'**
  String get loginCampus;

  /// No description provided for @loginAccount.
  ///
  /// In zh, this message translates to:
  /// **'教务账号'**
  String get loginAccount;

  /// No description provided for @loginAccountHint.
  ///
  /// In zh, this message translates to:
  /// **'学号或统一身份认证账号'**
  String get loginAccountHint;

  /// No description provided for @loginPassword.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get loginPassword;

  /// No description provided for @loginShowPassword.
  ///
  /// In zh, this message translates to:
  /// **'显示密码'**
  String get loginShowPassword;

  /// No description provided for @loginHidePassword.
  ///
  /// In zh, this message translates to:
  /// **'隐藏密码'**
  String get loginHidePassword;

  /// No description provided for @loginAccountRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入教务账号'**
  String get loginAccountRequired;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码'**
  String get loginPasswordRequired;

  /// No description provided for @loginSubmit.
  ///
  /// In zh, this message translates to:
  /// **'登录并同步'**
  String get loginSubmit;

  /// No description provided for @loginWebUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'浏览器跨域策略禁止直接访问教务接口，Web 端暂不支持登录。请使用 Android、iOS 或桌面端。'**
  String get loginWebUnsupported;

  /// No description provided for @loginWebUnsupportedButton.
  ///
  /// In zh, this message translates to:
  /// **'Web 端暂不支持登录'**
  String get loginWebUnsupportedButton;

  /// No description provided for @loginUnsupportedCampusButton.
  ///
  /// In zh, this message translates to:
  /// **'暂不支持此校区'**
  String get loginUnsupportedCampusButton;

  /// No description provided for @loginPrivacy.
  ///
  /// In zh, this message translates to:
  /// **'密码只用于本次登录，不会保存在设备上。登录会话保存在本机。'**
  String get loginPrivacy;

  /// No description provided for @datePatternMonthDay.
  ///
  /// In zh, this message translates to:
  /// **'{date}'**
  String datePatternMonthDay(DateTime date);

  /// No description provided for @datePatternFull.
  ///
  /// In zh, this message translates to:
  /// **'{date}'**
  String datePatternFull(DateTime date);

  /// No description provided for @datePatternWithWeekday.
  ///
  /// In zh, this message translates to:
  /// **'{date}'**
  String datePatternWithWeekday(DateTime date);

  /// No description provided for @datePatternDateTime.
  ///
  /// In zh, this message translates to:
  /// **'{date} {time}'**
  String datePatternDateTime(DateTime date, DateTime time);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
