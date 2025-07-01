// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Guarda un documento en la colección especificada
  Future<void> createDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection(collectionPath).doc(documentId).set(data);
  }

  /// Agrega un nuevo documento (sin ID definido) y devuelve su ID
  Future<String> addDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    DocumentReference docRef = await _db.collection(collectionPath).add(data);
    return docRef.id;
  }

  /// Lee un documento por ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    return await _db.collection(collectionPath).doc(documentId).get();
  }

  /// Lee todos los documentos de una colección
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllDocuments({
    required String collectionPath,
  }) async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _db.collection(collectionPath).get();
    return snapshot.docs;
  }

  /// Actualiza un documento existente
  Future<void> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection(collectionPath).doc(documentId).update(data);
  }

  /// Elimina un documento
  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    await _db.collection(collectionPath).doc(documentId).delete();
  }
}
