import 'package:flutter/material.dart';

/// Semantic colors for EGP rate-change direction.
@immutable
class RateColors extends ThemeExtension<RateColors> {
  const RateColors({
    required this.egpStrengthening,
    required this.egpWeakening,
  });

  /// Green — EGP strengthens when foreign rate decreases (`change < 0`).
  final Color egpStrengthening;

  /// Red — EGP weakens when foreign rate increases (`change > 0`).
  final Color egpWeakening;

  static const light = RateColors(
    egpStrengthening: Color(0xFF15803D),
    egpWeakening: Color(0xFFB91C1C),
  );

  static const dark = RateColors(
    egpStrengthening: Color(0xFF4ADE80),
    egpWeakening: Color(0xFFF87171),
  );

  @override
  RateColors copyWith({
    Color? egpStrengthening,
    Color? egpWeakening,
  }) {
    return RateColors(
      egpStrengthening: egpStrengthening ?? this.egpStrengthening,
      egpWeakening: egpWeakening ?? this.egpWeakening,
    );
  }

  @override
  RateColors lerp(ThemeExtension<RateColors>? other, double t) {
    if (other is! RateColors) return this;
    return RateColors(
      egpStrengthening:
          Color.lerp(egpStrengthening, other.egpStrengthening, t)!,
      egpWeakening: Color.lerp(egpWeakening, other.egpWeakening, t)!,
    );
  }
}

/// Material 3 themes seeded from teal for a finance look.
abstract final class AppTheme {
  static const Color _seed = Color(0xFF0F766E);

  static ThemeData get light => _build(Brightness.light, RateColors.light);

  static ThemeData get dark => _build(Brightness.dark, RateColors.dark);

  static RateColors rateColors(BuildContext context) =>
      Theme.of(context).extension<RateColors>()!;

  static ThemeData _build(Brightness brightness, RateColors rateColors) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [rateColors],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: _textTheme(colorScheme),
    );
  }

  static TextTheme _textTheme(ColorScheme colorScheme) {
    final base = Typography.material2021(colorScheme: colorScheme);
    final platform = base.black.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return platform.copyWith(
      titleMedium: platform.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      titleLarge: platform.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      bodyLarge: platform.bodyLarge?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
