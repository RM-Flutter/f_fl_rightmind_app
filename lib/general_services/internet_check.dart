
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../general_services/offline_overlay.service.dart';

class ConnectionService extends ChangeNotifier {
  bool _isConnected = true;
  bool get isConnected => _isConnected;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _periodicCheckTimer;
  final Connectivity _connectivity = Connectivity();
  
  // Callback to resume initialization when connection is restored
  VoidCallback? onConnectionRestored;

  ConnectionService() {
    _initializeConnectionCheck();
  }

  Future<void> _initializeConnectionCheck() async {
    // Check initial connection status multiple times to ensure accuracy
    await _checkConnectionStatus();
    await Future.delayed(const Duration(milliseconds: 300));
    await _checkConnectionStatus();
    
    // Show overlay if offline on startup
    if (!_isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        OfflineOverlayService.showOfflineOverlay();
      });
    }
    
    // Listen to connectivity changes (WiFi/Mobile/Ethernet/etc)
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });

    // Periodic check every 5 seconds to ensure we catch connection changes
    _periodicCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkConnectionStatus();
    });
  }

  Future<void> _checkConnectionStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Error checking connection status: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Consider connected if there's any network connection (WiFi, Mobile, Ethernet, VPN, etc.)
    // Only show offline if there's NO network connection at all (ConnectivityResult.none)
    final hasNetworkConnection = !results.contains(ConnectivityResult.none);
    
    if (_isConnected != hasNetworkConnection) {
      _isConnected = hasNetworkConnection;
      
      // Show/hide offline overlay based on connection status
      if (!_isConnected) {
        // Connection lost - show overlay
        WidgetsBinding.instance.addPostFrameCallback((_) {
          OfflineOverlayService.showOfflineOverlay();
        });
      } else {
        // Connection restored - hide overlay and trigger callback if registered
        WidgetsBinding.instance.addPostFrameCallback((_) {
          OfflineOverlayService.hideOfflineOverlay();
          // Call callback to resume initialization if registered (e.g., from SplashScreen)
          if (onConnectionRestored != null) {
            debugPrint("🔄 Connection restored, triggering initialization callback...");
            onConnectionRestored!();
          }
        });
      }
      
      notifyListeners();
      debugPrint('Connection status changed: ${_isConnected ? "Connected" : "Offline"}');
    }
  }

  // Manual check method that can be called from UI
  Future<void> checkConnection() async {
    await _checkConnectionStatus();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicCheckTimer?.cancel();
    super.dispose();
  }
}
