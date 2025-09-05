// Action model variants parsed from JSON to drive side-effects like navigation,
// external URL opening, toasts, or analytics tracking.

/// Base type for all actions. Concrete variants are parsed from JSON.
abstract class ServerDrivenUIAction {
  const ServerDrivenUIAction();

  /// Parses a JSON object into a typed [ServerDrivenUIAction] or returns null if unknown.
  static ServerDrivenUIAction? tryParse(dynamic value) {
    if (value is! Map<String, dynamic>) return null;
    final type = (value['type'] as String?)?.toLowerCase();
    switch (type) {
      case 'navigate':
        return NavigateAction(route: value['route'] as String? ?? '/');
      case 'open_url':
        return OpenUrlAction(url: value['url'] as String? ?? '');
      case 'toast':
        return ToastAction(message: value['message'] as String? ?? '');
      case 'track':
        return TrackAction(
          event: value['event'] as String? ?? 'event',
          props: value['props'] as Map<String, dynamic>?,
        );
      default:
        return null;
    }
  }
}

/// Navigates to another in-app route or opens an external URL if the route is a full URL.
class NavigateAction extends ServerDrivenUIAction {
  final String route;
  const NavigateAction({required this.route});
}

/// Opens an external URL using the platform browser.
class OpenUrlAction extends ServerDrivenUIAction {
  final String url;
  const OpenUrlAction({required this.url});
}

/// Shows a short-lived toast (Snackbar).
class ToastAction extends ServerDrivenUIAction {
  final String message;
  const ToastAction({required this.message});
}

/// Emits an analytics tracking event with optional properties.
class TrackAction extends ServerDrivenUIAction {
  final String event;
  final Map<String, dynamic>? props;
  const TrackAction({required this.event, this.props});
}
