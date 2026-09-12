import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// An [AssetBundle] that reads real files from disk synchronously and
/// wraps them in [SynchronousFuture].
///
/// Why this exists: `flutter test` runs each `testWidgets` body inside a
/// `FakeAsync` zone, which fast-forwards fake `Timer`s but cannot advance
/// real OS-level async I/O — so the default `rootBundle.loadString`
/// (which reads asset files via real, asynchronous `dart:io` calls) never
/// resolves during `tester.pump()`/`pumpAndSettle()`; it only completes
/// after the test body returns, which is too late for anything that
/// awaits it mid-test. `SynchronousFuture` sidesteps that entirely: its
/// `.then` runs its callback immediately in the current call stack
/// instead of scheduling a real async continuation, so an `await` on it
/// resolves in the same turn — no real I/O wait, nothing for FakeAsync to
/// get stuck on. The blocking `readAsStringSync` call itself is safe here
/// precisely because it's synchronous, not part of the event loop at all.
///
/// Paths are resolved relative to the process working directory, which
/// `flutter test` sets to the project root — the same root
/// `pubspec.yaml`'s asset paths (e.g. `assets/data/countries.json`) are
/// already relative to.
class SyncTestAssetBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) {
    return SynchronousFuture(File(key).readAsStringSync());
  }

  @override
  Future<ByteData> load(String key) {
    final bytes = File(key).readAsBytesSync();
    return SynchronousFuture(ByteData.view(Uint8List.fromList(bytes).buffer));
  }
}
