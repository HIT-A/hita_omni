import 'package:academic_api/academic_api.dart';
import 'package:flutter/material.dart';
import 'package:hita_omni/app/app.dart';
import 'package:hita_omni/core/navigation/navigation_controller.dart';
import 'package:hita_omni/core/plugin/plugin_registry.dart';
import 'package:hita_omni/core/storage/storage.dart';
import 'package:hita_omni/core/theme/theme_controller.dart';
import 'package:hita_omni/features/account/application/account_controller.dart';
import 'package:hita_omni/features/account/data/auth_repository.dart';
import 'package:hita_omni/features/account/data/session_store.dart';
import 'package:hita_omni/features/dashboard/application/dashboard_controller.dart';
import 'package:hita_omni/features/timetable/application/timetable_controller.dart';
import 'package:hita_omni/features/timetable/data/timetable_cache.dart';
import 'package:hita_omni/features/timetable/data/timetable_repository.dart';
import 'package:hita_omni/plugins/builtin_plugins.dart';
import 'package:provider/provider.dart';
import 'package:provider_hit/provider_hit.dart';

class NoopHttpTransport implements HttpTransport {
  @override
  Future<HttpResponseData> send(HttpRequestSpec request) {
    throw HttpTransportException('Unexpected network request in test');
  }
}

Widget buildTestApp({KeyValueStore? store}) {
  final appStore = store ?? MemoryKeyValueStore();
  final registry = createPluginRegistry();
  final providers = AcademicProviderCatalog(
    createHitProviders(transport: NoopHttpTransport()),
  );
  final account = AccountController(
    sessionStore: SessionStore(appStore),
    authRepository: AuthRepository(catalog: providers),
  );
  final timetable = TimetableController(
    account: account,
    repository: TimetableRepository(
      catalog: providers,
      cache: TimetableCache(appStore),
    ),
  );
  final dashboard = DashboardController(registry: registry, store: appStore);
  final theme = ThemeController(appStore);
  final navigation = NavigationController();

  return MultiProvider(
    providers: [
      Provider<KeyValueStore>.value(value: appStore),
      Provider<PluginRegistry>.value(value: registry),
      Provider<AcademicProviderCatalog>.value(value: providers),
      ChangeNotifierProvider<AccountController>.value(value: account),
      ChangeNotifierProvider<TimetableController>.value(value: timetable),
      ChangeNotifierProvider<DashboardController>.value(value: dashboard),
      ChangeNotifierProvider<ThemeController>.value(value: theme),
      ChangeNotifierProvider<NavigationController>.value(value: navigation),
    ],
    child: const HitaOmniApp(),
  );
}
