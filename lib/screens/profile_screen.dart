import 'package:ainutri/models/user.dart';
import 'package:ainutri/widgets/custom_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_localizations.dart';
import '../provider/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late UserData _user;
  late TextEditingController _usernameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _desiredWeightController;
  String? _selectedGoal;
  DateTime? _selectedBirthDate;

  @override
  void initState() {
    super.initState();
    _user = Provider.of<UserProvider>(context, listen: false).user;
    _usernameController = TextEditingController(text: _user.username);
    _heightController =
        TextEditingController(text: _user.height?.toString() ?? '');
    _weightController =
        TextEditingController(text: _user.weight?.toString() ?? '');
    _desiredWeightController =
        TextEditingController(text: _user.desiredWeight?.toString() ?? '');
    _selectedGoal = _user.goal;
    _selectedBirthDate = _user.birthDate;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _desiredWeightController.dispose();
    super.dispose();
  }

  Future<bool> _isUsernameUnique(String username) async {
    if (username == _user.username) {
      return true; // Skip the check if it's the current user's username
    }
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return querySnapshot.docs.isEmpty;
  }

  Future<void> _saveProfile(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Check if the username is unique (only if it's changed)
        if (_usernameController.text != _user.username) {
          bool isUnique = await _isUsernameUnique(_usernameController.text);
          if (!isUnique) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    AppLocalizations.of(context)?.translate('username_taken') ??
                        'Username already taken'),
              ),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }

        // Update user data in the provider and Firestore
        await userProvider.updateUser(
          context,
          username: _usernameController.text,
          height: double.tryParse(_heightController.text),
          weight: double.tryParse(_weightController.text),
          desiredWeight: double.tryParse(_desiredWeightController.text),
          goal: _selectedGoal,
          birthDate: _selectedBirthDate,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)?.translate('profile_updated') ??
                    'Profile updated successfully'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)
                    ?.translate('profile_update_failed') ??
                'Failed to update profile: $e'),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to the login screen or any other appropriate screen
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print("Error signing out: $e");
      // Handle sign-out error (e.g., show an error message)
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: localization?.translate("profile_title") ?? "Profile",
        showProfile: false,
        showSignOut: true,
        onSignOut: () => _signOut(context),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText:
                          localization?.translate('username') ?? 'Username',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localization?.translate('username_validation') ??
                            'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _heightController,
                    decoration: InputDecoration(
                      labelText:
                          localization?.translate('height') ?? 'Height (cm)',
                      prefixIcon: const Icon(Icons.height),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localization?.translate('height_validation') ??
                            'Please enter your height';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText:
                          localization?.translate('weight') ?? 'Weight (kg)',
                      prefixIcon: const Icon(Icons.fitness_center),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localization?.translate('weight_validation') ??
                            'Please enter your weight';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _desiredWeightController,
                    decoration: InputDecoration(
                      labelText: localization?.translate('desired_weight') ??
                          'Desired Weight (kg)',
                      prefixIcon: const Icon(Icons.flag),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localization
                                ?.translate('desired_weight_validation') ??
                            'Please enter your desired weight';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGoal,
                    decoration: InputDecoration(
                      labelText: localization?.translate('goal') ?? 'Goal',
                      prefixIcon: const Icon(Icons.track_changes),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: ['Lose Weight', 'Maintain', 'Gain Weight']
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedGoal = value;
                    }),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      _selectDate(context);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: localization?.translate('birth_date') ??
                            'Date of Birth',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(_selectedBirthDate != null
                          ? "${_selectedBirthDate!.toLocal()}".split(' ')[0]
                          : localization?.translate('select_date') ??
                              'Select Date'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _saveProfile(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            localization?.translate('save_profile') ??
                                'Save Profile',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }
}
