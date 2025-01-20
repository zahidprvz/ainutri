import 'package:ainutri/models/food_log_entry_model.dart';
import 'package:flutter/material.dart';

class RecentMeals extends StatelessWidget {
  final List<FoodLogEntry> recentMeals;

  const RecentMeals({Key? key, required this.recentMeals}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Recent Meals',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (recentMeals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('No meals logged yet.'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics:
                NeverScrollableScrollPhysics(), // To disable scrolling within a SingleChildScrollView
            itemCount: recentMeals.length,
            itemBuilder: (context, index) {
              final meal = recentMeals[index];
              return Card(
                child: ListTile(
                  leading: Icon(Icons.fastfood), // Placeholder for food image
                  title: Text(meal.foodName ?? 'Unknown Food'),
                  subtitle: Text(
                      '${meal.calories?.toStringAsFixed(0) ?? '-'} kcal, ${meal.protein?.toStringAsFixed(0) ?? '-'}g protein'),
                  trailing: IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () {
                      // TODO: Implement adding meal again
                    },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
