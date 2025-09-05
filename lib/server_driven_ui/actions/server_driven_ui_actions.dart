// Action model variants parsed from JSON.
// Only ToastAction changed to support an optional close button.

abstract class ServerDrivenUIAction {
  const ServerDrivenUIAction();

  static ServerDrivenUIAction? tryParse(dynamic value) {
    if (value is! Map<String, dynamic>) return null;
    final type = (value['type'] as String?)?.toLowerCase();

    switch (type) {
      case 'navigate':
        return NavigateAction(route: value['route'] as String? ?? '/');
      case 'open_url':
        return OpenUrlAction(url: value['url'] as String? ?? '');
      case 'toast':
        // NEW: closable + closeLabel support (various key aliases accepted)
        final closable =
            (value['closable'] == true) || (value['close'] == true);
        final closeLabel =
            (value['closeLabel'] as String?) ??
            (value['close_label'] as String?) ??
            (value['actionLabel'] as String?);
        return ToastAction(
          message: value['message'] as String? ?? '',
          closable: closable,
          closeLabel: closeLabel,
        );
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

class NavigateAction extends ServerDrivenUIAction {
  const NavigateAction({required this.route});
  final String route;
}

class OpenUrlAction extends ServerDrivenUIAction {
  const OpenUrlAction({required this.url});
  final String url;
}

// CHANGED: ToastAction now supports an optional close button.
class ToastAction extends ServerDrivenUIAction {
  const ToastAction({
    required this.message,
    this.closable = false,
    this.closeLabel,
  });

  /// Snackbar message text.
  final String message;

  /// Whether to show a close button as SnackBarAction.
  final bool closable;

  /// Optional label for the close action (defaults to "Close" if closable is true).
  final String? closeLabel;
}

class TrackAction extends ServerDrivenUIAction {
  const TrackAction({required this.event, this.props});
  final String event;
  final Map<String, dynamic>? props;
}
