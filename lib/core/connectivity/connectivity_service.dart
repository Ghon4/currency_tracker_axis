import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:currency_tracker_axis/core/constants/app_constants.dart';

/// Observes device network connectivity with debounced status updates.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _debounce;
  bool _isOnline = true;
  bool _initialized = false;

  /// Current online estimate (last known status).
  bool get isOnline => _isOnline;

  /// Emits when online status changes after debounce.
  Stream<bool> get onStatusChange => _controller.stream;

  /// Reads the initial connectivity state and starts listening for changes.
  Future<void> init() async {
    if (_initialized) return;

    final initial = await _connectivity.checkConnectivity();
    _isOnline = _hasConnection(initial);

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _debounce?.cancel();
      _debounce = Timer(AppConstants.connectivityDebounce, () {
        final online = _hasConnection(results);
        if (online == _isOnline) return;
        _isOnline = online;
        if (!_controller.isClosed) {
          _controller.add(online);
        }
      });
    });

    _initialized = true;
  }

  /// Returns whether any usable network interface is present.
  Future<bool> checkOnline() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = _hasConnection(results);
    return _isOnline;
  }

  bool _hasConnection(List<ConnectivityResult> results) => results.any(
        (result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet,
      );

  /// Cancels subscriptions and closes the status stream.
  Future<void> dispose() async {
    _debounce?.cancel();
    await _subscription?.cancel();
    await _controller.close();
    _initialized = false;
  }
}
