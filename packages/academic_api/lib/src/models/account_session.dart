class AccountSession {
  const AccountSession({
    required this.providerId,
    required this.username,
    required this.signedInAt,
    this.credentials = const <String, String>{},
    this.cookies = const <String, String>{},
    this.profile = const <String, String>{},
  });

  final String providerId;
  final String username;
  final Map<String, String> credentials;
  final Map<String, String> cookies;
  final Map<String, String> profile;
  final DateTime signedInAt;

  String get displayName {
    final value = profile['name']?.trim();
    return value == null || value.isEmpty ? username : value;
  }

  String get initial {
    final value = displayName.trim();
    return value.isEmpty ? 'H' : value.substring(0, 1);
  }

  String? get studentId => _profileValue('studentId');

  String? get school => _profileValue('school');

  String? get studentTypeLabel => _profileValue('studentTypeLabel');

  String get sessionId =>
      '$providerId:$username:${_stableTokenHash(<String>[...credentials.entries.map((entry) => '${entry.key}=${entry.value}'), ...cookies.entries.map((entry) => '${entry.key}=${entry.value}')].join('|'))}';

  AccountSession copyWith({
    String? providerId,
    String? username,
    Map<String, String>? credentials,
    Map<String, String>? cookies,
    Map<String, String>? profile,
    DateTime? signedInAt,
  }) {
    return AccountSession(
      providerId: providerId ?? this.providerId,
      username: username ?? this.username,
      credentials: credentials ?? this.credentials,
      cookies: cookies ?? this.cookies,
      profile: profile ?? this.profile,
      signedInAt: signedInAt ?? this.signedInAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'providerId': providerId,
    'username': username,
    'credentials': credentials,
    'cookies': cookies,
    'profile': profile,
    'signedInAt': signedInAt.toIso8601String(),
  };

  factory AccountSession.fromJson(Map<String, dynamic> json) {
    final providerId = json['providerId'] as String?;
    final legacyCampus = json['campus'] as String?;
    final resolvedProviderId = providerId?.trim().isNotEmpty == true
        ? providerId!
        : _legacyProviderId(legacyCampus);
    return AccountSession(
      providerId: resolvedProviderId,
      username: json['username'] as String? ?? '',
      credentials:
          _stringMap(json['credentials']) ??
          <String, String>{
            if ((json['accessToken'] as String?)?.trim().isNotEmpty == true)
              'accessToken': (json['accessToken'] as String).trim(),
            if ((json['refreshToken'] as String?)?.trim().isNotEmpty == true)
              'refreshToken': (json['refreshToken'] as String).trim(),
          },
      cookies: _stringMap(json['cookies']) ?? const <String, String>{},
      profile:
          _stringMap(json['profile']) ??
          <String, String>{
            if ((json['studentId'] as String?)?.trim().isNotEmpty == true)
              'studentId': (json['studentId'] as String).trim(),
            if ((json['name'] as String?)?.trim().isNotEmpty == true)
              'name': (json['name'] as String).trim(),
            if ((json['school'] as String?)?.trim().isNotEmpty == true)
              'school': (json['school'] as String).trim(),
            if ((json['studentType'] as String?)?.trim().isNotEmpty == true)
              'studentType': (json['studentType'] as String).trim(),
          },
      signedInAt:
          DateTime.tryParse(json['signedInAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  String? _profileValue(String key) {
    final value = profile[key]?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}

String _legacyProviderId(String? campus) {
  final value = campus?.trim();
  if (value == null || value.isEmpty) {
    return 'hit.shenzhen';
  }
  if (value.startsWith('hit.')) {
    return value;
  }
  return 'hit.$value';
}

Map<String, String>? _stringMap(Object? value) {
  if (value is! Map) {
    return null;
  }
  final result = <String, String>{};
  for (final entry in value.entries) {
    if (entry.key is String && entry.value is String) {
      result[entry.key as String] = entry.value as String;
    }
  }
  return result;
}

String _stableTokenHash(String token) {
  var hash = 0x811c9dc5;
  for (final codeUnit in token.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16);
}
