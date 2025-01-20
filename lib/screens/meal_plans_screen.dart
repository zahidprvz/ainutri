import 'dart:convert';
import 'package:ainutri/models/user.dart';
import 'package:ainutri/widgets/meal_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../app_localizations.dart';
import '../provider/user_provider.dart';
import '../widgets/custom_app_bar.dart';

class MealPlansScreen extends StatefulWidget {
  const MealPlansScreen({Key? key}) : super(key: key);

  @override
  _MealPlansScreenState createState() => _MealPlansScreenState();
}

class _MealPlansScreenState extends State<MealPlansScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _mealPlan;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchOrGenerateMealPlan();
  }

  Future<void> _fetchOrGenerateMealPlan() async {
    setState(() {
      _isLoading = true;
    });

    if (_auth.currentUser == null) {
      setState(() {
        _isLoading = false;
        _mealPlan = {'error': 'Utilisateur non connecté.'};
      });
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isRegistered) {
      setState(() {
        _isLoading = false;
        _mealPlan = {
          'error': "L'utilisateur n'a pas complété son inscription."
        };
      });
      return;
    }

    try {
      final userDocRef =
          _firestore.collection('users').doc(_auth.currentUser!.uid);
      final userDoc = await userDocRef.get();

      if (userDoc.exists && userDoc.data()!.containsKey('mealPlan')) {
        setState(() {
          _mealPlan = userDoc.data()!['mealPlan'];
        });
      } else {
        await _generateMealPlan(userProvider.user);
      }
    } catch (e) {
      setState(() {
        _mealPlan = {
          'error':
              'Erreur lors de la récupération ou de la génération du plan de repas: $e'
        };
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateMealPlan(UserData user) async {
    setState(() {
      _isLoading = true;
      _mealPlan = null; // Clear previous meal plan data
    });

    const apiKey =
        'AIzaSyD6KwygU1v79sfLxmrzscgxE3_54rS5stw'; // Replace with your actual API key
    const apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

    try {
      final prompt = _buildPrompt(user, context);

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("API Response: ${response.body}");

        // Extract the text response
        if (responseData['candidates'] != null &&
            responseData['candidates'].isNotEmpty) {
          final textResponse = responseData['candidates'][0]['content']['parts']
              [0]['text'] as String;

          // Find JSON string within `json ... ` (or however it's formatted)
          final regex = RegExp(r"`json(.*?)`", dotAll: true);
          final match = regex.firstMatch(textResponse);

          if (match != null) {
            final jsonString = match.group(1)!.trim();
            print("Extracted JSON: $jsonString");

            try {
              final mealPlanData = jsonDecode(jsonString);
              if (mealPlanData is Map<String, dynamic>) {
                // Save the meal plan to Firestore
                await _firestore
                    .collection('users')
                    .doc(_auth.currentUser!.uid)
                    .update({'mealPlan': mealPlanData});

                setState(() {
                  _mealPlan = mealPlanData;
                });
              } else {
                throw Exception('Invalid meal plan data format');
              }
            } catch (e) {
              print("Error decoding JSON: $e");
              setState(() {
                _mealPlan = {
                  'error': 'Erreur lors du décodage du plan de repas: $e'
                };
              });
            }
          } else {
            setState(() {
              _mealPlan = {
                'error': 'Could not find valid JSON meal plan data in response.'
              };
            });
          }
        } else {
          setState(() {
            _mealPlan = {'error': 'No candidates found in response.'};
          });
        }
      } else {
        print(
            "Error response from API: ${response.statusCode} - ${response.body}");
        setState(() {
          _mealPlan = {
            'error': 'Failed to generate meal plan: ${response.statusCode}'
          };
        });
      }
    } catch (e) {
      print("Error generating meal plan: $e");
      setState(() {
        _mealPlan = {'error': 'An error occurred: $e'};
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildPrompt(UserData user, BuildContext context) {
    var localization = AppLocalizations.of(context);

    return '''
    ${localization?.translate("create_meal_plan_intro") ?? "Créez un plan de repas quotidien en fonction des informations suivantes sur l'utilisateur :"}
    - ${localization?.translate("name") ?? "Nom"}: ${user.username ?? 'N/A'}
    - ${localization?.translate("gender") ?? "Sexe"}: ${user.gender ?? 'N/A'}
    - ${localization?.translate("age") ?? "Âge"}: ${DateTime.now().year - (user.birthDate?.year ?? DateTime.now().year)}
    - ${localization?.translate("height") ?? "Taille"}: ${user.height ?? 'N/A'} cm
    - ${localization?.translate("weight") ?? "Poids"}: ${user.weight ?? 'N/A'} kg
    - ${localization?.translate("goal") ?? "Objectif"}: ${user.goal ?? 'N/A'}
    - ${localization?.translate("workouts_per_week") ?? "Fréquence d'entraînement"}: ${user.workoutsPerWeek ?? 'N/A'}
    - ${localization?.translate("dietary_preference") ?? "Préférence alimentaire"}: ${user.diet ?? 'N/A'}
    - ${localization?.translate("desired_weight_gain_per_week") ?? "Gain de poids souhaité par semaine"}: ${user.gainPerWeek ?? 'N/A'}
    - ${localization?.translate("reasons_for_not_reaching_goals") ?? "Raisons de non atteinte des objectifs"}: ${user.reasonsForNotReachingGoals?.join(', ') ?? 'N/A'}
    - ${localization?.translate("objectives") ?? "Objectifs"}: ${user.accomplishments?.join(', ') ?? 'N/A'}
    - ${localization?.translate("tried_calorie_tracking") ?? "A déjà essayé le suivi des calories"}: ${user.triedCalorieTracking ?? 'N/A'}

    ${localization?.translate("meal_plan_instructions") ?? "Fournissez un plan de repas détaillé pour une journée, en français, qui comprend :"}
    - ${localization?.translate("breakfast") ?? "Petit-déjeuner"}
    - ${localization?.translate("lunch") ?? "Déjeuner"}
    - ${localization?.translate("dinner") ?? "Dîner"}
    - ${localization?.translate("snacks") ?? "Collations"} (le cas échéant)

    ${localization?.translate("meal_plan_adaptation") ?? "Assurez-vous que le plan de repas est adapté aux besoins et objectifs spécifiques de l'utilisateur."}

    Format the output as a JSON object, structured as follows:
    {
    "breakfast": [
      {
        "name": "meal name",
        "description": "short description of the meal"
      },
      // more breakfast items if needed
    ],
    "lunch": [
      // lunch items
    ],
    "dinner": [
      // dinner items
    ],
    "snacks": [
      // snack items if any
    ]
    }

    Ensure the output is valid JSON with no additional text or explanations outside the JSON structure.
    ''';
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: localization?.translate("meal_plan_title") ?? "Plan de Repas",
        showProfile: true,
        showSignOut: false,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _mealPlan != null
                ? _mealPlan!.containsKey('error')
                    ? Text(_mealPlan!['error'])
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localization?.translate("meal_plan_intro") ??
                                  "Voici votre plan de repas personnalisé :",
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 20),
                            _buildMealPlanContent(localization, _mealPlan!),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                onPressed: () => _generateMealPlan(
                                  Provider.of<UserProvider>(context,
                                          listen: false)
                                      .user,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    localization?.translate(
                                            "regenerate_meal_plan") ??
                                        "Régénérer le Plan de Repas",
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      )
                : Text(localization?.translate("no_meal_plan") ??
                    "Aucun plan de repas disponible."),
      ),
    );
  }

  Widget _buildMealPlanContent(
      AppLocalizations? localization, Map<String, dynamic> mealPlan) {
    List<Widget> mealSections = [];

    if (mealPlan['breakfast'] != null) {
      mealSections.add(MealCard(
        mealType: localization?.translate("breakfast") ?? "Petit-déjeuner",
        meals: mealPlan['breakfast'],
      ));
    }
    if (mealPlan['lunch'] != null) {
      mealSections.add(MealCard(
        mealType: localization?.translate("lunch") ?? "Déjeuner",
        meals: mealPlan['lunch'],
      ));
    }
    if (mealPlan['dinner'] != null) {
      mealSections.add(MealCard(
        mealType: localization?.translate("dinner") ?? "Dîner",
        meals: mealPlan['dinner'],
      ));
    }
    if (mealPlan['snacks'] != null) {
      mealSections.add(MealCard(
        mealType: localization?.translate("snacks") ?? "Collations",
        meals: mealPlan['snacks'],
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: mealSections,
    );
  }
}
