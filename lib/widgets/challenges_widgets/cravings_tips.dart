import 'package:flutter/material.dart';
import 'package:ainutri/app_localizations.dart';

class CravingsTips extends StatelessWidget {
  const CravingsTips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            localization?.translate('cravings_tips_title') ?? 'Cravings Tips'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TipCard(
            title: localization?.translate("cravings_tip1_title") ??
                "Understand Your Cravings",
            tips: [
              localization?.translate("cravings_tip1_desc1") ??
                  "Identify whether your craving is due to physical hunger, emotional needs, or habit.",
              localization?.translate("cravings_tip1_desc2") ??
                  "Keep a journal to track when and why cravings occur.",
            ],
          ),
          TipCard(
            title: localization?.translate("cravings_tip2_title") ??
                "Delay and Distract",
            tips: [
              localization?.translate("cravings_tip2_desc1") ??
                  "When a craving hits, try to wait it out for 15-20 minutes.",
              localization?.translate("cravings_tip2_desc2") ??
                  "Engage in a distracting activity like going for a walk, reading, or calling a friend.",
            ],
          ),
          TipCard(
            title: localization?.translate("cravings_tip3_title") ??
                "Stay Hydrated",
            tips: [
              localization?.translate("cravings_tip3_desc1") ??
                  "Sometimes thirst can be mistaken for a craving.",
              localization?.translate("cravings_tip3_desc2") ??
                  "Drink a glass of water and wait a few minutes to see if the craving subsides.",
            ],
          ),
          TipCard(
            title: localization?.translate("cravings_tip4_title") ??
                "Choose Healthy Alternatives",
            tips: [
              localization?.translate("cravings_tip4_desc1") ??
                  "If you're craving something sweet, try a piece of fruit or a small square of dark chocolate.",
              localization?.translate("cravings_tip4_desc2") ??
                  "If you're craving something salty, opt for a handful of nuts or air-popped popcorn.",
            ],
          ),
          TipCard(
            title: localization?.translate("cravings_tip5_title") ??
                "Don't Deprive Yourself Completely",
            tips: [
              localization?.translate("cravings_tip5_desc1") ??
                  "Allow yourself small, planned indulgences occasionally.",
              localization?.translate("cravings_tip5_desc2") ??
                  "Completely restricting your favorite foods can lead to stronger cravings and potential binges.",
            ],
          ),
          TipCard(
            title: localization?.translate("cravings_tip6_title") ??
                "Manage Stress",
            tips: [
              localization?.translate("cravings_tip6_desc1") ??
                  "Stress can be a major trigger for cravings.",
              localization?.translate("cravings_tip6_desc2") ??
                  "Practice stress-reducing techniques like exercise, meditation, or deep breathing.",
            ],
          ),
        ],
      ),
    );
  }
}

// TipCard Widget (Same as in previous examples)
class TipCard extends StatelessWidget {
  final String title;
  final List<String> tips;

  const TipCard({Key? key, required this.title, required this.tips})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...tips
                .map((tip) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text("• $tip"),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}
