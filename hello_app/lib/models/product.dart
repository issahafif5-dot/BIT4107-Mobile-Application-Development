// Represents an item/product in the supermarket inventory
class Product {
  final String? id; // Firestore document ID
  final int? localId; // Local ID for backward compatibility
  final String name;
  final String category;
  int currentStock;
  final int minimumStock;
  final String unit;
  final String imageUrl;
  final double? buyingPrice;
  final double? sellingPrice;

  Product({
    this.id,
    this.localId,
    required this.name,
    required this.category,
    required this.currentStock,
    required this.minimumStock,
    required this.unit,
    required this.imageUrl,
    this.buyingPrice,
    this.sellingPrice,
  });

  // Factory constructor for Firestore data
  factory Product.fromFirestore(Map<String, dynamic> data, String docId) {
    return Product(
      id: docId,
      name: data['productName'] ?? '',
      category: data['category'] ?? '',
      currentStock: data['quantity'] ?? 0,
      minimumStock: 20,
      unit: data['unit'] ?? 'units',
      imageUrl: data['imageUrl'] ?? '',
      buyingPrice: (data['buyingPrice'] as num?)?.toDouble(),
      sellingPrice: (data['sellingPrice'] as num?)?.toDouble(),
    );
  }

  bool get isLowStock => currentStock <= minimumStock;
  int get unitsToOrder => (minimumStock * 1.5).toInt() - currentStock;
}

// Represents a transaction that adjusts inventory (stock in or stock out)
class InventoryTransaction {
  final int id; // Unique transaction identifier
  final int productId; // Which product was affected
  final String productName; // Product name (for easy display)
  final int quantity; // How many units
  final String type; // "IN" (received) or "OUT" (sold/removed/damaged)
  final String reason; // Why: "Received Stock", "Damaged Item", "Sale", etc.
  final DateTime timestamp; // When this transaction occurred

  // Constructor - creates a transaction record
  InventoryTransaction({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.type,
    required this.reason,
    required this.timestamp,
  });

  // Formatted date string for display
  String get formattedDate => "${timestamp.day}/${timestamp.month}/${timestamp.year}";
}
