class Chapter {
  final int id;
  final String name;
  final String subject;
  final int pages;
  final int weightage;
  final String keyFormulas;
  final String detailedNotes;
  final String examples;
  final String practiceProblems;

  Chapter({
    required this.id,
    required this.name,
    required this.subject,
    required this.pages,
    required this.weightage,
    required this.keyFormulas,
    required this.detailedNotes,
    required this.examples,
    required this.practiceProblems,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'subject': subject,
        'pages': pages,
        'weightage': weightage,
        'key_formulas': keyFormulas,
        'detailed_notes': detailedNotes,
        'examples': examples,
        'practice_problems': practiceProblems,
      };

  factory Chapter.fromMap(Map<String, dynamic> m) => Chapter(
        id: m['id'] as int,
        name: m['name'] as String,
        subject: m['subject'] as String,
        pages: m['pages'] as int,
        weightage: m['weightage'] as int,
        keyFormulas: m['key_formulas'] as String,
        detailedNotes: m['detailed_notes'] as String,
        examples: m['examples'] as String,
        practiceProblems: m['practice_problems'] as String,
      );
}
