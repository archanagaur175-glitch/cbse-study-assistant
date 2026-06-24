import 'progress_entry.dart';

class LearnerModel {
  final String userId;
  final Map<int, ProgressEntry> progress;
  DateTime lastActive;
  int totalStudySessions;
  int totalMinutesStudied;

  LearnerModel({
    required this.userId,
    Map<int, ProgressEntry>? progress,
    DateTime? lastActive,
    this.totalStudySessions = 0,
    this.totalMinutesStudied = 0,
  })  : progress = progress ?? {},
        lastActive = lastActive ?? DateTime.now();

  ProgressEntry ensureProgress(int chapterId) {
    return progress.putIfAbsent(chapterId, () => ProgressEntry(chapterId: chapterId));
  }

  int get totalChaptersStarted => progress.length;
  int get totalChaptersCompleted =>
      progress.values.where((p) => p.masteryScore >= 0.8).length;

  List<ProgressEntry> get dueReviews => progress.values
      .where((p) =>
          p.nextReviewDue != null && p.nextReviewDue!.isBefore(DateTime.now()))
      .toList()
    ..sort((a, b) => (a.nextReviewDue ?? DateTime.now())
        .compareTo(b.nextReviewDue ?? DateTime.now()));

  double get overallMastery {
    if (progress.isEmpty) return 0.0;
    return progress.values.fold(0.0, (s, p) => s + p.masteryScore) /
        progress.length;
  }

  List<ProgressEntry> get weakestTopics {
    final list = progress.values.toList()
      ..sort((a, b) => a.masteryScore.compareTo(b.masteryScore));
    return list.take(5).toList();
  }

  List<ProgressEntry> get recentlyReviewed {
    final list = progress.values
        .where((p) => p.lastReviewed != null)
        .toList()
      ..sort((a, b) => (b.lastReviewed ?? DateTime(2000))
          .compareTo(a.lastReviewed ?? DateTime(2000)));
    return list.take(5).toList();
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'progress': progress.map((k, v) => MapEntry(k.toString(), v.toJson())),
        'lastActive': lastActive.toIso8601String(),
        'totalStudySessions': totalStudySessions,
        'totalMinutesStudied': totalMinutesStudied,
      };

  factory LearnerModel.fromJson(Map<String, dynamic> j) {
    final rawProgress = j['progress'] as Map<String, dynamic>? ?? {};
    final progress = rawProgress.map(
      (k, v) => MapEntry(int.parse(k),
          ProgressEntry.fromJson(v as Map<String, dynamic>)),
    );
    return LearnerModel(
      userId: j['userId'] as String,
      progress: progress,
      lastActive: j['lastActive'] != null
          ? DateTime.tryParse(j['lastActive'] as String) ?? DateTime.now()
          : DateTime.now(),
      totalStudySessions: j['totalStudySessions'] as int? ?? 0,
      totalMinutesStudied: j['totalMinutesStudied'] as int? ?? 0,
    );
  }
}
