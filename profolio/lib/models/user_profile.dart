import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:profolio/models/education.dart';
import 'package:profolio/models/experience.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final List<String> skills;
  final List<Experience> experience;
  final List<Education> education;
  final List<String> interests;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.skills = const [],
    this.experience = const [],
    this.education = const [],
    this.interests = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      skills: List<String>.from(json['skills'] as List? ?? []),
      experience: (json['experience'] as List?)
              ?.map((e) => Experience.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      education: (json['education'] as List?)
              ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      interests: List<String>.from(json['interests'] as List? ?? []),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'skills': skills,
      'experience': experience.map((e) => e.toJson()).toList(),
      'education': education.map((e) => e.toJson()).toList(),
      'interests': interests,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? skills,
    List<Experience>? experience,
    List<Education>? education,
    List<String>? interests,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          skills == other.skills &&
          experience == other.experience &&
          education == other.education &&
          interests == other.interests &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      skills.hashCode ^
      experience.hashCode ^
      education.hashCode ^
      interests.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() =>
      'UserProfile(id: $id, name: $name, email: $email, skills: $skills, '
      'experience: $experience, education: $education, interests: $interests, '
      'createdAt: $createdAt, updatedAt: $updatedAt)';
}