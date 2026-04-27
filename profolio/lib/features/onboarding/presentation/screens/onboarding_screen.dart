import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:profolio/core/routing/app_router.dart';
import 'package:profolio/features/onboarding/application/onboarding_controller.dart';
import 'package:profolio/models/education.dart';
import 'package:profolio/models/experience.dart';
import 'package:profolio/core/providers/firebase_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late TextEditingController _skillController;
  late TextEditingController _interestController;
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _skillController = TextEditingController();
    _interestController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _skillController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

        final controller = ref.watch(
          onboardingControllerProvider(user.uid),
        );
        final notifier = ref.read(
          onboardingControllerProvider(user.uid).notifier,
        );

        return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Complete Your Profile'),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stepper(
                    currentStep: controller.currentStep,
                    onStepContinue: () {
                      if (controller.currentStep < 3) {
                        notifier.nextStep();
                      }
                    },
                    onStepCancel: () {
                      if (controller.currentStep > 0) {
                        notifier.previousStep();
                      }
                    },
                    steps: [
                      Step(
                        title: const Text('Personal Details'),
                        isActive: controller.currentStep >= 0,
                        content: _buildPersonalDetailsStep(
                          controller,
                          notifier,
                          context,
                        ),
                      ),
                      Step(
                        title: const Text('Skills'),
                        isActive: controller.currentStep >= 1,
                        content:
                            _buildSkillsStep(controller, notifier, context),
                      ),
                      Step(
                        title: const Text('Experience & Education'),
                        isActive: controller.currentStep >= 2,
                        content: _buildExperienceEducationStep(
                          controller,
                          notifier,
                          context,
                        ),
                      ),
                      Step(
                        title: const Text('Interests'),
                        isActive: controller.currentStep >= 3,
                        content: _buildInterestsStep(
                          controller,
                          notifier,
                          context,
                        ),
                      ),
                    ],
                  ),
                  if (controller.isLoading) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                  if (controller.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              controller.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: notifier.clearError,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (controller.currentStep == 3)
                    ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () async {
                              await notifier.saveProfile();
                              if (mounted &&
                                  !controller.isLoading &&
                                  controller.error == null) {
                                context.go(AppRoutes.profile);
                              }
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: controller.isLoading
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
                            : const Text('Complete Profile'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsStep(
    OnboardingState state,
    OnboardingController notifier,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          initialValue: state.name,
          decoration: const InputDecoration(labelText: 'Full Name'),
          onChanged: notifier.updateName,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: state.email,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          onChanged: notifier.updateEmail,
        ),
      ],
    );
  }

  Widget _buildSkillsStep(
    OnboardingState state,
    OnboardingController notifier,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillController,
                decoration: const InputDecoration(labelText: 'Add a skill'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (_skillController.text.isNotEmpty) {
                  notifier.addSkill(_skillController.text.trim());
                  _skillController.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.skills.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.skills
                .map(
                  (skill) => Chip(
                    label: Text(skill),
                    onDeleted: () => notifier.removeSkill(skill),
                  ),
                )
                .toList(),
          ),
        ] else
          const Text('No skills added yet'),
      ],
    );
  }

  Widget _buildExperienceEducationStep(
    OnboardingState state,
    OnboardingController notifier,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Experience',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (state.experience.isNotEmpty)
          Column(
            children: List.generate(
              state.experience.length,
              (index) => Card(
                child: ListTile(
                  title: Text(state.experience[index].role),
                  subtitle: Text(state.experience[index].company),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => notifier.removeExperience(index),
                  ),
                ),
              ),
            ),
          )
        else
          const Text('No experience added'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showExperienceDialog(context, notifier),
          icon: const Icon(Icons.add),
          label: const Text('Add Experience'),
        ),
        const SizedBox(height: 24),
        Text(
          'Education',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (state.education.isNotEmpty)
          Column(
            children: List.generate(
              state.education.length,
              (index) => Card(
                child: ListTile(
                  title: Text(state.education[index].degree),
                  subtitle: Text(state.education[index].institution),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => notifier.removeEducation(index),
                  ),
                ),
              ),
            ),
          )
        else
          const Text('No education added'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _showEducationDialog(context, notifier),
          icon: const Icon(Icons.add),
          label: const Text('Add Education'),
        ),
      ],
    );
  }

  Widget _buildInterestsStep(
    OnboardingState state,
    OnboardingController notifier,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _interestController,
                decoration:
                    const InputDecoration(labelText: 'Add an interest'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (_interestController.text.isNotEmpty) {
                  notifier.addInterest(_interestController.text.trim());
                  _interestController.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (state.interests.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.interests
                .map(
                  (interest) => Chip(
                    label: Text(interest),
                    onDeleted: () => notifier.removeInterest(interest),
                  ),
                )
                .toList(),
          ),
        ] else
          const Text('No interests added yet'),
      ],
    );
  }

  void _showExperienceDialog(
    BuildContext context,
    OnboardingController notifier,
  ) {
    final roleController = TextEditingController();
    final companyController = TextEditingController();
    final durationController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Experience'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(labelText: 'Company'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duration'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (roleController.text.isNotEmpty &&
                  companyController.text.isNotEmpty &&
                  durationController.text.isNotEmpty) {
                notifier.addExperience(
                  Experience(
                    role: roleController.text.trim(),
                    company: companyController.text.trim(),
                    duration: durationController.text.trim(),
                    description: descriptionController.text.trim(),
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEducationDialog(
    BuildContext context,
    OnboardingController notifier,
  ) {
    final degreeController = TextEditingController();
    final institutionController = TextEditingController();
    final yearController = TextEditingController();
    final gradeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Education'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: degreeController,
                decoration: const InputDecoration(labelText: 'Degree'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: institutionController,
                decoration: const InputDecoration(labelText: 'Institution'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Year'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: gradeController,
                decoration:
                    const InputDecoration(labelText: 'Grade (Optional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (degreeController.text.isNotEmpty &&
                  institutionController.text.isNotEmpty &&
                  yearController.text.isNotEmpty) {
                notifier.addEducation(
                  Education(
                    degree: degreeController.text.trim(),
                    institution: institutionController.text.trim(),
                    year: yearController.text.trim(),
                    grade: gradeController.text.trim(),
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
