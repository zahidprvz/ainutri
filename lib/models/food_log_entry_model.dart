import 'package:cloud_firestore/cloud_firestore.dart';

class FoodLogEntry {
  final String? foodName;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? calories;
  final Timestamp timestamp;

  FoodLogEntry({
    required this.foodName,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.calories,
    required this.timestamp,
  });

  // Convert a FoodLogEntry object into a Map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'foodName': foodName,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'calories': calories,
      'timestamp': timestamp,
    };
  }

  // Create a FoodLogEntry object from Firestore data
  factory FoodLogEntry.fromFirestore(Map<String, dynamic> data) {
    return FoodLogEntry(
      foodName: data['foodName'],
      protein: data['protein']?.toDouble(),
      carbs: data['carbs']?.toDouble(),
      fat: data['fat']?.toDouble(),
      calories: data['calories']?.toDouble(),
      timestamp: data['timestamp'],
    );
  }
}
