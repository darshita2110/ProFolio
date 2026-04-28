import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profolio/core/routing/app_router.dart';
import 'package:profolio/core/theme/app_theme.dart';
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
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _skillCtrl    = TextEditingController();
  final _interestCtrl = TextEditingController();

  static const _steps = [
    _Step('Personal Info',  'Who are you?',              Icons.person_outline_rounded),
    _Step('Skills',         'What can you do?',          Icons.code_rounded),
    _Step('Journey',        'Experience & education',    Icons.work_outline_rounded),
    _Step('Interests',      'What lights you up?',       Icons.auto_awesome_outlined),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _skillCtrl.dispose();
    _interestCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgBase       = AppTheme.bgBaseOf(context);
    final bgCard       = AppTheme.bgCardOf(context);
    final bgSurface    = AppTheme.bgSurfaceOf(context);
    final borderColor  = AppTheme.borderOf(context);
    final textPrimary  = AppTheme.textPrimaryOf(context);
    final textSecondary= AppTheme.textSecondaryOf(context);
    final textMuted    = AppTheme.textMutedOf(context);

    final currentUser = ref.watch(currentUserProvider);
    return currentUser.when(
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => context.go(AppRoutes.auth));
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final state    = ref.watch(onboardingControllerProvider(user.uid));
        final notifier = ref.read(onboardingControllerProvider(user.uid).notifier);
        final step     = state.currentStep;
        final total    = _steps.length;

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: bgBase,
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          if (step > 0)
                            GestureDetector(
                              onTap: notifier.previousStep,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: bgCard,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Icon(Icons.arrow_back_rounded,
                                    size: 16, color: textPrimary),
                              ),
                            )
                          else
                            Row(children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.person_outline_rounded,
                                    color: Color(0xFF0F0E0C), size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text('ProFolio',
                                  style: GoogleFonts.dmSerifDisplay(
                                      fontSize: 18, color: textPrimary)),
                            ]),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: bgCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                            ),
                            child: Text('${step + 1} / $total',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: textMuted,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ]),

                        const SizedBox(height: 20),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (step + 1) / total,
                            backgroundColor: borderColor,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primary),
                            minHeight: 3,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_steps[step].icon,
                                color: AppTheme.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_steps[step].title,
                                  style: GoogleFonts.dmSerifDisplay(
                                      fontSize: 20, color: textPrimary)),
                              Text(_steps[step].subtitle,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12, color: textMuted)),
                            ],
                          ),
                        ]),

                        const SizedBox(height: 16),
                        Container(height: 1, color: borderColor),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: _buildStep(step, state, notifier, context),
                    ),
                  ),

                  if (state.error != null)
                    Container(
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppTheme.error.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline,
                            color: AppTheme.error, size: 15),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(state.error!,
                              style: GoogleFonts.dmSans(
                                  color: AppTheme.error, fontSize: 12)),
                        ),
                        GestureDetector(
                          onTap: notifier.clearError,
                          child: const Icon(Icons.close,
                              size: 15, color: AppTheme.error),
                        ),
                      ]),
                    ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: GestureDetector(
                      onTap: state.isLoading
                          ? null
                          : step == total - 1
                              ? () async {
                                  await notifier.saveProfile();
                                  if (mounted &&
                                      !ref
                                          .read(onboardingControllerProvider(user.uid))
                                          .isLoading &&
                                      ref
                                              .read(onboardingControllerProvider(user.uid))
                                              .error ==
                                          null) {
                                    context.go(AppRoutes.profile);
                                  }
                                }
                              : notifier.nextStep,
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: state.isLoading
                              ? null
                              : const LinearGradient(
                                  colors: [AppTheme.primary, AppTheme.primaryGlow],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                          color: state.isLoading
                              ? AppTheme.primary.withOpacity(0.5)
                              : null,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: state.isLoading
                              ? null
                              : [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  )
                                ],
                        ),
                        child: Center(
                          child: state.isLoading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF0F0E0C),
                                  ))
                              : Row(mainAxisSize: MainAxisSize.min, children: [
                                  Text(
                                    step == total - 1
                                        ? 'Complete Profile'
                                        : 'Continue',
                                    style: GoogleFonts.dmSans(
                                        color: const Color(0xFF0F0E0C),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    step == total - 1
                                        ? Icons.check_rounded
                                        : Icons.arrow_forward_rounded,
                                    color: const Color(0xFF0F0E0C),
                                    size: 17,
                                  ),
                                ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }


  Widget _buildStep(
    int step,
    OnboardingState state,
    OnboardingController notifier,
    BuildContext context,
  ) {
    switch (step) {
      case 0: return _personalStep(state, notifier, context);
      case 1: return _skillsStep(state, notifier, context);
      case 2: return _journeyStep(state, notifier, context);
      case 3: return _interestsStep(state, notifier, context);
      default: return const SizedBox();
    }
  }

  Widget _personalStep(OnboardingState state, OnboardingController n, BuildContext context) {
    if (_nameCtrl.text.isEmpty && state.name.isNotEmpty) _nameCtrl.text = state.name;
    if (_emailCtrl.text.isEmpty && state.email.isNotEmpty) _emailCtrl.text = state.email;
    return Column(children: [
      _field(context, _nameCtrl, 'Full Name', 'Jane Doe',
          Icons.person_outline_rounded, n.updateName),
      const SizedBox(height: 14),
      _field(context, _emailCtrl, 'Email Address', 'you@example.com',
          Icons.mail_outline_rounded, n.updateEmail,
          keyboard: TextInputType.emailAddress),
    ]);
  }

  Widget _skillsStep(OnboardingState state, OnboardingController n, BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chipInput(context, _skillCtrl, 'e.g. Flutter, Python, Design…',
          Icons.code_rounded, () {
        final v = _skillCtrl.text.trim();
        if (v.isNotEmpty) { n.addSkill(v); _skillCtrl.clear(); }
      }),
      const SizedBox(height: 16),
      if (state.skills.isNotEmpty) ...[
        Text('Added',
            style: GoogleFonts.dmSans(
                fontSize: 12, color: AppTheme.textMutedOf(context),
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: state.skills
              .map((s) => _chip(s, () => n.removeSkill(s)))
              .toList(),
        ),
      ] else
        _emptyHint('Add skills like "Flutter", "UI Design", "Python"…', context),
    ]);
  }

  Widget _journeyStep(OnboardingState state, OnboardingController n, BuildContext ctx) {
    return Column(children: [
      _subSection(
        context: ctx,
        title: 'Experience',
        icon: Icons.work_outline_rounded,
        color: AppTheme.primary,
        onAdd: () => _expSheet(ctx, n),
        items: state.experience.isEmpty
            ? null
            : state.experience.asMap().entries
                .map((e) => _record(ctx, e.value.role,
                      '${e.value.company} · ${e.value.duration}',
                      () => n.removeExperience(e.key)))
                .toList(),
      ),
      const SizedBox(height: 14),
      _subSection(
        context: ctx,
        title: 'Education',
        icon: Icons.school_outlined,
        color: AppTheme.accent,
        onAdd: () => _eduSheet(ctx, n),
        items: state.education.isEmpty
            ? null
            : state.education.asMap().entries
                .map((e) => _record(ctx, e.value.degree,
                      '${e.value.institution} · ${e.value.year}',
                      () => n.removeEducation(e.key)))
                .toList(),
      ),
    ]);
  }

  Widget _interestsStep(OnboardingState state, OnboardingController n, BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _chipInput(context, _interestCtrl, 'e.g. Photography, Gaming…',
          Icons.auto_awesome_outlined, () {
        final v = _interestCtrl.text.trim();
        if (v.isNotEmpty) { n.addInterest(v); _interestCtrl.clear(); }
      }),
      const SizedBox(height: 16),
      if (state.interests.isNotEmpty) ...[
        Text('Added',
            style: GoogleFonts.dmSans(
                fontSize: 12, color: AppTheme.textMutedOf(context),
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: state.interests
              .map((i) => _chip(i, () => n.removeInterest(i),
                  color: AppTheme.accent))
              .toList(),
        ),
      ] else
        _emptyHint('Add things you\'re passionate about', context),
    ]);
  }


  Widget _field(
    BuildContext context,
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon,
    Function(String) onChange, {
    TextInputType? keyboard,
  }) {
    return TextField(
      controller: ctrl,
      onChanged: onChange,
      keyboardType: keyboard,
      style: GoogleFonts.dmSans(color: AppTheme.textPrimaryOf(context), fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppTheme.textMutedOf(context)),
      ),
    );
  }

  Widget _chipInput(
    BuildContext context,
    TextEditingController ctrl,
    String hint,
    IconData icon,
    VoidCallback onAdd,
  ) {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: ctrl,
          onSubmitted: (_) => onAdd(),
          style: GoogleFonts.dmSans(color: AppTheme.textPrimaryOf(context), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 17, color: AppTheme.textMutedOf(context)),
          ),
        ),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: onAdd,
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.add_rounded, color: Color(0xFF0F0E0C), size: 20),
        ),
      ),
    ]);
  }

  Widget _chip(String label, VoidCallback onDel, {Color? color}) {
    final c = color ?? AppTheme.primary;
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 6, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 13, color: c, fontWeight: FontWeight.w500)),
        const SizedBox(width: 5),
        GestureDetector(
            onTap: onDel,
            child: Icon(Icons.close_rounded, size: 13, color: c)),
      ]),
    );
  }

  Widget _emptyHint(String text, BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(text,
        style: GoogleFonts.dmSans(
            fontSize: 13,
            color: AppTheme.textMutedOf(context),
            fontStyle: FontStyle.italic)),
  );

  Widget _subSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onAdd,
    List<Widget>? items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCardOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 0),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 13, color: color),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondaryOf(context))),
              const Spacer(),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.add_rounded, size: 13, color: color),
                    const SizedBox(width: 3),
                    Text('Add',
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: items == null || items.isEmpty
                ? _emptyHint('Nothing added yet', context)
                : Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _record(BuildContext context, String title, String sub, VoidCallback onDel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.bgBaseOf(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderOf(context)),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryOf(context))),
            Text(sub,
                style: GoogleFonts.dmSans(
                    fontSize: 11, color: AppTheme.textMutedOf(context))),
          ]),
        ),
        GestureDetector(
            onTap: onDel,
            child: const Icon(Icons.delete_outline_rounded,
                size: 16, color: AppTheme.error)),
      ]),
    );
  }

  void _expSheet(BuildContext ctx, OnboardingController n) {
    final r = TextEditingController(), c = TextEditingController(),
        d = TextEditingController(), desc = TextEditingController();
    _sheet(ctx,
      title: 'Add Experience',
      color: AppTheme.primary,
      fields: [
        _sf(ctx, r, 'Role', Icons.badge_outlined),
        _sf(ctx, c, 'Company', Icons.business_outlined),
        _sf(ctx, d, 'Duration', Icons.calendar_today_outlined, hint: 'e.g. Jan 2022 – Present'),
        _sf(ctx, desc, 'Description (optional)', Icons.notes_outlined, lines: 2),
      ],
      onAdd: () {
        if (r.text.isNotEmpty && c.text.isNotEmpty && d.text.isNotEmpty) {
          n.addExperience(Experience(
            role: r.text.trim(), company: c.text.trim(),
            duration: d.text.trim(),
            description: desc.text.trim().isNotEmpty ? desc.text.trim() : null,
          ));
          return true;
        }
        return false;
      },
    );
  }

  void _eduSheet(BuildContext ctx, OnboardingController n) {
    final d = TextEditingController(), i = TextEditingController(),
        y = TextEditingController(), g = TextEditingController();
    _sheet(ctx,
      title: 'Add Education',
      color: AppTheme.accent,
      fields: [
        _sf(ctx, d, 'Degree', Icons.school_outlined),
        _sf(ctx, i, 'Institution', Icons.location_city_outlined),
        _sf(ctx, y, 'Year', Icons.calendar_today_outlined),
        _sf(ctx, g, 'Grade / GPA (optional)', Icons.grade_outlined),
      ],
      onAdd: () {
        if (d.text.isNotEmpty && i.text.isNotEmpty && y.text.isNotEmpty) {
          n.addEducation(Education(
            degree: d.text.trim(), institution: i.text.trim(),
            year: y.text.trim(),
            grade: g.text.trim().isNotEmpty ? g.text.trim() : null,
          ));
          return true;
        }
        return false;
      },
    );
  }

  void _sheet(
    BuildContext ctx, {
    required String title,
    required Color color,
    required List<Widget> fields,
    required bool Function() onAdd,
  }) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgSurfaceOf(ctx),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bCtx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(bCtx).viewInsets.bottom + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.borderOf(ctx),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 22, color: AppTheme.textPrimaryOf(ctx))),
            const SizedBox(height: 16),
            ...fields.expand((f) => [f, const SizedBox(height: 12)]).toList()
              ..removeLast(),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () { if (onAdd()) Navigator.pop(bCtx); },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text('Add',
                      style: GoogleFonts.dmSans(
                          color: const Color(0xFF0F0E0C),
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sf(BuildContext context, TextEditingController ctrl, String label, IconData icon,
      {String? hint, int lines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: lines,
      style: GoogleFonts.dmSans(color: AppTheme.textPrimaryOf(context), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 16, color: AppTheme.textMutedOf(context)),
      ),
    );
  }
}

class _Step {
  final String title, subtitle;
  final IconData icon;
  const _Step(this.title, this.subtitle, this.icon);
}