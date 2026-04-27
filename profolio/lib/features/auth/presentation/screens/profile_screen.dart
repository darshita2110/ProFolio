import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final bool isEditing;

  const ProfileScreen({
    super.key,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Profile' : 'Your Profile'),
      ),
      body: const Center(
        child: Text('Profile Screen - Coming in Phase 5'),
      ),
    );
  }
}
