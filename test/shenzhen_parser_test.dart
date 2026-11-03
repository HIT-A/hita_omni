import 'package:flutter_test/flutter_test.dart';
import 'package:provider_hit/provider_hit.dart';

void main() {
  test('parses courses, classroom, teacher, and dates', () {
    final parsed = parseShenzhenWeek(<String, dynamic>{
      'code': 200,
      'content': <dynamic>[
        <String, dynamic>{
          'rqList': <dynamic>[
            <String, dynamic>{'RQ': '2024-09-02'},
            <String, dynamic>{'RQ': '2024-09-03'},
          ],
          'kcxxList': <dynamic>[
            <String, dynamic>{
              'XQJ': 1,
              'KSJC': 1,
              'JSJC': 2,
              'KCDM': 'COMP1001-01',
              'KCMC': '程序设计基础',
              'JSXM': '李四',
              'KBXX': '程序设计基础\n[A301] [1-16周]',
            },
            <String, dynamic>{
              'XQJ': 3,
              'KSJC': 3,
              'JSJC': 4,
              'KCDM': '',
              'KBXX': '大学物理\n[实验] [B203]',
            },
            <String, dynamic>{'XQJ': 9, 'KSJC': 1, 'JSJC': 1, 'KCMC': '无效课程'},
          ],
        },
      ],
    }, 3);

    expect(parsed.dates, <String>['2024-09-02', '2024-09-03']);
    expect(parsed.courses, hasLength(2));

    final first = parsed.courses[0];
    expect(first.name, '程序设计基础');
    expect(first.code, 'COMP1001');
    expect(first.teacher, '李四');
    expect(first.classroom, 'A301');
    expect(first.weekday, 1);
    expect(first.startPeriod, 1);
    expect(first.endPeriod, 2);
    expect(first.weeks, <int>[3]);

    final second = parsed.courses[1];
    expect(second.name, '大学物理');
    expect(second.classroom, 'B203');
    expect(second.weekday, 3);
    expect(second.startPeriod, 3);
    expect(second.endPeriod, 4);
  });

  test('keeps KBXX teacher names that contain week-like characters', () {
    final parsed = parseShenzhenWeek(<String, dynamic>{
      'content': <dynamic>[
        <String, dynamic>{
          'kcxxList': <dynamic>[
            <String, dynamic>{
              'XQJ': 2,
              'KSJC': 1,
              'JSJC': 2,
              'KCMC': '数据结构',
              'KBXX': '数据结构\n周老师\n[A301] [1-16周]',
            },
          ],
        },
      ],
    }, 1);

    expect(parsed.courses, hasLength(1));
    expect(parsed.courses.single.teacher, '周老师');
  });

  test('parses teacher metadata from selected subjects', () {
    final teachers = parseShenzhenTeacherMap(<String, dynamic>{
      'content': <dynamic>[
        <String, dynamic>{
          'kcdm': 'COMP1001-01',
          'kcmc': '程序设计基础',
          'JSXM': '李四',
        },
        <String, dynamic>{'kcdm': 'MATH2001', 'kcmc': '高等 数学', 'dgjsmc': '王五'},
      ],
    });

    expect(teachers['COMP1001'], '李四');
    expect(teachers['程序设计基础'], '李四');
    expect(teachers['MATH2001'], '王五');
    expect(teachers['高等数学'], '王五');
  });

  test('handles an empty week payload', () {
    final parsed = parseShenzhenWeek(<String, dynamic>{
      'code': 200,
      'content': <dynamic>[],
    }, 1);
    expect(parsed.courses, isEmpty);
    expect(parsed.dates, isEmpty);
  });
}
