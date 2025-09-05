// Component union with factory parser by "type".
// Added: HorizontalListComponent + SquareCardItem
// CardComponent now supports an optional primaryAction for card-wide tap.

import 'package:flutter/material.dart';
import '../actions/server_driven_ui_actions.dart';
import '../util/boxfit_parser.dart';
import '../util/color_parser.dart';

/// Base class for all server-driven components.
abstract class ServerDrivenUIComponent {
  const ServerDrivenUIComponent();

  /// Parses a component from its JSON representation using the "type" discriminator.
  factory ServerDrivenUIComponent.fromJson(Map<String, dynamic> json) {
    switch ((json['type'] as String?)?.toLowerCase()) {
      case 'header':
        return HeaderComponent(text: json['text'] as String? ?? '');
      case 'text':
        return TextComponent(text: json['text'] as String? ?? '');
      case 'image':
        return ImageComponent(
          url: json['url'] as String? ?? '',
          fit: parseBoxFit(json['fit'] as String?),
        );
      case 'button':
        return ButtonComponent(
          text: json['text'] as String? ?? 'Button',
          action: ServerDrivenUIAction.tryParse(json['action']),
        );

      case 'card':
        {
          // Optional primary tap action for the card itself.
          final primary = ServerDrivenUIAction.tryParse(json['action']);
          // Button actions (with optional per-button label).
          final rawActs = (json['actions'] as List<dynamic>? ?? []);
          final acts = <LabeledAction>[];
          for (final raw in rawActs) {
            if (raw is Map<String, dynamic>) {
              final act = ServerDrivenUIAction.tryParse(raw);
              if (act != null) {
                final labelRaw = (raw['label'] as String?)?.trim();
                final label = (labelRaw == null || labelRaw.isEmpty)
                    ? null
                    : labelRaw;
                acts.add(LabeledAction(action: act, label: label));
              }
            }
          }
          return CardComponent(
            title: json['title'] as String? ?? '',
            body: json['body'] as String? ?? '',
            actions: acts,
            primaryAction: primary,
          );
        }

      case 'horizontal_list':
        {
          final title = json['title'] as String?;
          final itemsRaw = (json['items'] as List<dynamic>? ?? []);
          final items = <SquareCardItem>[];
          for (final it in itemsRaw) {
            if (it is Map<String, dynamic>) {
              final type = (it['type'] as String?)?.toLowerCase();
              if (type == 'square_card') {
                items.add(SquareCardItem.fromJson(it));
              }
            }
          }
          return HorizontalListComponent(title: title, items: items);
        }

      default:
        return UnknownComponent(raw: json);
    }
  }
}

/// Big bold header text.
class HeaderComponent extends ServerDrivenUIComponent {
  final String text;
  const HeaderComponent({required this.text});
}

/// Body text paragraph.
class TextComponent extends ServerDrivenUIComponent {
  final String text;
  const TextComponent({required this.text});
}

/// Image with configurable BoxFit. Supports "asset://" scheme in renderer.
class ImageComponent extends ServerDrivenUIComponent {
  final String url;
  final BoxFit fit;
  const ImageComponent({required this.url, this.fit = BoxFit.cover});
}

/// Button with an optional action attached.
class ButtonComponent extends ServerDrivenUIComponent {
  final String text;
  final ServerDrivenUIAction? action;
  const ButtonComponent({required this.text, this.action});
}

/// A pair of an action and an optional UI label (from JSON "label") for button rows.
class LabeledAction {
  final ServerDrivenUIAction action;
  final String? label;
  const LabeledAction({required this.action, this.label});
}

/// Card layout with title/body and optional buttons.
/// [primaryAction] is executed when the card itself is tapped.
class CardComponent extends ServerDrivenUIComponent {
  final String title;
  final String body;
  final List<LabeledAction> actions;
  final ServerDrivenUIAction? primaryAction;
  const CardComponent({
    required this.title,
    required this.body,
    required this.actions,
    this.primaryAction,
  });
}

/// Horizontal list of square product-like cards.
class HorizontalListComponent extends ServerDrivenUIComponent {
  final String? title;
  final List<SquareCardItem> items;
  const HorizontalListComponent({this.title, required this.items});
}

/// A 150x150 square card item used inside [HorizontalListComponent].
class SquareCardItem {
  final String title;
  final String? subtitle;
  final String? image; // asset://... or http(s)://...
  final Color? bgColor; // parsed from hex like "#F3F6FF"
  final ServerDrivenUIAction action;

  const SquareCardItem({
    required this.title,
    this.subtitle,
    this.image,
    this.bgColor,
    required this.action,
  });

  factory SquareCardItem.fromJson(Map<String, dynamic> json) {
    return SquareCardItem(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      image: json['image'] as String?,
      bgColor: parseHexColor(json['bgColor'] as String?),
      action:
          ServerDrivenUIAction.tryParse(json['action']) ??
          const ToastAction(message: 'Tapped'),
    );
  }
}

/// Unknown component used as a safety net for forward-compatible JSON.
class UnknownComponent extends ServerDrivenUIComponent {
  final Map<String, dynamic> raw;
  const UnknownComponent({required this.raw});
}
