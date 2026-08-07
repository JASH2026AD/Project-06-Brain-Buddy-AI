import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  NetworkInfo(this._connectivity);

  final Connectivity _connectivity;

  Future<bool> get isConnected async {
    final List<ConnectivityResult> results = await _connectivity
        .checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Stream<bool> get onConnectionChanged => _connectivity.onConnectivityChanged
      .map((List<ConnectivityResult> results) {
        return !results.contains(ConnectivityResult.none);
      });
}
