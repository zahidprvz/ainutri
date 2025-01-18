import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import '../../provider/user_provider.dart';
import 'base_ask_user_screen.dart';

class AskUserStep19 extends StatefulWidget {
  const AskUserStep19({Key? key}) : super(key: key);

  @override
  _AskUserStep19State createState() => _AskUserStep19State();
}

class _AskUserStep19State extends State<AskUserStep19> {
  @override
  void initState() {
    super.initState();
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    // Update the isRegistered flag in the UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.completeRegistration();

    // Navigate to the home screen
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              localization?.translate("ask_user_step19_title") ??
                  "Création de votre plan",
            ),
          ],
        ),
      ),
    );
  }
}
