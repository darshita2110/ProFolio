import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profolio/core/constants/firestore_constants.dart';
import 'package:profolio/core/providers/firebase_providers.dart';
import 'package:profolio/core/services/firestore_service.dart';
import 'package:profolio/models/user_profile.dart';

final userProfileProvider = StreamProvider.family<UserProfile?, String>((
  ref,
  userId,
) {
  final firestoreService = ref.watch(firestoreServiceProvider);

  return firestoreService
      .streamDocument(
        collection: FirestoreConstants.usersCollection,
        docId: userId,
      )
      .map((data) {
        if (data == null) return null;
        return UserProfile.fromJson(data);
      });
});

class ProfileState {
  final bool isLoading;
  final String? error;

  ProfileState({
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileController extends StateNotifier<ProfileState> {
  final IFirestoreService firestoreService;

  ProfileController({required this.firestoreService}) : super(ProfileState());

  Future<void> updateProfile({
    required String userId,
    required UserProfile profile,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
      );

      await firestoreService.updateDocument(
        collection: FirestoreConstants.usersCollection,
        docId: userId,
        data: updatedProfile.toJson(),
      );

      state = state.copyWith(isLoading: false);
    } on FirestoreException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    }
  }

  Future<void> deleteProfile({required String userId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await firestoreService.deleteDocument(
        collection: FirestoreConstants.usersCollection,
        docId: userId,
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

final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return ProfileController(firestoreService: firestoreService);
});
