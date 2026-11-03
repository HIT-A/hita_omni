import 'package:academic_api/academic_api.dart';
import 'package:provider_hit/provider_hit.dart';

/// Compile-time provider registration.
///
/// External school packages are added here with one entry. The app has no
/// runtime plugin discovery and no dynamic code loading.
AcademicProviderCatalog buildProviderCatalog(HttpTransport transport) {
  return AcademicProviderCatalog(createHitProviders(transport: transport));
}
