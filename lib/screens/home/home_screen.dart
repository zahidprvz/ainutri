import 'dart:convert';
import 'dart:io';
import 'package:ainutri/models/food_log_entry_model.dart';
import 'package:ainutri/widgets/challenges_card.dart';
import 'package:ainutri/widgets/custom_app_bar.dart';
import 'package:ainutri/widgets/food_log_widgets/daily_summary_card.dart';
import 'package:ainutri/widgets/food_log_widgets/recent_meals.dart';
import 'package:ainutri/widgets/upload_options_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';
import '../../app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _isLoading = false;
  Map<String, dynamic>? _foodData;
  late AnimationController _animationController;
  Stream<List<FoodLogEntry>>? _foodLogStream;
  Future<double>? _dailyCalorieTotal;
  Future<double>? _dailyProteinTotal;
  Future<double>? _dailyCarbsTotal;
  Future<double>? _dailyFatTotal;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();
    _loadFoodLogs();
    _fetchDailyTotals();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFoodLogs();
    _fetchDailyTotals();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadFoodLogs() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isRegistered) {
      setState(() {
        _foodLogStream = userProvider.getFoodLogsForToday();
      });
    }
  }

  void _fetchDailyTotals() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _dailyCalorieTotal = userProvider.calculateDailyCalorieTotal();
      _dailyProteinTotal = userProvider.calculateDailyProteinTotal();
      _dailyCarbsTotal = userProvider.calculateDailyCarbsTotal();
      _dailyFatTotal = userProvider.calculateDailyFatTotal();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _image = image;
        _isLoading = true;
        _foodData = null;
      });
      _analyzeImageWithGemini(image);
    }
  }

  Future<void> _analyzeImageWithGemini(XFile image) async {
    const apiKey =
        'AIzaSyD6KwygU1v79sfLxmrzscgxE3_54rS5stw'; // Replace with your actual API key
    const apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

    try {
      final imageBytes = await image.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // Show the loading overlay on the image
      _showLoadingOverlay();

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      'Analyze the food in this image and provide its nutritional values in the following JSON format:\n\n`json\n{\n  "food": "Food Name",\n  "protein": "Protein value in grams",\n  "carbs": "Carbs value in grams",\n  "fat": "Fat value in grams",\n  "calories": "Total calorie value"\n}\n`\n\nIf you are unable to determine the exact nutritional values, provide your best estimate using typical values for this type of food. Always provide a value for each field, even if it is an estimate or a range. Do not return any fields with a "not found" value. Ensure the output is valid JSON and only includes the JSON, no additional text.'
                },
                {
                  'inlineData': {
                    'mimeType': 'image/jpeg',
                    'data': base64Image,
                  }
                },
              ]
            }
          ]
        }),
      );

      // Remove the loading overlay
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("API Response: ${response.body}");

        if (responseData.containsKey('candidates') &&
            responseData['candidates'].isNotEmpty) {
          final candidate = responseData['candidates'][0];
          if (candidate.containsKey('content') &&
              candidate['content'].containsKey('parts')) {
            final parts = candidate['content']['parts'];
            final textPart = parts.firstWhere(
              (part) =>
                  part is Map<String, dynamic> && part.containsKey('text'),
              orElse: () => null,
            );

            if (textPart != null) {
              final textResponse = textPart['text'];
              final regex = RegExp(r'`json(.*?)`', dotAll: true);
              final match = regex.firstMatch(textResponse);

              if (match != null) {
                final jsonString = match.group(1)!.trim();
                try {
                  final foodData = jsonDecode(jsonString);
                  if (foodData is Map<String, dynamic> &&
                      foodData.containsKey('food')) {
                    // Show results in a new dialog with editing capability
                    _showResultDialog(foodData);
                  } else {
                    throw Exception('Invalid food data format: $jsonString');
                  }
                } catch (e) {
                  print("Error decoding JSON: $e");
                  _showErrorDialog('Error decoding food data.');
                }
              } else {
                print("Could not find JSON in the text response.");
                _showErrorDialog('Could not find food data in the response.');
              }
            } else {
              print("Text part not found in the response.");
              _showErrorDialog('Text part not found in the response.');
            }
          } else {
            print("Content or parts not found in the candidate.");
            _showErrorDialog('Content or parts not found in the candidate.');
          }
        } else {
          print("No candidates found in the response.");
          _showErrorDialog('No candidates found in the response.');
        }
      } else {
        print(
            'Failed to analyze image: ${response.statusCode} ${response.body}');
        _showErrorDialog('Failed to analyze image: ${response.statusCode}');
      }
    } catch (e) {
      print("Error analyzing image: $e");
      _showErrorDialog('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Center(
            child: SizedBox(
              height: 350, // Adjust the size as needed
              width: 350, // Adjust the size as needed
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(File(_image!.path)), // Display the selected image
                  CircularProgressIndicator(), // Use your loading indicator
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Analysis Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showResultDialog(Map<String, dynamic> foodData) {
    if (!mounted) return;

    Map<String, dynamic> editableFoodData = Map.from(foodData);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  if (_image != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          File(_image!.path),
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  TextFormField(
                    initialValue: editableFoodData['food'] ?? '',
                    decoration: InputDecoration(labelText: 'Food Name'),
                    onChanged: (value) => editableFoodData['food'] = value,
                  ),
                  TextFormField(
                    initialValue: editableFoodData['protein'] ?? '',
                    decoration: InputDecoration(labelText: 'Protein (g)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => editableFoodData['protein'] = value,
                  ),
                  TextFormField(
                    initialValue: editableFoodData['carbs'] ?? '',
                    decoration: InputDecoration(labelText: 'Carbs (g)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => editableFoodData['carbs'] = value,
                  ),
                  TextFormField(
                    initialValue: editableFoodData['fat'] ?? '',
                    decoration: InputDecoration(labelText: 'Fat (g)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => editableFoodData['fat'] = value,
                  ),
                  TextFormField(
                    initialValue: editableFoodData['calories'] ?? '',
                    decoration: InputDecoration(labelText: 'Calories'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => editableFoodData['calories'] = value,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      setState(() {
                        _foodData = editableFoodData;
                      });
                      await _addFoodLogEntry(editableFoodData);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    child: const Text('Log Data',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addFoodLogEntry(Map<String, dynamic> foodData) async {
    FoodLogEntry entry = FoodLogEntry(
      foodName: foodData['food'],
      protein: parseNutrientValue(foodData['protein']),
      carbs: parseNutrientValue(foodData['carbs']),
      fat: parseNutrientValue(foodData['fat']),
      calories: parseNutrientValue(foodData['calories']),
      timestamp: Timestamp.now(),
    );

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.addFoodLogEntry(entry);

    _fetchDailyTotals();
    _loadFoodLogs();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Food log entry added successfully')),
    );
  }

  double? parseNutrientValue(dynamic value) {
    if (value is String) {
      String numericString = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(numericString);
    } else if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  void _showUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return UploadOptionsWidget(
          onOptionSelected: (source) {
            _pickImage(source);
          },
        );
      },
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context);
    var userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Accueil',
        showProfile: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FutureBuilder<List<double>>(
              future: Future.wait([
                _dailyCalorieTotal ?? Future.value(0.0),
                _dailyProteinTotal ?? Future.value(0.0),
                _dailyCarbsTotal ?? Future.value(0.0),
                _dailyFatTotal ?? Future.value(0.0),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final dailyTotals = snapshot.data!;
                  return DailySummaryCard(
                    caloriesConsumed: dailyTotals[0],
                    caloriesGoal: 2000,
                    proteinConsumed: dailyTotals[1],
                    proteinGoal: 150,
                    carbsConsumed: dailyTotals[2],
                    carbsGoal: 250,
                    fatConsumed: dailyTotals[3],
                    fatGoal: 70,
                  );
                }
              },
            ),
            StreamBuilder<List<FoodLogEntry>>(
              stream: _foodLogStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return RecentMeals(recentMeals: snapshot.data!);
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(localization?.translate("no_recent_meals") ??
                        "No recent meals"),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            // Challenges Card
            ChallengesCard(),
            const SizedBox(height: 20),
            if (!userProvider.isRegistered)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/ask_user_step1');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        localization?.translate("complete_registration") ??
                            'Complete Registration',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadOptions,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}
