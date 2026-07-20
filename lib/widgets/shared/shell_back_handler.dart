import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps a bottom-nav shell (client/owner/admin) so the system back button
/// behaves like a normal app instead of bailing out immediately: these
/// shells are reached via `context.go()`, which replaces the route stack
/// rather than pushing onto it, so there is nothing left for the back
/// button to pop — without this, Android just kills the app.
///
/// Behavior: if not on the shell's home tab, back switches to it; if
/// already on the home tab, a second back press within 2s exits the app.
class ShellBackHandler extends StatefulWidget {
  final bool isAtHome;
  final VoidCallback onGoHome;
  final Widget child;

  const ShellBackHandler({
    super.key,
    required this.isAtHome,
    required this.onGoHome,
    required this.child,
  });

  @override
  State<ShellBackHandler> createState() => _ShellBackHandlerState();
}

class _ShellBackHandlerState extends State<ShellBackHandler> {
  DateTime? _lastBackPress;

  void _handleBack() {
    if (!widget.isAtHome) {
      widget.onGoHome();
      return;
    }

    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: widget.child,
    );
  }
}
