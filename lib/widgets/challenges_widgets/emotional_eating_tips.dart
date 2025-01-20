import 'package:flutter/material.dart';
import 'package:ainutri/app_localizations.dart';

class EmotionalEatingTips extends StatelessWidget {
  const EmotionalEatingTips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization?.translate('emotional_eating_tips_title') ??
            'Emotional Eating Tips'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TipCard(
            title: localization?.translate("emotional_eating_tip1_title") ??
                "Identify Your Triggers",
            tips: [
              localization?.translate("emotional_eating_tip1_desc1") ??
                  "Recognize the emotions, situations, or people that lead you to emotional eating.",
              localization?.translate("emotional_eating_tip1_desc2") ??
                  "Keep a food and mood journal to track patterns.",
            ],
          ),
          TipCard(
            title: localization?.translate("emotional_eating_tip2_title") ??
                "Find Healthy Coping Mechanisms",
            tips: [
              localization?.translate("emotional_eating_tip2_desc1") ??
                  "Engage in activities that help you manage stress, such as exercise, meditation, or spending time with loved ones.",
              localization?.translate("emotional_eating_tip2_desc2") ??
                  "Practice mindful eating and savor each bite.",
            ],
          ),
          TipCard(
            title: localization?.translate("emotional_eating_tip3_title") ??
                "Distinguish Between Physical and Emotional Hunger",
            tips: [
              localization?.translate("emotional_eating_tip3_desc1") ??
                  "Physical hunger builds gradually, while emotional hunger is often sudden and specific.",
              localization?.translate("emotional_eating_tip3_desc2") ??
                  "Ask yourself if you would eat a healthy, less appealing food (like an apple) if you were truly hungry.",
            ],
          ),
          TipCard(
            title: localization?.translate("emotional_eating_tip4_title") ??
                "Delay and Distract",
            tips: [
              localization?.translate("emotional_eating_tip4_desc1") ??
                  "When you feel the urge to eat emotionally, try to delay for 15-20 minutes.",
              localization?.translate("emotional_eating_tip4_desc2") ??
                  "Engage in a distracting activity during that time, like reading, taking a walk, or calling a friend.",
            ],
          ),
          TipCard(
            title: localization?.translate("emotional_eating_tip5_title") ??
                "Remove Temptations",
            tips: [
              localization?.translate("emotional_eating_tip5_desc1") ??
                  "Keep unhealthy trigger foods out of your home.",
              localization?.translate("emotional_eating_tip5_desc2") ??
                  "Stock your kitchen with nutritious snacks that you can reach for instead.",
            ],
          ),
          TipCard(
            title: localization?.translate("emotional_eating_tip6_title") ??
                "Seek Professional Help",
            tips: [
              localization?.translate("emotional_eating_tip6_desc1") ??
                  "If emotional eating is significantly impacting your life, consider talking to a therapist or counselor.",
              localization?.translate("emotional_eating_tip6_desc2") ??
                  "A registered dietitian can also help you develop a healthier relationship with food.",
            ],
          ),
        ],
      ),
    );
  }
}

// TipCard Widget (Same as in weight_loss_tips.dart)
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
