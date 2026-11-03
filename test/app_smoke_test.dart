import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hita_omni/core/storage/key_value_store.dart';
import 'package:hita_omni/core/utils/date_time.dart';
import 'package:hita_omni/features/timetable/data/timetable_cache.dart';
import 'package:hita_omni/features/timetable/domain/course.dart';
import 'package:hita_omni/features/timetable/domain/term.dart';
import 'package:hita_omni/features/timetable/domain/time_slot.dart';
import 'package:hita_omni/features/timetable/domain/timetable_snapshot.dart';
import 'package:hita_omni/features/timetable/presentation/widgets/week_grid.dart';

import 'support/test_app.dart';

void main() {
  testWidgets('shows the core navigation and dashboard', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('今日'), findsWidgets);
    expect(find.text('时间表'), findsWidgets);
    expect(find.text('我的'), findsWidgets);
    expect(find.text('未连接教务'), findsNothing);
    expect(find.text('下一节课'), findsOneWidget);
    expect(find.text('今日课程'), findsOneWidget);
    expect(find.text('还没有课表数据'), findsNothing);
    expect(find.text('接下来 14 天没有课程安排。'), findsOneWidget);
    expect(find.text('今天没有课程'), findsOneWidget);
    expect(find.text('同步课表后显示教学周进度。'), findsNothing);
  });

  testWidgets('opens the account page from navigation', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1100, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('我的'));
    await tester.pumpAndSettle();

    expect(find.text('连接你的教务账号'), findsOneWidget);
    expect(find.text('登录教务账号'), findsOneWidget);

    await tester.tap(find.text('登录教务账号'));
    await tester.pumpAndSettle();

    expect(find.text('连接教务系统'), findsOneWidget);
    expect(find.text('登录并同步'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('adds a dashboard panel from the editor', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1100, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('编辑面板'));
    await tester.pumpAndSettle();
    expect(find.text('编辑今日面板'), findsOneWidget);

    await tester.tap(find.byTooltip('添加 快捷操作'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('完成'));
    await tester.pumpAndSettle();

    expect(find.text('快捷操作'), findsOneWidget);
    expect(find.text('打开时间表'), findsOneWidget);
  });

  testWidgets('fits the mobile shell without layout exceptions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('时间表'));
    await tester.pumpAndSettle();

    expect(find.text('时间表'), findsWidgets);
    expect(find.text('还没有课表数据'), findsNothing);
    expect(find.byType(WeekGrid), findsOneWidget);
    expect(find.text('第 1 周'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders cached timetable data without a login session', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1100, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final now = DateTime.now();
    final store = MemoryKeyValueStore();

    final term = const Term(
      yearCode: '2026-2027',
      termCode: '1',
      name: '2026-2027 秋季学期',
      isCurrent: true,
    );
    final snapshot = TimetableSnapshot(
      term: term,
      startDate: startOfWeek(now),
      slots: const <TimeSlot>[
        TimeSlot(startMinute: 8 * 60, endMinute: 8 * 60 + 45),
      ],
      courses: <Course>[
        Course(
          name: '高等数学',
          weekday: now.weekday,
          startPeriod: 1,
          endPeriod: 1,
          weeks: const <int>[1],
        ),
      ],
      totalWeeks: 20,
      calendarVerified: true,
      fetchedAt: now,
    );
    await TimetableCache(store).save(
      TimetableCacheData.single(
        providerId: 'hit.shenzhen',
        terms: <Term>[term],
        snapshot: snapshot,
      ),
    );

    await tester.pumpWidget(buildTestApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('高等数学'), findsWidgets);
    expect(find.text('第 1 周'), findsWidgets);
    expect(find.text('未登录'), findsWidgets);
  });
}
