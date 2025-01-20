import 'package:flutter/material.dart';
import 'package:ainutri/app_localizations.dart';

class SupportTips extends StatelessWidget {
  const SupportTips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            localization?.translate('support_tips_title') ?? 'Support Tips'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TipCard(
            title: localization?.translate("support_tip1_title") ??
                "Talk to Friends and Family",
            tips: [
              localization?.translate("support_tip1_desc1") ??
                  "Share your goals and challenges with people you trust.",
              localization?.translate("support_tip1_desc2") ??
                  "Ask for their encouragement and understanding.",
            ],
          ),
          TipCard(
            title: localization?.translate("support_tip2_title") ??
                "Join a Support Group",
            tips: [
              localization?.translate("support_tip2_desc1") ??
                  "Connect with others who are facing similar challenges.",
              localization?.translate("support_tip2_desc2") ??
                  "Share experiences, tips, and encouragement in a group setting.",
            ],
          ),
          TipCard(
            title: localization?.translate("support_tip3_title") ??
                "Find an Accountability Partner",
            tips: [
              localization?.translate("support_tip3_desc1") ??
                  "Pair up with someone who has similar goals.",
              localization?.translate("support_tip3_desc2") ??
                  "Check in with each other regularly to stay on track and motivated.",
            ],
          ),
          TipCard(
            title: localization?.translate("support_tip4_title") ??
                "Seek Professional Help",
            tips: [
              localization?.translate("support_tip4_desc1") ??
                  "Consider talking to a therapist, counselor, or registered dietitian.",
              localization?.translate("support_tip4_desc2") ??
                  "They can provide personalized guidance and support.",
            ],
          ),
          TipCard(
            title: localization?.translate("support_tip5_title") ??
                "Use Online Communities",
            tips: [
              localization?.translate("support_tip5_desc1") ??
                  "Join online forums or social media groups related to healthy eating and weight management.",
              localization?.translate("support_tip5_desc2") ??
                  "Share your experiences and learn from others.",
            ],
          ),
          TipCard(
            title: localization?.translate("support_tip6_title") ??
                "Celebrate Your Successes",
            tips: [
              localization?.translate("support_tip6_desc1") ??
                  "Acknowledge and celebrate your achievements, no matter how small.",
              localization?.translate("support_tip6_desc2") ??
                  "Share your successes with your support network to reinforce positive behaviors.",
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
