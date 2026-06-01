import 'package:flutter_test/flutter_test.dart';
import 'package:kickin_utilities/kickin_utilities.dart';

void main() {
  test('KResult.tryRun and KSpacing values', () async {
    final r = await KResult.tryRunAsync<int>(() async => 42);
    expect(r.isSuccess, isTrue);
    expect(r.value, 42);

    final err = await KResult.tryRunAsync<int>(() async => throw Exception('boom'));
    expect(err.isError, isTrue);
  });

  test('KSpacing constants and num extensions', () {
    expect(KSpacing.md, 16);
    expect(1.toHBox, isNotNull);
    expect(500.inMs, isA<Duration>());
  });
}
