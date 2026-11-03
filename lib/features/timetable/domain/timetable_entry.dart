import 'timetable_snapshot.dart';

/// A locally managed timetable. The snapshot is the immutable academic data;
/// [id] and [name] are the user-facing identity that survives refreshes.
class TimetableEntry {
  const TimetableEntry({
    required this.id,
    required this.name,
    required this.snapshot,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final TimetableSnapshot snapshot;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayName {
    final trimmed = name.trim();
    return trimmed.isEmpty ? snapshot.term.shortName : trimmed;
  }

  int get courseCount => snapshot.courses.length;

  TimetableEntry copyWith({
    String? id,
    String? name,
    TimetableSnapshot? snapshot,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimetableEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      snapshot: snapshot ?? this.snapshot,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TimetableEntry.fromSnapshot({
    required String id,
    required TimetableSnapshot snapshot,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final timestamp = snapshot.fetchedAt;
    return TimetableEntry(
      id: id,
      name: name ?? snapshot.term.shortName,
      snapshot: snapshot,
      createdAt: createdAt ?? timestamp,
      updatedAt: updatedAt ?? timestamp,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'snapshot': snapshot.toJson(),
  };

  static TimetableEntry? tryFromJson(
    Map<String, dynamic> json, {
    String providerId = '',
  }) {
    final rawSnapshot = json['snapshot'];
    if (rawSnapshot is! Map<String, dynamic>) {
      return null;
    }
    final snapshot = TimetableSnapshot.fromJson(rawSnapshot);
    final id = (json['id'] as String?)?.trim();
    final name = json['name'] as String? ?? '';
    final createdAt =
        DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        snapshot.fetchedAt;
    final updatedAt =
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
        snapshot.fetchedAt;
    return TimetableEntry(
      id: id == null || id.isEmpty
          ? timetableEntryId(providerId, snapshot.term.id)
          : id,
      name: name,
      snapshot: snapshot,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// One timetable per provider and term. The ID stays stable across syncs so a
/// renamed timetable keeps its identity when its snapshot is refreshed.
String timetableEntryId(String providerId, String termId) {
  return '$providerId::$termId';
}
