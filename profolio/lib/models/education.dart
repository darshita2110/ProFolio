class Education {
  final String degree;
  final String institution;
  final String year;
  final String? grade;

  Education({
    required this.degree,
    required this.institution,
    required this.year,
    this.grade,
  });

  /// Create Education from JSON
  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      degree: json['degree'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      year: json['year'] as String? ?? '',
      grade: json['grade'] as String?,
    );
  }

  /// Convert Education to JSON
  Map<String, dynamic> toJson() {
    return {
      'degree': degree,
      'institution': institution,
      'year': year,
      'grade': grade,
    };
  }

  /// Create a copy of Education with modified fields
  Education copyWith({
    String? degree,
    String? institution,
    String? year,
    String? grade,
  }) {
    return Education(
      degree: degree ?? this.degree,
      institution: institution ?? this.institution,
      year: year ?? this.year,
      grade: grade ?? this.grade,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Education &&
          runtimeType == other.runtimeType &&
          degree == other.degree &&
          institution == other.institution &&
          year == other.year &&
          grade == other.grade;

  @override
  int get hashCode =>
      degree.hashCode ^
      institution.hashCode ^
      year.hashCode ^
      grade.hashCode;

  @override
  String toString() =>
      'Education(degree: $degree, institution: $institution, year: $year, grade: $grade)';
}
