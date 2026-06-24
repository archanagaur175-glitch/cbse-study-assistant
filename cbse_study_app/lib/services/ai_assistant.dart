import '../models/chapter.dart';
import '../models/learner_model.dart';
import '../models/progress_entry.dart';

class AiAssistant {
  static String summarizeNotes(String notes) {
    final lines = notes
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.length <= 2) return notes;
    return '${lines.first}\n${lines[1]}';
  }

  static String generateHint(String problem, Chapter chapter) {
    final formulas = chapter.keyFormulas.split('\n');
    final relevant = <String>[];
    final lowerProblem = problem.toLowerCase();

    for (final f in formulas) {
      final parts = f.split(':');
      if (parts.length >= 2) {
        final term = parts[0].trim().toLowerCase();
        if (lowerProblem.contains(term)) {
          relevant.add(f);
        }
      }
    }

    if (relevant.isEmpty && formulas.isNotEmpty) {
      relevant.add(formulas.first);
    }

    if (relevant.isEmpty) {
      return 'Review the key formulas section of this chapter.';
    }

    return 'Hint: Try using this formula:\n${relevant.join('\n')}';
  }

  static Chapter? recommendNextChapter({
    required LearnerModel learner,
    required List<Chapter> chapters,
    Chapter? currentChapter,
  }) {
    final subjectOrder = <String, List<String>>{
      'Physics': [
        'Electric Charges and Fields',
        'Electrostatic Potential and Capacitance',
        'Current Electricity',
        'Magnetism and Matter',
      ],
      'Chemistry': [
        'Solutions',
        'Electrochemistry',
        'Chemical Kinetics',
        'Haloalkanes and Haloarenes',
        'Aldehydes, Ketones and Carboxylic Acids',
        'Coordination Compounds',
      ],
      'Mathematics': [
        'Relations and Functions',
        'Matrices',
        'Continuity and Differentiability',
        'Integrals',
        'Three Dimensional Geometry',
        'Probability',
      ],
      'Biology': [
        'Reproduction in Organisms',
        'Principles of Inheritance and Variation',
        'Molecular Basis of Inheritance',
        'Biomolecules',
        'Sexual Reproduction in Flowering Plants',
        'Biotechnology: Principles and Processes',
      ],
    };

    if (currentChapter != null) {
      final order = subjectOrder[currentChapter.subject] ?? [];
      final idx = order.indexOf(currentChapter.name);
      if (idx >= 0 && idx + 1 < order.length) {
        final next = chapters.cast<Chapter?>().firstWhere(
            (c) => c!.name == order[idx + 1],
            orElse: () => null);
        if (next != null) return next;
      }
    }

    final weakSubjectsProgress = <String, double>{};
    for (final entry in learner.progress.values) {
      final ch = chapters.cast<Chapter?>().firstWhere(
          (c) => c!.id == entry.chapterId,
          orElse: () => null);
      if (ch != null) {
        final current = weakSubjectsProgress[ch.subject] ?? 0.0;
        weakSubjectsProgress[ch.subject] =
            current + (1.0 - entry.masteryScore);
      }
    }

    if (weakSubjectsProgress.isNotEmpty) {
      final sorted = weakSubjectsProgress.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final weakestSubject = sorted.first.key;
      final unstarted = chapters
          .where((c) =>
              c.subject == weakestSubject &&
              !learner.progress.containsKey(c.id))
          .toList();
      if (unstarted.isNotEmpty) return unstarted.first;
    }

    final started = learner.progress.keys.toSet();
    final unstarted =
        chapters.where((c) => !started.contains(c.id)).toList();
    if (unstarted.isNotEmpty) return unstarted.first;

    final dueReviews = learner.dueReviews;
    if (dueReviews.isNotEmpty) {
      return chapters.cast<Chapter?>().firstWhere(
          (c) => c!.id == dueReviews.first.chapterId,
          orElse: () => null);
    }

    return null;
  }

  static List<_StudyPlanItem> generateStudyPlan({
    required LearnerModel learner,
    required List<Chapter> chapters,
    required int availableMinutes,
  }) {
    final plan = <_StudyPlanItem>[];

    final dueEntries = learner.dueReviews;
    for (final entry in dueEntries) {
      final chapter = chapters.cast<Chapter?>().firstWhere(
          (c) => c!.id == entry.chapterId,
          orElse: () => null);
      if (chapter != null) {
        plan.add(_StudyPlanItem(
          chapter: chapter,
          reason: 'Due for review',
          estimatedMinutes: (chapter.pages * 0.12 * 8).round().clamp(5, 60),
        ));
      }
    }

    final weakEntries = learner.weakestTopics;
    for (final entry in weakEntries) {
      if (plan.any((p) => p.chapter.id == entry.chapterId)) continue;
      final chapter = chapters.cast<Chapter?>().firstWhere(
          (c) => c!.id == entry.chapterId,
          orElse: () => null);
      if (chapter != null) {
        plan.add(_StudyPlanItem(
          chapter: chapter,
          reason: 'Weak area (${(entry.masteryScore * 100).round()}% mastery)',
          estimatedMinutes: (chapter.pages * 0.12 * 8).round(),
        ));
      }
    }

    final totalPlanned = plan.fold(0, (s, p) => s + p.estimatedMinutes);
    var remaining = availableMinutes - totalPlanned;

    if (remaining > 0) {
      final unstarted = chapters
          .where((c) => !learner.progress.containsKey(c.id))
          .toList();
      for (final chapter in unstarted) {
        if (remaining <= 0) break;
        final est = (chapter.pages * 0.12 * 8).round();
        if (est <= remaining) {
          plan.add(_StudyPlanItem(
            chapter: chapter,
            reason: 'New topic',
            estimatedMinutes: est,
          ));
          remaining -= est;
        }
      }
    }

    return plan;
  }
}

class _StudyPlanItem {
  final Chapter chapter;
  final String reason;
  final int estimatedMinutes;
  _StudyPlanItem({
    required this.chapter,
    required this.reason,
    required this.estimatedMinutes,
  });
}
