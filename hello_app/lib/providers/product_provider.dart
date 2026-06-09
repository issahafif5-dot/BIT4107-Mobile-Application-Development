import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class ProductProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  final List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<List<Product>> getProductsStream() {
    return _firestoreService.getProductsStream();
  }

  Future<void> addProduct({
    required String productName,
    required String category,
    required int quantity,
    required double buyingPrice,
    required double sellingPrice,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.addProduct(
        productName: productName,
        category: category,
        quantity: quantity,
        buyingPrice: buyingPrice,
        sellingPrice: sellingPrice,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
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
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.updateProduct(
        productId: productId,
        productName: productName,
        category: category,
        quantity: quantity,
        buyingPrice: buyingPrice,
        sellingPrice: sellingPrice,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.deleteProduct(productId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProductQuantity({
    required String productId,
    required int newQuantity,
  }) async {
    try {
      await _firestoreService.updateProductQuantity(
        productId: productId,
        newQuantity: newQuantity,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  List<String> getCategories(List<Product> products) {
    Set<String> categories = {'All'};
    for (var product in products) {
      categories.add(product.category);
    }
    return categories.toList();
  }

  List<Product> filterByCategory(String category, List<Product> products) {
    if (category == 'All') {
      return products;
    }
    return products.where((p) => p.category == category).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
