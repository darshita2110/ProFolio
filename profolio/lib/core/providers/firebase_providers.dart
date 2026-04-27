import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profolio/core/services/firebase_auth_service.dart';
import 'package:profolio/core/services/firestore_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final authServiceProvider = Provider<IAuthService>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthService(firebaseAuth);
});

final firestoreServiceProvider = Provider<IFirestoreService>((ref) {
  final firebaseFirestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreService(firebaseFirestore);
});

final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});
