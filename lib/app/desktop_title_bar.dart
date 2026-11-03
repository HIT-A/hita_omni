import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../core/i18n/i18n_context.dart';
import '../core/theme/app_theme.dart';

const _titleBarHeight = 36.0;

class DesktopTitleBar extends StatefulWidget {
  const DesktopTitleBar({super.key});

  @override
  State<DesktopTitleBar> createState() => _DesktopTitleBarState();
}

class _DesktopTitleBarState extends State<DesktopTitleBar> {
  Window? _window;
  ListenerId? _listenerId;
  bool _maximized = false;

  @override
  void initState() {
    super.initState();
    final window = WindowManager.instance.getCurrent();
    _window = window;
    if (window != null) {
      _maximized = window.isMaximized;
      _listenerId = window.addListener(_onWindowEvent);
    }
  }

  void _onWindowEvent(WindowEvent event) {
    if (event is WindowMaximizedEvent || event is WindowRestoredEvent) {
      final window = _window;
      if (window != null && mounted) {
        setState(() => _maximized = window.isMaximized);
      }
    }
  }

  @override
  void dispose() {
    final window = _window;
    final listenerId = _listenerId;
    if (window != null) {
      if (listenerId != null) {
        window.removeListener(listenerId);
      }
      window.dispose();
    }
    super.dispose();
  }

  void _toggleMaximize() {
    final window = _window;
    if (window == null) return;
    final maximized = window.isMaximized;
    if (maximized) {
      window.unmaximize();
    } else {
      window.maximize();
    }
    if (mounted) {
      setState(() => _maximized = !maximized);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: context.surfaces.page,
      child: SizedBox(
        height: _titleBarHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.surfaces.outline)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.move,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (_) => _window?.startDragging(),
                    onDoubleTap: _toggleMaximize,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              _WindowButton(
                tooltip: l10n.windowMinimize,
                icon: Icons.remove_rounded,
                onPressed: () => _window?.minimize(),
              ),
              _WindowButton(
                tooltip: _maximized ? l10n.windowRestore : l10n.windowMaximize,
                icon: _maximized
                    ? Icons.filter_none_rounded
                    : Icons.crop_square_rounded,
                onPressed: _toggleMaximize,
              ),
              _WindowButton(
                tooltip: l10n.commonClose,
                icon: Icons.close_rounded,
                onPressed: () => _window?.close(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WindowButton extends StatelessWidget {
  const _WindowButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(
        width: 44,
        height: _titleBarHeight,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}
