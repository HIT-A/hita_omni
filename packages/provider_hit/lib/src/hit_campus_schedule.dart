import 'package:academic_api/academic_api.dart';

import 'hit_campus.dart';

abstract final class HitCampusSchedule {
  static List<TimeSlot> forCampus(
    HitCampus campus, {
    HitStudentType studentType = HitStudentType.undergraduate,
  }) {
    if (studentType == HitStudentType.graduate) {
      return switch (campus) {
        HitCampus.shenzhen || HitCampus.harbin => _graduate,
        HitCampus.weihai => _weihaiUndergraduate,
      };
    }
    return switch (campus) {
      HitCampus.shenzhen => _shenzhenUndergraduate,
      HitCampus.harbin => _harbinUndergraduate,
      HitCampus.weihai => _weihaiUndergraduate,
    };
  }

  static List<TimeSlot> _slots(List<(int, int, int, int)> values) {
    return <TimeSlot>[
      for (final (startHour, startMinute, endHour, endMinute) in values)
        TimeSlot(
          startMinute: startHour * 60 + startMinute,
          endMinute: endHour * 60 + endMinute,
        ),
    ];
  }

  static final List<TimeSlot> _harbinUndergraduate = _slots(
    const <(int, int, int, int)>[
      (8, 0, 8, 50),
      (8, 55, 9, 45),
      (10, 0, 10, 50),
      (10, 55, 11, 45),
      (13, 45, 14, 35),
      (14, 40, 15, 30),
      (15, 45, 16, 35),
      (16, 40, 17, 30),
      (18, 30, 19, 20),
      (19, 25, 20, 15),
      (20, 30, 21, 20),
      (21, 25, 22, 15),
    ],
  );

  static final List<TimeSlot> _weihaiUndergraduate = _slots(
    const <(int, int, int, int)>[
      (8, 0, 8, 50),
      (8, 55, 9, 45),
      (10, 5, 10, 55),
      (11, 0, 11, 50),
      (14, 0, 14, 50),
      (14, 55, 15, 45),
      (16, 5, 16, 55),
      (17, 0, 17, 50),
      (18, 40, 19, 30),
      (19, 35, 20, 25),
      (20, 45, 21, 35),
      (21, 40, 22, 30),
    ],
  );

  static final List<TimeSlot> _shenzhenUndergraduate = _slots(
    const <(int, int, int, int)>[
      (8, 30, 9, 20),
      (9, 25, 10, 15),
      (10, 30, 11, 20),
      (11, 25, 12, 15),
      (14, 0, 14, 50),
      (14, 55, 15, 45),
      (16, 0, 16, 50),
      (16, 55, 17, 45),
      (18, 45, 19, 35),
      (19, 40, 20, 30),
      (20, 45, 21, 35),
      (21, 40, 22, 30),
    ],
  );

  static final List<TimeSlot> _graduate = _slots(const <(int, int, int, int)>[
    (8, 0, 8, 50),
    (8, 55, 9, 45),
    (10, 0, 10, 50),
    (10, 55, 11, 45),
    (14, 0, 14, 50),
    (14, 55, 15, 45),
    (16, 0, 16, 50),
    (16, 55, 17, 45),
    (18, 45, 19, 35),
    (19, 40, 20, 30),
    (20, 45, 21, 35),
    (21, 40, 22, 30),
  ]);
}
