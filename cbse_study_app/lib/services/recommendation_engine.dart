import '../models/chapter.dart';
import '../models/learner_model.dart';
import '../models/profile.dart';
import '../models/progress_entry.dart';
import 'spaced_repetition.dart';

class RecommendationEngine {
  final List<Chapter> chapters;
  final Profile profile;
  final LearnerModel learner;

  RecommendationEngine({
    required this.chapters,
    required this.profile,
    required this.learner,
  });

  List<Chapter> getTopRecommendations({int count = 5}) {
    final scored = chapters.map((ch) {
      final progress = learner.progress[ch.id];
      return _ScoredWithReasons(
        chapter: ch,
        score: _scoreChapter(ch, progress),
        reasons: _reasonsFor(ch, progress),
      );
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(count).map((s) => s.chapter).toList();
  }

  double _scoreChapter(Chapter ch, ProgressEntry? progress) {
    double score = 0;

    final weakLower = profile.weakSubjects.map((s) => s.toLowerCase()).toSet();
    final strongLower = profile.strongSubjects.map((s) => s.toLowerCase()).toSet();
    final subj = ch.subject.toLowerCase();

    if (weakLower.contains(subj)) score += 30;
    if (strongLower.contains(subj)) score += 5;

    score += (ch.weightage / 16.0) * 20;

    if (progress != null) {
      final recencyBoost = progress.daysSinceLastReview.clamp(0, 30) / 30.0 * 15;
      score += recencyBoost;

      final masteryPenalty = (1.0 - progress.masteryScore) * 25;
      score += masteryPenalty;

      if (SpacedRepetition.isDue(progress)) {
        score += 20;
      }

      score -= (progress.retryCount * 2).clamp(0, 10);

      score -= progress.averageResponseTime / 60.0;
    } else {
      score += 15;
    }

    final diffMap = {'easy': 1.0, 'medium': 0.65, 'hard': 0.3};
    final diffScore = diffMap[profile.difficulty] ?? 0.65;
    score += (15 - (ch.pages - 20).abs().clamp(0, 15)) * diffScore;

    final noteMap = {'short': 1.3, 'medium': 1.0, 'long': 0.7};
    final noteScore = noteMap[profile.noteLength] ?? 1.0;
    score += (ch.pages <= 18 ? 10 : ch.pages <= 24 ? 5 : 0) * noteScore;

    if (profile.dailyStudyMinutes >= 120) score += 10;
    else if (profile.dailyStudyMinutes >= 60) score += 5;

    final goalMap = {'competitive': 1.2, 'board': 0.8, 'foundation': 0.5};
    score *= goalMap[profile.examGoal] ?? 0.8;

    return score;
  }

  List<String> _reasonsFor(Chapter ch, ProgressEntry? progress) {
    final reasons = <String>[];
    final subj = ch.subject.toLowerCase();
    final weakLower = profile.weakSubjects.map((s) => s.toLowerCase()).toSet();

    if (weakLower.contains(subj)) {
      reasons.add('Weak subject');
    }
    if (progress == null) {
      reasons.add('Not started');
    } else {
      if (SpacedRepetition.isDue(progress)) {
        reasons.add('Due for review');
      }
      if (progress.masteryScore < 0.4) {
        reasons.add('Low mastery (${(progress.masteryScore * 100).round()}%)');
      }
      if (progress.retryCount > 3) {
        reasons.add('Needs revisiting');
      }
      if (progress.daysSinceLastReview > 14) {
        reasons.add('Not seen in ${progress.daysSinceLastReview} days');
      }
    }
    if (ch.weightage >= 14) {
      reasons.add('High weightage (${ch.weightage}%)');
    }
    return reasons;
  }

  List<String> getReasonsForChapter(Chapter ch) {
    final progress = learner.progress[ch.id];
    return _reasonsFor(ch, progress);
  }

  List<Chapter> search(String query) {
    final q = query.toLowerCase();
    return chapters.where((ch) {
      return ch.name.toLowerCase().contains(q) ||
          ch.subject.toLowerCase().contains(q) ||
          ch.keyFormulas.toLowerCase().contains(q) ||
          ch.detailedNotes.toLowerCase().contains(q);
    }).toList();
  }

  int calculateRecoveryTime(Chapter chapter) {
    return (chapter.pages * 0.12 * 8).round();
  }
}

class _ScoredWithReasons {
  final Chapter chapter;
  final double score;
  final List<String> reasons;
  _ScoredWithReasons({
    required this.chapter,
    required this.score,
    required this.reasons,
  });
}
