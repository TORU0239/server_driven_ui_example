// Embedded fallback JSON for offline/demo usage or when route/asset is missing.

class ServerDrivenUIFallbackJson {
  /// Default Home page shown when assets are missing or route is unknown.
  static const String home = '''
  {
    "version": 1,
    "title": "Home",
    "components": [
      { "type": "header", "text": "Welcome 👋 (Fallback JSON)" },
      {
        "type": "card",
        "title": "Promo",
        "body": "This is a fallback page bundled in the app.",
        "actions": [{ "type": "navigate", "route": "/detail" }]
      }
    ]
  }
  ''';

  /// Not-found page as an optional intermediate fallback.
  static const String notFound = '''
  {
    "version": 1,
    "title": "Not Found",
    "components": [
      { "type": "header", "text": "Page not found" },
      { "type": "text", "text": "No local JSON matched this route. Showing fallback." },
      { "type": "button", "text": "Go Home", "action": { "type": "navigate", "route": "/" } }
    ]
  }
  ''';
}
