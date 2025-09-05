// Added: GridComponent/MetricCardItem, VerticalListComponent/ListItem
// Existing components unchanged. CardComponent keeps primaryAction + actions (with labels).

import 'package:flutter/material.dart';
import '../actions/server_driven_ui_actions.dart';
import '../util/boxfit_parser.dart';
import '../util/color_parser.dart';

abstract class ServerDrivenUIComponent {
  const ServerDrivenUIComponent();

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
          final primary = ServerDrivenUIAction.tryParse(json['action']);
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
              if (type == 'square_card') items.add(SquareCardItem.fromJson(it));
            }
          }
          return HorizontalListComponent(title: title, items: items);
        }

      // ✅ NEW: Grid + MetricCard items
      case 'grid':
        {
          final title = json['title'] as String?;
          final itemsRaw = (json['items'] as List<dynamic>? ?? []);
          final items = <MetricCardItem>[];
          for (final it in itemsRaw) {
            if (it is Map<String, dynamic>) {
              final type = (it['type'] as String?)?.toLowerCase();
              if (type == 'metric_card') items.add(MetricCardItem.fromJson(it));
            }
          }
          return GridComponent(title: title, items: items);
        }

      // ✅ NEW: Vertical list + ListItem items
      case 'vertical_list':
        {
          final title = json['title'] as String?;
          final itemsRaw = (json['items'] as List<dynamic>? ?? []);
          final items = <ListItem>[];
          for (final it in itemsRaw) {
            if (it is Map<String, dynamic>) {
              final type = (it['type'] as String?)?.toLowerCase();
              if (type == 'list_item') items.add(ListItem.fromJson(it));
            }
          }
          return VerticalListComponent(title: title, items: items);
        }

      default:
        return UnknownComponent(raw: json);
    }
  }
}

// --- Existing components (unchanged) ---

class HeaderComponent extends ServerDrivenUIComponent {
  final String text;
  const HeaderComponent({required this.text});
}

class TextComponent extends ServerDrivenUIComponent {
  final String text;
  const TextComponent({required this.text});
}

class ImageComponent extends ServerDrivenUIComponent {
  final String url;
  final BoxFit fit;
  const ImageComponent({required this.url, this.fit = BoxFit.cover});
}

class ButtonComponent extends ServerDrivenUIComponent {
  final String text;
  final ServerDrivenUIAction? action;
  const ButtonComponent({required this.text, this.action});
}

class LabeledAction {
  final ServerDrivenUIAction action;
  final String? label;
  const LabeledAction({required this.action, this.label});
}

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

class HorizontalListComponent extends ServerDrivenUIComponent {
  final String? title;
  final List<SquareCardItem> items;
  const HorizontalListComponent({this.title, required this.items});
}

class SquareCardItem {
  final String title;
  final String? subtitle;
  final String? image;
  final Color? bgColor;
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

// --- NEW: Grid ---

class GridComponent extends ServerDrivenUIComponent {
  final String? title;
  final List<MetricCardItem> items;
  const GridComponent({this.title, required this.items});
}

class MetricCardItem {
  final String title;
  final String value;
  final String? delta; // e.g., "+12%" / "-2%"
  final Color? bgColor;
  final String? iconName; // e.g., "person", "shopping_cart"
  final ServerDrivenUIAction action;

  const MetricCardItem({
    required this.title,
    required this.value,
    this.delta,
    this.bgColor,
    this.iconName,
    required this.action,
  });

  factory MetricCardItem.fromJson(Map<String, dynamic> json) {
    return MetricCardItem(
      title: json['title'] as String? ?? '',
      value: json['value'] as String? ?? '',
      delta: json['delta'] as String?,
      bgColor: parseHexColor(json['bgColor'] as String?),
      iconName: json['icon'] as String?,
      action:
          ServerDrivenUIAction.tryParse(json['action']) ??
          const ToastAction(message: 'Tapped'),
    );
  }
}

// --- NEW: Vertical List ---

class VerticalListComponent extends ServerDrivenUIComponent {
  final String? title;
  final List<ListItem> items;
  const VerticalListComponent({this.title, required this.items});
}

class ListItem {
  final String title;
  final String? subtitle;
  final String? leadingIcon; // material icon name
  final String? leadingImage; // asset:// or http(s)://
  final String? trailingTag; // small tag on the right
  final Color? tagColor; // background color for tag
  final ServerDrivenUIAction action;

  const ListItem({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leadingImage,
    this.trailingTag,
    this.tagColor,
    required this.action,
  });

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      leadingIcon: json['leadingIcon'] as String?,
      leadingImage: json['leadingImage'] as String?,
      trailingTag: json['trailingTag'] as String?,
      tagColor: parseHexColor(json['tagColor'] as String?),
      action:
          ServerDrivenUIAction.tryParse(json['action']) ??
          const ToastAction(message: 'Tapped'),
    );
  }
}

class UnknownComponent extends ServerDrivenUIComponent {
  final Map<String, dynamic> raw;
  const UnknownComponent({required this.raw});
}
