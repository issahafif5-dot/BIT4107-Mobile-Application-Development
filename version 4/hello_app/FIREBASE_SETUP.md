# Firebase Integration Guide

## Project Overview
This Inventory Management App has been successfully integrated with Firebase for:
- **Authentication** (Firebase Auth)
- **Database** (Cloud Firestore)
- **Real-time Updates** (Firestore Streams)

## Setup Instructions

### 1. Firebase Project Setup

#### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: "Section Two Supermarket"
4. Follow the setup wizard
5. Enable Google Analytics (optional)

#### Step 2: Enable Firebase Services
1. **Authentication**
   - Go to "Authentication" in left sidebar
   - Click "Get started"
   - Enable "Email/Password" provider
   - Optional: Enable other providers (Google, Facebook, etc.)

2. **Cloud Firestore**
   - Go to "Firestore Database" in left sidebar
   - Click "Create database"
   - Choose "Start in test mode" for development
   - Select region closest to you
   - Click "Create"

3. **Apply Security Rules**
   - Go to "Firestore" > "Rules" tab
   - Replace with content from `firestore.rules`
   - Click "Publish"

### 2. Configure Firebase for Android

#### Step 1: Register Android App
1. In Firebase Console, click the Android icon
2. Enter package name: `com.example.section_two_supermarket`
3. Enter app nickname (optional)
4. Download `google-services.json`
5. Place it in `android/app/` directory

#### Step 2: Update Android Files
1. **android/build.gradle** (Project level)
   ```gradle
   buildscript {
     dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
     }
   }
   ```

2. **android/app/build.gradle** (App level)
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

### 3. Update Firebase Options

Edit `lib/firebase/firebase_options.dart`:
1. Go to Firebase Console > Project Settings
2. Copy your project credentials:
   - API Key
   - Project ID
   - App ID
   - Messaging Sender ID
   - Auth Domain
   - Storage Bucket
   - Measurement ID

3. Replace placeholder values in firebase_options.dart with your actual credentials

### 4. Install Dependencies

Run:
```bash
flutter pub get
```

### 5. Initialize Firestore Collections

In Firebase Console > Firestore, create collections with sample data:

#### Users Collection
```
Collection: users
Document: {user_id}
Fields:
  - uid: string
  - name: string
  - email: string
  - role: string (default: "staff")
  - createdAt: timestamp
```

#### Products Collection
```
Collection: products
Document: {product_id}
Fields:
  - productName: string
  - category: string
  - quantity: integer
  - buyingPrice: number
  - sellingPrice: number
  - unit: string
  - imageUrl: string
  - createdAt: timestamp
  - updatedAt: timestamp
```

#### Transactions Collection
```
Collection: transactions
Document: {transaction_id}
Fields:
  - productId: string (reference to products)
  - transactionType: string ("Stock In", "Stock Out", "Adjustment")
  - quantityChanged: integer
  - previousQuantity: integer
  - newQuantity: integer
  - timestamp: timestamp
```

## Architecture

### Services Layer
- **auth_service.dart** - Firebase Authentication operations
- **firestore_service.dart** - Firestore database operations

### Providers Layer (State Management)
- **auth_provider.dart** - Authentication state & logic
- **product_provider.dart** - Product operations & state
- **transaction_provider.dart** - Transaction operations & state

### Updated Screens
All screens are now using Firestore Streams for real-time data:
- **LoginScreen** - Firebase email/password authentication
- **DashboardScreen** - Real-time inventory summary
- **ProductsScreen** - Real-time product list with search
- **TransactionsScreen** - Real-time transaction history
- **AdjustStockScreen** - Stock adjustment with auto transaction recording

## Features

### Authentication
- Email/Password Sign Up
- Email/Password Sign In
- Sign Out
- Password Reset
- Automatic user data sync

### Inventory Management
- Real-time product updates
- Add/Edit/Delete products
- Search products by name
- Filter products by category
- Stock level monitoring

### Transactions
- Real-time transaction recording
- Automatic transaction creation on stock changes
- Filter by transaction type
- Transaction history with timestamps

### Dashboard
- Total products count
- Total inventory quantity
- Low stock alerts
- Recent transactions view

## Firestore Security Rules

The app uses Firestore Security Rules located in `firestore.rules`:

- Users can only access their own document
- Authenticated users can read products
- Authenticated users can create/update products
- Transactions are read-only (write via cloud functions)
- Deny all other access by default

## Demo Credentials

For testing, create a test account in Firebase Console:
- Email: `demo@inventory.com`
- Password: `Demo@123` (must be at least 6 characters)

## Testing Checklist

- [ ] Create a Firebase project
- [ ] Enable Authentication (Email/Password)
- [ ] Enable Firestore Database
- [ ] Apply Security Rules
- [ ] Register Android app and add google-services.json
- [ ] Update firebase_options.dart with your credentials
- [ ] Run `flutter pub get`
- [ ] Build and test the app
- [ ] Test sign up functionality
- [ ] Test sign in functionality
- [ ] Test product management (add/edit/delete)
- [ ] Test stock adjustment
- [ ] Verify real-time updates

## Troubleshooting

### Firebase Connection Issues
- Ensure google-services.json is in correct location
- Verify firebase_options.dart credentials are correct
- Check internet connection
- Verify Firestore rules allow operations

### Authentication Failures
- Ensure email format is valid
- Password must be at least 6 characters
- Check email isn't already registered
- Verify Firebase Auth is enabled

### Firestore Access Denied
- Check Security Rules are properly set
- Verify user is authenticated
- Check collection/document permissions
- Review Firestore logs in Firebase Console

## Next Steps

1. Customize Firestore rules for production
2. Add custom claims for admin users
3. Implement cloud functions for complex operations
4. Set up automated backups
5. Configure monitoring and analytics
6. Add user roles and permissions system

## Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Flutter Firebase Plugin](https://firebase.flutter.dev/)

---

**Integration completed successfully!** All existing UI, navigation, and functionality have been preserved while adding Firebase backend capabilities.
