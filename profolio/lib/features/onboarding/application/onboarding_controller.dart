import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profolio/core/providers/firebase_providers.dart';
import 'package:profolio/core/services/firestore_service.dart';
import 'package:profolio/core/constants/firestore_constants.dart';
import 'package:profolio/models/education.dart';
import 'package:profolio/models/experience.dart';
import 'package:profolio/models/user_profile.dart';

class OnboardingState {
  final int currentStep;
  final String name;
  final String email;
  final List<String> skills;
  final List<Experience> experience;
  final List<Education> education;
  final List<String> interests;
  final bool isLoading;
  final String? error;

  OnboardingState({
    this.currentStep = 0,
    this.name = '',
    this.email = '',
    this.skills = const [],
    this.experience = const [],
    this.education = const [],
    this.interests = const [],
    this.isLoading = false,
    this.error,
  });

  OnboardingState copyWith({
    int? currentStep,
    String? name,
    String? email,
    List<String>? skills,
    List<Experience>? experience,
    List<Education>? education,
    List<String>? interests,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      name: name ?? this.name,
      email: email ?? this.email,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      interests: interests ?? this.interests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OnboardingController extends StateNotifier<OnboardingState> {
  final IFirestoreService firestoreService;
  final String userId;

  OnboardingController({
    required this.firestoreService,
    required this.userId,
  }) : super(OnboardingState());

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  void addSkill(String skill) {
    if (skill.isNotEmpty && !state.skills.contains(skill)) {
      state = state.copyWith(
        skills: [...state.skills, skill],
      );
    }
  }

  void removeSkill(String skill) {
    state = state.copyWith(
      skills: state.skills.where((s) => s != skill).toList(),
    );
  }

  void addExperience(Experience exp) {
    state = state.copyWith(
      experience: [...state.experience, exp],
    );
  }

  void removeExperience(int index) {
    final updated = List<Experience>.from(state.experience);
    updated.removeAt(index);
    state = state.copyWith(experience: updated);
  }

  void addEducation(Education edu) {
    state = state.copyWith(
      education: [...state.education, edu],
    );
  }

  void removeEducation(int index) {
    final updated = List<Education>.from(state.education);
    updated.removeAt(index);
    state = state.copyWith(education: updated);
  }

  void addInterest(String interest) {
    if (interest.isNotEmpty && !state.interests.contains(interest)) {
      state = state.copyWith(
        interests: [...state.interests, interest],
      );
    }
  }

  void removeInterest(String interest) {
    state = state.copyWith(
      interests: state.interests.where((i) => i != interest).toList(),
    );
  }

  void nextStep() {
    if (state.currentStep < 3) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<void> saveProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userProfile = UserProfile(
        id: userId,
        name: state.name,
        email: state.email,
        skills: state.skills,
        experience: state.experience,
        education: state.education,
        interests: state.interests,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestoreService.createDocument(
        collection: FirestoreConstants.usersCollection,
        docId: userId,
        data: userProfile.toJson(),
      );

      state = state.copyWith(isLoading: false);
    } on FirestoreException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final onboardingControllerProvider = StateNotifierProvider.family<
    OnboardingController,
    OnboardingState,
    String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return OnboardingController(
    firestoreService: firestoreService,
    userId: userId,
  );
});
