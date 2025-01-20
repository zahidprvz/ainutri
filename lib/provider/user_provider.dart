import 'package:ainutri/models/food_log_entry_model.dart';
import 'package:ainutri/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserData _user = UserData(); // Initialize with default values
  bool _isDataLoaded = false;

  UserData get user => _user;
  bool get isDataLoaded => _isDataLoaded;

  bool get isRegistered {
    return _user.isRegistered ?? false;
  }

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
      String? photoURL,
      Map<String, dynamic>? mealPlan}) async {
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
        if (mealPlan != null) 'mealPlan': mealPlan,
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
        mealPlan: mealPlan,
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
}
