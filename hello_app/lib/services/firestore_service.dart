import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // User operations
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'role': 'staff',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Product operations
  Stream<List<Product>> getProductsStream() {
    try {
      return _db.collection('products').snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => Product.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get products stream: $e');
    }
  }

  Future<void> addProduct({
    required String productName,
    required String category,
    required int quantity,
    required double buyingPrice,
    required double sellingPrice,
  }) async {
    try {
      await _db.collection('products').add({
        'productName': productName,
        'category': category,
        'quantity': quantity,
        'buyingPrice': buyingPrice,
        'sellingPrice': sellingPrice,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct({
    required String productId,
    required String productName,
    required String category,
    required int quantity,
    required double buyingPrice,
    required double sellingPrice,
  }) async {
    try {
      await _db.collection('products').doc(productId).update({
        'productName': productName,
        'category': category,
        'quantity': quantity,
        'buyingPrice': buyingPrice,
        'sellingPrice': sellingPrice,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _db.collection('products').doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<void> updateProductQuantity({
    required String productId,
    required int newQuantity,
  }) async {
    try {
      await _db.collection('products').doc(productId).update({
        'quantity': newQuantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product quantity: $e');
    }
  }

  // Transaction operations
  Stream<List<Map<String, dynamic>>> getTransactionsStream() {
    try {
      return _db
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      throw Exception('Failed to get transactions stream: $e');
    }
  }

  Future<void> addTransaction({
    required String productId,
    required String transactionType,
    required int quantityChanged,
    required int previousQuantity,
    required int newQuantity,
  }) async {
    try {
      await _db.collection('transactions').add({
        'productId': productId,
        'transactionType': transactionType,
        'quantityChanged': quantityChanged,
        'previousQuantity': previousQuantity,
        'newQuantity': newQuantity,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getTransactionsByProduct(String productId) {
    try {
      return _db
          .collection('transactions')
          .where('productId', isEqualTo: productId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      throw Exception('Failed to get transactions by product: $e');
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final productsSnapshot = await _db.collection('products').get();
      final transactionsSnapshot = await _db.collection('transactions').get();

      int totalProducts = productsSnapshot.docs.length;
      int totalQuantity = 0;

      for (var doc in productsSnapshot.docs) {
        totalQuantity += (doc['quantity'] as int? ?? 0);
      }

      return {
        'totalProducts': totalProducts,
        'totalQuantity': totalQuantity,
        'recentTransactions': transactionsSnapshot.docs.length,
      };
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getLowStockProducts() {
    try {
      return _db.collection('products').snapshots().map((snapshot) {
        return snapshot.docs
            .where((doc) => (doc['quantity'] as int? ?? 0) <= 20)
            .map((doc) => doc.data())
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get low stock products: $e');
    }
  }
}
