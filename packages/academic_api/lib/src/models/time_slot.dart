import '../date_time.dart';

class TimeSlot {
  const TimeSlot({required this.startMinute, required this.endMinute});

  final int startMinute;
  final int endMinute;

  String get startLabel => formatClock(startMinute);
  String get endLabel => formatClock(endMinute);

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startMinute: (json['startMinute'] as num?)?.toInt() ?? 0,
      endMinute: (json['endMinute'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'startMinute': startMinute,
    'endMinute': endMinute,
  };
}
