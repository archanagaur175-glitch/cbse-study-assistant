class Profile {
  final String name;
  final String grade;
  final List<String> weakSubjects;
  final List<String> strongSubjects;
  final int dailyStudyMinutes;
  final String examGoal;
  final String difficulty;
  final String noteLength;

  Profile({
    required this.name,
    required this.grade,
    required this.weakSubjects,
    required this.strongSubjects,
    required this.dailyStudyMinutes,
    required this.examGoal,
    required this.difficulty,
    required this.noteLength,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'grade': grade,
        'weak_subjects': weakSubjects,
        'strong_subjects': strongSubjects,
        'daily_study_minutes': dailyStudyMinutes,
        'exam_goal': examGoal,
        'difficulty': difficulty,
        'note_length': noteLength,
      };

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        name: j['name'] as String? ?? '',
        grade: j['grade'] as String? ?? '',
        weakSubjects: List<String>.from(j['weak_subjects'] ?? []),
        strongSubjects: List<String>.from(j['strong_subjects'] ?? []),
        dailyStudyMinutes: j['daily_study_minutes'] as int? ?? 60,
        examGoal: j['exam_goal'] as String? ?? 'board',
        difficulty: j['difficulty'] as String? ?? 'medium',
        noteLength: j['note_length'] as String? ?? 'medium',
      );
}
