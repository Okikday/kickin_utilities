// lib/smart_isolate.dart
export 'smart_isolate_io.dart'
    if (dart.library.js_interop) 'smart_isolate_web.dart';
