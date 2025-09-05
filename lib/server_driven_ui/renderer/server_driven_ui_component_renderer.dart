// Renders components to widgets.
// Added:
// - HorizontalListComponent with 150x150 square cards (scrollable).
// - CardComponent is clickable (primaryAction) in addition to button row.
// - Analyzer-safe fallback return at the end of build().

import 'package:flutter/material.dart';
import '../actions/server_driven_ui_actions.dart';
import '../actions/server_driven_ui_action_handler.dart';
import '../models/server_driven_ui_component.dart';

class ServerDrivenUIComponentRenderer extends StatelessWidget {
  const ServerDrivenUIComponentRenderer({super.key, required this.component});

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
          clipBehavior: Clip.antiAlias, // ripple clipping
          child: InkWell(
            onTap: c.primaryAction == null
                ? null
                : () => ServerDrivenUIActionHandler.handle(
                    context,
                    c.primaryAction!,
                  ),
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
                              onPressed: () =>
                                  ServerDrivenUIActionHandler.handle(
                                    context,
                                    la.action,
                                  ),
                              child: Text(
                                la.label ?? _labelForAction(la.action),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );

      case HorizontalListComponent c:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((c.title ?? '').trim().isNotEmpty) ...[
              Text(c.title!, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
            ],
            SizedBox(
              height: 150, // item height (square 150x150)
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: c.items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _squareCard(context, c.items[i]),
              ),
            ),
          ],
        );

      case UnknownComponent _:
        return const SizedBox.shrink();
    }

    // Safety fallback (should never hit if all cases are covered).
    return const SizedBox.shrink();
  }

  /// Local asset images via "asset://", otherwise network.
  Widget _buildImage(ImageComponent c) {
    if (c.url.startsWith('asset://')) {
      final assetPath = 'assets/${c.url.substring('asset://'.length)}';
      return Image.asset(assetPath, fit: c.fit);
    }
    return Image.network(c.url, fit: c.fit);
  }

  /// Square 150x150 product-like card (for horizontal list).
  Widget _squareCard(BuildContext context, SquareCardItem item) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => ServerDrivenUIActionHandler.handle(context, item.action),
          child: Container(
            color: item.bgColor ?? Theme.of(context).colorScheme.surfaceVariant,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if ((item.image ?? '').isNotEmpty) _squareBgImage(item.image!),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _squareTexts(context, item),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _squareBgImage(String url) {
    if (url.startsWith('asset://')) {
      final assetPath = 'assets/${url.substring('asset://'.length)}';
      return Image.asset(assetPath, fit: BoxFit.cover);
    }
    return Image.network(url, fit: BoxFit.cover);
  }

  Widget _squareTexts(BuildContext context, SquareCardItem item) {
    final title = Text(
      item.title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final subtitleText = (item.subtitle ?? '').trim();
    final subtitle = subtitleText.isEmpty
        ? const SizedBox.shrink()
        : Text(
            subtitleText,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.black54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [title, subtitle],
    );
  }

  /// Derives human-friendly labels for actions when JSON doesn't provide "label".
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
