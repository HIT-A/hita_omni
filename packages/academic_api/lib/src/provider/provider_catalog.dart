import 'academic_provider.dart';

/// Compile-time list of known providers.
///
/// Flutter AOT has no automatic package discovery, so the app must register
/// providers explicitly. The catalog validates IDs and provides routing.
class AcademicProviderCatalog {
  AcademicProviderCatalog(Iterable<AcademicProvider> providers)
    : all = List<AcademicProvider>.unmodifiable(providers) {
    final indexed = <String, AcademicProvider>{};
    for (final provider in this.providers) {
      if (indexed.containsKey(provider.id)) {
        throw ArgumentError('Duplicate academic provider id: ${provider.id}');
      }
      indexed[provider.id] = provider;
    }
    _byId = Map<String, AcademicProvider>.unmodifiable(indexed);
  }

  final List<AcademicProvider> all;

  late final Map<String, AcademicProvider> _byId;

  List<AcademicProvider> get providers => all;

  List<String> get ids => _byId.keys.toList(growable: false);

  AcademicProvider? byId(String id) => _byId[id];

  AcademicProvider require(String id) {
    final provider = _byId[id];
    if (provider == null) {
      throw StateError('Unknown academic provider: $id');
    }
    return provider;
  }
}
