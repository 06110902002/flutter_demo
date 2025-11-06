import 'package:flutter/material.dart';

class ToastUtil {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static void show(String message) {
    if (_isShowing) {
      _overlayEntry?.remove();
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.8,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    _isShowing = true;
    final context = navigatorKey.currentContext;
    if (context != null) {
      Overlay.of(context).insert(_overlayEntry!);
      Future.delayed(const Duration(seconds: 3), dismiss);
    }
  }

  static void dismiss() {
    if (_isShowing) {
      _overlayEntry?.remove();
      _isShowing = false;
    }
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();