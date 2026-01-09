import 'package:flutter/material.dart';

/// Simple app router with a smooth slide+fade transition.
class AppRouter {
  static Route<T> _buildRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slide = Tween<Offset>(begin: const Offset(0.12, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic))
            .animate(animation);
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);
        return SlideTransition(
          position: slide,
          child: FadeTransition(opacity: fade, child: child),
        );
      },
    );
  }

  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(_buildRoute<T>(page));
  }

  static Future<T?> pushReplacement<T, TO>(BuildContext context, Widget page) {
    return Navigator.of(context).pushReplacement<T, TO>(_buildRoute<T>(page));
  }

  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget page) {
    return Navigator.of(context).pushAndRemoveUntil<T>(_buildRoute<T>(page), (route) => false);
  }

  static void pop(BuildContext context, [Object? result]) {
    Navigator.of(context).pop(result);
  }
}
