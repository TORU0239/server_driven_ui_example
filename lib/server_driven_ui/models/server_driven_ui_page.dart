// Page model that aggregates components parsed from JSON.

import 'server_driven_ui_component.dart';

/// Represents a server-driven page loaded from JSON.
/// Holds a list of typed components to be rendered by the renderer.
class ServerDrivenUIPage {
  /// Optional schema version for compatibility checks.
  final int? version;

  /// Page title to be displayed in the AppBar.
  final String? title;

  /// Ordered list of components that form the page's body.
  final List<ServerDrivenUIComponent> components;

  ServerDrivenUIPage({this.version, this.title, required this.components});

  /// Creates a [ServerDrivenUIPage] from a decoded JSON map.
  factory ServerDrivenUIPage.fromJson(Map<String, dynamic> json) {
    final comps = (json['components'] as List<dynamic>? ?? [])
        .map((e) => ServerDrivenUIComponent.fromJson(e as Map<String, dynamic>))
        .toList();
    return ServerDrivenUIPage(
      version: json['version'] as int?,
      title: json['title'] as String?,
      components: comps,
    );
  }
}
