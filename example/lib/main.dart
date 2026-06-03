import 'package:flutter/material.dart';
import 'package:kickin_utilities/kickin_utilities.dart';

void main() {
  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('kickin_utilities example')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Spacing md = ${KSpacing.md}'),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
