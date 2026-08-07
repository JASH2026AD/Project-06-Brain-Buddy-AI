import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../models/app_user.dart';
import '../../../../models/user_profile.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../settings/presentation/providers/theme_preference_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    final AppUser? user = ref.watch(currentUserProvider);
    final AsyncValue<UserProfile?> profileAsync = ref.watch(userProfileProvider);
    final AsyncValue<ThemeMode> themeModeAsync = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        centerTitle: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              themeModeAsync.asData?.value == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () {
              final ThemeMode current = themeModeAsync.asData?.value ?? ThemeMode.system;
              final ThemeMode next = current == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              final ThemePreferenceNotifier notifier =
                  ref.read(themeModeProvider.notifier);
              notifier.setThemeMode(next);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () {
              _showSignOutDialog(context, ref);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userProfileProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Welcome Hero Header
                profileAsync.when(
                  data: (UserProfile? profile) {
                    final String studentName = profile?.fullName.isNotEmpty == true
                        ? profile!.fullName
                        : (user?.displayName ?? 'Student');
                    final String college = profile?.collegeName ?? 'University';
                    final String major = profile?.major ?? 'General Studies';
                    final String year = profile?.academicYear ?? 'Student';

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      color: colors.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: colors.onPrimaryContainer,
                              foregroundColor: colors.primaryContainer,
                              child: Text(
                                studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Welcome back, $studentName!',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$major • $year',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: colors.onPrimaryContainer.withValues(alpha: 0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    college,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colors.onPrimaryContainer.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const _HeaderLoadingPlaceholder(),
                  error: (error, stackTrace) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Welcome, ${user?.email ?? "Student"}'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Key Academic Metrics Row
                Text(
                  'Academic Progress Overview',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                profileAsync.when(
                  data: (profile) => Row(
                    children: <Widget>[
                      Expanded(
                        child: _MetricCard(
                          title: 'Target GPA',
                          value: '${(profile?.targetGpa ?? 3.8).toStringAsFixed(2)} / 4.0',
                          icon: Icons.stars_rounded,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: 'Study Hours',
                          value: '14.5 hrs',
                          icon: Icons.timer_rounded,
                          color: colors.tertiary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: 'Active Courses',
                          value: '5 Registered',
                          icon: Icons.auto_stories_rounded,
                          color: colors.secondary,
                        ),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stackTrace) => const SizedBox(),
                ),
                const SizedBox(height: 28),

                // AI Companion Quick Assistant Banner (Phase 2 preview)
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(Icons.psychology_rounded, color: colors.primary, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              'AI Study Assistant',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Chip(
                              label: const Text('Gemini 2.5 Flash'),
                              avatar: const Icon(Icons.auto_awesome, size: 16),
                              backgroundColor: colors.primaryContainer,
                              labelStyle: TextStyle(
                                color: colors.onPrimaryContainer,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Ask questions, generate exam flashcards, organize assignment deadlines, or summarize lecture transcripts.',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('AI Assistant Engine ready for Phase 2!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                          label: const Text('Start AI Chat Session'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Quick Action Modules Grid
                Text(
                  'Student Tools & Hub',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: <Widget>[
                    _QuickActionTile(
                      icon: Icons.calendar_month_rounded,
                      title: 'Class Timetable',
                      subtitle: 'Schedules & Reminders',
                      onTap: () {},
                    ),
                    _QuickActionTile(
                      icon: Icons.note_alt_rounded,
                      title: 'Smart Notes',
                      subtitle: 'AI Summary & PDF',
                      onTap: () {},
                    ),
                    _QuickActionTile(
                      icon: Icons.calculate_rounded,
                      title: 'GPA Calculator',
                      subtitle: 'Grade Estimator',
                      onTap: () {},
                    ),
                    _QuickActionTile(
                      icon: Icons.settings_rounded,
                      title: 'App Settings',
                      subtitle: 'Preferences & Sync',
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of AI College Companion?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final AuthController controller =
                  ref.read(authControllerProvider.notifier);
              controller.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: colors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderLoadingPlaceholder extends StatelessWidget {
  const _HeaderLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: SizedBox(
        height: 110,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
