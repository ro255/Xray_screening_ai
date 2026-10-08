import 'package:flutter/material.dart';

/// Brand palette.
///
/// These constants feed [AppTheme]. Inside widgets prefer
/// `Theme.of(context).colorScheme` (and [StatusColors] for success / warning /
/// info) rather than reading them directly, so screens follow the theme.
abstract final class AppColors {
  static const primary = Color(0xFF087E75);
  static const primaryDark = Color(0xFF075F59);
  static const canvas = Color(0xFFF6F9F8);
  static const surface = Colors.white;
  static const ink = Color(0xFF172923);
  static const muted = Color(0xFF71817C);
  static const border = Color(0xFFE4EDEA);
  static const soft = Color(0xFFEAF2F0);
  static const success = Color(0xFF2E7D52);
  static const successSoft = Color(0xFFE4F4EC);
  static const warning = Color(0xFFC7701F);
  static const warningSoft = Color(0xFFFCEFE2);
  static const error = Color(0xFFC6473F);
  static const errorSoft = Color(0xFFFBEAE9);
  static const info = Color(0xFF2F6FB2);
}

/// Corner radii. Bigger surfaces get bigger radii; controls stay at [md].
abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double pill = 999;
}

/// Spacing scale used for gutters and gaps between sections.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
}

abstract final class AppShadows {
  /// Resting card elevation: wide, faint and tinted with the ink colour
  /// (pure-black shadows read grey and heavy on the teal canvas).
  static List<BoxShadow> soft(ColorScheme scheme) => [
        BoxShadow(
          color: scheme.onSurface.withValues(alpha: 0.05),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: scheme.onSurface.withValues(alpha: 0.04),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ];

  /// Coloured glow, reserved for the hero card.
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.30),
          blurRadius: 32,
          spreadRadius: -6,
          offset: const Offset(0, 16),
        ),
      ];
}

abstract final class AppGradients {
  /// Deep teal to brand teal, derived from the scheme's primary colour.
  static LinearGradient brand(ColorScheme scheme) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(
            scheme.shadow.withValues(alpha: 0.32),
            scheme.primary,
          ),
          scheme.primary,
        ],
      );
}

/// A semantic colour with its soft background and readable text colour.
class StatusTone {
  const StatusTone({
    required this.color,
    required this.container,
    required this.onContainer,
  });

  /// Strong colour for icons, badges and meters.
  final Color color;

  /// Soft tinted background.
  final Color container;

  /// Text colour that stays readable on [container].
  final Color onContainer;

  static StatusTone lerp(StatusTone a, StatusTone b, double t) => StatusTone(
        color: Color.lerp(a.color, b.color, t)!,
        container: Color.lerp(a.container, b.container, t)!,
        onContainer: Color.lerp(a.onContainer, b.onContainer, t)!,
      );
}

/// Success / warning / info tones. Material's [ColorScheme] has no slots for
/// these, so they live in a [ThemeExtension]:
///
/// ```dart
/// final tone = StatusColors.of(context).warning;
/// ```
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.success,
    required this.warning,
    required this.info,
  });

  final StatusTone success;
  final StatusTone warning;
  final StatusTone info;

  static const light = StatusColors(
    success: StatusTone(
      color: AppColors.success,
      container: AppColors.successSoft,
      onContainer: Color(0xFF14532D),
    ),
    warning: StatusTone(
      color: AppColors.warning,
      container: AppColors.warningSoft,
      onContainer: Color(0xFF6B3A0A),
    ),
    info: StatusTone(
      color: AppColors.info,
      container: Color(0xFFE3EEF8),
      onContainer: Color(0xFF153E6B),
    ),
  );

  static StatusColors of(BuildContext context) =>
      Theme.of(context).extension<StatusColors>() ?? light;

  @override
  StatusColors copyWith({
    StatusTone? success,
    StatusTone? warning,
    StatusTone? info,
  }) =>
      StatusColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        info: info ?? this.info,
      );

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      success: StatusTone.lerp(success, other.success, t),
      warning: StatusTone.lerp(warning, other.warning, t),
      info: StatusTone.lerp(info, other.info, t),
    );
  }
}

/// Builds the app's Material 3 theme.
abstract final class AppTheme {
  static ThemeData light() {
    final scheme = _colorScheme();
    final text = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      highlightColor: Colors.transparent,
      splashFactory: InkSparkle.splashFactory,
      extensions: const <ThemeExtension<dynamic>>[StatusColors.light],
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      // Colours are intentionally left to Material 3 defaults so that
      // FilledButton and FilledButton.tonal each keep their own look.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 54),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: text.labelLarge?.copyWith(fontSize: 15),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: text.labelLarge,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        border: _outline(scheme.outline),
        enabledBorder: _outline(scheme.outline),
        focusedBorder: _outline(scheme.primary, width: 1.8),
        errorBorder: _outline(scheme.error),
        focusedErrorBorder: _outline(scheme.error, width: 1.8),
        labelStyle:
            text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        hintStyle: text.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainer,
        side: BorderSide.none,
        labelStyle: text.labelMedium,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          side: WidgetStatePropertyAll(
            BorderSide(color: scheme.outlineVariant),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? scheme.primaryContainer
                : scheme.surfaceContainerLowest;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.onSurface.withValues(alpha: 0.38);
            }
            return states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant;
          }),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.labelMedium?.copyWith(
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ColorScheme _colorScheme() {
    return ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD8F0EA),
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.primary,
      secondaryContainer: const Color(0xFFE3F3EF),
      onSecondaryContainer: AppColors.primaryDark,
      surface: AppColors.canvas,
      onSurface: AppColors.ink,
      // A touch darker than AppColors.muted so small text passes AA contrast.
      onSurfaceVariant: const Color(0xFF56665F),
      surfaceContainerLowest: AppColors.surface,
      surfaceContainerLow: const Color(0xFFF1F6F4),
      surfaceContainer: AppColors.soft,
      surfaceContainerHigh: const Color(0xFFE3EDEA),
      surfaceContainerHighest: const Color(0xFFDCE7E3),
      outline: const Color(0xFFC5D5CF),
      outlineVariant: AppColors.border,
      error: AppColors.error,
      errorContainer: AppColors.errorSoft,
      onErrorContainer: const Color(0xFF7A1F1A),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    final base = ThemeData(brightness: Brightness.light, useMaterial3: true)
        .textTheme
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 32,
        height: 1.12,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        height: 1.25,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.45,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }

  static OutlineInputBorder _outline(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}