import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profolio/core/routing/app_router.dart';
import 'package:profolio/features/onboarding/application/onboarding_controller.dart';
import 'package:profolio/models/education.dart';
import 'package:profolio/models/experience.dart';
import 'package:profolio/core/providers/firebase_providers.dart';
import 'package:profolio/core/theme/app_theme.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _skillController;
  late TextEditingController _interestController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _skillController = TextEditingController();
    _interestController = TextEditingController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _skillController.dispose();
    _interestController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _animateProgress(int step, int total) {
    _progressController.animateTo(
      (step + 1) / total,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final state = ref.watch(onboardingControllerProvider(user.uid));
        final notifier =
            ref.read(onboardingControllerProvider(user.uid).notifier);

        final steps = [
          _StepConfig(
            title: 'Personal Info',
            subtitle: 'Tell us about yourself',
            icon: Icons.person_outline_rounded,
          ),
          _StepConfig(
            title: 'Your Skills',
            subtitle: 'What are you good at?',
            icon: Icons.code_rounded,
          ),
          _StepConfig(
            title: 'Experience & Education',
            subtitle: 'Your professional journey',
            icon: Icons.work_outline_rounded,
          ),
          _StepConfig(
            title: 'Interests',
            subtitle: 'What do you love?',
            icon: Icons.interests_outlined,
          ),
        ];

        final totalSteps = steps.length;
        final currentStep = state.currentStep;

        _animateProgress(currentStep, totalSteps);

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: AppTheme.bgBase,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (currentStep > 0)
                              GestureDetector(
                                onTap: notifier.previousStep,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bgCard,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  child: const Icon(Icons.arrow_back_rounded,
                                      size: 16, color: AppTheme.textPrimary),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF8B5CF6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.person_outline_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'ProFolio',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            const Spacer(),
                            Text(
                              '${currentStep + 1} / $totalSteps',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (currentStep + 1) / totalSteps,
                            backgroundColor: AppTheme.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primary),
                            minHeight: 4,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Step dots
                        Row(
                          children: List.generate(totalSteps, (i) {
                            final isActive = i == currentStep;
                            final isDone = i < currentStep;
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: Column(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: isDone
                                            ? AppTheme.primary
                                            : isActive
                                                ? AppTheme.primary
                                                    .withOpacity(0.4)
                                                : AppTheme.border,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      steps[i].title,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        color: isActive
                                            ? AppTheme.primary
                                            : isDone
                                                ? AppTheme.textSecondary
                                                : AppTheme.textMuted,
                                        fontWeight: isActive
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 28),

                        // Step title
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                steps[currentStep].icon,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  steps[currentStep].title,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  steps[currentStep].subtitle,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppTheme.border),

                  // Step content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildCurrentStep(
                          currentStep, state, notifier, context),
                    ),
                  ),

                  // Error display
                  if (state.error != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: AppTheme.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppTheme.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(state.error!,
                                style: GoogleFonts.dmSans(
                                    color: AppTheme.error, fontSize: 13)),
                          ),
                          GestureDetector(
                            onTap: notifier.clearError,
                            child: const Icon(Icons.close,
                                size: 16, color: AppTheme.error),
                          ),
                        ],
                      ),
                    ),

                  // Bottom CTA
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: _buildCTA(
                        currentStep, totalSteps, state, notifier, context, user.uid),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildCurrentStep(
    int step,
    OnboardingState state,
    OnboardingController notifier,
    BuildContext context,
  ) {
    switch (step) {
      case 0:
        return _buildPersonalStep(state, notifier);
      case 1:
        return _buildSkillsStep(state, notifier);
      case 2:
        return _buildExpEduStep(state, notifier, context);
      case 3:
        return _buildInterestsStep(state, notifier);
      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalStep(OnboardingState state, OnboardingController notifier) {
    return Column(
      children: [
        _styledField(
          controller: _nameController,
          label: 'Full Name',
          hint: 'John Doe',
          icon: Icons.person_outline_rounded,
          onChanged: notifier.updateName,
          initialValue: state.name,
        ),
        const SizedBox(height: 16),
        _styledField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'you@example.com',
          icon: Icons.mail_outline_rounded,
          onChanged: notifier.updateEmail,
          keyboardType: TextInputType.emailAddress,
          initialValue: state.email,
        ),
      ],
    );
  }

  Widget _buildSkillsStep(OnboardingState state, OnboardingController notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillController,
                style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
                decoration: _inputDec('e.g. Flutter, Python, Design…',
                    Icons.code_rounded),
                onSubmitted: (v) => _addSkill(v, notifier),
              ),
            ),
            const SizedBox(width: 8),
            _addBtn(() => _addSkill(_skillController.text, notifier)),
          ],
        ),
        const SizedBox(height: 20),
        if (state.skills.isNotEmpty) ...[
          Text(
            'Added Skills',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.skills
                .map((s) => _chip(s, () => notifier.removeSkill(s)))
                .toList(),
          ),
        ] else
          _emptyHint('Add skills like "Flutter", "UI Design", "Python"…'),
      ],
    );
  }

  Widget _buildExpEduStep(
    OnboardingState state,
    OnboardingController notifier,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subSection(
          title: 'Experience',
          icon: Icons.work_outline_rounded,
          color: AppTheme.primary,
          onAdd: () => _showExpDialog(context, notifier),
          children: state.experience.isEmpty
              ? [_emptyHint('No experience yet')]
              : state.experience
                  .asMap()
                  .entries
                  .map((e) => _recordTile(
                        title: e.value.role,
                        subtitle: '${e.value.company} · ${e.value.duration}',
                        onDelete: () => notifier.removeExperience(e.key),
                        color: AppTheme.primary,
                      ))
                  .toList(),
        ),
        const SizedBox(height: 20),
        _subSection(
          title: 'Education',
          icon: Icons.school_outlined,
          color: AppTheme.accent,
          onAdd: () => _showEduDialog(context, notifier),
          children: state.education.isEmpty
              ? [_emptyHint('No education yet')]
              : state.education
                  .asMap()
                  .entries
                  .map((e) => _recordTile(
                        title: e.value.degree,
                        subtitle:
                            '${e.value.institution} · ${e.value.year}',
                        onDelete: () => notifier.removeEducation(e.key),
                        color: AppTheme.accent,
                      ))
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildInterestsStep(
      OnboardingState state, OnboardingController notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _interestController,
                style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
                decoration: _inputDec(
                    'e.g. Photography, Gaming, Music…',
                    Icons.interests_outlined),
                onSubmitted: (v) => _addInterest(v, notifier),
              ),
            ),
            const SizedBox(width: 8),
            _addBtn(() => _addInterest(_interestController.text, notifier)),
          ],
        ),
        const SizedBox(height: 20),
        if (state.interests.isNotEmpty) ...[
          Text(
            'Added Interests',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: state.interests
                .map((i) =>
                    _chip(i, () => notifier.removeInterest(i), color: AppTheme.accent))
                .toList(),
          ),
        ] else
          _emptyHint('Add things you\'re passionate about'),
      ],
    );
  }

  Widget _buildCTA(
    int currentStep,
    int totalSteps,
    OnboardingState state,
    OnboardingController notifier,
    BuildContext context,
    String userId,
  ) {
    final isLast = currentStep == totalSteps - 1;

    return GestureDetector(
      onTap: state.isLoading
          ? null
          : isLast
              ? () async {
                  await notifier.saveProfile();
                  if (mounted && state.error == null) {
                    context.go(AppRoutes.profile);
                  }
                }
              : notifier.nextStep,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: state.isLoading
                ? [const Color(0xFF4B4DB5), const Color(0xFF6364BC)]
                : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: state.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLast ? 'Complete Profile' : 'Continue',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isLast
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _addSkill(String v, OnboardingController notifier) {
    final val = v.trim();
    if (val.isNotEmpty) {
      notifier.addSkill(val);
      _skillController.clear();
    }
  }

  void _addInterest(String v, OnboardingController notifier) {
    final val = v.trim();
    if (val.isNotEmpty) {
      notifier.addInterest(val);
      _interestController.clear();
    }
  }

  InputDecoration _inputDec(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: AppTheme.textMuted),
    );
  }

  Widget _styledField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    String initialValue = '',
    TextInputType? keyboardType,
  }) {
    if (controller.text.isEmpty && initialValue.isNotEmpty) {
      controller.text = initialValue;
    }
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppTheme.textMuted),
      ),
    );
  }

  Widget _addBtn(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _chip(String label, VoidCallback onDelete, {Color? color}) {
    final c = color ?? AppTheme.primary;
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
                fontSize: 13, color: c, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close_rounded, size: 14, color: c),
          ),
        ],
      ),
    );
  }

  Widget _emptyHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          color: AppTheme.textMuted,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _subSection({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onAdd,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 14, color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded, size: 14),
                  label: Text('Add', style: GoogleFonts.dmSans(fontSize: 12)),
                  style: TextButton.styleFrom(
                    foregroundColor: color,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recordTile({
    required String title,
    required String subtitle,
    required VoidCallback onDelete,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgBase,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                Text(subtitle,
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline_rounded,
                size: 18, color: AppTheme.error),
          ),
        ],
      ),
    );
  }

  void _showExpDialog(BuildContext context, OnboardingController notifier) {
    final roleCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Experience',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: roleCtrl,
              style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Role',
                prefixIcon:
                    const Icon(Icons.badge_outlined, size: 16, color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: companyCtrl,
              style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Company',
                prefixIcon: const Icon(Icons.business_outlined,
                    size: 16, color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: durationCtrl,
              style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Duration',
                hintText: 'e.g. Jan 2022 – Present',
                prefixIcon: const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              maxLines: 2,
              style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: const Icon(Icons.notes_outlined,
                    size: 16, color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (roleCtrl.text.isNotEmpty &&
                    companyCtrl.text.isNotEmpty &&
                    durationCtrl.text.isNotEmpty) {
                  notifier.addExperience(Experience(
                    role: roleCtrl.text.trim(),
                    company: companyCtrl.text.trim(),
                    duration: durationCtrl.text.trim(),
                    description: descCtrl.text.trim().isNotEmpty
                        ? descCtrl.text.trim()
                        : null,
                  ));
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Add Experience',
                style: GoogleFonts.dmSans(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEduDialog(BuildContext context, OnboardingController notifier) {
    final degreeCtrl = TextEditingController();
    final instCtrl = TextEditingController();
    final yearCtrl = TextEditingController();
    final gradeCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Education',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: degreeCtrl,
              style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Degree',
                prefixIcon: const Icon(Icons.school_outlined,
                    size: 16, color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: instCtrl,
              style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Institution',
                prefixIcon: const Icon(Icons.location_city_outlined,
                    size: 16, color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: yearCtrl,
              style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Year',
                prefixIcon: const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: gradeCtrl,
              style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: 'Grade / GPA (optional)',
                prefixIcon: const Icon(Icons.grade_outlined,
                    size: 16, color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (degreeCtrl.text.isNotEmpty &&
                    instCtrl.text.isNotEmpty &&
                    yearCtrl.text.isNotEmpty) {
                  notifier.addEducation(Education(
                    degree: degreeCtrl.text.trim(),
                    institution: instCtrl.text.trim(),
                    year: yearCtrl.text.trim(),
                    grade: gradeCtrl.text.trim().isNotEmpty
                        ? gradeCtrl.text.trim()
                        : null,
                  ));
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Add Education',
                style: GoogleFonts.dmSans(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepConfig {
  final String title;
  final String subtitle;
  final IconData icon;

  _StepConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}