import 'package:cloud_firestore/cloud_firestore.dart';

abstract class IFirestoreService {
  Future<void> createDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  });

  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String docId,
  });

  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  });

  Future<void> deleteDocument({
    required String collection,
    required String docId,
  });

  Stream<Map<String, dynamic>?> streamDocument({
    required String collection,
    required String docId,
  });

  Future<bool> documentExists({
    required String collection,
    required String docId,
  });
}

class FirestoreService implements IFirestoreService {
  final FirebaseFirestore _firebaseFirestore;

  FirestoreService(this._firebaseFirestore);

  @override
  Future<void> createDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firebaseFirestore.collection(collection).doc(docId).set(data);
    } catch (e) {
      throw FirestoreException(message: 'Failed to create document: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      final doc = await _firebaseFirestore.collection(collection).doc(docId).get();
      return doc.data();
    } catch (e) {
      throw FirestoreException(message: 'Failed to get document: $e');
    }
  }

  @override
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firebaseFirestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw FirestoreException(message: 'Failed to update document: $e');
    }
  }

  @override
  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _firebaseFirestore.collection(collection).doc(docId).delete();
    } catch (e) {
      throw FirestoreException(message: 'Failed to delete document: $e');
    }
  }

  @override
  Stream<Map<String, dynamic>?> streamDocument({
    required String collection,
    required String docId,
  }) {
    try {
      return _firebaseFirestore
          .collection(collection)
          .doc(docId)
          .snapshots()
          .map((snapshot) => snapshot.data());
    } catch (e) {
      throw FirestoreException(message: 'Failed to stream document: $e');
    }
  }

  @override
  Future<bool> documentExists({
    required String collection,
    required String docId,
  }) async {
    try {
      final doc = await _firebaseFirestore.collection(collection).doc(docId).get();
      return doc.exists;
    } catch (e) {
      throw FirestoreException(message: 'Failed to check document existence: $e');
    }
  }
}

class FirestoreException implements Exception {
  final String message;

  FirestoreException({required this.message});

  @override
  String toString() => message;
}
