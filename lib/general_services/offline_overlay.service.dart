import 'package:flutter/material.dart';
import '../modules/offline/views/offline_screen.dart';
import '../routing/app_router.dart';

class OfflineOverlayService {
  static OverlayEntry? _offlineOverlay;
  static bool _isShowing = false;

  static void showOfflineOverlay() {
    if (_isShowing) {
      debugPrint('Offline overlay already showing');
      return;
    }
    
    // Wait a bit to ensure navigator is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isShowing) return; // Double check after delay
      
      try {
        _isShowing = true;
        _offlineOverlay = OverlayEntry(
          builder: (context) => const OfflineScreen(),
          opaque: true,
        );
        
        // Use rootNavigatorKey from app_router.dart (GoRouter's navigator)
        if (rootNavigatorKey.currentState?.overlay != null) {
          rootNavigatorKey.currentState!.overlay!.insert(_offlineOverlay!);
          debugPrint('Offline overlay shown successfully');
        } else {
          debugPrint('⚠️ Cannot show offline overlay: navigator overlay not available');
          _isShowing = false;
          _offlineOverlay = null;
        }
      } catch (e) {
        debugPrint('Error showing offline overlay: $e');
        _isShowing = false;
        _offlineOverlay = null;
      }
    });
  }

  static void hideOfflineOverlay() {
    if (!_isShowing) {
      // Already hidden, reset state
      _offlineOverlay = null;
      return;
    }
    
    if (_offlineOverlay == null) {
      // Overlay entry is null, just reset state
      _isShowing = false;
      return;
    }
    
    try {
      final overlay = _offlineOverlay;
      _offlineOverlay = null;
      _isShowing = false;
      
      // Remove overlay if navigator is available
      if (rootNavigatorKey.currentState?.overlay != null && overlay != null) {
        overlay.remove();
        debugPrint('Offline overlay hidden');
      } else {
        debugPrint('Offline overlay state reset (navigator not available)');
      }
    } catch (e) {
      debugPrint('Error hiding offline overlay: $e');
      _isShowing = false;
      _offlineOverlay = null;
    }
  }

  static bool get isShowing => _isShowing;
}

