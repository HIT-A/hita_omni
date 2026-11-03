# Repository Guidelines

## Project Overview

HITA Omni is a cross-platform Flutter campus assistant for Harbin Institute of Technology students. The initial core is deliberately small:

- **今日**: a configurable dashboard with add/remove/reorder panels.
- **时间表**: a local-first weekly timetable with course details.
- **我的**: account, Shenzhen EAS login, sync, theme.

Only the Shenzhen campus is implemented. HIT providers live in `packages/provider_hit`; Harbin/Weihai are registered placeholders with `isAvailable == false` that fail before any network request. Do not add fake sessions or fake timetable data for them.

## Architecture & Data Flow

Feature-first layout:

```text
app/                    composition root, provider catalog, shell, theme
  └── features/         account, dashboard, timetable
        └── core/       network, storage, plugin, i18n, theme, utils
  └── shared/           reusable presentation widgets
packages/academic_api/  provider contracts + canonical models + HTTP primitives
packages/provider_hit/  static HIT providers
plugins/                compile-time UI plugin registration
l10n/                   ARB source + generated AppLocalizations
```

- State management is plain `ChangeNotifier` + `provider` ([docs](https://pub.dev/packages/provider)). Do not introduce Riverpod, BLoC, or a service locator.
- Controllers are created in `lib/app/bootstrap.dart` and injected via `MultiProvider`; feature widgets never construct repositories.
- Feature folders use `application/`, `data/`, `domain/`, `presentation/`.
- Intended dependency direction: `app → features → core/shared`. `core` and `shared` must not import `features` or `app`. Avoid new feature-to-feature dependencies; existing exceptions include `app_info.dart` imports and dashboard imports of timetable presentation helpers.
- Auth flow: `LoginPage` → `AccountController` → `AuthRepository` → `AcademicProviderCatalog` → `AcademicProvider` (static HIT or future Wasm adapter) → `ApiClient`/`HttpTransport` → `SessionStore`.
- Timetable flow: `TimetableController` → `TimetableRepository` → `AcademicProvider`; successful sync overwrites the provider-scoped `TimetableCache`.
- Academic providers are compile-time packages. `AcademicProviderCatalog` routes by stable `providerId` (e.g. `hit.shenzhen`). The UI plugin system (`OmniPlugin`) is separate and only contributes dashboard panels/pages.
- Timetable data is independent of login state. It loads from cache without a session and survives sign-out/session expiry. Only a successful academic sync may replace it.
- Course views (next class, today schedule, timetable page) must not display login state or navigate to login. Login/sync controls belong to the account page. They must also treat the current local timetable as complete: an empty dataset renders an empty week/day, never a “no timetable data” state.
- On Linux X11, `bootstrap` configures `window_manager` to hide the native title bar; `AppShell` then adds a title-less drag/caption bar. Keep that bar free of title text and preserve the native title-bar fallback when plugin initialization fails. On Wayland, keep the native GTK/KDE title bar: nativeapi 0.5.x leaves a native CSD input region over the Flutter view, so custom caption buttons at the right edge receive no pointer events. Do not re-enable the custom Wayland caption bar without fixing that upstream behavior. Other platforms keep their native title bar. Native runners must not set a window title; the platform/desktop owns it.
- `TimetableController` uses `_generation`, `_sessionId`, and `_busy` to prevent stale sync results from mutating state. Preserve this guard in any new async sync path.
- UI plugins are compile-time only. `OmniPlugin` contributes `DashboardPanelDefinition` and `AppPageDefinition`; `PluginRegistry` rejects duplicate IDs. Register new UI plugins in `lib/plugins/builtin_plugins.dart`.
- Academic providers are not `OmniPlugin`s. Register them in `lib/app/provider_catalog.dart`; `AcademicProviderCatalog` rejects duplicate provider IDs.

## Key Directories

| Path | Purpose |
| --- | --- |
| `lib/app/` | Composition root, app root, shell, brand constants, web font loading |
| `lib/core/` | Cross-cutting contracts and platform adapters |
| `lib/core/network/` | Platform transport adapters; API client/types come from `academic_api` |
| `lib/core/storage/` | `KeyValueStore`: native JSON file, Web `localStorage`, memory fallback |
| `lib/core/plugin/` | Plugin, panel, page contracts and registry |
| `lib/core/i18n/` | `context.l10n` and generated-localization helpers |
| `lib/core/theme/`, `lib/core/navigation/` | Theme tokens/state and shell navigation state |
| `lib/features/account/` | Session, auth repository, login page, account page |
| `lib/features/dashboard/` | Dashboard controller, editor/grid, built-in panels and plugin |
| `lib/features/timetable/` | Canonical model re-exports, provider-scoped cache, controllers, week grid |
| `packages/academic_api/` | Public provider SDK: contracts, models, auth, HTTP primitives |
| `packages/provider_hit/` | Static Shenzhen/Harbin/Weihai providers and HIT parsers |
| `lib/l10n/` | `app_zh.arb` and generated `app_localizations*.dart` |
| `lib/plugins/` | Built-in plugin registration |
| `lib/shared/` | `SurfaceCard`, `EmptyState`, `StatusChip`, `InfoRow`, `AppLogo` |
| `test/` | Hermetic unit + widget tests; shared harness in `test/support/` |
| `tool/` | Web run/build scripts |
| `docs/reference/` | API contract, localization workflow, Wasm plugin design |

## Development Commands

Run from the repository root.

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

Localization code generation is required after ARB changes:

```bash
flutter gen-l10n
```

Web commands must use local CanvasKit/fonts:

```bash
./tool/web_run.sh
./tool/web_build.sh
# equivalent:
flutter run -d chrome --no-web-resources-cdn
flutter build web --no-web-resources-cdn
```

- `tool/web_build.sh` supports extra args, e.g. `--base-href /subpath/`.
- Deploy `build/web/` with `canvaskit/` and `assets/assets/fonts/` intact. See [Flutter web deployment](https://docs.flutter.dev/platform-integration/web/building).
- `PROJECT_MEMORY.md` is gitignored and local-only. Update it only when the user requests a commit or explicit memory maintenance.
- On commit requests, also add a developer log under `docs/logs/` using `.md` (the root `.gitignore` ignores `*.log`).
- When changing external endpoints, auth, timetable mappings, or plugin contracts, update `docs/reference/api-list.md`.
- **Do not run compile, test, simulator, install, or application-start commands without explicit user permission.** Read-only inspection is allowed. `flutter gen-l10n` is code generation; ask if the current task does not already authorize it.

## Code Conventions & Common Patterns

- Format with `dart format`; analyzer uses `flutter_lints` and `prefer_single_quotes`.
- Reactive read in build: `context.watch<T>()`; action/callback read: `context.read<T>()`. Use local `setState` only for transient UI state.
- Controllers expose immutable-ish state and `notifyListeners()`; do not expose repositories to widgets.
- Keep async boundaries explicit. Use `unawaited(...)` only for fire-and-forget work whose errors are handled internally.
- Errors: use `ApiException`, `AuthExpiredException`, `AuthException`, `HttpTransportException`. Controllers currently expose Chinese `String? error`; UI displays it. Never log or persist passwords, tokens, or cookies.
- Preserve the manual RSA PKCS#1 v1.5 implementation and X.509 parsing in `shenzhen_auth_api.dart` / `rsa_public_key.dart`. Tests pin the swapped `CLIENT_RSA_*` fields.
- Preserve `ApiClient._resolve`, which keeps the `/incoSpringBoot` base path. Do not replace it with `Uri.resolve('/path')`.
- Localization uses official `gen_l10n` + ARB:
  - UI layers must use `context.l10n` from `lib/core/i18n/i18n_context.dart`.
  - Never add `l10n.t(...)` or hardcoded Chinese to `lib/app`, `lib/shared`, or feature `presentation/`; a test enforces this.
  - Add keys to `lib/l10n/app_zh.arb` with `@key` metadata for placeholders, then run `flutter gen-l10n`.
  - Never hand-edit `app_localizations*.dart`.
  - Complex date/time text uses generated `DateTime` placeholders (`MMMd`, `yMMMMd`, `MMMEd`, `Hm`).
  - Reference: [Flutter internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization).
- Brand constants: `appName` and `appVersion`/`appVersionLabel` are in `lib/app/app_info.dart`. Keep `appVersion` in sync with `pubspec.yaml`. The app name is not localized. Desktop window titles are intentionally not set by the application.
- Plugin panels use localized metadata functions:
  ```dart
  DashboardPanelDefinition(
    id: 'example.panel',
    title: (l10n) => l10n.examplePanelTitle,
    description: (l10n) => l10n.examplePanelDescription,
    icon: Icons.extension_outlined,
    builder: (_) => const ExamplePanel(),
  )
  ```
  Add the corresponding ARB keys and regenerate. `AppPageDefinition.label` is currently a plain string and not localizable.
- Theme: use `context.surfaces`, `context.colors`, `context.isDark`, `AppRadii`, `withValues(alpha: ...)`; prefer shared `SurfaceCard`/`StatusChip`/`EmptyState` over ad-hoc styling.
- Academic providers: one provider per system/campus with a stable `providerId`. Keep duplicate-registration validation. HIT-specific `Campus`, student types, schedules, auth, and parsing stay inside `provider_hit`; do not add campus switches to core or UI. External providers implement `AcademicProvider` from `academic_api`.
- Timetable cache is provider-scoped and unencrypted; it is intentionally independent of the session. Do not clear it on logout. It stores multiple locally managed timetables per provider with an active timetable ID. Migration from `timetable.cache.v1` maps to `hit.shenzhen`; v2 single-snapshot data migrates to one v3 entry. New writes use `timetable.cache.v3`.
- Timetable management supports selecting the active local timetable, renaming it, and deleting it without requiring a session. A successful sync updates the entry for the same term and preserves its custom name; a new term creates a new entry. Selecting a term in the timetable page only switches existing local tables; creating a table is explicit through the manager add menu (EAS import implemented; ICS import and blank timetable are placeholders).
- Term visibility is shared: use `TermFilter.forTimetableAndAssessment` for the timetable and future score/exam modules. It keeps all terms from the enrollment year onward (future terms included), falls back to the recent four years without enrollment info, then falls back to the raw list; sort newest first. Do not add a current-term upper bound.
- Keep sessions/timetable plaintext risk in mind: passwords are not stored; token/Cookies and timetable data live in app-private JSON or `localStorage`.

## Important Files

| File | Why it matters |
| --- | --- |
| `lib/main.dart` | Calls `bootstrap()` |
| `lib/app/bootstrap.dart` | Single composition root; platform storage/HTTP and all controllers |
| `lib/app/app.dart` | `MaterialApp`, generated localizations, theme, web fonts |
| `lib/app/app_shell.dart` | Mobile bottom nav / desktop rail; plugin pages appended |
| `lib/app/app_info.dart` | Fixed brand and app version |
| `lib/app/web_fonts.dart` | Web-only `FontLoader` setup before `runApp` |
| `lib/l10n/app_zh.arb`, `l10n.yaml` | Localization source/config |
| `lib/core/i18n/i18n_context.dart` | `context.l10n` and date/theme helpers |
| `lib/core/plugin/omni_plugin.dart`, `dashboard_panel.dart`, `plugin_registry.dart` | Plugin contracts |
| `lib/plugins/builtin_plugins.dart` | Built-in plugin registration |
| `lib/features/account/application/account_controller.dart` | Session lifecycle |
| `packages/provider_hit/lib/src/shenzhen_auth_api.dart` | Shenzhen login/RSA flow |
| `packages/provider_hit/lib/src/rsa_public_key.dart` | DER parsing and PKCS#1 encryption |
| `lib/features/timetable/application/timetable_controller.dart` | Sync, cache, multi-timetable selection/rename/delete |
| `lib/features/timetable/data/timetable_cache.dart` | Provider-scoped `timetable.cache.v3` JSON and v2/v1 migration |
| `lib/features/timetable/domain/timetable_entry.dart` | Local timetable identity/name plus snapshot |
| `lib/features/timetable/presentation/widgets/timetable_manager_sheet.dart` | Timetable management sheet |
| `lib/features/timetable/presentation/widgets/timetable_add_sheet.dart` | Add menu and EAS term import flow |
| `packages/provider_hit/lib/src/shenzhen_timetable_api.dart` | 25-week fetch, parser, merge rules |
| `packages/academic_api/lib/src/models/timetable_snapshot.dart` | Week/date/occurrence calculations |
| `lib/features/dashboard/presentation/dashboard_page.dart` | Dashboard editor and panel layout |
| `test/support/test_app.dart` | Provider graph for widget tests; no network |
| `web/flutter_bootstrap.js` | Local CanvasKit and font fallback URLs |
| `tool/web_build.sh`, `tool/web_run.sh` | Enforce local web resources |
| `docs/reference/api-list.md` | External API/auth/cache contract |
| `docs/reference/localization.md` | ARB workflow |

## Runtime/Tooling Preferences

- Flutter `3.47.9` stable / Dart `3.13.7`; `sdk: ^3.13.5`. Use standard Flutter CLI, not Gradle directly.
- Package manager: Flutter/pub (`pubspec.yaml`/`pubspec.lock`). No Node/Bun runtime is required.
- Dependencies: `provider`, `http`, `intl`, `path_provider`, `web`, `window_manager`, `flutter_localizations`. No `build_runner`, Freezed, database, or runtime language-pack loader.
- Only Flutter `gen_l10n` is generated. Generated localization files are committed and must not be edited by hand.
- Web is self-hosted to avoid blocked gstatic assets. Do not remove:
  - `web/flutter_bootstrap.js` template tokens;
  - `canvasKitBaseUrl: 'canvaskit/'`;
  - `fontFallbackBaseUrl: 'assets/assets/fonts/'`;
  - bundled web-only fonts.
- Web login is intentionally disabled (`kIsWeb`). Enabling it requires a proxy or native/WebView auth path plus CORS changes; do not simply remove the guard.
- Android has `INTERNET`; macOS has `com.apple.security.network.client`. The package/bundle/application ID is `me.ilovo.hita`; release signing, app icons, and store metadata are still template-level.
- No CI, FVM pin, Makefile, or melos config exists.


## AI Agent Tooling

- Official Flutter/Dart agent skills are installed in `.agents/skills/` and pinned by `skills-lock.json`. Read the relevant `SKILL.md` on demand before implementing a matching workflow.
- Dart MCP server is configured for project use:
  - OMP: `.omp/mcp.json`
  - Universal/agent-plugin clients: `.agents/mcp_config.json`
  - Codex: `.codex/config.toml`
  - Command: `dart mcp-server`
- Prefer the Dart MCP tools for analyzer diagnostics, symbol lookup, tests, running apps, and runtime inspection when the server is connected.
- Official proactive hot-reload rule: after editing `.dart` files under `lib/`, use `hot_reload` for widget/simple method changes and `hot_restart` for `main`, `initState`, global/static state, or fundamental logic changes. Skip comment/docstring-only edits and files outside `lib/`.
- Only use hot reload/restart when a Flutter app is already running and the user permits interacting with it. Do not start an app, build, or test without explicit permission.

## Testing & QA

- Framework: `flutter_test` only ([docs](https://docs.flutter.dev/testing/overview)). 42 tests across 11 files plus `test/support/test_app.dart`.
- Run from repository root so filesystem-scanning tests resolve `lib/...` paths:
  ```bash
  flutter test
  flutter test test/shenzhen_parser_test.dart
  flutter test test/localization_test.dart
  ```
- Test harness uses the real provider graph, `MemoryKeyValueStore`, and `NoopHttpTransport` that throws on any network request. Keep tests hermetic.
- Covered areas: timetable snapshot math/merging, term visibility filtering, Shenzhen week parser, RSA/X.509 and login fallback, provider catalog/routing/cache isolation, session identity and v1 migration, multi-timetable selection/rename/delete, timetable cache v2-to-v3 migration, dashboard layout, localization guards, and widget smoke/mobile/cached-without-login behavior.
- `test/localization_test.dart` enforces:
  - no hardcoded Chinese/legacy runtime-i18n hooks in UI layers;
  - course views do not reference login state/navigation;
  - generated localizations resolve.
- Important gaps: live Shenzhen auth, platform/web rendering, storage I/O failures, most controller success paths, and non-Chinese locales.
- After ARB edits: run `flutter gen-l10n`, then `flutter analyze` and `flutter test`. Adding a locale also requires updating locale assertions in `test/localization_test.dart`.
- After auth/parser/cache changes, update `docs/reference/api-list.md` and the parser/snapshot/provider/auth/term-filter tests listed there.
- Wasm runtime plugins are designed but not implemented. See `docs/reference/wasm-plugin-system.md`; do not describe them as available functionality. The App Store iOS build must remain loader-free; only the experimental sideload build may enable the Wasm interpreter.
- Trust code and tests when README/detail docs conflict. Known README drift: its UI plugin example uses stale String metadata and it still mentions pull-to-refresh and Web cookie-managed sessions that do not match current behavior.
