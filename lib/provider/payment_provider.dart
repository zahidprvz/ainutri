import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentProvider with ChangeNotifier {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _purchaseSuccess = false;
  String? _error;

  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];

  // Product IDs (from App Store Connect)
  final Set<String> _productIds = {
    'com.example.ainutri.sub.monthly', // Replace with your actual IDs
    'com.example.ainutri.sub.yearly',
  };

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Coupon code (fetch from Firestore)
  String _couponCode = '';

  bool get isAvailable => _isAvailable;
  bool get purchasePending => _purchasePending;
  bool get purchaseSuccess => _purchaseSuccess;
  String? get error => _error;
  List<ProductDetails> get products => _products;

  PaymentProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();

    if (_isAvailable) {
      await _getProducts();
      await _fetchCouponCode();
      _verifyPastPurchases(); // Verify any previous purchases

      // Set up a listener for purchase updates
      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdate,
        onDone: () {
          _subscription.cancel();
        },
        onError: (error) {
          _handleError(error);
        },
      );
    } else {
      // Handle the case where In-App Purchases are not available
      print('In-App Purchases are not available on this device.');
    }
  }

  // Fetch the coupon code from Firestore
  Future<void> _fetchCouponCode() async {
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

  // Public method to allow UI to apply the coupon code
  void applyCouponCode(String code) {
    if (code == _couponCode) {
      // Handle valid coupon code (e.g., apply a discount)
      print("Valid coupon code applied!");
    } else {
      // Handle invalid coupon code
      print("Invalid coupon code.");
    }
    notifyListeners(); // Notify UI about the change
  }

  Future<void> _getProducts() async {
    ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_productIds);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the case where some product IDs are not found
      print("Some product IDs were not found: ${response.notFoundIDs}");
    }
    _products = response.productDetails;
  }

  void _verifyPastPurchases() {
    // TODO: Implement logic to check for past purchases and restore them
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _purchasePending = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _handleError(purchaseDetails.error);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            _purchaseSuccess = true;
          } else {
            _handleInvalidPurchase(purchaseDetails);
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        _purchasePending = false;
      }
      notifyListeners();
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // TODO: Implement server-side receipt validation to verify the purchase
    return true; // Return true if the purchase is valid
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // TODO: Handle invalid purchase
    print('Invalid purchase: ${purchaseDetails.productID}');
  }

  void _handleError(IAPError? error) {
    _error = error?.message ?? 'An unknown error occurred.';
    _purchasePending = false;
    notifyListeners();
  }

  void buySubscription(ProductDetails product) {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
