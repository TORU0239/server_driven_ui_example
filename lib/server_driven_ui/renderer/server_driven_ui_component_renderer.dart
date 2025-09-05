// Maps a typed ServerDrivenUIComponent to actual Flutter widgets.
// Pure rendering only; side-effects are delegated to the action handler.

import 'package:flutter/material.dart';
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
                    children: c.actions
                        .map(
                          (a) => OutlinedButton(
                            onPressed: () =>
                                ServerDrivenUIActionHandler.handle(context, a),
                            child: const Text('Action'),
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
    // Default return to satisfy non-nullable Widget return type
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
}
