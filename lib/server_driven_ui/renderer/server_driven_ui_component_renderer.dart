// Added support for:
// - GridComponent (2-column metric cards, 150~180 height depending on content)
// - VerticalListComponent (clickable list items with icon/tag)
// Existing behavior preserved: clickable CardComponent (primaryAction), horizontal list, etc.
// Includes analyzer-safe fallback return.

import 'package:flutter/material.dart';
import '../actions/server_driven_ui_actions.dart';
import '../actions/server_driven_ui_action_handler.dart';
import '../models/server_driven_ui_component.dart';
import '../util/icon_parser.dart';

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
          child: AspectRatio(aspectRatio: 2, child: _buildImage(c.url, c.fit)),
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
          clipBehavior: Clip.antiAlias,
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
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: c.items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _squareCard(context, c.items[i]),
              ),
            ),
          ],
        );

      // ✅ NEW: Grid
      case GridComponent c:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((c.title ?? '').trim().isNotEmpty) ...[
              Text(c.title!, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
            ],
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6, // tweak to taste
              ),
              itemCount: c.items.length,
              itemBuilder: (_, i) => _metricCard(context, c.items[i]),
            ),
          ],
        );

      // ✅ NEW: Vertical list
      case VerticalListComponent c:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((c.title ?? '').trim().isNotEmpty) ...[
              Text(c.title!, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
            ],
            ...List.generate(c.items.length, (i) {
              final w = _listItem(context, c.items[i]);
              if (i == c.items.length - 1) return w;
              return Column(children: [w, const SizedBox(height: 8)]);
            }),
          ],
        );

      case UnknownComponent _:
        return const SizedBox.shrink();
    }

    // Safety fallback (should never hit if all cases are covered).
    return const SizedBox.shrink();
  }

  // --- Helpers ---

  Widget _buildImage(String url, BoxFit fit) {
    if (url.startsWith('asset://')) {
      final assetPath = 'assets/${url.substring('asset://'.length)}';
      return Image.asset(assetPath, fit: fit);
    }
    return Image.network(url, fit: fit);
  }

  // Horizontal 150x150 square card
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
                if ((item.image ?? '').isNotEmpty)
                  (item.image!.startsWith('asset://')
                      ? Image.asset(
                          'assets/${item.image!.substring('asset://'.length)}',
                          fit: BoxFit.cover,
                        )
                      : Image.network(item.image!, fit: BoxFit.cover)),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if ((item.subtitle ?? '').trim().isNotEmpty)
                          Text(
                            item.subtitle!,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: Colors.black54),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Grid metric card (clickable)
  Widget _metricCard(BuildContext context, MetricCardItem item) {
    final bg = item.bgColor ?? Theme.of(context).colorScheme.surfaceVariant;
    final delta = (item.delta ?? '').trim();
    final Color deltaColor = delta.startsWith('-')
        ? Colors.red.shade700
        : delta.startsWith('+')
        ? Colors.green.shade700
        : Colors.black54;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ServerDrivenUIActionHandler.handle(context, item.action),
        child: Container(
          color: bg,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(iconFromName(item.iconName), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.labelLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item.value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (delta.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  delta,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: deltaColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Vertical list item (clickable)
  Widget _listItem(BuildContext context, ListItem item) {
    final leading = (item.leadingImage ?? '').isNotEmpty
        ? _leadingImage(item.leadingImage!)
        : CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.08),
            child: Icon(
              iconFromName(item.leadingIcon),
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
          );

    final tag = (item.trailingTag ?? '').trim();
    final trailing = tag.isEmpty
        ? null
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  item.tagColor ?? Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(tag, style: Theme.of(context).textTheme.labelSmall),
          );

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ServerDrivenUIActionHandler.handle(context, item.action),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if ((item.subtitle ?? '').trim().isNotEmpty)
                      Text(
                        item.subtitle!,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _leadingImage(String url) {
    if (url.startsWith('asset://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/${url.substring('asset://'.length)}',
          width: 32,
          height: 32,
          fit: BoxFit.cover,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(url, width: 32, height: 32, fit: BoxFit.cover),
    );
  }

  // Derive label for action when JSON doesn't include "label"
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
    } else if (a is OpenUrlAction) {
      final host = Uri.tryParse(a.url)?.host;
      return (host == null || host.isEmpty) ? 'Open Link' : 'Open $host';
    } else if (a is ToastAction) {
      return 'Show Toast';
    } else if (a is TrackAction) {
      return 'Track Event';
    }
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
