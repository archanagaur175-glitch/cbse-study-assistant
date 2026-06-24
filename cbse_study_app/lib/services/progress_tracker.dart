import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/learner_model.dart';
import '../models/progress_entry.dart';
import 'spaced_repetition.dart';

class ProgressTracker {
  final LearnerModel _learner;
  final void Function(LearnerModel) _onSave;
  int _elapsedSeconds = 0;
  Timer? _timer;
  bool _paused = false;
  int? _currentChapterId;

  ProgressTracker({
    required LearnerModel learner,
    required void Function(LearnerModel) onSave,
  })  : _learner = learner,
        _onSave = onSave;

  LearnerModel get learner => _learner;

  int get elapsedSeconds => _elapsedSeconds;
  bool get isRunning => _timer != null && !_paused;

  ProgressEntry getProgress(int chapterId) {
    return _learner.ensureProgress(chapterId);
  }

  void startTracking(int chapterId) {
    _currentChapterId = chapterId;
    _elapsedSeconds = 0;
    _paused = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_paused) {
        _elapsedSeconds++;
      }
    });
    final entry = getProgress(chapterId);
    if (entry.lastReviewed == null) {
      entry.lastReviewed = DateTime.now();
      _onSave(_learner);
    }
  }

  void pause() {
    _paused = true;
  }

  void resume() {
    _paused = false;
  }

  void recordQuizAttempt({
    required int chapterId,
    required bool correct,
    required double responseTimeSeconds,
  }) {
    final entry = getProgress(chapterId);
    entry.recordAttempt(correct: correct, responseTime: responseTimeSeconds);

    final quality = SpacedRepetition.qualityFromPerformance(
      correct: correct,
      responseTimeSeconds: responseTimeSeconds,
    );
    SpacedRepetition.scheduleReview(entry: entry, quality: quality);

    _learner.totalStudySessions++;
    _learner.lastActive = DateTime.now();
    _onSave(_learner);
  }

  void stopTracking() {
    _timer?.cancel();
    _timer = null;
    if (_currentChapterId != null && _elapsedSeconds > 0) {
      _learner.totalMinutesStudied += (_elapsedSeconds / 60).round().clamp(1, 60);
      _onSave(_learner);
    }
    _elapsedSeconds = 0;
    _currentChapterId = null;
  }

  void dispose() {
    stopTracking();
  }
}

class AutoTimerWidget extends StatefulWidget {
  final Chapter chapter;
  final ProgressTracker tracker;
  final Widget child;

  const AutoTimerWidget({
    super.key,
    required this.chapter,
    required this.tracker,
    required this.child,
  });

  @override
  State<AutoTimerWidget> createState() => _AutoTimerWidgetState();
}

class _AutoTimerWidgetState extends State<AutoTimerWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.tracker.startTracking(widget.chapter.id);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.tracker.stopTracking();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      widget.tracker.pause();
    } else if (state == AppLifecycleState.resumed) {
      widget.tracker.resume();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
