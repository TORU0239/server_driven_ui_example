// Component union (sealed-like) with a factory parser by "type".
// Each concrete component only holds data; rendering is handled separately.

import 'package:flutter/material.dart';
import '../actions/server_driven_ui_actions.dart';
import '../util/boxfit_parser.dart';

/// Base class for all server-driven components.
/// Concrete subtypes represent specific UI elements like text, image, button, etc.
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
        final acts = (json['actions'] as List<dynamic>? ?? [])
            .map((e) => ServerDrivenUIAction.tryParse(e))
            .whereType<ServerDrivenUIAction>()
            .toList();
        return CardComponent(
          title: json['title'] as String? ?? '',
          body: json['body'] as String? ?? '',
          actions: acts,
        );
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

/// Card layout with title, body, and optional action buttons.
class CardComponent extends ServerDrivenUIComponent {
  final String title;
  final String body;
  final List<ServerDrivenUIAction> actions;
  const CardComponent({
    required this.title,
    required this.body,
    required this.actions,
  });
}

/// Unknown component used as a safety net for forward-compatible JSON.
class UnknownComponent extends ServerDrivenUIComponent {
  final Map<String, dynamic> raw;
  const UnknownComponent({required this.raw});
}
