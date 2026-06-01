import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kickin_utilities/kickin_utilities.dart';

final counterProvider = NotifierProvider<KIntNotifier, int>(() => KIntNotifier());

void main() {
  runApp(const ProviderScope(child: ExampleApp()));
}

class ExampleApp extends ConsumerWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('kickin_utilities example')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Spacing md = ${KSpacing.md}'),
              const SizedBox(height: 12),
              Text('Count: $count'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(counterProvider.notifier).set(count + 1),
                child: const Text('Increment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
