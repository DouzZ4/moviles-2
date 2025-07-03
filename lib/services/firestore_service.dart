// firestore_service.dart
// Servicio para operaciones CRUD con Firestore en la app CheckINC.
// Permite crear, leer, actualizar y eliminar documentos en colecciones.

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Instancia de la base de datos Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Guarda un documento en la colección especificada (con ID propio)
  Future<void> createDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection(collectionPath).doc(documentId).set(data);
  }

  /// Agrega un nuevo documento (ID autogenerado) y devuelve su ID
  Future<String> addDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    DocumentReference docRef = await _db.collection(collectionPath).add(data);
    return docRef.id;
  }

  /// Lee un documento por su ID
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

  /// Elimina un documento por su ID
  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    await _db.collection(collectionPath).doc(documentId).delete();
  }
}
