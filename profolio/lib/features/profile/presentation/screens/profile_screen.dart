import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profolio/core/routing/app_router.dart';
import 'package:profolio/core/providers/firebase_providers.dart';
import 'package:profolio/features/profile/application/profile_controller.dart';
import 'package:profolio/models/user_profile.dart';

class ProfileScreen extends ConsumerWidget {
  final bool isEditing;

  const ProfileScreen({
    super.key,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return currentUser.when(
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRoutes.auth);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userProfile = ref.watch(userProfileProvider(user.uid));

        return userProfile.when(
          data: (profile) {
            if (profile == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Profile')),
                body: const Center(
                  child: Text('Profile not found. Please complete onboarding.'),
                ),
              );
            }

            return isEditing
                ? _buildEditMode(context, ref, profile, user.uid)
                : _buildViewMode(context, ref, profile, user.uid);
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            appBar: AppBar(title: const Text('Profile')),
            body: Center(child: Text('Error: $error')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildViewMode(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    String userId,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('${AppRoutes.profile}?editing=true'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authController = ref.read(authControllerProvider.notifier);
              await authController.signOut();
              if (context.mounted) {
                context.go(AppRoutes.auth);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              context,
              title: 'Personal Information',
              children: [
                _buildInfoRow('Name', profile.name),
                _buildInfoRow('Email', profile.email),
              ],
            ),
            const SizedBox(height: 24),
            if (profile.skills.isNotEmpty) ...[
              _buildCard(
                context,
                title: 'Skills',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.skills
                        .map((skill) => Chip(label: Text(skill)))
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            if (profile.experience.isNotEmpty) ...[
              _buildCard(
                context,
                title: 'Experience',
                children: profile.experience
                    .map((exp) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exp.role,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              exp.company,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              exp.duration,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (exp.description != null) ...[
                              const SizedBox(height: 8),
                              Text(exp.description!),
                            ],
                          ],
                        ))
                    .toList()
                    .fold<List<Widget>>(
                      [],
                      (prev, widget) => [
                        ...prev,
                        widget,
                        const SizedBox(height: 16),
                      ],
                    ),
              ),
              const SizedBox(height: 24),
            ],
            if (profile.education.isNotEmpty) ...[
              _buildCard(
                context,
                title: 'Education',
                children: profile.education
                    .map((edu) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              edu.degree,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              edu.institution,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              'Year: ${edu.year}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (edu.grade != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Grade: ${edu.grade}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ))
                    .toList()
                    .fold<List<Widget>>(
                      [],
                      (prev, widget) => [
                        ...prev,
                        widget,
                        const SizedBox(height: 16),
                      ],
                    ),
              ),
              const SizedBox(height: 24),
            ],
            if (profile.interests.isNotEmpty) ...[
              _buildCard(
                context,
                title: 'Interests',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.interests
                        .map((interest) => Chip(label: Text(interest)))
                        .toList(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditMode(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    String userId,
  ) {
    final nameController = TextEditingController(text: profile.name);
    final emailController = TextEditingController(text: profile.email);
    final profileController = ref.read(profileControllerProvider.notifier);
    final profileState = ref.watch(profileControllerProvider);

    return WillPopScope(
      onWillPop: () async {
        context.go(AppRoutes.profile);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.profile),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                enabled: false,
              ),
              const SizedBox(height: 32),
              if (profileState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    profileState.error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: profileState.isLoading
                    ? null
                    : () async {
                        final updatedProfile = profile.copyWith(
                          name: nameController.text.trim(),
                        );
                        await profileController.updateProfile(
                          userId: userId,
                          profile: updatedProfile,
                        );
                        if (context.mounted &&
                            !profileState.isLoading &&
                            profileState.error == null) {
                          context.go(AppRoutes.profile);
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: profileState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
}
