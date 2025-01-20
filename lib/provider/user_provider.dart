import 'package:ainutri/models/food_log_entry_model.dart';
import 'package:ainutri/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserData _user = UserData();
  bool _isDataLoaded = false;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  UserData get user => _user;
  bool get isDataLoaded => _isDataLoaded;

  bool get isRegistered {
    return _user.isRegistered ?? false;
  }

  // In-App Purchase related properties
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  bool _isAvailable = false; // Is IAP available on the device
  List<ProductDetails> _products = []; // Available products for purchase
  List<PurchaseDetails> _purchases = []; // User's past purchases
  String?
      _subscriptionStatus; // e.g., 'active', 'expired', 'canceled', 'free_trial'
  bool _purchasePending = false;
  DateTime? _subscriptionExpiryDate;
  String? _couponCode;
  bool _purchaseSuccess = false;
  String? _error;

  // Getters for IAP related properties
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  String? get subscriptionStatus => _subscriptionStatus;
  DateTime? get subscriptionExpiryDate => _subscriptionExpiryDate;

  // Product IDs (replace with your actual product IDs from App Store Connect)
  final Set<String> _productIds = {
    'com.example.ainutri.sub.monthly',
    'com.example.ainutri.sub.yearly',
  };

  UserProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        // Reset data if the user logs out
        _user = UserData();
        _isDataLoaded = false;
        notifyListeners();
      }
    });
    _initialize();
  }

  Future<void> _initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();

    if (_isAvailable) {
      await _getProducts();
      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdate,
        onDone: () {
          _subscription!.cancel();
        },
        onError: (error) {
          // Handle error here
          print('Error during purchase: ${error.toString()}');
        },
      );
      await _loadCouponCode();
    }

    notifyListeners();
  }

  Future<void> _getProducts() async {
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_productIds);
    if (response.error != null) {
      // Handle the error here
      print('Error fetching products: ${response.error}');
    } else {
      _products = response.productDetails;
    }
  }

  Future<void> _loadUserData(String uid) async {
    _isDataLoaded = false;

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        _user = UserData.fromFirestore(data);
      } else {
        // Handle case where user document doesn't exist (maybe a new signup)
        _user = UserData(); // Set default values or handle as needed
      }
    } catch (e) {
      print("Error loading user data: $e");
      // Handle error, maybe set _user to default values or show an error state
    } finally {
      _isDataLoaded = true;
      notifyListeners();
    }
  }

  // Method to update isRegistered after completing onboarding
  Future<void> completeRegistration() async {
    if (_auth.currentUser != null) {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'isRegistered': true});
      // _user.isRegistered = true; // No need to set this here
      notifyListeners();
    }
  }

  // Updated updateUser method with all parameters:
  Future<void> updateUser(BuildContext context,
      {String? goal,
      double? height,
      double? weight,
      DateTime? birthDate,
      double? desiredWeight,
      String? workoutsPerWeek,
      String? gender,
      String? triedCalorieTracking,
      double? gainPerWeek,
      List<String>? reasonsForNotReachingGoals,
      String? diet,
      List<String>? accomplishments,
      double? rating,
      String? username,
      String? photoURL}) async {
    if (_auth.currentUser == null) {
      // Handle the case where the user is not logged in
      return;
    }

    try {
      // Update Firestore document
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        if (goal != null) 'goal': goal,
        if (height != null) 'height': height,
        if (weight != null) 'weight': weight,
        if (birthDate != null) 'birthDate': birthDate,
        if (desiredWeight != null) 'desiredWeight': desiredWeight,
        if (workoutsPerWeek != null) 'workoutsPerWeek': workoutsPerWeek,
        if (gender != null) 'gender': gender,
        if (triedCalorieTracking != null)
          'triedCalorieTracking': triedCalorieTracking,
        if (gainPerWeek != null) 'gainPerWeek': gainPerWeek,
        if (reasonsForNotReachingGoals != null)
          'reasonsForNotReachingGoals': reasonsForNotReachingGoals,
        if (diet != null) 'diet': diet,
        if (accomplishments != null) 'accomplishments': accomplishments,
        if (rating != null) 'rating': rating,
        if (username != null) 'username': username,
        if (photoURL != null) 'photoURL': photoURL,
      });

      // Update local user data
      _user = _user.copyWith(
        goal: goal,
        height: height,
        weight: weight,
        birthDate: birthDate,
        desiredWeight: desiredWeight,
        workoutsPerWeek: workoutsPerWeek,
        gender: gender,
        triedCalorieTracking: triedCalorieTracking,
        gainPerWeek: gainPerWeek,
        reasonsForNotReachingGoals: reasonsForNotReachingGoals,
        diet: diet,
        accomplishments: accomplishments,
        rating: rating,
        username: username,
        photoURL: photoURL,
      );

      notifyListeners();
    } catch (e) {
      print("Error updating user data: $e");
      // Handle error (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update user data: $e")),
      );
    }
  }

  // Add a new method to add a food log entry
  Future<void> addFoodLogEntry(FoodLogEntry entry) async {
    if (_auth.currentUser == null) {
      print("User not logged in.");
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('foodLogs')
          .add(entry.toMap()); // Use the toMap method

      print("Food log entry added successfully");
    } catch (e) {
      print("Error adding food log entry: $e");
      // Handle error (e.g., show a snackbar)
    }
  }

  // Method to fetch food log entries for the current day
  Stream<List<FoodLogEntry>> getFoodLogsForToday() {
    if (_auth.currentUser == null) {
      // Return an empty stream if the user is not logged in
      return Stream.value([]);
    }

    // Get the start and end of the current day
    final now = DateTime.now();
    final startOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final endOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day + 1));

    // Query Firestore for food log entries within the current day
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('foodLogs')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodLogEntry.fromFirestore(doc.data()))
          .toList();
    });
  }

  // Method to calculate total calories consumed for the current day
  Future<double> calculateDailyCalorieTotal() async {
    if (_auth.currentUser == null) {
      return 0.0;
    }

    final now = DateTime.now();
    final startOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final endOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day + 1));

    final snapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('foodLogs')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .get();

    double totalCalories = 0.0;
    for (var doc in snapshot.docs) {
      final entry = FoodLogEntry.fromFirestore(doc.data());
      totalCalories +=
          entry.calories ?? 0.0; // Use null-aware operator with a default value
    }

    return totalCalories;
  }

  // Method to calculate total protein consumed for the current day
  Future<double> calculateDailyProteinTotal() async {
    if (_auth.currentUser == null) {
      return 0.0;
    }

    final now = DateTime.now();
    final startOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final endOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day + 1));

    final snapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('foodLogs')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .get();

    double totalProtein = 0.0;
    for (var doc in snapshot.docs) {
      final entry = FoodLogEntry.fromFirestore(doc.data());
      totalProtein += entry.protein ?? 0.0;
    }

    return totalProtein;
  }

  // Method to calculate total carbs consumed for the current day
  Future<double> calculateDailyCarbsTotal() async {
    if (_auth.currentUser == null) {
      return 0.0;
    }

    final now = DateTime.now();
    final startOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final endOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day + 1));

    final snapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('foodLogs')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .get();

    double totalCarbs = 0.0;
    for (var doc in snapshot.docs) {
      final entry = FoodLogEntry.fromFirestore(doc.data());
      totalCarbs += entry.carbs ?? 0.0;
    }

    return totalCarbs;
  }

  // Method to calculate total fat consumed for the current day
  Future<double> calculateDailyFatTotal() async {
    if (_auth.currentUser == null) {
      return 0.0;
    }

    final now = DateTime.now();
    final startOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    final endOfDay =
        Timestamp.fromDate(DateTime(now.year, now.month, now.day + 1));

    final snapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('foodLogs')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .get();

    double totalFat = 0.0;
    for (var doc in snapshot.docs) {
      final entry = FoodLogEntry.fromFirestore(doc.data());
      totalFat += entry.fat ?? 0.0;
    }

    return totalFat;
  }

  // Method to fetch the coupon code from Firestore
  Future<void> _loadCouponCode() async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('appData').doc('paymentSettings').get();
      if (doc.exists) {
        _couponCode = doc.get('couponCode') ?? '';
      }
    } catch (e) {
      print("Error fetching coupon code: $e");
    }
  }

  // Method to check if a coupon code is valid
  bool isCouponValid(String? code) {
    return code != null && code == _couponCode;
  }

  // Method to apply a coupon code (implement your logic here)
  void applyCoupon(String code) {
    if (isCouponValid(code)) {
      // Apply the discount or enable premium features
      _user = _user.copyWith(
          isPremium: true); // Assuming you have an isPremium field in UserData
      notifyListeners();
    }
  }

  // Method to handle successful purchase
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.purchased) {
      // Verify the purchase (implement your verification logic here)
      bool isValid = await _verifyPurchase(purchaseDetails);

      if (isValid) {
        // Update user's subscription status in Firestore
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({
          'subscriptionStatus': 'active', // Or other relevant status
          'subscriptionExpiryDate': Timestamp.fromDate(DateTime.now()
              .add(Duration(days: 30))), // Example: 30 days for monthly
        });

        // Update local user data
        _user = _user.copyWith(
          subscriptionStatus: 'active',
          subscriptionExpiryDate: DateTime.now().add(Duration(days: 30)),
        );

        _purchaseSuccess = true;
        notifyListeners();
      } else {
        // Handle invalid purchase
        _handleInvalidPurchase(purchaseDetails);
      }
    }
  }

  // Placeholder for purchase verification logic
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // TODO: Implement server-side receipt validation to verify the purchase
    return true; // Assume purchase is valid for now
  }

  // Placeholder for handling invalid purchase
  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    print('Invalid purchase: ${purchaseDetails.productID}');
    // TODO: Handle invalid purchase (e.g., display an error message)
  }

  // Method to handle errors during the purchase process
  void _handleError(IAPError? error) {
    _error = error?.message ?? 'An unknown error occurred.';
    _purchasePending = false;
    notifyListeners();
  }

  // Method to initiate the purchase process
  void buySubscription(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // Method to check if the user has an active subscription
  bool hasActiveSubscription() {
    return _user.subscriptionStatus == 'active' &&
        (_user.subscriptionExpiryDate == null ||
            _user.subscriptionExpiryDate!.isAfter(DateTime.now()));
  }

  // Method to check if the user has used a coupon
  bool hasUsedCoupon() {
    return _user.hasUsedCoupon ?? false;
  }

  // Method to mark that the user has used a coupon
  Future<void> markCouponAsUsed() async {
    if (_auth.currentUser != null) {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'hasUsedCoupon': true,
      });
      _user = _user.copyWith(hasUsedCoupon: true);
      notifyListeners();
    }
  }

  // Exposing a method to get available products
  List<ProductDetails> getAvailableProducts() {
    return _products;
  }

  // Method to check if a purchase is pending
  bool isPurchasePending() {
    return _purchasePending;
  }

  // Method to get any error that occurred during the purchase process
  String? getPurchaseError() {
    return _error;
  }

  // Call this when the user completes the purchase process
  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show a loading indicator or some UI to indicate the purchase is pending
        _purchasePending = true;
        notifyListeners();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            // Handle successful purchase
            await _handlePurchase(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        _purchasePending = false;
        notifyListeners();
      }
    });
  }
}
