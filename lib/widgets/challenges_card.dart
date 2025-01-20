import 'package:flutter/material.dart';

class ChallengesCard extends StatefulWidget {
  const ChallengesCard({Key? key}) : super(key: key);

  @override
  _ChallengesCardState createState() => _ChallengesCardState();
}

class _ChallengesCardState extends State<ChallengesCard> {
  // Sample data for challenges - replace with your actual data
  // and route names for each challenge screen
  final List<Map<String, dynamic>> _challenges = [
    {
      'title': "Perte de poids", // Directly in French
      'icon': Icons.trending_down,
      'routeName': '/weight_loss_tips' // Replace with your actual route
    },
    {
      'title': "Manger émotionnel", // Directly in French
      'icon': Icons.sentiment_very_dissatisfied,
      'routeName': '/emotional_eating_tips' // Replace with your actual route
    },
    {
      'title': "Manque de temps", // Directly in French
      'icon': Icons.schedule,
      'routeName': '/time_management_tips' // Replace with your actual route
    },
    {
      'title': "Motivation", // Directly in French
      'icon': Icons.whatshot,
      'routeName': '/motivation_tips' // Replace with your actual route
    },
    {
      'title': "Envies", // Directly in French
      'icon': Icons.fastfood,
      'routeName': '/cravings_tips' // Replace with your actual route
    },
    {
      'title': "Manque de soutien", // Directly in French
      'icon': Icons.people,
      'routeName': '/support_tips' // Replace with your actual route
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor,
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Rencontrez-vous des défis ?",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Sélectionnez ci-dessous pour des conseils et un accompagnement personnalisé.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 1.0,
              ),
              itemCount: _challenges.length,
              itemBuilder: (context, index) {
                final challenge = _challenges[index];
                return _buildChallengeItem(
                  context: context,
                  title: challenge['title'],
                  icon: challenge['icon'],
                  routeName: challenge['routeName'],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeItem(
      {required BuildContext context,
      required String title,
      required IconData icon,
      String? routeName}) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(10.0),
      child: InkWell(
        onTap: routeName != null
            ? () {
                Navigator.pushNamed(context, routeName);
              }
            : null, // Disable tap if no routeName is provided
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
