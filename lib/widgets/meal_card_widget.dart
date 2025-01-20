import 'package:flutter/material.dart';

class MealCard extends StatelessWidget {
  final String mealType; // e.g., "Breakfast", "Lunch", "Dinner"
  final List<dynamic> meals;

  const MealCard({Key? key, required this.mealType, required this.meals})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              mealType,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: meals.length, // Use the length of the meals list
            itemBuilder: (context, index) {
              final meal = meals[index];
              return _buildMealItem(meal);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMealItem(dynamic meal) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meal['name'] ?? 'Repas',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          ),
          if (meal['description'] != null)
            Text(
              meal['description'],
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          const SizedBox(height: 8), // Add some space between items
        ],
      ),
    );
  }
}
