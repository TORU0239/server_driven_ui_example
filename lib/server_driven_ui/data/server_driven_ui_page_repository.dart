// Repository to load page JSON (local assets only, per-screen).
// Each screen "pretends" to call an API by loading its own JSON when navigated to.

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/server_driven_ui_page.dart';
import '../util/route_asset_resolver.dart';
import 'server_driven_ui_fallback_json.dart';

/// Loads [ServerDrivenUIPage] from local asset JSON based on a route string.
class ServerDrivenUIPageRepository {
  /// Loads JSON for the given [route] by trying several candidate asset paths.
  /// Falls back to a NotFound page, then to Home if nothing matches.
  Future<ServerDrivenUIPage> loadFromRoute(String route) async {
    final candidates = resolveAssetCandidates(route);

    for (final assetPath in candidates) {
      try {
        final jsonStr = await rootBundle.loadString(assetPath);
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return ServerDrivenUIPage.fromJson(map);
      } catch (_) {
        // Continue to next candidate.
      }
    }

    // Fallback chain: NotFound -> Home
    try {
      final notFound =
          jsonDecode(ServerDrivenUIFallbackJson.notFound)
              as Map<String, dynamic>;
      return ServerDrivenUIPage.fromJson(notFound);
    } catch (_) {
      return ServerDrivenUIPage.fromJson(
        jsonDecode(ServerDrivenUIFallbackJson.home) as Map<String, dynamic>,
      );
    }
  }
}
