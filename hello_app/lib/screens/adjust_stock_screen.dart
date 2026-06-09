import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/transaction_provider.dart';

class AdjustStockScreen extends StatefulWidget {
  const AdjustStockScreen({super.key});

  @override
  State<AdjustStockScreen> createState() => _AdjustStockScreenState();
}

class _AdjustStockScreenState extends State<AdjustStockScreen> {
  String? _selectedProductId;
  String _adjustmentType = 'Stock In';
  String _selectedReason = 'Received Stock';
  int _quantity = 1;
  bool _isSubmitting = false;

  final Map<String, List<String>> _reasonsByType = {
    'Stock In': [
      'Received Stock',
      'Return from Customer',
      'Stock Correction',
      'Manual Entry',
    ],
    'Stock Out': [
      'Sold',
      'Damaged',
      'Expired',
      'Lost/Shrinkage',
      'Customer Return Pending',
      'Stock Correction',
    ],
    'Adjustment': [
      'Inventory Count',
      'System Correction',
      'Stock Reconciliation',
    ],
  };

  List<String> get _availableReasons => _reasonsByType[_adjustmentType] ?? [];

  void _onTypeChanged(String newType) {
    setState(() {
      _adjustmentType = newType;
      _selectedReason = _availableReasons.first;
    });
  }

  void _submitAdjustment() async {
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product')),
      );
      return;
    }

    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be greater than 0')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final productProvider = context.read<ProductProvider>();
      final transactionProvider = context.read<TransactionProvider>();

      final streamSnapshot =
          await productProvider.getProductsStream().first;
      final product = streamSnapshot
          .firstWhere((p) => p.id == _selectedProductId, orElse: () {
        throw Exception('Product not found');
      });

      final previousQuantity = product.currentStock;
      int newQuantity = previousQuantity;

      if (_adjustmentType == 'Stock In') {
        newQuantity = previousQuantity + _quantity;
      } else if (_adjustmentType == 'Stock Out') {
        newQuantity = (previousQuantity - _quantity).clamp(0, 999999);
      } else {
        newQuantity = _quantity;
      }

      await productProvider.updateProductQuantity(
        productId: _selectedProductId!,
        newQuantity: newQuantity,
      );

      await transactionProvider.addTransaction(
        productId: _selectedProductId!,
        transactionType: _adjustmentType,
        quantityChanged: _quantity,
        previousQuantity: previousQuantity,
        newQuantity: newQuantity,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock adjusted: $_adjustmentType $_quantity units'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _selectedProductId = null;
          _adjustmentType = 'Stock In';
          _selectedReason = 'Received Stock';
          _quantity = 1;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Section Two Supermarket - Adjust Stock'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 2,
        centerTitle: true,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          return StreamBuilder<List<Product>>(
            stream: productProvider.getProductsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final products = snapshot.data ?? [];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Adjust Stock Levels',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Select Product',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedProductId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Choose a product',
                      ),
                      items: products
                          .map((product) => DropdownMenuItem(
                                value: product.id,
                                child: Text(product.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProductId = value;
                        });
                      },
                    ),
                    if (_selectedProductId != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Builder(builder: (context) {
                              final product = products.firstWhere(
                                (p) => p.id == _selectedProductId,
                              );
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Current Stock',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      Text(
                                        '${product.currentStock} ${product.unit}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Minimum Stock',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      Text(
                                        '${product.minimumStock} ${product.unit}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'Adjustment Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'Stock In',
                          label: Text('Stock In'),
                          icon: Icon(Icons.arrow_upward),
                        ),
                        ButtonSegment(
                          value: 'Stock Out',
                          label: Text('Stock Out'),
                          icon: Icon(Icons.arrow_downward),
                        ),
                        ButtonSegment(
                          value: 'Adjustment',
                          label: Text('Adjustment'),
                          icon: Icon(Icons.tune),
                        ),
                      ],
                      selected: {_adjustmentType},
                      onSelectionChanged: (Set<String> newSelection) {
                        _onTypeChanged(newSelection.first);
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Quantity',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: 'Enter quantity',
                        suffixIcon: const Icon(Icons.numbers),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _quantity = int.tryParse(value) ?? 1;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Reason',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedReason,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _availableReasons
                          .map((reason) => DropdownMenuItem(
                                value: reason,
                                child: Text(reason),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedReason = value ?? _selectedReason;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isSubmitting ? null : _submitAdjustment,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Submit Adjustment'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
