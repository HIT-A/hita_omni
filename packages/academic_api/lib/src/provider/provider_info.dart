import '../models/time_slot.dart';

enum ProviderAuthMode { password, webVpn }

enum ProviderPlatform { android, ios, web, windows, macos, linux }

class AcademicProviderInfo {
  const AcademicProviderInfo({
    required this.displayName,
    required this.school,
    required this.campusLabel,
    required this.authMode,
    required this.isAvailable,
    required this.note,
    this.platforms = const <ProviderPlatform>{
      ProviderPlatform.android,
      ProviderPlatform.ios,
      ProviderPlatform.web,
      ProviderPlatform.windows,
      ProviderPlatform.macos,
      ProviderPlatform.linux,
    },
    this.defaultSlots = const <TimeSlot>[],
  });

  final String displayName;
  final String school;
  final String campusLabel;
  final ProviderAuthMode authMode;
  final bool isAvailable;
  final String note;
  final Set<ProviderPlatform> platforms;
  final List<TimeSlot> defaultSlots;

  bool get supportsPasswordLogin =>
      isAvailable && authMode == ProviderAuthMode.password;
}

class AuthRequest {
  const AuthRequest({required this.fields});

  final Map<String, String> fields;
}

class AuthResult {
  const AuthResult({
    required this.credentials,
    this.cookies = const <String, String>{},
    this.profile = const <String, String>{},
  });

  final Map<String, String> credentials;
  final Map<String, String> cookies;
  final Map<String, String> profile;
}
