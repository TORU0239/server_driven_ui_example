import 'package:flutter/material.dart';
import 'sdui_page_screen.dart';

class ServerDrivenUIApp extends StatelessWidget {
  const ServerDrivenUIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SDUI Playground (Local Only)',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        final routeName = settings.name ?? '/';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ServerDrivenUIPageScreen(
            routeName: routeName,
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
