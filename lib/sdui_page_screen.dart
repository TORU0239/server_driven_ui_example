import 'package:flutter/material.dart';

class ServerDrivenUIPageScreen extends StatefulWidget {
  const ServerDrivenUIPageScreen({
    super.key,
    required this.routeName,
    required this.pageTitleFallback,
  });

  final String routeName;
  final String pageTitleFallback;

  @override
  State<StatefulWidget> createState() => _ServerDrivenUIPageScreenState();
}

class _ServerDrivenUIPageScreenState extends State<ServerDrivenUIPageScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pageTitleFallback)),
      body: Center(
        child: Text('This is a placeholder for ${widget.routeName}'),
      ),
    );
  }
}
