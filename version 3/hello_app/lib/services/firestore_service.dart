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
    String unit = 'units',
  }) async {
    try {
      await _db.collection('products').add({
        'productName': productName,
        'category': category,
        'quantity': quantity,
        'buyingPrice': buyingPrice,
        'sellingPrice': sellingPrice,
        'unit': unit,
        'imageUrl': '',
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

  Future<void> seedInitialProducts() async {
    try {
      final snapshot = await _db.collection('products').limit(1).get();
      if (snapshot.docs.isNotEmpty) return; // Already seeded

      final List<Map<String, dynamic>> initialProducts = [
        {
          'productName': 'Farm Fresh Eggs',
          'category': 'Dairy',
          'quantity': 50,
          'buyingPrice': 2.50,
          'sellingPrice': 3.50,
          'unit': 'tray',
          'imageUrl': 'images/eggs.jpg',
          'minimumStock': 10,
        },
        {
          'productName': 'Whole Wheat Bread',
          'category': 'Bakery',
          'quantity': 20,
          'buyingPrice': 1.20,
          'sellingPrice': 1.80,
          'unit': 'loaf',
          'imageUrl': 'images/bread.jpg',
          'minimumStock': 15,
        },
        {
          'productName': 'All Purpose Flour',
          'category': 'Baking',
          'quantity': 30,
          'buyingPrice': 0.80,
          'sellingPrice': 1.50,
          'unit': 'kg',
          'imageUrl': 'images/flour.jpg',
          'minimumStock': 10,
        },
        {
          'productName': 'Granulated Sugar',
          'category': 'Baking',
          'quantity': 40,
          'buyingPrice': 1.00,
          'sellingPrice': 1.60,
          'unit': 'kg',
          'imageUrl': 'images/sugar.jpg',
          'minimumStock': 15,
        },
        {
          'productName': 'Red Tomatoes',
          'category': 'Produce',
          'quantity': 15,
          'buyingPrice': 0.50,
          'sellingPrice': 1.20,
          'unit': 'kg',
          'imageUrl': 'images/tomatoes.jpg',
          'minimumStock': 20,
        },
        {
          'productName': 'Whole Milk',
          'category': 'Dairy',
          'quantity': 25,
          'buyingPrice': 1.10,
          'sellingPrice': 1.50,
          'unit': 'liter',
          'imageUrl': 'images/whole milk.jpg',
          'minimumStock': 10,
        },
        {
          'productName': 'Cooking Oil',
          'category': 'Pantry',
          'quantity': 12,
          'buyingPrice': 5.00,
          'sellingPrice': 7.50,
          'unit': 'liter',
          'imageUrl': 'images/cooking oil.jpg',
          'minimumStock': 5,
        },
        {
          'productName': 'Premium Rice',
          'category': 'Pantry',
          'quantity': 10,
          'buyingPrice': 15.00,
          'sellingPrice': 22.00,
          'unit': '10kg bag',
          'imageUrl': 'images/rice(10kg bag).jpg',
          'minimumStock': 5,
        },
      ];

      for (var product in initialProducts) {
        product['createdAt'] = FieldValue.serverTimestamp();
        product['updatedAt'] = FieldValue.serverTimestamp();
        await _db.collection('products').add(product);
      }
    } catch (e) {
      throw Exception('Failed to seed products: $e');
    }
  }

  // Combined operation for efficiency
  Future<void> adjustStock({
    required String productId,
    required String productName,
    required String transactionType,
    required int quantityChanged,
    required int previousQuantity,
    required int newQuantity,
  }) async {
    final batch = _db.batch();

    final productRef = _db.collection('products').doc(productId);
    batch.update(productRef, {
      'quantity': newQuantity,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final transactionRef = _db.collection('transactions').doc();
    batch.set(transactionRef, {
      'productId': productId,
      'productName': productName,
      'transactionType': transactionType,
      'quantityChanged': quantityChanged,
      'previousQuantity': previousQuantity,
      'newQuantity': newQuantity,
      'timestamp': FieldValue.serverTimestamp(),
    });

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to adjust stock: $e');
    }
  }

  // Transaction operations
  Stream<List<Map<String, dynamic>>> getTransactionsStream() {
    try {
      return _db.collection('transactions').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (e) {
      throw Exception('Failed to get transactions stream: $e');
    }
  }

  Future<void> addTransaction({
    required String productId,
    required String productName,
    required String transactionType,
    required int quantityChanged,
    required int previousQuantity,
    required int newQuantity,
  }) async {
    try {
      await _db.collection('transactions').add({
        'productId': productId,
        'productName': productName,
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
          .snapshots()
          .map((snapshot) {
        final docs = snapshot.docs.map((doc) => doc.data()).toList();
        docs.sort((a, b) {
          final aTime = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
          final bTime = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
          return bTime.compareTo(aTime);
        });
        return docs;
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
        totalQuantity += (doc['quantity'] as num?)?.toInt() ?? 0;
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
