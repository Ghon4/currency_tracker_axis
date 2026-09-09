import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:currency_tracker_axis/core/connectivity/connectivity_service.dart';
import 'package:currency_tracker_axis/core/connectivity/connectivity_status.dart';
import 'package:currency_tracker_axis/core/connectivity/usecases/watch_connectivity.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class _FakeConnectivity extends Fake implements Connectivity {
  _FakeConnectivity(this._results);

  List<ConnectivityResult> _results;
  final _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  void emit(List<ConnectivityResult> results) {
    _results = results;
    _controller.add(results);
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;
}

void main() {
  group('ConnectivityService', () {
    test('init reads initial online state', () async {
      final fake = _FakeConnectivity([ConnectivityResult.wifi]);
      final service = ConnectivityService(connectivity: fake);
      await service.init();
      expect(service.isOnline, isTrue);
      await service.dispose();
    });

    test('init reads initial offline state', () async {
      final fake = _FakeConnectivity([ConnectivityResult.none]);
      final service = ConnectivityService(connectivity: fake);
      await service.init();
      expect(service.isOnline, isFalse);
      await service.dispose();
    });

    test('emits status change after debounce', () async {
      final fake = _FakeConnectivity([ConnectivityResult.wifi]);
      final service = ConnectivityService(connectivity: fake);
      await service.init();

      final future = service.onStatusChange.first;
      fake.emit([ConnectivityResult.none]);
      // Debounce is 800ms in AppConstants.
      await Future<void>.delayed(const Duration(milliseconds: 900));
      expect(await future, isFalse);
      expect(service.isOnline, isFalse);
      await service.dispose();
    });
  });

  group('WatchConnectivity', () {
    test('yields current status then changes', () async {
      final fake = _FakeConnectivity([ConnectivityResult.wifi]);
      final service = ConnectivityService(connectivity: fake);
      await service.init();
      final watch = WatchConnectivity(service);

      final statuses = <ConnectivityStatus>[];
      final sub = watch().listen(statuses.add);

      await Future<void>.delayed(Duration.zero);
      expect(statuses.first, ConnectivityStatus.online);

      fake.emit([ConnectivityResult.none]);
      await Future<void>.delayed(const Duration(milliseconds: 900));
      expect(statuses.last, ConnectivityStatus.offline);

      await sub.cancel();
      await service.dispose();
    });
  });
}
