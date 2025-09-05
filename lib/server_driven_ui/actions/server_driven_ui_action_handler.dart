// Centralized action executor to keep widgets stateless and free of side-effects.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'server_driven_ui_actions.dart';

/// Executes [ServerDrivenUIAction]s. Widgets delegate to this to avoid side-effects in build().
class ServerDrivenUIActionHandler {
  const ServerDrivenUIActionHandler._();

  /// Handles all supported action types: navigate/openUrl/toast/track.
  static Future<void> handle(
    BuildContext context,
    ServerDrivenUIAction action,
  ) async {
    if (action is NavigateAction) {
      final route = action.route.trim();

      // Special "back" keyword to pop the current screen.
      if (route == 'back') {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        return;
      }

      // If the string looks like a full URL, open it externally.
      if (_looksLikeUrl(route)) {
        await launchUrl(Uri.parse(route), mode: LaunchMode.externalApplication);
        return;
      }

      // Otherwise, treat as an in-app route name.
      Navigator.of(context).pushNamed(route);
      return;
    }

    if (action is OpenUrlAction) {
      if (action.url.isNotEmpty) {
        await launchUrl(
          Uri.parse(action.url),
          mode: LaunchMode.externalApplication,
        );
      }
      return;
    }

    if (action is ToastAction) {
      if (context.mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(action.message),
            // ⬇️ closable 옵션이 true면 닫기 버튼을 노출
            action: action.closable
                ? SnackBarAction(
                    label: (action.closeLabel?.trim().isNotEmpty ?? false)
                        ? action.closeLabel!.trim()
                        : 'Close',
                    onPressed: () => messenger.hideCurrentSnackBar(),
                  )
                : null,
          ),
        );
      }
      return;
    }

    if (action is TrackAction) {
      // Hook actual analytics SDK here in real apps.
      // ignore: avoid_print
      print('track: ${action.event} ${action.props ?? {}}');
      return;
    }
  }

  /// Heuristic to decide if a string is an absolute URL.
  static bool _looksLikeUrl(String s) =>
      s.startsWith('http://') || s.startsWith('https://');
}
