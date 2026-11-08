import 'dart:async';
import 'package:flutter/material.dart';

class SessionTimeoutWatcher extends StatefulWidget {
  final Widget child;
  final int timeoutSeconds;
  final VoidCallback onTimeout;

  const SessionTimeoutWatcher({
    super.key,
    required this.child,
    required this.timeoutSeconds,
    required this.onTimeout,
  });

  @override
  State<SessionTimeoutWatcher> createState() => _SessionTimeoutWatcherState();
}

class _SessionTimeoutWatcherState extends State<SessionTimeoutWatcher> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant SessionTimeoutWatcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeoutSeconds != widget.timeoutSeconds) {
      _resetTimer();
    }
  }

  void _startTimer() {
    if (widget.timeoutSeconds <= 0) return;
    _timer?.cancel();
    _timer = Timer(Duration(seconds: widget.timeoutSeconds), () {
      widget.onTimeout();
    });
  }

  void _resetTimer() {
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerUp: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
