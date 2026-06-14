import 'package:flutter/foundation.dart';
import '../services/firestore_service.dart';

class TransactionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  final List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Stream<List<Map<String, dynamic>>> getTransactionsStream() {
    return _firestoreService.getTransactionsStream();
  }

  Stream<List<Map<String, dynamic>>> getTransactionsByProduct(String productId) {
    return _firestoreService.getTransactionsByProduct(productId);
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
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.addTransaction(
        productId: productId,
        productName: productName,
        transactionType: transactionType,
        quantityChanged: quantityChanged,
        previousQuantity: previousQuantity,
        newQuantity: newQuantity,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
