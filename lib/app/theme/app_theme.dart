import 'package:flutter/material.dart';

/// Semantic colors for rate change direction (finance teal theme).
@immutable
class RateChangeColors extends ThemeExtension<RateChangeColors> {
  const RateChangeColors({
    required this.positive,
    required this.negative,
  });

  /// Green used when EGP strengthens / favorable change display.
  final Color positive;

  /// Red used when EGP weakens / unfavorable change display.
  final Color negative;

  static const light = RateChangeColors(
    positive: Color(0xFF15803D),
    negative: Color(0xFFB91C1C),
  );

  static const dark = RateChangeColors(
    positive: Color(0xFF22C55E),
    negative: Color(0xFFEF4444),
  );

  @override
  RateChangeColors copyWith({Color? positive, Color? negative}) {
    return RateChangeColors(
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
    );
  }

  @override
  RateChangeColors lerp(ThemeExtension<RateChangeColors>? other, double t) {
    if (other is! RateChangeColors) return this;
    return RateChangeColors(
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
    );
  }
}

/// Material 3 themes seeded from teal for a finance look.
abstract final class AppTheme {
  static const Color _seed = Color(0xFF0F766E);

  static ThemeData get light => _build(Brightness.light, RateChangeColors.light);

  static ThemeData get dark => _build(Brightness.dark, RateChangeColors.dark);

  static ThemeData _build(Brightness brightness, RateChangeColors changeColors) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [changeColors],
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
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

    // Rate rows: titleMedium for currency name, bodyLarge for values.
    return platform.copyWith(
      titleMedium: platform.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: platform.bodyLarge?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
