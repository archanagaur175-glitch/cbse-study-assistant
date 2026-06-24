import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../models/learner_model.dart';
import '../models/profile.dart';
import '../models/progress_entry.dart';
import '../services/recommendation_engine.dart';
import '../services/progress_service.dart';
import '../data/chapters.dart';

class AppState extends ChangeNotifier {
  Profile profile;
  LearnerModel learner;
  RecommendationEngine engine;
  int tabIndex = 0;

  int _chapterTimerSeconds = 0;
  Timer? _timer;
  bool _timerPaused = false;
  int? _trackingChapterId;

  AppState({required this.profile, required this.learner})
      : engine = RecommendationEngine(
          chapters: allChapters,
          profile: profile,
          learner: learner,
        );

  int get elapsedSeconds => _chapterTimerSeconds;
  int get totalChaptersStarted => learner.progress.length;
  int get totalChaptersCompleted =>
      learner.progress.values.where((p) => p.masteryScore >= 0.8).length;
  double get overallMastery {
    if (learner.progress.isEmpty) return 0.0;
    return learner.progress.values.fold(0.0, (s, p) => s + p.masteryScore) /
        learner.progress.length;
  }

  List<ProgressEntry> get dueReviews {
    final list = learner.progress.values
        .where((p) =>
            p.nextReviewDue != null && p.nextReviewDue!.isBefore(DateTime.now()))
        .toList()
      ..sort((a, b) => (a.nextReviewDue ?? DateTime.now())
          .compareTo(b.nextReviewDue ?? DateTime.now()));
    return list;
  }

  List<ProgressEntry> get weakestTopics {
    final list = learner.progress.values.toList()
      ..sort((a, b) => a.masteryScore.compareTo(b.masteryScore));
    return list.take(5).toList();
  }

  ProgressEntry getProgress(int chapterId) {
    return learner.ensureProgress(chapterId);
  }

  ProgressEntry? getProgressOrNull(int chapterId) {
    return learner.progress[chapterId];
  }

  void startChapterTimer(int chapterId) {
    _trackingChapterId = chapterId;
    _chapterTimerSeconds = 0;
    _timerPaused = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_timerPaused) _chapterTimerSeconds++;
    });
    final entry = getProgress(chapterId);
    if (entry.lastReviewed == null) entry.lastReviewed = DateTime.now();
  }

  void pauseTimer() => _timerPaused = true;
  void resumeTimer() => _timerPaused = false;

  void stopChapterTimer() {
    _timer?.cancel();
    _timer = null;
    if (_trackingChapterId != null && _chapterTimerSeconds > 0) {
      learner.totalMinutesStudied +=
          (_chapterTimerSeconds / 60).round().clamp(1, 60);
      notifyListeners();
    }
    _chapterTimerSeconds = 0;
    _trackingChapterId = null;
  }

  void recordQuizAttempt({
    required int chapterId,
    required bool correct,
    required double responseTimeSeconds,
  }) {
    final entry = getProgress(chapterId);
    ProgressService.recordAttempt(
      entry: entry,
      correct: correct,
      responseTimeSeconds: responseTimeSeconds,
    );
    learner.totalStudySessions++;
    learner.lastActive = DateTime.now();
    engine = RecommendationEngine(
      chapters: allChapters,
      profile: profile,
      learner: learner,
    );
    notifyListeners();
    _save();
  }

  void markStudied({required int chapterId, required bool understood}) {
    final timeSeconds = _chapterTimerSeconds.toDouble().clamp(1.0, 3600.0);
    final entry = getProgress(chapterId);
    ProgressService.recordAttempt(
      entry: entry,
      correct: understood,
      responseTimeSeconds: timeSeconds,
    );
    learner.totalStudySessions++;
    learner.lastActive = DateTime.now();
    engine = RecommendationEngine(
      chapters: allChapters,
      profile: profile,
      learner: learner,
    );
    notifyListeners();
    _save();
  }

  void setTab(int index) {
    tabIndex = index;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('learner_model_${profile.name}',
        jsonEncode(learner.toJson()));
  }

  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(profile.toJson()));
  }

  Future<void> clearAll() async {
    _timer?.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('learner_model_${profile.name}');
    await prefs.remove('user_profile');
  }

  static Future<AppState?> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    if (profileJson == null) return null;
    final profile = Profile.fromJson(jsonDecode(profileJson) as Map<String, dynamic>);
    final learnerJson = prefs.getString('learner_model_${profile.name}');
    final learner = learnerJson != null
        ? LearnerModel.fromJson(jsonDecode(learnerJson) as Map<String, dynamic>)
        : LearnerModel(userId: profile.name);
    return AppState(profile: profile, learner: learner);
  }

  static AppState createNew(Profile profile) {
    return AppState(
      profile: profile,
      learner: LearnerModel(userId: profile.name),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
