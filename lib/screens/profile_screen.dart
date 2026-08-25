import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_back_button.dart';
import '../widgets/section_header.dart';

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String _formatMemberSince(DateTime date) {
  return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
}

// The real GirlStadium account screen: identity header, account
// information, name editing, and sign-out. Reacts to the signed-in
// user's own Firestore profile document via a stream - no other
// state-management package involved.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: user == null
            ? const _ProfileErrorState(
                message: "You're not signed in.",
                onRetry: null,
              )
            : StreamBuilder<UserProfile?>(
                stream: UserProfileService.instance.watchProfile(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accentPink),
                    );
                  }

                  if (snapshot.hasError) {
                    return _ProfileErrorState(
                      message: "Couldn't load your profile. Please try again.",
                      onRetry: () => UserProfileService.instance
                          .ensureProfileSynced(user)
                          .catchError((_) {}),
                    );
                  }

                  final profile = snapshot.data;
                  if (profile == null) {
                    return _MissingProfileState(user: user);
                  }

                  return _ProfileContent(user: user, profile: profile);
                },
              ),
      ),
    );
  }
}

// Shown if the current user's profile document is unexpectedly
// missing. Attempts one recreation using the current Firebase Auth
// user rather than leaving a permanent empty screen - the widget's own
// State guards against retrying more than once so a persistently
// failing write can't loop forever.
class _MissingProfileState extends StatefulWidget {
  final User user;

  const _MissingProfileState({required this.user});

  @override
  State<_MissingProfileState> createState() => _MissingProfileStateState();
}

class _MissingProfileStateState extends State<_MissingProfileState> {
  bool _attemptedRecreate = false;

  @override
  void initState() {
    super.initState();
    _attemptedRecreate = true;
    UserProfileService.instance.ensureProfileSynced(widget.user).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileErrorState(
      message: "Setting up your profile...",
      onRetry: _attemptedRecreate
          ? () => UserProfileService.instance
              .ensureProfileSynced(widget.user)
              .catchError((_) {})
          : null,
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ProfileErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 40),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final User user;
  final UserProfile profile;

  const _ProfileContent({required this.user, required this.profile});

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign out of GirlStadium?',
          style: TextStyle(color: AppColors.textWarm),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.accentPink, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // ProfileScreen is pushed on top of Home, which sits on AuthGate's
      // own route - pop back down to that root route first so AuthGate
      // (not this now-unauthenticated screen) is what's visible once
      // its authStateChanges listener switches to Intro automatically.
      Navigator.of(context).popUntil((route) => route.isFirst);
      await AuthService.instance.signOut();
    }
  }

  Future<void> _editName(BuildContext context) async {
    final result = await showDialog<_EditNameResult>(
      context: context,
      builder: (dialogContext) => _EditNameDialog(uid: profile.uid, currentName: profile.name),
    );

    if (result != null && result.authSyncFailed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name updated. Account sync will retry automatically.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileHero(profile: profile),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Account Information', icon: Icons.badge_outlined),
          const SizedBox(height: 14),
          _AccountInfoCard(profile: profile),
          const SizedBox(height: 20),
          _ActionButton(
            label: 'Edit Name',
            icon: Icons.edit_outlined,
            onTap: () => _editName(context),
          ),
          const SizedBox(height: 12),
          _ActionButton(
            label: 'Sign Out',
            icon: Icons.logout_rounded,
            isDestructive: true,
            onTap: () => _confirmSignOut(context),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  final UserProfile profile;

  const _ProfileHero({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileAvatar(profile: profile, size: 96),
        const SizedBox(height: 16),
        Text(
          profile.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textWarm,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceBase,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLavender.withValues(alpha: 0.6)),
          ),
          child: Text(
            profile.providerLabel,
            style: const TextStyle(
              color: AppColors.accentPink,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final UserProfile profile;
  final double size;

  const _ProfileAvatar({required this.profile, required this.size});

  @override
  Widget build(BuildContext context) {
    final ring = Container(
      width: size + 8,
      height: size + 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(colors: AppColors.heroGradient),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPink.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: _buildAvatarContent(),
        ),
      ),
    );

    return Center(child: ring);
  }

  Widget _buildAvatarContent() {
    final photoUrl = profile.photoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const ColoredBox(
            color: AppColors.surfaceBase,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.accentPink,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _InitialsAvatar(name: profile.name),
      );
    }
    return _InitialsAvatar(name: profile.name);
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;

  const _InitialsAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: AppColors.heroGradient),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AccountInfoCard extends StatelessWidget {
  final UserProfile profile;

  const _AccountInfoCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final createdAt = profile.createdAt;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceBase,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLavender.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Email', value: profile.email),
          _InfoDivider(),
          _InfoRow(label: 'Sign-in Method', value: profile.providerLabel),
          _InfoDivider(),
          _InfoRow(
            label: 'Member Since',
            value: createdAt != null ? _formatMemberSince(createdAt) : '—',
          ),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(color: AppColors.borderLavender.withValues(alpha: 0.35), height: 1);
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textWarm,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textWarm;
    final radius = BorderRadius.circular(16);

    return Material(
      color: AppColors.surfaceBase,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: isDestructive
                  ? AppColors.error.withValues(alpha: 0.4)
                  : AppColors.borderLavender.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditNameResult {
  final bool authSyncFailed;

  const _EditNameResult({this.authSyncFailed = false});
}

// A compact, GirlStadium-styled dialog for editing just the display
// name. Updates Firestore (the source ProfileScreen's stream reads
// from) first, then Firebase Auth's displayName - if the second step
// fails, the dialog still closes since the name the user sees is
// already correct, but the caller shows a clear warning rather than
// pretending everything succeeded.
class _EditNameDialog extends StatefulWidget {
  final String uid;
  final String currentName;

  const _EditNameDialog({required this.uid, required this.currentName});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String? _errorMessage;

  static const _maxNameLength = 60;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter your name';
    if (trimmed.length > _maxNameLength) return 'Name is too long';
    return null;
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    final name = _controller.text.trim();
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await UserProfileService.instance.updateName(widget.uid, name);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = "Couldn't update your name. Please try again.";
      });
      return;
    }

    var authSyncFailed = false;
    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
    } catch (_) {
      authSyncFailed = true;
    }

    if (!mounted) return;
    Navigator.of(context).pop(_EditNameResult(authSyncFailed: authSyncFailed));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Edit Name', style: TextStyle(color: AppColors.textWarm)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _controller,
              autofocus: true,
              maxLength: _maxNameLength,
              validator: _validateName,
              style: const TextStyle(color: AppColors.textWarm),
              cursorColor: AppColors.accentPink,
              decoration: InputDecoration(
                hintText: 'Name',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surfaceBase,
                counterStyle: const TextStyle(color: AppColors.textMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.borderLavender.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.accentPink, width: 1.4),
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
        ),
        TextButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentPink),
                )
              : const Text(
                  'Save',
                  style: TextStyle(color: AppColors.accentPink, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
