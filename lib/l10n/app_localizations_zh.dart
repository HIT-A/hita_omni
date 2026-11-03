// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get navToday => '今日';

  @override
  String get navTimetable => '时间表';

  @override
  String get navAccount => '我的';

  @override
  String get sidebarExpand => '展开侧边栏';

  @override
  String get sidebarCollapse => '收起侧边栏';

  @override
  String get commonLogin => '登录';

  @override
  String get commonLogout => '退出登录';

  @override
  String get commonCancel => '取消';

  @override
  String get commonDone => '完成';

  @override
  String get commonClose => '关闭';

  @override
  String get windowMinimize => '最小化';

  @override
  String get windowMaximize => '最大化';

  @override
  String get windowRestore => '还原窗口';

  @override
  String get commonRetry => '重试';

  @override
  String get commonSync => '同步课表';

  @override
  String get commonSyncing => '同步中…';

  @override
  String get commonLoginAccount => '登录账号';

  @override
  String get commonNotSet => '未设置';

  @override
  String get commonNotAvailable => '未获取';

  @override
  String commonWeek(int week) {
    return '第 $week 周';
  }

  @override
  String get commonCurrentWeek => '本周';

  @override
  String get commonDelete => '删除';

  @override
  String get commonRemove => '移除';

  @override
  String get commonAdd => '添加';

  @override
  String get commonLoading => '加载中…';

  @override
  String get campusShenzhenLabel => '深圳校区';

  @override
  String get campusShenzhenShort => '深圳';

  @override
  String get campusShenzhenNote => '使用深圳校区新版教务账号登录，会话仅保存在本机。';

  @override
  String get campusHarbinLabel => '本部校区';

  @override
  String get campusHarbinShort => '本部';

  @override
  String get campusHarbinNote => '本部教务使用 WebVPN 网页认证，当前版本暂未接入。';

  @override
  String get campusWeihaiLabel => '威海校区';

  @override
  String get campusWeihaiShort => '威海';

  @override
  String get campusWeihaiNote => '威海教务使用 WebVPN 网页认证，当前版本暂未接入。';

  @override
  String get studentTypeUndergraduate => '本科生';

  @override
  String get studentTypeGraduate => '研究生';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get greetingNight => '夜深了';

  @override
  String get greetingMorning => '早上好';

  @override
  String get greetingAfternoon => '下午好';

  @override
  String get greetingEvening => '晚上好';

  @override
  String get dateWeekdayLong1 => '星期一';

  @override
  String get dateWeekdayLong2 => '星期二';

  @override
  String get dateWeekdayLong3 => '星期三';

  @override
  String get dateWeekdayLong4 => '星期四';

  @override
  String get dateWeekdayLong5 => '星期五';

  @override
  String get dateWeekdayLong6 => '星期六';

  @override
  String get dateWeekdayLong7 => '星期日';

  @override
  String get dateWeekdayShort1 => '一';

  @override
  String get dateWeekdayShort2 => '二';

  @override
  String get dateWeekdayShort3 => '三';

  @override
  String get dateWeekdayShort4 => '四';

  @override
  String get dateWeekdayShort5 => '五';

  @override
  String get dateWeekdayShort6 => '六';

  @override
  String get dateWeekdayShort7 => '日';

  @override
  String get timeJustNow => '刚刚';

  @override
  String timeMinutesAgo(int count) {
    return '$count 分钟前';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count 小时前';
  }

  @override
  String timeTodayAt(DateTime time) {
    final intl.DateFormat timeDateFormat = intl.DateFormat.Hm(localeName);
    final String timeString = timeDateFormat.format(time);

    return '今天 $timeString';
  }

  @override
  String timeYesterdayAt(DateTime time) {
    final intl.DateFormat timeDateFormat = intl.DateFormat.Hm(localeName);
    final String timeString = timeDateFormat.format(time);

    return '昨天 $timeString';
  }

  @override
  String durationDays(int count) {
    return '$count 天';
  }

  @override
  String durationHours(int count) {
    return '$count 小时';
  }

  @override
  String durationMinutes(int count) {
    return '$count 分钟';
  }

  @override
  String get durationLessThanMinute => '不到 1 分钟';

  @override
  String get dashboardEditPanels => '编辑面板';

  @override
  String get dashboardWeekNotStarted => '学期未开始';

  @override
  String get dashboardWeekEnded => '学期已结束';

  @override
  String get dashboardSyncing => '正在同步';

  @override
  String get dashboardSyncFailed => '同步失败';

  @override
  String get dashboardEmptyTitle => '今日面板是空的';

  @override
  String get dashboardEmptyMessage => '添加需要的面板，或恢复默认布局。';

  @override
  String get dashboardAddPanel => '添加面板';

  @override
  String get dashboardResetDefault => '恢复默认';

  @override
  String get dashboardEditTitle => '编辑今日面板';

  @override
  String get dashboardEditSubtitle => '拖动排序，移除不需要的面板。';

  @override
  String get dashboardAddPanelSection => '添加面板';

  @override
  String get dashboardAllPanelsAdded => '所有面板都已添加。';

  @override
  String get dashboardRemovePanel => '移除面板';

  @override
  String dashboardAddPanelTooltip(String title) {
    return '添加 $title';
  }

  @override
  String get dashboardLoginRequired => '请先登录教务账号';

  @override
  String get dashboardSynced => '课表已更新';

  @override
  String get panelNextClassTitle => '下一节课';

  @override
  String get panelNextClassOngoingTitle => '正在上课';

  @override
  String get panelNextClassDescription => '正在上的课或接下来最近的一节课。';

  @override
  String get panelNextClassSyncTooltip => '同步课表';

  @override
  String get panelNextClassNotLoggedIn => '未登录';

  @override
  String get panelNextClassLoginPrompt => '登录教务账号后，这里会显示今天的课程和下一节课。';

  @override
  String get panelNextClassGoLogin => '去登录';

  @override
  String get panelNextClassNoCourses => '接下来 14 天没有课程安排。';

  @override
  String get panelNextClassNotSynced => '还没有同步课表。';

  @override
  String panelNextClassPeriods(int start, int end) {
    return '第 $start-$end 节';
  }

  @override
  String panelNextClassWeeks(String weeks) {
    return '第 $weeks 周';
  }

  @override
  String panelNextClassEndsIn(String duration) {
    return '还有 $duration 下课';
  }

  @override
  String panelNextClassStartsIn(String duration) {
    return '还有 $duration 开始';
  }

  @override
  String get panelNextClassOngoing => '进行中';

  @override
  String get panelNextClassUpcoming => '即将开始';

  @override
  String get panelNextClassSync => '同步课表';

  @override
  String get panelTodayScheduleTitle => '今日课程';

  @override
  String get panelTodayScheduleDescription => '今天全部课程的紧凑时间线。';

  @override
  String panelTodayScheduleCount(int count) {
    return '$count 节';
  }

  @override
  String get panelTodayScheduleLoginTitle => '登录后查看今日课程';

  @override
  String get panelTodayScheduleLoginMessage => '连接教务账号，自动同步课表与教学周。';

  @override
  String get panelTodayScheduleLoginAction => '登录账号';

  @override
  String get panelTodayScheduleSyncNow => '立即同步';

  @override
  String get panelTodayScheduleNoCoursesTitle => '今天没有课程';

  @override
  String get panelTodayScheduleNoCoursesMessage => '享受空闲的一天，或者去完整课表看看这周安排。';

  @override
  String get panelTodayScheduleViewFull => '查看完整课表';

  @override
  String get panelTodayScheduleOngoing => '进行中';

  @override
  String panelTodaySchedulePeriods(int start, int end) {
    return '第 $start-$end 节';
  }

  @override
  String get panelWeekProgressTitle => '本周进度';

  @override
  String get panelWeekProgressDescription => '当前教学周、学期进度与剩余天数。';

  @override
  String panelWeekProgressWeek(int week) {
    return '第 $week 周';
  }

  @override
  String panelWeekProgressTotalWeeks(int count) {
    return '共 $count 周';
  }

  @override
  String get panelWeekProgressTermEnded => '本学期已结束。';

  @override
  String get panelWeekProgressTermNotStarted => '本学期尚未开始。';

  @override
  String panelWeekProgressDaysLeft(int count) {
    return '本周还剩 $count 天';
  }

  @override
  String get panelWeekProgressEstimated => '教学周为估算值';

  @override
  String get panelWeekProgressEnded => '已结束';

  @override
  String get panelWeekProgressNotStarted => '未开始';

  @override
  String get panelAccountTitle => '账户';

  @override
  String get panelAccountDescription => '登录状态与最近一次课表同步时间。';

  @override
  String get panelAccountLoginTooltip => '登录账号';

  @override
  String get panelAccountSyncTooltip => '同步课表';

  @override
  String get panelAccountNotLoggedIn => '未登录';

  @override
  String get panelAccountConnectHint => '连接教务账号以同步课表';

  @override
  String get panelAccountLogin => '登录';

  @override
  String get panelAccountSyncing => '正在同步课表…';

  @override
  String get panelAccountNotSynced => '尚未同步课表';

  @override
  String panelAccountSyncedAt(String time) {
    return '课表同步于 $time';
  }

  @override
  String get panelAccountSettings => '账户与设置';

  @override
  String get panelQuickActionsTitle => '快捷操作';

  @override
  String get panelQuickActionsDescription => '快速打开时间表、同步课表或切换外观。';

  @override
  String get panelQuickActionsOpenTimetable => '打开时间表';

  @override
  String get panelQuickActionsSync => '同步课表';

  @override
  String get panelQuickActionsLoginSync => '登录并同步';

  @override
  String get panelQuickActionsAccount => '账户';

  @override
  String panelQuickActionsAppearance(String mode) {
    return '外观：$mode';
  }

  @override
  String get panelQuickActionsSynced => '课表已同步';

  @override
  String get panelQuickActionsBusy => '同步中…';

  @override
  String get pluginCoreName => '核心面板';

  @override
  String get pluginCoreDescription => '今日课程、下一节课、教学周与账户状态。';

  @override
  String get timetableTitle => '时间表';

  @override
  String get timetableSubtitle => '查看本地课表，按周浏览课程。';

  @override
  String timetableSubtitleWithTerm(String term, String campus) {
    return '$term · $campus';
  }

  @override
  String get timetableSyncTooltip => '同步课表';

  @override
  String get timetableLoginTooltip => '登录账号';

  @override
  String get timetableLoginRequired => '请先登录教务账号';

  @override
  String get timetablePreviousWeek => '上一周';

  @override
  String get timetableNextWeek => '下一周';

  @override
  String get timetableThisWeek => '本周';

  @override
  String get timetableSelectTerm => '选择学期';

  @override
  String get timetableTermPlaceholder => '选择学期';

  @override
  String timetableWeekRange(String start, String end) {
    return '$start - $end';
  }

  @override
  String timetableCourseCount(int count) {
    return '$count 门课';
  }

  @override
  String get timetableEstimated => '教学周为估算值';

  @override
  String get timetableRetry => '重试';

  @override
  String get timetableLoginTitle => '登录后同步课表';

  @override
  String get timetableLoginMessage => '连接深圳校区教务账号，课程会自动同步到今日和时间表。';

  @override
  String get timetableSyncNow => '同步课表';

  @override
  String get timetableSyncNowBusy => '同步中…';

  @override
  String get timetableLoginAction => '登录账号';

  @override
  String get timetableMissingSlots => '课表缺少节次信息';

  @override
  String get timetableDetailTime => '上课时间';

  @override
  String get timetableDetailWeeks => '教学周';

  @override
  String get timetableDetailLocation => '地点';

  @override
  String get timetableDetailTeacher => '教师';

  @override
  String get timetableDetailNotFilled => '未填写';

  @override
  String get timetableDetailClose => '关闭';

  @override
  String get timetableAddTooltip => '添加课表';

  @override
  String get timetableAddTitle => '添加课表';

  @override
  String get timetableAddImportTitle => '导入课表';

  @override
  String get timetableAddImportSubtitle => '从教务导入指定学期';

  @override
  String get timetableAddIcsTitle => '导入 ICS';

  @override
  String get timetableAddIcsSubtitle => '从 ICS 文件导入课表';

  @override
  String get timetableAddBlankTitle => '新建空白课表';

  @override
  String get timetableAddBlankSubtitle => '手动创建一份本地课表';

  @override
  String get timetableAddComingSoon => '即将支持';

  @override
  String get timetableImportSubtitle => '选择要导入的学期';

  @override
  String get timetableImportNoSession => '需要登录教务账号';

  @override
  String get timetableImportNoSessionMessage => '登录后可在此导入教务课表。';

  @override
  String get timetableImportFailed => '导入失败';

  @override
  String get timetableImportRetry => '重试';

  @override
  String get timetableImportEmpty => '暂无可导入学期';

  @override
  String get timetableImportEmptyMessage => '教务系统未返回可选学期。';

  @override
  String get timetableImportExisting => '已有本地课表，导入会更新';

  @override
  String get timetableImportSuccess => '课表导入完成';

  @override
  String get timetableManageTooltip => '课表管理';

  @override
  String get timetableManagerTitle => '课表管理';

  @override
  String timetableManagerSubtitle(int count) {
    return '$count 份本地课表';
  }

  @override
  String get timetableManagerEmpty => '还没有本地课表';

  @override
  String get timetableManagerEmptyMessage =>
      '同步教务后，每学期会生成一份本地课表，可在这里切换、重命名或删除。';

  @override
  String get timetableManagerCurrent => '当前';

  @override
  String get timetableManagerActions => '课表操作';

  @override
  String get timetableManagerRename => '重命名';

  @override
  String get timetableManagerDelete => '删除';

  @override
  String get timetableManagerSaveFailed => '保存失败，请稍后重试';

  @override
  String get timetableRenameTitle => '重命名课表';

  @override
  String get timetableRenameLabel => '课表名称';

  @override
  String get timetableRenameEmpty => '名称不能为空';

  @override
  String get timetableRenameCancel => '取消';

  @override
  String get timetableRenameSave => '保存';

  @override
  String get timetableDeleteTitle => '删除课表';

  @override
  String timetableDeleteMessage(String name) {
    return '确定删除“$name”？本地课程数据将一并移除。';
  }

  @override
  String get timetableDeleteCancel => '取消';

  @override
  String get timetableDeleteConfirm => '删除';

  @override
  String get accountTitle => '我的';

  @override
  String get accountSubtitle => '账号、同步和外观设置。';

  @override
  String get accountConnectTitle => '连接你的教务账号';

  @override
  String get accountConnectMessage => '同步课表、教学周和今日课程。';

  @override
  String get accountLogin => '登录';

  @override
  String get accountErrorDismiss => '关闭';

  @override
  String get accountSectionAccount => '账号';

  @override
  String get accountNotLoggedIn => '尚未登录';

  @override
  String get accountNotLoggedInMessage => '当前版本已接入深圳校区教务。登录后即可同步课表。';

  @override
  String get accountLoginAccount => '登录教务账号';

  @override
  String get accountCampus => '校区';

  @override
  String get accountStudentId => '学号';

  @override
  String get accountSchool => '学院';

  @override
  String get accountLoginTime => '登录时间';

  @override
  String get accountSyncStatus => '课表状态';

  @override
  String get accountSyncing => '同步中…';

  @override
  String get accountNotSynced => '尚未同步';

  @override
  String get accountSynced => '已同步';

  @override
  String get accountSync => '同步课表';

  @override
  String get accountRelogin => '重新登录';

  @override
  String get accountLogout => '退出登录';

  @override
  String get accountLogoutTitle => '退出登录？';

  @override
  String get accountLogoutMessage => '本地课表会保留，但需要重新登录才能同步教务更新。';

  @override
  String get accountLogoutAction => '退出';

  @override
  String get accountLoggedOut => '已退出登录';

  @override
  String get accountConnected => '已连接';

  @override
  String get accountSyncError => '同步异常';

  @override
  String accountLastSynced(String time) {
    return '上次同步 $time';
  }

  @override
  String get accountAppearance => '外观';

  @override
  String get accountPlugins => '扩展';

  @override
  String get accountNoPlugins => '没有注册扩展。';

  @override
  String get accountAbout => '关于';

  @override
  String get accountAboutText =>
      '当前已接入深圳校区新版教务接口；本部与威海校区需要 WebVPN 网页认证，将在后续版本接入。';

  @override
  String get accountSettings => '账户与设置';

  @override
  String accountPluginPanels(int count) {
    return '$count 个面板';
  }

  @override
  String accountPluginPages(int count) {
    return '$count 个页面';
  }

  @override
  String get loginTitle => '登录账号';

  @override
  String get loginBrandTitle => '连接教务系统';

  @override
  String get loginBrandSubtitle => '登录后自动同步课表与教学周。';

  @override
  String get loginCampus => '校区';

  @override
  String get loginAccount => '教务账号';

  @override
  String get loginAccountHint => '学号或统一身份认证账号';

  @override
  String get loginPassword => '密码';

  @override
  String get loginShowPassword => '显示密码';

  @override
  String get loginHidePassword => '隐藏密码';

  @override
  String get loginAccountRequired => '请输入教务账号';

  @override
  String get loginPasswordRequired => '请输入密码';

  @override
  String get loginSubmit => '登录并同步';

  @override
  String get loginWebUnsupported =>
      '浏览器跨域策略禁止直接访问教务接口，Web 端暂不支持登录。请使用 Android、iOS 或桌面端。';

  @override
  String get loginWebUnsupportedButton => 'Web 端暂不支持登录';

  @override
  String get loginUnsupportedCampusButton => '暂不支持此校区';

  @override
  String get loginPrivacy => '密码只用于本次登录，不会保存在设备上。登录会话保存在本机。';

  @override
  String datePatternMonthDay(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String datePatternFull(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String datePatternWithWeekday(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String datePatternDateTime(DateTime date, DateTime time) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);
    final intl.DateFormat timeDateFormat = intl.DateFormat.Hm(localeName);
    final String timeString = timeDateFormat.format(time);

    return '$dateString $timeString';
  }
}
