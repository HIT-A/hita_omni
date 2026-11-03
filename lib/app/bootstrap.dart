import 'package:academic_api/academic_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/navigation/navigation_controller.dart';
import '../core/network/http_transport.dart';
import '../core/plugin/plugin_registry.dart';
import '../core/storage/storage.dart';
import '../core/theme/theme_controller.dart';
import '../features/account/application/account_controller.dart';
import '../features/account/data/auth_repository.dart';
import '../features/account/data/session_store.dart';
import '../features/dashboard/application/dashboard_controller.dart';
import '../features/timetable/application/timetable_controller.dart';
import '../features/timetable/data/timetable_cache.dart';
import '../features/timetable/data/timetable_repository.dart';
import '../plugins/builtin_plugins.dart';
import 'app.dart';
import 'desktop_window.dart';
import 'provider_catalog.dart';
import 'web_fonts.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDesktopWindow();
  await loadWebFonts();

  final store = await createKeyValueStore();
  final registry = createPluginRegistry();
  final transport = createHttpTransport();
  final providers = buildProviderCatalog(transport);

  final account = AccountController(
    sessionStore: SessionStore(store),
    authRepository: AuthRepository(catalog: providers),
  );
  final timetable = TimetableController(
    account: account,
    repository: TimetableRepository(
      catalog: providers,
      cache: TimetableCache(store),
    ),
  );
  final dashboard = DashboardController(registry: registry, store: store);
  final theme = ThemeController(store);
  final navigation = NavigationController();

  runApp(
    MultiProvider(
      providers: [
        Provider<KeyValueStore>.value(value: store),
        Provider<PluginRegistry>.value(value: registry),
        Provider<AcademicProviderCatalog>.value(value: providers),
        ChangeNotifierProvider<AccountController>.value(value: account),
        ChangeNotifierProvider<TimetableController>.value(value: timetable),
        ChangeNotifierProvider<DashboardController>.value(value: dashboard),
        ChangeNotifierProvider<ThemeController>.value(value: theme),
        ChangeNotifierProvider<NavigationController>.value(value: navigation),
      ],
      child: const HitaOmniApp(),
    ),
  );
}
