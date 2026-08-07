import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/app_providers.dart';

final FutureProvider<void> firebaseInitializationProvider =
    FutureProvider<void>(
      (Ref ref) => ref.watch(firebaseServiceProvider).initialize(),
    );

class AppInitializationScreen extends ConsumerWidget {
  const AppInitializationScreen({super.key, this.settingsError});

  const AppInitializationScreen.loadingSettings({super.key})
    : settingsError = null;

  const AppInitializationScreen.settingsError(Object error, {super.key})
    : settingsError = error;

  final Object? settingsError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (settingsError != null) {
      return _SetupScaffold(
        title: AppStrings.settingsErrorTitle,
        body: AppStrings.initializationBody,
        error: settingsError,
      );
    }

    final AsyncValue<void> firebaseInitialization = ref.watch(
      firebaseInitializationProvider,
    );
    return firebaseInitialization.when(
      loading: () => const _SetupScaffold(
        title: AppStrings.initializationTitle,
        body: AppStrings.initializationBody,
        isLoading: true,
      ),
      data: (_) => const _SetupScaffold(
        title: AppStrings.firebaseReadyTitle,
        body: AppStrings.firebaseReadyBody,
        isFirebaseReady: true,
      ),
      error: (Object error, StackTrace stackTrace) => _SetupScaffold(
        title: AppStrings.firebasePendingTitle,
        body: AppStrings.firebasePendingBody,
        error: error,
        onRetry: () => ref.invalidate(firebaseInitializationProvider),
      ),
    );
  }
}

class _SetupScaffold extends StatelessWidget {
  const _SetupScaffold({
    required this.title,
    required this.body,
    this.error,
    this.isLoading = false,
    this.isFirebaseReady = false,
    this.onRetry,
  });

  final String title;
  final String body;
  final Object? error;
  final bool isLoading;
  final bool isFirebaseReady;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colors.primaryContainer,
                    foregroundColor: colors.onPrimaryContainer,
                    child: const Icon(Icons.school_rounded, size: 32),
                  ),
                  const SizedBox(height: 24),
                  Text(AppStrings.appName, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Text(title, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Text(body, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            AppStrings.configurationLabel,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          const _StatusRow(
                            label: AppStrings.localStorageReady,
                            isReady: true,
                          ),
                          const SizedBox(height: 12),
                          const _StatusRow(
                            label: AppStrings.materialReady,
                            isReady: true,
                          ),
                          const SizedBox(height: 12),
                          _StatusRow(
                            label: isFirebaseReady
                                ? AppStrings.firebaseReady
                                : AppStrings.firebasePending,
                            isReady: isFirebaseReady,
                            isLoading: isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (error != null) ...<Widget>[
                    const SizedBox(height: 16),
                    ExpansionTile(
                      title: const Text(AppStrings.technicalDetails),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SelectableText(error.toString()),
                        ),
                      ],
                    ),
                  ],
                  if (onRetry != null) ...<Widget>[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text(AppStrings.retry),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(AppStrings.phaseZero, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.phaseZeroDescription,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.isReady,
    this.isLoading = false,
  });

  final String label;
  final bool isReady;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        if (isLoading)
          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else
          Icon(
            isReady ? Icons.check_circle_rounded : Icons.pending_rounded,
            color: isReady ? colors.primary : colors.onSurfaceVariant,
          ),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
      ],
    );
  }
}
