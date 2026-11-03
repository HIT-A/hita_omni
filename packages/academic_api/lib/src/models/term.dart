class Term {
  const Term({
    required this.yearCode,
    required this.termCode,
    required this.name,
    this.isCurrent = false,
  });

  final String yearCode;
  final String termCode;
  final String name;
  final bool isCurrent;

  String get id => '$yearCode-$termCode';

  String get shortName => name.isEmpty ? '$yearCode 学期 $termCode' : name;

  factory Term.fromJson(Map<String, dynamic> json) {
    final yearCode = json['yearCode'] as String? ?? '';
    final termCode = json['termCode'] as String? ?? '';
    return Term(
      yearCode: yearCode,
      termCode: termCode,
      name: json['name'] as String? ?? '',
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'yearCode': yearCode,
    'termCode': termCode,
    'name': name,
    'isCurrent': isCurrent,
  };

  static String semesterName(String termCode) {
    return switch (termCode) {
      '1' => '秋季学期',
      '2' => '春季学期',
      '3' => '夏季学期',
      _ => '第 $termCode 学期',
    };
  }
}
