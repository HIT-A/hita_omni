enum HitCampus {
  shenzhen,
  harbin,
  weihai;

  String get providerId => 'hit.$name';
}

enum HitStudentType {
  undergraduate,
  graduate;

  static HitStudentType fromApi(String? value) {
    if (value == null || value.isEmpty) {
      return HitStudentType.undergraduate;
    }
    return value == '1'
        ? HitStudentType.undergraduate
        : HitStudentType.graduate;
  }

  static HitStudentType fromName(String? name) {
    return HitStudentType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => HitStudentType.undergraduate,
    );
  }

  String get label => switch (this) {
    HitStudentType.undergraduate => '本科生',
    HitStudentType.graduate => '研究生',
  };
}
