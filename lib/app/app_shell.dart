import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/i18n/i18n_context.dart';
import '../core/navigation/navigation_controller.dart';
import '../core/plugin/app_page.dart';
import '../core/plugin/plugin_registry.dart';
import '../core/theme/app_theme.dart';
import '../features/account/presentation/account_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/timetable/presentation/timetable_page.dart';
import 'desktop_window.dart';

const _railWidth = 76.0;
const _railExtendedWidth = 224.0;

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool? _sidebarExpanded;

  @override
  Widget build(BuildContext context) {
    final pluginPages = context.read<PluginRegistry>().pages;
    final l10n = context.l10n;
    final pages = <AppPageDefinition>[
      AppPageDefinition(
        id: CorePageIds.today,
        label: l10n.navToday,
        icon: Icons.today_outlined,
        selectedIcon: Icons.today_rounded,
        order: 0,
        builder: (_) => const DashboardPage(),
      ),
      AppPageDefinition(
        id: CorePageIds.timetable,
        label: l10n.navTimetable,
        icon: Icons.calendar_view_week_outlined,
        selectedIcon: Icons.calendar_view_week_rounded,
        order: 1,
        builder: (_) => const TimetablePage(),
      ),
      AppPageDefinition(
        id: CorePageIds.account,
        label: l10n.navAccount,
        icon: Icons.person_outline_rounded,
        selectedIcon: Icons.person_rounded,
        order: 2,
        builder: (_) => const AccountPage(),
      ),
      ...pluginPages,
    ];

    return Consumer<NavigationController>(
      builder: (context, navigation, _) {
        final selectedIndex = _selectedIndex(pages, navigation.pageId);
        final width = MediaQuery.sizeOf(context).width;
        final wide = width >= 760;
        final expanded = _sidebarExpanded ?? width >= 1120;
        final body = IndexedStack(
          index: selectedIndex,
          children: <Widget>[
            for (final page in pages)
              KeyedSubtree(
                key: ValueKey(page.id),
                child: page.builder(context),
              ),
          ],
        );

        final shell = Scaffold(
          body: wide
              ? Row(
                  children: <Widget>[
                    SafeArea(
                      right: false,
                      bottom: false,
                      child: _SideNavigation(
                        pages: pages,
                        selectedIndex: selectedIndex,
                        extended: expanded,
                        onToggle: () {
                          setState(() => _sidebarExpanded = !expanded);
                        },
                        onSelected: (index) {
                          navigation.go(pages[index].id);
                        },
                      ),
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: context.surfaces.outline,
                    ),
                    Expanded(child: body),
                  ],
                )
              : body,
          bottomNavigationBar: wide
              ? null
              : DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: context.surfaces.outline),
                    ),
                  ),
                  child: NavigationBar(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (index) {
                      navigation.go(pages[index].id);
                    },
                    destinations: <NavigationDestination>[
                      for (final page in pages)
                        NavigationDestination(
                          icon: Icon(page.icon),
                          selectedIcon: Icon(page.selectedIcon ?? page.icon),
                          label: page.label,
                        ),
                    ],
                  ),
                ),
        );
        if (!desktopTitleBarEnabled) {
          return shell;
        }
        return buildDesktopShell(
          Column(
            children: <Widget>[
              buildDesktopTitleBar(),
              Expanded(child: shell),
            ],
          ),
        );
      },
    );
  }

  static int _selectedIndex(List<AppPageDefinition> pages, String pageId) {
    final index = pages.indexWhere((page) => page.id == pageId);
    return index < 0 ? 0 : index;
  }
}

class _SideNavigation extends StatelessWidget {
  const _SideNavigation({
    required this.pages,
    required this.selectedIndex,
    required this.extended,
    required this.onToggle,
    required this.onSelected,
  });

  final List<AppPageDefinition> pages;
  final int selectedIndex;
  final bool extended;
  final VoidCallback onToggle;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: extended,
      minWidth: _railWidth,
      minExtendedWidth: _railExtendedWidth,
      selectedIndex: selectedIndex,
      labelType: NavigationRailLabelType.none,
      onDestinationSelected: onSelected,
      leading: _SidebarToggle(extended: extended, onToggle: onToggle),
      destinations: <NavigationRailDestination>[
        for (final page in pages)
          NavigationRailDestination(
            icon: _destinationIcon(page.icon, page.label),
            selectedIcon: _destinationIcon(
              page.selectedIcon ?? page.icon,
              page.label,
            ),
            label: Text(page.label),
          ),
      ],
    );
  }

  Widget _destinationIcon(IconData icon, String label) {
    final child = Icon(icon);
    return extended ? child : Tooltip(message: label, child: child);
  }
}

class _SidebarToggle extends StatelessWidget {
  const _SidebarToggle({required this.extended, required this.onToggle});

  final bool extended;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final animation = NavigationRail.extendedAnimation(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final width =
            _railWidth + (_railExtendedWidth - _railWidth) * animation.value;
        return SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                tooltip: extended ? l10n.sidebarCollapse : l10n.sidebarExpand,
                onPressed: onToggle,
                icon: Icon(
                  extended ? Icons.menu_open_rounded : Icons.menu_rounded,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        );
      },
    );
  }
}
