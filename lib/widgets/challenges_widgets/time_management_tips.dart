import 'package:flutter/material.dart';
import 'package:ainutri/app_localizations.dart';

class TimeManagementTips extends StatelessWidget {
  const TimeManagementTips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization?.translate('time_management_tips_title') ??
            'Time Management Tips'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TipCard(
            title: localization?.translate("time_management_tip1_title") ??
                "Plan Ahead",
            tips: [
              localization?.translate("time_management_tip1_desc1") ??
                  "Create a meal plan for the week to save time on grocery shopping and meal prep.",
              localization?.translate("time_management_tip1_desc2") ??
                  "Prepare ingredients in advance, such as chopping vegetables or marinating meat.",
            ],
          ),
          TipCard(
            title: localization?.translate("time_management_tip2_title") ??
                "Cook Once, Eat Twice (or More!)",
            tips: [
              localization?.translate("time_management_tip2_desc1") ??
                  "Double or triple recipes and freeze leftovers for quick meals on busy days.",
              localization?.translate("time_management_tip2_desc2") ??
                  "Use leftovers creatively in new dishes.",
            ],
          ),
          TipCard(
            title: localization?.translate("time_management_tip3_title") ??
                "Embrace One-Pan/Pot Meals",
            tips: [
              localization?.translate("time_management_tip3_desc1") ??
                  "Simplify cooking and cleanup by using one-pan or one-pot recipes.",
              localization?.translate("time_management_tip3_desc2") ??
                  "Sheet pan dinners, stir-fries, and slow cooker meals are great options.",
            ],
          ),
          TipCard(
            title: localization?.translate("time_management_tip4_title") ??
                "Utilize Kitchen Gadgets",
            tips: [
              localization?.translate("time_management_tip4_desc1") ??
                  "Use a slow cooker or pressure cooker to reduce cooking time.",
              localization?.translate("time_management_tip4_desc2") ??
                  "Invest in a food processor to speed up chopping and prepping.",
            ],
          ),
          TipCard(
            title: localization?.translate("time_management_tip5_title") ??
                "Stock Your Pantry and Freezer",
            tips: [
              localization?.translate("time_management_tip5_desc1") ??
                  "Keep healthy staples on hand for quick and easy meals.",
              localization?.translate("time_management_tip5_desc2") ??
                  "Frozen fruits, vegetables, and pre-cooked grains can be lifesavers.",
            ],
          ),
          TipCard(
            title: localization?.translate("time_management_tip6_title") ??
                "Don't Be Afraid of Shortcuts",
            tips: [
              localization?.translate("time_management_tip6_desc1") ??
                  "Use pre-cut vegetables, rotisserie chicken, or other convenience items to save time.",
              localization?.translate("time_management_tip6_desc2") ??
                  "Embrace healthy pre-packaged meals or meal delivery services when needed.",
            ],
          ),
        ],
      ),
    );
  }
}

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
