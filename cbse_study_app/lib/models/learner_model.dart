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
