import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String? username;
  final String? uid;
  final String? email;
  final bool? isRegistered;
  final String? goal;
  final double? height;
  final double? weight;
  final DateTime? birthDate;
  final double? desiredWeight;
  final String? workoutsPerWeek;
  final String? gender;
  final String? triedCalorieTracking;
  final double? gainPerWeek;
  final List<String>? reasonsForNotReachingGoals;
  final String? diet;
  final List<String>? accomplishments;
  final double? rating;
  final String? photoURL;
  final Map<String, dynamic>? mealPlan;
  final String? subscriptionStatus;
  final DateTime? subscriptionExpiryDate;
  final bool? hasUsedCoupon;
  final bool? isPremium;

  UserData({
    this.username,
    this.uid,
    this.email,
    this.isRegistered = false,
    this.goal,
    this.height,
    this.weight,
    this.birthDate,
    this.desiredWeight,
    this.workoutsPerWeek,
    this.gender,
    this.triedCalorieTracking,
    this.gainPerWeek,
    this.reasonsForNotReachingGoals,
    this.diet,
    this.accomplishments,
    this.rating,
    this.photoURL,
    this.mealPlan,
    this.subscriptionStatus,
    this.subscriptionExpiryDate,
    this.hasUsedCoupon = false,
    this.isPremium = false,
  });

  // Create a UserData object from Firestore data
  factory UserData.fromFirestore(Map<String, dynamic> data) {
    return UserData(
      username: data['username'],
      uid: data['uid'],
      email: data['email'],
      isRegistered: data['isRegistered'] ?? false,
      goal: data['goal'],
      height: data['height']?.toDouble(),
      weight: data['weight']?.toDouble(),
      birthDate: data['birthDate']?.toDate(),
      desiredWeight: data['desiredWeight']?.toDouble(),
      workoutsPerWeek: data['workoutsPerWeek'],
      gender: data['gender'],
      triedCalorieTracking: data['triedCalorieTracking'],
      gainPerWeek: data['gainPerWeek']?.toDouble(),
      reasonsForNotReachingGoals: data['reasonsForNotReachingGoals'] is Iterable
          ? List<String>.from(data['reasonsForNotReachingGoals'])
          : null,
      diet: data['diet'],
      accomplishments: data['accomplishments'] is Iterable
          ? List<String>.from(data['accomplishments'])
          : null,
      rating: data['rating']?.toDouble(),
      photoURL: data['photoURL'],
      mealPlan: data['mealPlan'],
      subscriptionStatus: data['subscriptionStatus'],
      subscriptionExpiryDate: data['subscriptionExpiryDate']?.toDate(),
      hasUsedCoupon: data['hasUsedCoupon'] ?? false,
      isPremium: data['isPremium'] ?? false,
    );
  }

  UserData copyWith({
    String? goal,
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
    bool? isRegistered,
    Map<String, dynamic>? mealPlan,
    String? subscriptionStatus,
    DateTime? subscriptionExpiryDate,
    bool? hasUsedCoupon,
    bool? isPremium,
  }) {
    return UserData(
      username: username ?? this.username,
      uid: uid,
      email: email,
      isRegistered: isRegistered ?? this.isRegistered,
      goal: goal ?? this.goal,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      birthDate: birthDate ?? this.birthDate,
      desiredWeight: desiredWeight ?? this.desiredWeight,
      workoutsPerWeek: workoutsPerWeek ?? this.workoutsPerWeek,
      gender: gender ?? this.gender,
      triedCalorieTracking: triedCalorieTracking ?? this.triedCalorieTracking,
      gainPerWeek: gainPerWeek ?? this.gainPerWeek,
      reasonsForNotReachingGoals:
          reasonsForNotReachingGoals ?? this.reasonsForNotReachingGoals,
      diet: diet ?? this.diet,
      accomplishments: accomplishments ?? this.accomplishments,
      rating: rating ?? this.rating,
      photoURL: photoURL ?? this.photoURL,
      mealPlan: mealPlan ?? this.mealPlan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiryDate:
          subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      hasUsedCoupon: hasUsedCoupon ?? this.hasUsedCoupon,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
