import 'package:flutter/material.dart';
import 'package:ainutri/app_localizations.dart';

class WeightLossTips extends StatelessWidget {
  const WeightLossTips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization?.translate('weight_loss_tips_title') ??
            'Weight Loss Tips'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TipCard(
            title: localization?.translate("weight_loss_tip1_title") ??
                "Set Realistic Goals",
            tips: [
              localization?.translate("weight_loss_tip1_desc1") ??
                  "Aim for gradual, sustainable weight loss.",
              localization?.translate("weight_loss_tip1_desc2") ??
                  "Focus on long-term lifestyle changes.",
            ],
          ),
          TipCard(
            title: localization?.translate("weight_loss_tip2_title") ??
                "Eat Mindfully",
            tips: [
              localization?.translate("weight_loss_tip2_desc1") ??
                  "Pay attention to your body's hunger and fullness cues.",
              localization?.translate("weight_loss_tip2_desc2") ??
                  "Avoid distractions while eating, such as watching TV or using your phone.",
            ],
          ),
          TipCard(
            title: localization?.translate("weight_loss_tip3_title") ??
                "Choose Whole Foods",
            tips: [
              localization?.translate("weight_loss_tip3_desc1") ??
                  "Focus on whole, unprocessed foods like fruits, vegetables, whole grains, and lean proteins.",
              localization?.translate("weight_loss_tip3_desc2") ??
                  "Limit processed foods, sugary drinks, and excessive saturated and unhealthy fats.",
            ],
          ),
          TipCard(
            title: localization?.translate("weight_loss_tip4_title") ??
                "Control Portion Sizes",
            tips: [
              localization?.translate("weight_loss_tip4_desc1") ??
                  "Be mindful of portion sizes to manage calorie intake.",
              localization?.translate("weight_loss_tip4_desc2") ??
                  "Use smaller plates and bowls to help control portions.",
            ],
          ),
          TipCard(
            title: localization?.translate("weight_loss_tip5_title") ??
                "Stay Hydrated",
            tips: [
              localization?.translate("weight_loss_tip5_desc1") ??
                  "Drink plenty of water throughout the day.",
              localization?.translate("weight_loss_tip5_desc2") ??
                  "Sometimes thirst can be mistaken for hunger.",
            ],
          ),
          TipCard(
            title: localization?.translate("weight_loss_tip6_title") ??
                "Increase Physical Activity",
            tips: [
              localization?.translate("weight_loss_tip6_desc1") ??
                  "Incorporate regular exercise into your routine.",
              localization?.translate("weight_loss_tip6_desc2") ??
                  "Find activities you enjoy to make it easier to stick with them.",
            ],
          ),
          TipCard(
            title: localization?.translate("weight_loss_tip7_title") ??
                "Get Enough Sleep",
            tips: [
              localization?.translate("weight_loss_tip7_desc1") ??
                  "Aim for 7-9 hours of quality sleep per night.",
              localization?.translate("weight_loss_tip7_desc2") ??
                  "Lack of sleep can affect hormones that regulate appetite and metabolism.",
            ],
          ),
          TipCard(
            title: localization?.translate("weight_loss_tip8_title") ??
                "Manage Stress",
            tips: [
              localization?.translate("weight_loss_tip8_desc1") ??
                  "Practice stress-reduction techniques like yoga, meditation, or deep breathing.",
              localization?.translate("weight_loss_tip8_desc2") ??
                  "Chronic stress can lead to unhealthy eating habits.",
            ],
          ),
          TipCard(
            title: localization?.translate("weight_loss_tip9_title") ??
                "Seek Support",
            tips: [
              localization?.translate("weight_loss_tip9_desc1") ??
                  "Talk to friends, family, or a healthcare professional about your weight loss goals.",
              localization?.translate("weight_loss_tip9_desc2") ??
                  "Consider joining a support group or working with a registered dietitian or nutritionist.",
            ],
          ),
        ],
      ),
    );
  }
}

// TipCard Widget (You can customize this further)
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
