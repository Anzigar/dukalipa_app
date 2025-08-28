import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../services/appwrite_service.dart';

/// API client using Appwrite for backend operations
class ApiClient {
  final AppwriteService _appwriteService;
  late final Databases _databases;
  late final Storage _storage;

  ApiClient() : _appwriteService = AppwriteService() {
    _databases = _appwriteService.databases;
    _storage = _appwriteService.storage;
  }

  /// Get documents from a collection
  Future<DocumentList> getDocuments({
    required String collectionId,
    List<String>? queries,
  }) async {
    try {
      return await _databases.listDocuments(
        databaseId: 'shop_management_db',
        collectionId: collectionId,
        queries: queries ?? [],
      );
    } catch (e) {
      throw Exception('Failed to get documents: ${e.toString()}');
    }
  }

  /// Get a single document
  Future<Document> getDocument({
    required String collectionId,
    required String documentId,
  }) async {
    try {
      return await _databases.getDocument(
        databaseId: 'shop_management_db',
        collectionId: collectionId,
        documentId: documentId,
      );
    } catch (e) {
      throw Exception('Failed to get document: ${e.toString()}');
    }
  }

  /// Create a document
  Future<Document> createDocument({
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _databases.createDocument(
        databaseId: 'shop_management_db',
        collectionId: collectionId,
        documentId: documentId,
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to create document: ${e.toString()}');
    }
  }

  /// Update a document
  Future<Document> updateDocument({
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _databases.updateDocument(
        databaseId: 'shop_management_db',
        collectionId: collectionId,
        documentId: documentId,
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to update document: ${e.toString()}');
    }
  }

  /// Delete a document
  Future<void> deleteDocument({
    required String collectionId,
    required String documentId,
  }) async {
    try {
      await _databases.deleteDocument(
        databaseId: 'shop_management_db',
        collectionId: collectionId,
        documentId: documentId,
      );
    } catch (e) {
      throw Exception('Failed to delete document: ${e.toString()}');
    }
  }

  /// Upload a file to storage
  Future<File> uploadFile({
    required String bucketId,
    required String fileId,
    required InputFile file,
  }) async {
    try {
      return await _storage.createFile(
        bucketId: bucketId,
        fileId: fileId,
        file: file,
      );
    } catch (e) {
      throw Exception('Failed to upload file: ${e.toString()}');
    }
  }

  /// Get file preview URL
  String getFilePreview({
    required String bucketId,
    required String fileId,
    int? width,
    int? height,
  }) {
    return _storage.getFilePreview(
      bucketId: bucketId,
      fileId: fileId,
      width: width,
      height: height,
    ).toString();
  }

  /// Delete a file from storage
  Future<void> deleteFile({
    required String bucketId,
    required String fileId,
  }) async {
    try {
      await _storage.deleteFile(
        bucketId: bucketId,
        fileId: fileId,
      );
    } catch (e) {
      throw Exception('Failed to delete file: ${e.toString()}');
    }
  }
}