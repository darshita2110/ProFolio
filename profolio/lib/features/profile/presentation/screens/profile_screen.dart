import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profolio/core/routing/app_router.dart';
import 'package:profolio/core/providers/firebase_providers.dart';
import 'package:profolio/core/theme/app_theme.dart';
import 'package:profolio/features/auth/application/auth_controller.dart';
import 'package:profolio/features/profile/application/profile_controller.dart';
import 'package:profolio/models/education.dart';
import 'package:profolio/models/experience.dart';
import 'package:profolio/models/user_profile.dart';

class ProfileScreen extends ConsumerWidget {
  final bool isEditing;
  const ProfileScreen({super.key, this.isEditing = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    return currentUser.when(
      data: (user) {
        if (user == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => context.go(AppRoutes.auth));
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final profileAsync = ref.watch(userProfileProvider(user.uid));
        return profileAsync.when(
          data: (profile) {
            if (profile == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) => context.go(AppRoutes.onboarding));
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            return isEditing
                ? _EditProfile(profile: profile, userId: user.uid)
                : _ViewProfile(profile: profile);
          },
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
    );
  }
}

class _ViewProfile extends ConsumerWidget {
  final UserProfile profile;
  const _ViewProfile({required this.profile});

  String get _initials {
    final words = profile.name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppTheme.bgBase,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              GestureDetector(
                onTap: () => ref.read(themeModeProvider.notifier).toggle(),
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCardOf(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderOf(context)),
                  ),
                  child: Icon(
                    AppTheme.isDark(context)
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    size: 16,
                    color: AppTheme.isDark(context)
                        ? AppTheme.primaryGlow
                        : AppTheme.accent,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _iconBtn(Icons.edit_outlined,
                  () => context.go(AppRoutes.editProfile)),
              const SizedBox(width: 4),
              _iconBtn(Icons.logout_outlined, () async {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) context.go(AppRoutes.auth);
              }),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroHeader(profile: profile, initials: _initials),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    _stat('${profile.skills.length}', 'Skills'),
                    _divider(),
                    _stat('${profile.experience.length}', 'Jobs'),
                    _divider(),
                    _stat('${profile.education.length}', 'Education'),
                    _divider(),
                    _stat('${profile.interests.length}', 'Interests'),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (profile.skills.isNotEmpty) ...[
                  _Section(title: 'Skills', icon: Icons.code_rounded, iconColor: AppTheme.primary),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: profile.skills.map((s) => _SkillChip(s)).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                if (profile.experience.isNotEmpty) ...[
                  _Section(title: 'Experience', icon: Icons.work_outline_rounded, iconColor: AppTheme.primary),
                  const SizedBox(height: 12),
                  ...profile.experience.map((e) => _ExpCard(exp: e)),
                  const SizedBox(height: 24),
                ],
                if (profile.education.isNotEmpty) ...[
                  _Section(title: 'Education', icon: Icons.school_outlined, iconColor: AppTheme.accent),
                  const SizedBox(height: 12),
                  ...profile.education.map((e) => _EduCard(edu: e)),
                  const SizedBox(height: 24),
                ],
                if (profile.interests.isNotEmpty) ...[
                  _Section(title: 'Interests', icon: Icons.auto_awesome_outlined, iconColor: AppTheme.accent),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: profile.interests.map((i) => _InterestChip(i)).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                if (profile.skills.isEmpty && profile.experience.isEmpty &&
                    profile.education.isEmpty && profile.interests.isEmpty)
                  _EmptyState(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, size: 16, color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _stat(String val, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(children: [
          Text(val,
              style: GoogleFonts.dmSerifDisplay(
                  fontSize: 24, color: AppTheme.primary)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, color: AppTheme.border, margin: const EdgeInsets.symmetric(vertical: 10));
}

class _HeroHeader extends StatelessWidget {
  final UserProfile profile;
  final String initials;
  const _HeroHeader({required this.profile, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1510), Color(0xFF0F0E0C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.primary.withOpacity(0.10),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.bgBase, width: 3),
                  ),
                  child: Center(
                    child: Text(initials,
                        style: GoogleFonts.dmSerifDisplay(
                            fontSize: 28, color: const Color(0xFF0F0E0C))),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(profile.name,
                          style: GoogleFonts.dmSerifDisplay(
                              fontSize: 24, color: AppTheme.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(profile.email,
                          style: GoogleFonts.dmSans(
                              fontSize: 12, color: AppTheme.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      if (profile.experience.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppTheme.primary.withOpacity(0.3)),
                          ),
                          child: Text(
                            '${profile.experience.first.role} · ${profile.experience.first.company}',
                            style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  const _Section({required this.title, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: iconColor),
      ),
      const SizedBox(width: 10),
      Text(title,
          style: GoogleFonts.dmSerifDisplay(
              fontSize: 18, color: AppTheme.textPrimary)),
    ]);
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String label;
  const _InterestChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accent.withOpacity(0.25)),
      ),
      child: Text(label,
          style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppTheme.accent,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _ExpCard extends StatelessWidget {
  final Experience exp;
  const _ExpCard({required this.exp});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.business_rounded,
                size: 17, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exp.role,
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 1),
                Text(exp.company,
                    style: GoogleFonts.dmSans(
                        fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(exp.duration,
                      style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500)),
                ),
                if (exp.description != null && exp.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(exp.description!,
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          height: 1.5)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EduCard extends StatelessWidget {
  final Education edu;
  const _EduCard({required this.edu});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school_rounded,
                size: 17, color: AppTheme.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(edu.degree,
                    style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 1),
                Text(edu.institution,
                    style: GoogleFonts.dmSans(
                        fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 5),
                Row(children: [
                  _badge(edu.year, AppTheme.accent),
                  if (edu.grade != null && edu.grade!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _badge('GPA ${edu.grade}', AppTheme.success),
                  ],
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(text,
        style: GoogleFonts.dmSans(
            fontSize: 11, color: color, fontWeight: FontWeight.w500)),
  );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border),
            ),
            child: const Icon(Icons.person_outline_rounded,
                color: AppTheme.textMuted, size: 32),
          ),
          const SizedBox(height: 16),
          Text('Your profile is empty',
              style: GoogleFonts.dmSerifDisplay(
                  fontSize: 20, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Tap the edit button to add your story.',
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: AppTheme.textMuted)),
        ]),
      ),
    );
  }
}

class _EditProfile extends ConsumerStatefulWidget {
  final UserProfile profile;
  final String userId;
  const _EditProfile({required this.profile, required this.userId});

  @override
  ConsumerState<_EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<_EditProfile> {
  late TextEditingController _nameCtrl;
  late TextEditingController _skillInput;
  late TextEditingController _interestInput;
  late List<String> _skills;
  late List<String> _interests;
  late List<Experience> _experience;
  late List<Education> _education;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _skillInput = TextEditingController();
    _interestInput = TextEditingController();
    _skills = List.from(widget.profile.skills);
    _interests = List.from(widget.profile.interests);
    _experience = List.from(widget.profile.experience);
    _education = List.from(widget.profile.education);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _skillInput.dispose();
    _interestInput.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = widget.profile.copyWith(
      name: _nameCtrl.text.trim(),
      skills: _skills,
      interests: _interests,
      experience: _experience,
      education: _education,
      updatedAt: DateTime.now(),
    );
    await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(userId: widget.userId, profile: updated);
    if (mounted && ref.read(profileControllerProvider).error == null) {
      context.go(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pState = ref.watch(profileControllerProvider);
    return Scaffold(
      backgroundColor: AppTheme.bgBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRoutes.profile),
        ),
        title: Text('Edit Profile',
            style: GoogleFonts.dmSerifDisplay(
                fontSize: 20, color: AppTheme.textPrimary)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: pState.isLoading ? null : _save,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: pState.isLoading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0F0E0C)))
                    : Text('Save',
                        style: GoogleFonts.dmSans(
                            color: const Color(0xFF0F0E0C),
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
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
            if (pState.error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                ),
                child: Text(pState.error!,
                    style: GoogleFonts.dmSans(
                        color: AppTheme.error, fontSize: 13)),
              ),

            _editCard(
              title: 'Personal',
              icon: Icons.person_outline_rounded,
              child: TextField(
                controller: _nameCtrl,
                style: GoogleFonts.dmSans(color: AppTheme.textPrimary),
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
            ),
            const SizedBox(height: 14),

            _editCard(
              title: 'Skills',
              icon: Icons.code_rounded,
              child: Column(children: [
                _chipInput(
                  ctrl: _skillInput,
                  hint: 'e.g. Flutter, Python…',
                  onAdd: () {
                    final v = _skillInput.text.trim();
                    if (v.isNotEmpty && !_skills.contains(v)) {
                      setState(() => _skills.add(v));
                    }
                    _skillInput.clear();
                  },
                ),
                if (_skills.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: _skills
                        .map((s) => _editChip(
                            s, () => setState(() => _skills.remove(s))))
                        .toList(),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 14),

            _editCard(
              title: 'Experience',
              icon: Icons.work_outline_rounded,
              action: _addBtn(() => _expDialog()),
              child: Column(
                children: _experience.isEmpty
                    ? [_hint('No experience yet')]
                    : _experience
                        .asMap()
                        .entries
                        .map((e) => _recordRow(
                              e.value.role,
                              '${e.value.company} · ${e.value.duration}',
                              () => setState(
                                  () => _experience.removeAt(e.key)),
                            ))
                        .toList(),
              ),
            ),
            const SizedBox(height: 14),

            _editCard(
              title: 'Education',
              icon: Icons.school_outlined,
              action: _addBtn(() => _eduDialog()),
              child: Column(
                children: _education.isEmpty
                    ? [_hint('No education yet')]
                    : _education
                        .asMap()
                        .entries
                        .map((e) => _recordRow(
                              e.value.degree,
                              '${e.value.institution} · ${e.value.year}',
                              () => setState(
                                  () => _education.removeAt(e.key)),
                            ))
                        .toList(),
              ),
            ),
            const SizedBox(height: 14),

            _editCard(
              title: 'Interests',
              icon: Icons.auto_awesome_outlined,
              child: Column(children: [
                _chipInput(
                  ctrl: _interestInput,
                  hint: 'e.g. Photography, Gaming…',
                  onAdd: () {
                    final v = _interestInput.text.trim();
                    if (v.isNotEmpty && !_interests.contains(v)) {
                      setState(() => _interests.add(v));
                    }
                    _interestInput.clear();
                  },
                ),
                if (_interests.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: _interests
                        .map((i) => _editChip(
                            i,
                            () => setState(() => _interests.remove(i)),
                            color: AppTheme.accent))
                        .toList(),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _editCard({
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
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 0),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: AppTheme.primary),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary)),
              const Spacer(),
              if (action != null) action,
            ]),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }

  Widget _chipInput(
      {required TextEditingController ctrl,
      required String hint,
      required VoidCallback onAdd}) {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: ctrl,
          style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (_) => onAdd(),
        ),
      ),
      const SizedBox(width: 8),
      GestureDetector(
        onTap: onAdd,
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.add_rounded,
              color: Color(0xFF0F0E0C), size: 20),
        ),
      ),
    ]);
  }

  Widget _editChip(String label, VoidCallback onDel, {Color? color}) {
    final c = color ?? AppTheme.primary;
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 6, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontSize: 12, color: c, fontWeight: FontWeight.w500)),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: onDel,
          child: Icon(Icons.close_rounded, size: 13, color: c),
        ),
      ]),
    );
  }

  Widget _recordRow(String title, String sub, VoidCallback onDel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgBase,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
              Text(sub,
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: AppTheme.textMuted)),
            ],
          ),
        ),
        GestureDetector(
          onTap: onDel,
          child: const Icon(Icons.delete_outline_rounded,
              size: 17, color: AppTheme.error),
        ),
      ]),
    );
  }

  Widget _addBtn(VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.add_rounded, size: 14, color: AppTheme.primary),
        const SizedBox(width: 4),
        Text('Add',
            style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppTheme.primary,
                fontWeight: FontWeight.w600)),
      ]),
    ),
  );

  Widget _hint(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Text(text,
        style: GoogleFonts.dmSans(
            fontSize: 13,
            color: AppTheme.textMuted,
            fontStyle: FontStyle.italic)),
  );

  void _expDialog() {
    final r = TextEditingController(), c = TextEditingController(),
        d = TextEditingController(), desc = TextEditingController();
    _sheet(
      title: 'Add Experience',
      accentColor: AppTheme.primary,
      fields: [
        _sheetField(r, 'Role', Icons.badge_outlined),
        _sheetField(c, 'Company', Icons.business_outlined),
        _sheetField(d, 'Duration', Icons.calendar_today_outlined,
            hint: 'e.g. Jan 2022 – Present'),
        _sheetField(desc, 'Description (optional)', Icons.notes_outlined,
            maxLines: 2),
      ],
      onAdd: () {
        if (r.text.isNotEmpty && c.text.isNotEmpty && d.text.isNotEmpty) {
          setState(() => _experience.add(Experience(
                role: r.text.trim(),
                company: c.text.trim(),
                duration: d.text.trim(),
                description: desc.text.trim().isNotEmpty ? desc.text.trim() : null,
              )));
          return true;
        }
        return false;
      },
    );
  }

  void _eduDialog() {
    final d = TextEditingController(), i = TextEditingController(),
        y = TextEditingController(), g = TextEditingController();
    _sheet(
      title: 'Add Education',
      accentColor: AppTheme.accent,
      fields: [
        _sheetField(d, 'Degree', Icons.school_outlined),
        _sheetField(i, 'Institution', Icons.location_city_outlined),
        _sheetField(y, 'Year', Icons.calendar_today_outlined),
        _sheetField(g, 'Grade / GPA (optional)', Icons.grade_outlined),
      ],
      onAdd: () {
        if (d.text.isNotEmpty && i.text.isNotEmpty && y.text.isNotEmpty) {
          setState(() => _education.add(Education(
                degree: d.text.trim(),
                institution: i.text.trim(),
                year: y.text.trim(),
                grade: g.text.trim().isNotEmpty ? g.text.trim() : null,
              )));
          return true;
        }
        return false;
      },
    );
  }

  void _sheet({
    required String title,
    required Color accentColor,
    required List<Widget> fields,
    required bool Function() onAdd,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 22, color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            ...fields.expand((f) => [f, const SizedBox(height: 12)]).toList()
              ..removeLast(),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () {
                if (onAdd()) Navigator.pop(ctx);
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
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

  Widget _sheetField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: GoogleFonts.dmSans(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 16, color: AppTheme.textMuted),
      ),
    );
  }
}