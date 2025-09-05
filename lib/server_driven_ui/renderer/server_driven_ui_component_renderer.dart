// Maps a typed ServerDrivenUIComponent to actual Flutter widgets.
// Pure rendering only; side-effects are delegated to the action handler.
// Card action buttons can show a custom label from JSON ("label"), otherwise
// a derived label based on the action content is used.

import 'package:flutter/material.dart';
import '../actions/server_driven_ui_actions.dart';
import '../actions/server_driven_ui_action_handler.dart';
import '../models/server_driven_ui_component.dart';

/// Stateless renderer that turns components into widgets.
class ServerDrivenUIComponentRenderer extends StatelessWidget {
  const ServerDrivenUIComponentRenderer({super.key, required this.component});

  /// The component to render.
  final ServerDrivenUIComponent component;

  @override
  Widget build(BuildContext context) {
    switch (component) {
      case HeaderComponent c:
        return Text(
          c.text,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        );

      case TextComponent c:
        return Text(c.text, style: Theme.of(context).textTheme.bodyLarge);

      case ImageComponent c:
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(aspectRatio: 2, child: _buildImage(c)),
        );

      case ButtonComponent c:
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: c.action == null
                ? null
                : () => ServerDrivenUIActionHandler.handle(context, c.action!),
            child: Text(c.text),
          ),
        );

      case CardComponent c:
        return Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(c.body),
                if (c.actions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: c.actions
                        .map(
                          (la) => OutlinedButton(
                            onPressed: () => ServerDrivenUIActionHandler.handle(
                              context,
                              la.action,
                            ),
                            child: Text(la.label ?? _labelForAction(la.action)),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );

      case UnknownComponent _:
        return const SizedBox.shrink();
    }

    // Analyzer-satisfying fallback: should never be reached.
    return const SizedBox.shrink();
  }

  /// Supports local asset images via "asset://" scheme; falls back to network.
  Widget _buildImage(ImageComponent c) {
    if (c.url.startsWith('asset://')) {
      final assetPath = 'assets/${c.url.substring('asset://'.length)}';
      return Image.asset(assetPath, fit: c.fit);
    }
    return Image.network(c.url, fit: c.fit);
  }

  /// Computes a human-friendly label from the action content (no label stored in action).
  String _labelForAction(ServerDrivenUIAction a) {
    if (a is NavigateAction) {
      final r = a.route.trim();
      if (r == 'back') return 'Back';
      if (_looksLikeUrl(r)) return 'Open Link';
      if (r.startsWith('/')) {
        final name = r.substring(1).isEmpty ? 'Home' : r.substring(1);
        return 'Go to ${_titleCase(name)}';
      }
      return 'Navigate';
    }

    if (a is OpenUrlAction) {
      final host = Uri.tryParse(a.url)?.host;
      return (host == null || host.isEmpty) ? 'Open Link' : 'Open $host';
    }

    if (a is ToastAction) return 'Show Toast';
    if (a is TrackAction) return 'Track Event';

    return 'Action';
  }

  bool _looksLikeUrl(String s) =>
      s.startsWith('http://') || s.startsWith('https://');

  String _titleCase(String s) {
    if (s.isEmpty) return s;
    final parts = s
        .split(RegExp(r'[-_/ ]+'))
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.map((p) => p[0].toUpperCase() + p.substring(1)).join(' ');
  }
}
