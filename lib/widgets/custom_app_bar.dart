import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showProfile;
  final bool showSignOut;
  final VoidCallback? onSignOut;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showProfile = false,
    this.showSignOut = false,
    this.onSignOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: Offset(0.0, 2.0),
              blurRadius: 3.0,
              color: Color.fromARGB(50, 0, 0, 0),
            ),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 4, // Add a subtle shadow
      centerTitle: true,
      systemOverlayStyle:
          SystemUiOverlayStyle.light, // For status bar text color
      actions: [
        if (showProfile)
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        if (showSignOut)
          IconButton(
            icon: const Icon(Icons.logout, size: 28),
            tooltip: 'Sign Out',
            onPressed: onSignOut,
          ),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
