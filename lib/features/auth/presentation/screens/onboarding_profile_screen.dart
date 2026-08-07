import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/app_user.dart';
import '../../../../models/user_profile.dart';
import '../providers/auth_providers.dart';

class OnboardingProfileScreen extends ConsumerStatefulWidget {
  const OnboardingProfileScreen({super.key});

  @override
  ConsumerState<OnboardingProfileScreen> createState() =>
      _OnboardingProfileScreenState();
}

class _OnboardingProfileScreenState
    extends ConsumerState<OnboardingProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String _selectedYear = 'Freshman';
  double _targetGpa = 3.8;

  final List<String> _academicYears = const <String>[
    'Freshman',
    'Sophomore',
    'Junior',
    'Senior',
    'Graduate',
  ];

  @override
  void initState() {
    super.initState();
    final AppUser? user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _collegeController.dispose();
    _majorController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final AuthController controller = ref.read(authControllerProvider.notifier);
    final bool success = await controller.completeStudentProfile(
      fullName: _nameController.text,
      collegeName: _collegeController.text,
      major: _majorController.text,
      academicYear: _selectedYear,
      targetGpa: _targetGpa,
      bio: _bioController.text,
    );

    if (!mounted) return;
    if (!success) {
      final AuthState authState = ref.read(authControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.errorMessage ?? 'Profile setup failed. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final AuthState authState = ref.watch(authControllerProvider);
    final bool isLoading = authState.status == AuthStatus.loading;

    final AsyncValue<UserProfile?> profileAsync = ref.watch(userProfileProvider);
    final UserProfile? existingProfile = profileAsync.asData?.value;

    if (existingProfile != null &&
        _collegeController.text.isEmpty &&
        existingProfile.collegeName.isNotEmpty) {
      _collegeController.text = existingProfile.collegeName;
      _majorController.text = existingProfile.major;
      _selectedYear = existingProfile.academicYear;
      _targetGpa = existingProfile.targetGpa;
      _bioController.text = existingProfile.bio;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Student Profile'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () {
              final AuthController controller = ref.read(authControllerProvider.notifier);
              controller.signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: colors.primaryContainer,
                              foregroundColor: colors.onPrimaryContainer,
                              child: const Icon(Icons.school_rounded, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Welcome to College Companion',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Let\'s build your academic profile',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(color: colors.onSurface, fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Enter your name'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _collegeController,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(color: colors.onSurface, fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: 'University / College Name',
                            hintText: 'e.g. Stanford University',
                            prefixIcon: Icon(Icons.account_balance_outlined),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Enter your university or college name'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _majorController,
                          textInputAction: TextInputAction.next,
                          style: TextStyle(color: colors.onSurface, fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: 'Major / Field of Study',
                            hintText: 'e.g. Computer Science',
                            prefixIcon: Icon(Icons.menu_book_rounded),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Enter your major or degree'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedYear,
                          style: TextStyle(color: colors.onSurface, fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: 'Academic Level / Year',
                            prefixIcon: Icon(Icons.class_outlined),
                          ),
                          items: _academicYears
                              .map(
                                (yr) => DropdownMenuItem<String>(
                                  value: yr,
                                  child: Text(
                                    yr,
                                    style: TextStyle(color: colors.onSurface),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedYear = val);
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Target GPA: ${_targetGpa.toStringAsFixed(2)} / 4.0',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        Slider(
                          value: _targetGpa,
                          min: 2.0,
                          max: 4.0,
                          divisions: 20,
                          label: _targetGpa.toStringAsFixed(2),
                          onChanged: (val) {
                            setState(() => _targetGpa = val);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bioController,
                          maxLines: 2,
                          style: TextStyle(color: colors.onSurface, fontSize: 16),
                          decoration: const InputDecoration(
                            labelText: 'Academic Goals / Bio (Optional)',
                            hintText: 'e.g. Preparing for AI research & internship interviews',
                            prefixIcon: Icon(Icons.edit_note_rounded),
                          ),
                        ),
                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: isLoading ? null : _handleSubmitProfile,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Complete Profile & Enter Dashboard',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
