import 'package:flutter/material.dart';
import 'package:ainutri/app_localizations.dart';

class MotivationTips extends StatelessWidget {
  const MotivationTips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization?.translate('motivation_tips_title') ??
            'Motivation Tips'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TipCard(
            title: localization?.translate("motivation_tip1_title") ??
                "Set Realistic Goals",
            tips: [
              localization?.translate("motivation_tip1_desc1") ??
                  "Start with small, achievable goals and gradually increase the difficulty.",
              localization?.translate("motivation_tip1_desc2") ??
                  "Break down larger goals into smaller, manageable steps.",
            ],
          ),
          TipCard(
            title: localization?.translate("motivation_tip2_title") ??
                "Find Your 'Why'",
            tips: [
              localization?.translate("motivation_tip2_desc1") ??
                  "Identify your deep-seated reasons for wanting to change your eating habits or lose weight.",
              localization?.translate("motivation_tip2_desc2") ??
                  "Connect with your values and how a healthier lifestyle aligns with them.",
            ],
          ),
          TipCard(
            title: localization?.translate("motivation_tip3_title") ??
                "Track Your Progress",
            tips: [
              localization?.translate("motivation_tip3_desc1") ??
                  "Keep a journal or use an app to track your food intake, exercise, and other relevant metrics.",
              localization?.translate("motivation_tip3_desc2") ??
                  "Monitor your progress and celebrate your achievements, no matter how small.",
            ],
          ),
          TipCard(
            title: localization?.translate("motivation_tip4_title") ??
                "Reward Yourself",
            tips: [
              localization?.translate("motivation_tip4_desc1") ??
                  "Set up a system of non-food rewards for reaching milestones or sticking to your plan.",
              localization?.translate("motivation_tip4_desc2") ??
                  "Treat yourself to something you enjoy, like a new book, a relaxing bath, or an activity you love.",
            ],
          ),
          TipCard(
            title: localization?.translate("motivation_tip5_title") ??
                "Find a Support System",
            tips: [
              localization?.translate("motivation_tip5_desc1") ??
                  "Share your goals with friends, family, or a support group.",
              localization?.translate("motivation_tip5_desc2") ??
                  "Surround yourself with people who encourage and motivate you.",
            ],
          ),
          TipCard(
            title: localization?.translate("motivation_tip6_title") ??
                "Visualize Success",
            tips: [
              localization?.translate("motivation_tip6_desc1") ??
                  "Regularly imagine yourself achieving your goals and enjoying the benefits of a healthier lifestyle.",
              localization?.translate("motivation_tip6_desc2") ??
                  "Create a vision board or use affirmations to reinforce your motivation.",
            ],
          ),
        ],
      ),
    );
  }
}

// Same TipCard widget as before
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
