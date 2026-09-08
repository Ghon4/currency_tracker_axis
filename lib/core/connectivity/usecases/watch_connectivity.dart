import 'package:currency_tracker_axis/core/connectivity/connectivity_service.dart';
import 'package:currency_tracker_axis/core/connectivity/connectivity_status.dart';

/// Emits the current connectivity status, then subsequent changes.
class WatchConnectivity {
  const WatchConnectivity(this._service);

  final ConnectivityService _service;

  Stream<ConnectivityStatus> call() async* {
    yield _service.isOnline
        ? ConnectivityStatus.online
        : ConnectivityStatus.offline;
    yield* _service.onStatusChange.map(
      (online) =>
          online ? ConnectivityStatus.online : ConnectivityStatus.offline,
    );
  }
}
