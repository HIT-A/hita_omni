import 'dart:convert';

import 'package:academic_api/academic_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hita_omni/core/storage/storage.dart';
import 'package:hita_omni/features/account/application/account_controller.dart';
import 'package:hita_omni/features/account/data/auth_repository.dart';
import 'package:hita_omni/features/account/data/session_store.dart';
import 'package:hita_omni/features/timetable/application/timetable_controller.dart';
import 'package:hita_omni/features/timetable/data/timetable_cache.dart';
import 'package:hita_omni/features/timetable/data/timetable_repository.dart';
import 'package:hita_omni/features/timetable/domain/timetable_entry.dart';
import 'package:provider_hit/provider_hit.dart';

import 'support/test_app.dart';

void main() {
  const termA = Term(
    yearCode: '2026-2027',
    termCode: '1',
    name: '2026-2027 秋季学期',
    isCurrent: true,
  );
  const termB = Term(
    yearCode: '2025-2026',
    termCode: '2',
    name: '2025-2026 春季学期',
  );

  TimetableSnapshot snapshotFor(Term term, {String courseName = '高等数学'}) {
    final start = DateTime(2026, 9, 7);
    return TimetableSnapshot(
      term: term,
      startDate: start,
      slots: const <TimeSlot>[
        TimeSlot(startMinute: 8 * 60, endMinute: 8 * 60 + 45),
        TimeSlot(startMinute: 10 * 60, endMinute: 10 * 60 + 45),
      ],
      courses: <Course>[
        Course(
          name: courseName,
          weekday: DateTime.monday,
          startPeriod: 1,
          endPeriod: 1,
          weeks: const <int>[1],
        ),
      ],
      totalWeeks: 20,
      calendarVerified: true,
      fetchedAt: DateTime(2026, 9, 1),
    );
  }

  testWidgets('switches, renames, and deletes local timetables', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1100, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final store = MemoryKeyValueStore();
    final cache = TimetableCache(store);
    final entryA = TimetableEntry.fromSnapshot(
      id: 'timetable-a',
      snapshot: snapshotFor(termA),
      name: '主课表',
    );
    final entryB = TimetableEntry.fromSnapshot(
      id: 'timetable-b',
      snapshot: snapshotFor(termB, courseName: '大学物理'),
      name: '实验课表',
    );
    await cache.save(
      TimetableCacheData(
        providerId: 'hit.shenzhen',
        terms: const <Term>[termA, termB],
        timetables: <TimetableEntry>[entryA, entryB],
        activeTimetableId: entryA.id,
      ),
    );

    final providers = AcademicProviderCatalog(
      createHitProviders(transport: NoopHttpTransport()),
    );
    final account = AccountController(
      sessionStore: SessionStore(store),
      authRepository: AuthRepository(catalog: providers),
    );
    final timetable = TimetableController(
      account: account,
      repository: TimetableRepository(catalog: providers, cache: cache),
    );
    addTearDown(timetable.dispose);
    addTearDown(account.dispose);

    expect(timetable.activeTimetable?.id, entryA.id);
    expect(timetable.snapshot?.term.id, termA.id);
    expect(timetable.timetables, hasLength(2));

    const remoteOnlyTerm = Term(
      yearCode: '2027-2028',
      termCode: '1',
      name: '2027-2028 秋季学期',
    );
    await timetable.selectTerm(remoteOnlyTerm);
    expect(timetable.timetables, hasLength(2));
    expect(timetable.snapshot?.term.id, termA.id);

    await timetable.selectTimetable(entryB.id);
    expect(timetable.activeTimetable?.id, entryB.id);
    expect(timetable.snapshot?.term.id, termB.id);
    expect(cache.readFor('hit.shenzhen')?.activeTimetableId, entryB.id);

    expect(await timetable.renameTimetable(entryB.id, '物理课表'), isTrue);
    expect(timetable.activeTimetable?.displayName, '物理课表');

    expect(await timetable.deleteTimetable(entryA.id), isTrue);
    expect(timetable.timetables.single.id, entryB.id);
    expect(timetable.activeTimetable?.displayName, '物理课表');

    expect(await timetable.deleteTimetable(entryB.id), isTrue);
    expect(timetable.timetables, isEmpty);
    expect(timetable.snapshot, isNull);
    expect(cache.readFor('hit.shenzhen')?.timetables, isEmpty);
  });

  test('migrates the v2 single-snapshot cache to a managed entry', () async {
    final store = MemoryKeyValueStore();
    final cache = TimetableCache(store);
    final snapshot = snapshotFor(termA);
    await store.setString(
      'timetable.cache.v2',
      jsonEncode(<String, dynamic>{
        'activeProviderId': 'hit.shenzhen',
        'providers': <String, dynamic>{
          'hit.shenzhen': <String, dynamic>{
            'terms': <Map<String, dynamic>>[termA.toJson()],
            'snapshot': snapshot.toJson(),
          },
        },
      }),
    );

    final migrated = cache.readFor('hit.shenzhen');
    expect(migrated, isNotNull);
    expect(migrated!.timetables, hasLength(1));
    expect(migrated.activeTimetable?.snapshot.term.id, termA.id);
    expect(migrated.activeTimetableId, migrated.timetables.single.id);

    await cache.save(migrated);
    expect(store.getString('timetable.cache.v2'), isNull);
    expect(store.getString('timetable.cache.v3'), isNotNull);
  });

  testWidgets('opens the timetable manager sheet', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = MemoryKeyValueStore();
    await TimetableCache(store).save(
      TimetableCacheData(
        providerId: 'hit.shenzhen',
        terms: const <Term>[termA, termB],
        timetables: <TimetableEntry>[
          TimetableEntry.fromSnapshot(
            id: 'timetable-a',
            snapshot: snapshotFor(termA),
            name: '主课表',
          ),
          TimetableEntry.fromSnapshot(
            id: 'timetable-b',
            snapshot: snapshotFor(termB, courseName: '大学物理'),
            name: '实验课表',
          ),
        ],
        activeTimetableId: 'timetable-a',
      ),
    );

    await tester.pumpWidget(buildTestApp(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('时间表'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('课表管理'));
    await tester.pumpAndSettle();

    expect(find.text('课表管理'), findsOneWidget);
    expect(find.text('主课表'), findsWidgets);
    expect(find.text('实验课表'), findsOneWidget);
    expect(find.text('当前'), findsOneWidget);
    expect(find.byTooltip('添加课表'), findsOneWidget);

    await tester.tap(find.byTooltip('添加课表'));
    await tester.pumpAndSettle();
    expect(find.text('添加课表'), findsOneWidget);
    expect(find.text('导入课表'), findsOneWidget);
    expect(find.text('导入 ICS'), findsOneWidget);
    expect(find.text('新建空白课表'), findsOneWidget);
    expect(find.text('即将支持'), findsNWidgets(2));

    await tester.tap(find.text('导入课表'));
    await tester.pumpAndSettle();
    expect(find.text('需要登录教务账号'), findsOneWidget);
    expect(find.text('登录后可在此导入教务课表。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
