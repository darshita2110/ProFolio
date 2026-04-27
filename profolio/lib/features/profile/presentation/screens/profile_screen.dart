import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profolio/core/routing/app_router.dart';
import 'package:profolio/core/providers/firebase_providers.dart';
import 'package:profolio/features/profile/application/profile_controller.dart';
import 'package:profolio/models/user_profile.dart';
import 'package:profolio/models/education.dart';
import 'package:profolio/models/experience.dart';
import 'package:profolio/features/auth/application/auth_controller.dart';
import 'package:profolio/core/theme/app_theme.dart';

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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final userProfile = ref.watch(userProfileProvider(user.uid));

        return userProfile.when(
          data: (profile) {
            if (profile == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.go(AppRoutes.onboarding);
              });
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return isEditing
                ? _EditProfileScreen(profile: profile, userId: user.uid)
                : _ViewProfileScreen(profile: profile, userId: user.uid);
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(
            body: Center(child: Text('Error: $e')),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}

// ─── View Mode ───────────────────────────────────────────────────────────────

class _ViewProfileScreen extends ConsumerWidget {
  final UserProfile profile;
  final String userId;

  const _ViewProfileScreen({required this.profile, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initials = profile.name.isNotEmpty
        ? profile.name
            .trim()
            .split(' ')
            .where((w) => w.isNotEmpty)
            .take(2)
            .map((w) => w[0].toUpperCase())
            .join()
        : '?';

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      body: CustomScrollView(
        slivers: [
          // Hero app bar
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppTheme.bgBase,
            elevation: 0,
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      size: 18, color: AppTheme.textPrimary),
                ),
                onPressed: () => context.go(AppRoutes.editProfile),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Icon(Icons.logout_outlined,
                      size: 18, color: AppTheme.textSecondary),
                ),
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) context.go(AppRoutes.auth);
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Gradient bg
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D0D20), Color(0xFF0A0A0F)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Decorative circle
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primary.withOpacity(0.12),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Profile info
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                profile.name,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.mail_outline,
                                      size: 13, color: AppTheme.textMuted),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      profile.email,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        color: AppTheme.textMuted,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (profile.experience.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${profile.experience.first.role} @ ${profile.experience.first.company}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats row
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem(
                      '${profile.skills.length}', 'Skills', context),
                  _verticalDivider(),
                  _statItem(
                      '${profile.experience.length}', 'Experience', context),
                  _verticalDivider(),
                  _statItem(
                      '${profile.education.length}', 'Education', context),
                  _verticalDivider(),
                  _statItem(
                      '${profile.interests.length}', 'Interests', context),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (profile.skills.isNotEmpty) ...[
                  _sectionHeader(context, 'Skills', Icons.code_rounded),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.skills
                        .map((skill) => _skillChip(skill, context))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                if (profile.experience.isNotEmpty) ...[
                  _sectionHeader(
                      context, 'Experience', Icons.work_outline_rounded),
                  const SizedBox(height: 12),
                  ...profile.experience.map(
                    (exp) => _experienceCard(exp, context),
                  ),
                  const SizedBox(height: 24),
                ],

                if (profile.education.isNotEmpty) ...[
                  _sectionHeader(
                      context, 'Education', Icons.school_outlined),
                  const SizedBox(height: 12),
                  ...profile.education.map(
                    (edu) => _educationCard(edu, context),
                  ),
                  const SizedBox(height: 24),
                ],

                if (profile.interests.isNotEmpty) ...[
                  _sectionHeader(
                      context, 'Interests', Icons.interests_outlined),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.interests
                        .map((i) => _interestChip(i, context))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                if (profile.skills.isEmpty &&
                    profile.experience.isEmpty &&
                    profile.education.isEmpty &&
                    profile.interests.isEmpty)
                  _emptyState(context),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(width: 1, height: 32, color: AppTheme.border);
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppTheme.primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _skillChip(String skill, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        skill,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _interestChip(String interest, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accent.withOpacity(0.25)),
      ),
      child: Text(
        interest,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          color: AppTheme.accent,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _experienceCard(Experience exp, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child:
                  Icon(Icons.business_rounded, color: AppTheme.primary, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exp.role,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  exp.company,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    exp.duration,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppTheme.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (exp.description != null && exp.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    exp.description!,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _educationCard(Education edu, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.school_rounded, color: AppTheme.accent, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  edu.degree,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  edu.institution,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Class of ${edu.year}',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (edu.grade != null && edu.grade!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'GPA: ${edu.grade}',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(Icons.person_outline_rounded,
                  color: AppTheme.textMuted, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Your profile is empty',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the edit button to add your skills,\nexperience, and more.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Edit Mode ───────────────────────────────────────────────────────────────

class _EditProfileScreen extends ConsumerStatefulWidget {
  final UserProfile profile;
  final String userId;

  const _EditProfileScreen({required this.profile, required this.userId});

  @override
  ConsumerState<_EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<_EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _skillInput;
  late TextEditingController _interestInput;
  late List<String> _skills;
  late List<String> _interests;
  late List<Experience> _experience;
  late List<Education> _education;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _skillInput = TextEditingController();
    _interestInput = TextEditingController();
    _skills = List.from(widget.profile.skills);
    _interests = List.from(widget.profile.interests);
    _experience = List.from(widget.profile.experience);
    _education = List.from(widget.profile.education);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skillInput.dispose();
    _interestInput.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = widget.profile.copyWith(
      name: _nameController.text.trim(),
      skills: _skills,
      interests: _interests,
      experience: _experience,
      education: _education,
      updatedAt: DateTime.now(),
    );

    await ref.read(profileControllerProvider.notifier).updateProfile(
          userId: widget.userId,
          profile: updated,
        );

    if (mounted) {
      final state = ref.read(profileControllerProvider);
      if (state.error == null) {
        context.go(AppRoutes.profile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.profile),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: profileState.isLoading ? null : _save,
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: profileState.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (profileState.error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                ),
                child: Text(
                  profileState.error!,
                  style: GoogleFonts.dmSans(color: AppTheme.error),
                ),
              ),

            _editSection(
              title: 'Personal',
              icon: Icons.person_outline_rounded,
              child: TextField(
                controller: _nameController,
                style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline_rounded,
                      size: 18, color: AppTheme.textMuted),
                ),
              ),
            ),

            const SizedBox(height: 16),

            _editSection(
              title: 'Skills',
              icon: Icons.code_rounded,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _skillInput,
                          style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'e.g. Flutter, Python…',
                          ),
                          onSubmitted: (v) => _addSkill(v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _addButton(() => _addSkill(_skillInput.text)),
                    ],
                  ),
                  if (_skills.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _skills
                          .map((s) => _editChip(s, () {
                                setState(() => _skills.remove(s));
                              }))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            _editSection(
              title: 'Experience',
              icon: Icons.work_outline_rounded,
              action: TextButton.icon(
                onPressed: () => _showExpDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: Text('Add', style: GoogleFonts.dmSans(fontSize: 13)),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ),
              child: Column(
                children: _experience.isEmpty
                    ? [
                        _emptyHint('No experience added yet'),
                      ]
                    : _experience
                        .asMap()
                        .entries
                        .map((e) => _expTile(e.value, () {
                              setState(() => _experience.removeAt(e.key));
                            }))
                        .toList(),
              ),
            ),

            const SizedBox(height: 16),

            _editSection(
              title: 'Education',
              icon: Icons.school_outlined,
              action: TextButton.icon(
                onPressed: () => _showEduDialog(),
                icon: const Icon(Icons.add, size: 16),
                label: Text('Add', style: GoogleFonts.dmSans(fontSize: 13)),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ),
              child: Column(
                children: _education.isEmpty
                    ? [_emptyHint('No education added yet')]
                    : _education
                        .asMap()
                        .entries
                        .map((e) => _eduTile(e.value, () {
                              setState(() => _education.removeAt(e.key));
                            }))
                        .toList(),
              ),
            ),

            const SizedBox(height: 16),

            _editSection(
              title: 'Interests',
              icon: Icons.interests_outlined,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _interestInput,
                          style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'e.g. Photography, Gaming…',
                          ),
                          onSubmitted: (v) => _addInterest(v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _addButton(() => _addInterest(_interestInput.text)),
                    ],
                  ),
                  if (_interests.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _interests
                          .map((i) => _editChip(i, () {
                                setState(() => _interests.remove(i));
                              },
                              color: AppTheme.accent))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _addSkill(String v) {
    final val = v.trim();
    if (val.isNotEmpty && !_skills.contains(val)) {
      setState(() => _skills.add(val));
    }
    _skillInput.clear();
  }

  void _addInterest(String v) {
    final val = v.trim();
    if (val.isNotEmpty && !_interests.contains(val)) {
      setState(() => _interests.add(val));
    }
    _interestInput.clear();
  }

  Widget _editSection({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 14, color: AppTheme.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                if (action != null) action,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _addButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _editChip(String label, VoidCallback onDelete,
      {Color? color}) {
    final c = color ?? AppTheme.primary;
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: c,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close_rounded, size: 14, color: c),
          ),
        ],
      ),
    );
  }

  Widget _expTile(Experience exp, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
                Text(exp.role,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                Text(
                    '${exp.company} · ${exp.duration}',
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                size: 18, color: AppTheme.error),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _eduTile(Education edu, VoidCallback onDelete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
                Text(edu.degree,
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                Text(
                    '${edu.institution} · ${edu.year}',
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                size: 18, color: AppTheme.error),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _emptyHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  void _showExpDialog() {
    final roleCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => _buildDialog(
        title: 'Add Experience',
        fields: [
          _dialogField(roleCtrl, 'Role', Icons.badge_outlined),
          _dialogField(companyCtrl, 'Company', Icons.business_outlined),
          _dialogField(durationCtrl, 'Duration (e.g. 2020–2023)',
              Icons.calendar_today_outlined),
          _dialogField(descCtrl, 'Description (optional)',
              Icons.notes_outlined,
              maxLines: 3),
        ],
        onAdd: () {
          if (roleCtrl.text.isNotEmpty &&
              companyCtrl.text.isNotEmpty &&
              durationCtrl.text.isNotEmpty) {
            setState(() => _experience.add(Experience(
                  role: roleCtrl.text.trim(),
                  company: companyCtrl.text.trim(),
                  duration: durationCtrl.text.trim(),
                  description: descCtrl.text.trim().isNotEmpty
                      ? descCtrl.text.trim()
                      : null,
                )));
            Navigator.pop(ctx);
          }
        },
      ),
    );
  }

  void _showEduDialog() {
    final degreeCtrl = TextEditingController();
    final institutionCtrl = TextEditingController();
    final yearCtrl = TextEditingController();
    final gradeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => _buildDialog(
        title: 'Add Education',
        fields: [
          _dialogField(degreeCtrl, 'Degree', Icons.school_outlined),
          _dialogField(institutionCtrl, 'Institution', Icons.location_city_outlined),
          _dialogField(yearCtrl, 'Year', Icons.calendar_today_outlined),
          _dialogField(gradeCtrl, 'Grade / GPA (optional)', Icons.grade_outlined),
        ],
        onAdd: () {
          if (degreeCtrl.text.isNotEmpty &&
              institutionCtrl.text.isNotEmpty &&
              yearCtrl.text.isNotEmpty) {
            setState(() => _education.add(Education(
                  degree: degreeCtrl.text.trim(),
                  institution: institutionCtrl.text.trim(),
                  year: yearCtrl.text.trim(),
                  grade: gradeCtrl.text.trim().isNotEmpty
                      ? gradeCtrl.text.trim()
                      : null,
                )));
            Navigator.pop(ctx);
          }
        },
      ),
    );
  }

  Widget _buildDialog({
    required String title,
    required List<Widget> fields,
    required VoidCallback onAdd,
  }) {
    return AlertDialog(
      backgroundColor: AppTheme.bgSurface,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title,
          style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: fields
              .expand((f) => [f, const SizedBox(height: 12)])
              .toList()
            ..removeLast(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',
              style: GoogleFonts.dmSans(color: AppTheme.textMuted)),
        ),
        ElevatedButton(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Add',
              style: GoogleFonts.dmSans(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(icon, size: 16, color: AppTheme.textMuted),
      ),
    );
  }
}