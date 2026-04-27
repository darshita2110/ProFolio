class Experience {
  final String role;
  final String company;
  final String duration;
  final String? description;

  Experience({
    required this.role,
    required this.company,
    required this.duration,
    this.description,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      role: json['role'] as String? ?? '',
      company: json['company'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'company': company,
      'duration': duration,
      'description': description,
    };
  }

  Experience copyWith({
    String? role,
    String? company,
    String? duration,
    String? description,
  }) {
    return Experience(
      role: role ?? this.role,
      company: company ?? this.company,
      duration: duration ?? this.duration,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Experience &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          company == other.company &&
          duration == other.duration &&
          description == other.description;

  @override
  int get hashCode =>
      role.hashCode ^
      company.hashCode ^
      duration.hashCode ^
      description.hashCode;

  @override
  String toString() =>
      'Experience(role: $role, company: $company, duration: $duration, description: $description)';
}
