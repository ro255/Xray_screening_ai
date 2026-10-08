import 'package:diesease_ai_app/core/app_language.dart';
import 'package:diesease_ai_app/core/app_theme.dart';
import 'package:diesease_ai_app/core/app_widget.dart';
import 'package:diesease_ai_app/core/screening_module.dart';
import 'package:diesease_ai_app/feature/xray/xray_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final health = context.read<Future<HealthStatus>>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: _Header()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        _Greeting(strings: strings),
                        _HealthStatusPill(health: health),
                        const SizedBox(height: AppSpacing.lg),
                        _FeaturedCard(
                          strings: strings,
                          onPressed: () => context.go('/xray'),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        _SectionHeader(
                          title: strings.screeningServices,
                          badge: '${modules.length} ${strings.services}',
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
                const _ServiceGrid(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    child: InfoNote(text: strings.screeningDisclaimer),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _openModule(BuildContext context, ScreeningModule module) {
  if (module.enabled) {
    context.go(module.route);
    return;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(AppStrings.of(context).unavailable)),
    );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 20, AppSpacing.lg, 0),
      child: Row(
        children: [
          IconBadge(
            icon: Icons.health_and_safety_rounded,
            size: 44,
            background: scheme.primary,
            foreground: scheme.onPrimary,
          ),
          const SizedBox(width: 12),
          Text('AfyaCheck', style: textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.welcome,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Text(strings.healthMatters, style: theme.textTheme.headlineLarge),
      ],
    );
  }
}

class _HealthStatusPill extends StatelessWidget {
  const _HealthStatusPill({required this.health});

  final Future<HealthStatus> health;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final scheme = Theme.of(context).colorScheme;
    final status = StatusColors.of(context);
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topLeft,
      child: FutureBuilder<HealthStatus>(
        future: health,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done ||
              !snapshot.hasData) {
            return const SizedBox.shrink();
          }
          final h = snapshot.data!;
          final ok = h.isOk;
          final tone = ok
              ? status.success
              : StatusTone(
                  color: scheme.error,
                  container: scheme.errorContainer,
                  onContainer: scheme.onErrorContainer,
                );

          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusPill(
                icon: ok ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                label: ok ? strings.serviceReady : strings.serviceDegraded,
                tone: tone,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.strings, required this.onPressed});

  final AppStrings strings;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final borderRadius = BorderRadius.circular(AppRadius.xl);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppGradients.brand(scheme),
        borderRadius: borderRadius,
        boxShadow: AppShadows.glow(scheme.primary),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            const Positioned(top: -41, right: -41, child: _ScanRing(size: 190)),
            const Positioned(top: -6, right: -6, child: _ScanRing(size: 120)),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _HeroTag(label: strings.available),
                      const Spacer(),
                      const _HeroIconTile(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    strings.xrayScreening,
                    style: textTheme.headlineSmall?.copyWith(
                      color: scheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    strings.xrayDescription,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: onPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.onPrimary,
                      foregroundColor: scheme.primary,
                    ),
                    icon: const Icon(Icons.document_scanner_rounded, size: 20),
                    label: Text(strings.startScreening),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.onPrimary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded, size: 14, color: scheme.onPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(color: scheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroIconTile extends StatelessWidget {
  const _HeroIconTile();

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return IconBadge(
      icon: Icons.medical_information_rounded,
      size: 52,
      iconSize: 26,
      radius: 18,
      background: onPrimary.withValues(alpha: 0.18),
      foreground: onPrimary,
    );
  }
}

class _ScanRing extends StatelessWidget {
  const _ScanRing({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onPrimary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.14), width: 1.2),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.badge});

  final String title;
  final String badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(child: Text(title, style: textTheme.titleLarge)),
        const SizedBox(width: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              badge,
              style: textTheme.labelMedium?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          mainAxisExtent: 184,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _ServiceCard(
            module: modules[index],
            onTap: () => _openModule(context, modules[index]),
          ),
          childCount: modules.length,
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.module, required this.onTap});

  final ScreeningModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final available = module.enabled;
    return SoftCard(
      onTap: onTap,
      elevated: available,
      color: available ? null : scheme.surfaceContainerLow,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconBadge(
                icon: module.icon,
                size: 46,
                background: available
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHigh,
                foreground: available
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
              if (!available)
                Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.moduleTitle(module.id, module.title),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium?.copyWith(
                  color: available
                      ? scheme.onSurface
                      : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                available
                    ? strings.moduleSubtitle(module.id, module.subtitle)
                    : strings.comingSoon,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}