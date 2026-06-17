# Firebase Integration - Quick Reference

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd hello_app
flutter pub get
```

### 2. Configure Firebase Credentials
Edit `lib/firebase/firebase_options.dart` and replace with your Firebase project credentials:
- Go to Firebase Console > Project Settings
- Copy your project details
- Update the configuration

### 3. Add google-services.json (Android)
1. Download `google-services.json` from Firebase Console
2. Place in `android/app/` directory

### 4. Run the App
```bash
flutter run
```

## 📚 API Reference

### AuthProvider
```dart
// Sign up
await authProvider.signUp(
  email: 'user@example.com',
  password: 'password',
  name: 'User Name',
);

// Sign in
await authProvider.signIn(
  email: 'user@example.com',
  password: 'password',
);

// Sign out
await authProvider.signOut();

// Properties
authProvider.currentUser        // Current Firebase user
authProvider.isAuthenticated    // Is user logged in
authProvider.isLoading          // Loading state
authProvider.errorMessage       // Error message
```

### ProductProvider
```dart
// Get real-time products stream
productProvider.getProductsStream()

// Add product
await productProvider.addProduct(
  productName: 'Rice',
  category: 'Grains',
  quantity: 50,
  buyingPrice: 1000,
  sellingPrice: 1500,
);

// Update product
await productProvider.updateProduct(
  productId: 'doc_id',
  productName: 'Rice',
  category: 'Grains',
  quantity: 45,
  buyingPrice: 1000,
  sellingPrice: 1500,
);

// Delete product
await productProvider.deleteProduct('doc_id');

// Update quantity only
await productProvider.updateProductQuantity(
  productId: 'doc_id',
  newQuantity: 45,
);
```

### TransactionProvider
```dart
// Get all transactions stream
transactionProvider.getTransactionsStream()

// Get product-specific transactions
transactionProvider.getTransactionsByProduct('productId')

// Add transaction
await transactionProvider.addTransaction(
  productId: 'doc_id',
  transactionType: 'Stock In',
  quantityChanged: 10,
  previousQuantity: 40,
  newQuantity: 50,
);
```

## 🎯 Firestore Query Examples

### Get All Products
```dart
final products = await FirebaseFirestore.instance
    .collection('products')
    .get();
```

### Get Low Stock Products
```dart
final lowStock = await FirebaseFirestore.instance
    .collection('products')
    .where('quantity', isLessThanOrEqualTo: 20)
    .get();
```

### Get Recent Transactions
```dart
final recent = await FirebaseFirestore.instance
    .collection('transactions')
    .orderBy('timestamp', descending: true)
    .limit(10)
    .get();
```

### Get Product Transactions
```dart
final productTxns = await FirebaseFirestore.instance
    .collection('transactions')
    .where('productId', isEqualTo: 'product_id')
    .orderBy('timestamp', descending: true)
    .get();
```

## 🔍 Usage Examples

### In Screens
```dart
// Using with Consumer
Consumer<ProductProvider>(
  builder: (context, productProvider, _) {
    return StreamBuilder<List<Product>>(
      stream: productProvider.getProductsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        final products = snapshot.data ?? [];
        // Build UI
      },
    );
  },
)

// Reading provider
final authProvider = context.read<AuthProvider>();
await authProvider.signIn(email: email, password: password);
```

## 🗑️ Firestore Collections Schema

### Users
```json
{
  "uid": "firebase_user_id",
  "name": "John Doe",
  "email": "john@example.com",
  "role": "staff",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### Products
```json
{
  "productName": "Rice",
  "category": "Grains",
  "quantity": 50,
  "buyingPrice": 1000,
  "sellingPrice": 1500,
  "unit": "bags",
  "imageUrl": "path/to/image",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

### Transactions
```json
{
  "productId": "product_doc_id",
  "transactionType": "Stock In",
  "quantityChanged": 10,
  "previousQuantity": 40,
  "newQuantity": 50,
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## 🛡️ Security Rules Quick Ref

- Users: Can only read/write their own document
- Products: Authenticated users can read/write
- Transactions: Authenticated users can only read
- Default: Deny all unauthorized access

## 🐛 Common Issues & Solutions

### Issue: "Project not initialized"
**Solution**: Ensure Firebase is initialized in main.dart before runApp()

### Issue: "Firestore access denied"
**Solution**: Check Security Rules in Firebase Console and verify user is authenticated

### Issue: "Document not found"
**Solution**: Verify document ID is correct and collection exists in Firestore

### Issue: "User not found"
**Solution**: Ensure email is registered and password is correct

## 📱 Testing Demo Flow

1. **Sign Up**
   - Email: test@inventory.com
   - Password: Test@123
   - Name: Test User

2. **Add Product**
   - Name: Test Product
   - Category: Test
   - Quantity: 100
   - Prices: Any values

3. **Adjust Stock**
   - Select product
   - Choose adjustment type
   - Enter quantity
   - Submit

4. **View Transactions**
   - Check transaction appeared
   - Verify quantity updated

## 🔗 Important Files

| File | Purpose |
|------|---------|
| `lib/firebase/firebase_options.dart` | Firebase config |
| `lib/services/auth_service.dart` | Auth operations |
| `lib/services/firestore_service.dart` | DB operations |
| `lib/providers/auth_provider.dart` | Auth state |
| `lib/providers/product_provider.dart` | Product state |
| `lib/providers/transaction_provider.dart` | Transaction state |
| `firestore.rules` | Security rules |
| `FIREBASE_SETUP.md` | Full setup guide |

## 📞 Support Resources

- [Firebase Docs](https://firebase.google.com/docs)
- [Firestore Guide](https://firebase.google.com/docs/firestore)
- [Firebase Auth](https://firebase.google.com/docs/auth)
- [Flutter Firebase](https://firebase.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)

---

**Version**: 1.0  
**Last Updated**: 2024  
**Status**: Production Ready (after configuration)
