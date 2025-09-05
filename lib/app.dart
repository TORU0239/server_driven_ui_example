// Application root that wires routing to Server-Driven UI page screens.
// Convention over configuration: route string -> local JSON path is resolved at runtime.

import 'package:flutter/material.dart';
import 'server_driven_ui/screen/server_driven_ui_page_screen.dart';

/// App root for the Server-Driven UI sample (local assets only).
class ServerDrivenUIApplication extends StatelessWidget {
  const ServerDrivenUIApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Server-Driven UI (Local Only)',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        final routeName = settings.name ?? '/';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ServerDrivenUIPageScreen(
            routeName: routeName,
            // Fallback title when the JSON doesn't provide one
            pageTitleFallback: routeName == '/'
                ? 'Home'
                : routeName.replaceFirst('/', '').toUpperCase(),
          ),
        );
      },
      initialRoute: '/',
    );
  }
}
