// A screen that loads its page JSON (local) when navigated to and renders components.

import 'package:flutter/material.dart';
import '../data/server_driven_ui_page_repository.dart';
import '../models/server_driven_ui_page.dart';
import '../renderer/server_driven_ui_component_renderer.dart';

/// One screen = one page JSON. Simulates "API call per screen" using local assets.
class ServerDrivenUIPageScreen extends StatefulWidget {
  const ServerDrivenUIPageScreen({
    super.key,
    required this.routeName,
    required this.pageTitleFallback,
  });

  /// The route string (e.g., "/", "/detail") used to resolve which JSON to load.
  final String routeName;

  /// Title used when the loaded JSON doesn't provide one.
  final String pageTitleFallback;

  @override
  State<ServerDrivenUIPageScreen> createState() =>
      _ServerDrivenUIPageScreenState();
}

class _ServerDrivenUIPageScreenState extends State<ServerDrivenUIPageScreen> {
  final _repo = ServerDrivenUIPageRepository();
  late Future<ServerDrivenUIPage> _future;

  @override
  void initState() {
    super.initState();
    // Each navigation triggers a fresh JSON load for that route.
    _future = _repo.loadFromRoute(widget.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ServerDrivenUIPage>(
      future: _future,
      builder: (context, snap) {
        final theme = Theme.of(context);
        if (snap.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.pageTitleFallback)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.hasError || !snap.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.pageTitleFallback)),
            body: Center(
              child: Text(
                'Failed to load page',
                style: theme.textTheme.bodyLarge,
              ),
            ),
          );
        }

        final page = snap.data!;
        return Scaffold(
          appBar: AppBar(title: Text(page.title ?? widget.pageTitleFallback)),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: page.components.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                ServerDrivenUIComponentRenderer(component: page.components[i]),
          ),
        );
      },
    );
  }
}
