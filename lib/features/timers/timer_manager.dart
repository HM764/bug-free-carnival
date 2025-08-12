import 'dart:async';
import 'timer_dialog.dart';

/// Owns a list of timers and a single periodic ticker.
class TimerManager {
  final void Function() onTick;
  final List<TimerInstance> timers = [];
  Timer? _ticker;

  TimerManager({required this.onTick});

  void dispose() {
    _ticker?.cancel();
    _ticker = null;
  }

  void addTimer(TimerSettings settings) {
    final t = TimerInstance(
      originalSeconds: settings.seconds,
      remainingSeconds: settings.seconds,
      name: settings.name,
      stepIndex: settings.stepIndex,
    );
    timers.add(t);
    _ensureTicker();
  }

  void pause(TimerInstance t) {
    t.isRunning = false;
    _checkRunning();
  }

  void resume(TimerInstance t) {
    t.isRunning = true;
    _ensureTicker();
  }

  void restart(TimerInstance t) {
    t.remainingSeconds = t.originalSeconds;
    t.isRunning = true;
    _ensureTicker();
  }

  void clearAll() {
    timers.clear();
    _checkRunning();
  }

  void _ensureTicker() {
    if (_ticker != null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      bool anyChanged = false;
      for (final t in timers) {
        if (!t.isRunning) continue;
        if (t.remainingSeconds > 0) {
          t.remainingSeconds -= 1;
          anyChanged = true;
        }
      }
      if (anyChanged) {
        onTick();
      }
      _checkRunning();
    });
  }

  void _checkRunning() {
    final anyRunning = timers.any((t) => t.isRunning && t.remainingSeconds > 0);
    if (!anyRunning) {
      _ticker?.cancel();
      _ticker = null;
    }
    onTick();
  }
}
