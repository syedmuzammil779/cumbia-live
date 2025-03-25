part of 'theme.dart';

class AppTextStyles {
  const AppTextStyles({required this.color});

  final Color color;

  TextStyle get base => GoogleFonts.mulish(color: color);

  TextStyle get heading => base.withGoogleFont(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32,
        letterSpacing: 0.5,
      );

  TextStyle get display => base
      .withGoogleFont(
        fontSize: 48,
        height: 60,
        letterSpacing: 0.5,
      )
      .regular;

  TextStyle get title => base
      .withGoogleFont(
        fontSize: 40,
        height: 50,
        letterSpacing: 0.5,
      )
      .bold;

  TextStyle get subHeadingLarge => base
      .withGoogleFont(
        fontSize: 16,
        height: 20,
        letterSpacing: 0.5,
      )
      .medium;

  TextStyle get subHeadingSmall => base
      .withGoogleFont(
        fontSize: 14,
        height: 18,
        letterSpacing: 0.5,
      )
      .medium;

  TextStyle get labelSmall => base
      .withGoogleFont(
        fontSize: 12,
        height: 15,
        letterSpacing: 0,
      )
      .regular;

  TextStyle get labelMedium => base
      .withGoogleFont(
        fontSize: 14,
        height: 17.5,
        letterSpacing: 0,
      )
      .regular;

  TextStyle get displayMedium => base.withGoogleFont(
        fontSize: 45,
        fontWeight: FontWeight.w500,
        height: 52,
      );

  TextStyle get placeholder => base.withGoogleFont(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 17.5,
        letterSpacing: 0.5,
      );

  TextStyle get bodySmall => base.withGoogleFont(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 17.5,
        letterSpacing: 0.5,
      );

  TextStyle get bodyLarge => base.withGoogleFont(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 20,
        letterSpacing: 0,
      );

  TextStyle get textSmall => base.withGoogleFont(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16,
        letterSpacing: 0.5,
      );

  TextStyle get textLarge => base.withGoogleFont(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 17.5,
        letterSpacing: 0.5,
      );
}

extension TextThemeContext on BuildContext {
  AppTextStyles get textStyles => AppTextStyles(
        color: const AppColors.light().colorScheme.onSurface,
      );

  TextStyle? get heading => textStyles.heading;

  TextStyle? get display => textStyles.display;

  TextStyle? get title => textStyles.title;

  TextStyle? get labelSmall => textStyles.labelSmall;

  TextStyle? get labelMedium => textStyles.labelMedium;

  TextStyle? get subHeadingLarge => textStyles.subHeadingLarge;

  TextStyle? get subHeadingSmall => textStyles.subHeadingSmall;

  TextStyle? get placeholder => textStyles.placeholder;

  TextStyle? get bodySmall => textStyles.bodySmall;

  TextStyle? get bodyLarge => textStyles.bodyLarge;

  TextStyle? get textSmall => textStyles.textSmall;

  TextStyle? get textLarge => textStyles.textLarge;
}

extension TextStyleWeight on TextStyle {
  /// w700
  TextStyle get bold => withGoogleFont(fontWeight: FontWeight.w700);

  /// w600
  TextStyle get semiBold => withGoogleFont(fontWeight: FontWeight.w600);

  /// w500
  TextStyle get medium => withGoogleFont(fontWeight: FontWeight.w500);

  /// w400
  TextStyle get regular => withGoogleFont(fontWeight: FontWeight.w400);

  TextStyle get underline => withGoogleFont(
        decoration: TextDecoration.underline,
      );
}

extension TextStyleWithGoogleFont on TextStyle {
  TextStyle withGoogleFont({
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,

    /// [height] in logical pixels as defined in Figma.
    /// It will be transformed into percentage as required by Flutter.
    double? height,

    /// [letterSpacing] in percentage as defined in Figma.
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.getFont(
      googleFontFamily,
      textStyle: copyWith(
        fontWeight: fontWeight,
        fontSize: fontSize,
        color: color,
        height: 12,
        letterSpacing: letterSpacing,
        decoration: decoration,
      ),
    );
  }

  double get heightInPixel => (height ?? 0) * (fontSize ?? 0);

  String get googleFontFamily {
    if (fontFamily == null) return 'Mulish';
    final family = fontFamily!.split('_').first;
    return family
        .splitMapJoin(
          RegExp('[A-Z][a-z]*'),
          onMatch: (m) => ' ${m.group(0)}',
          onNonMatch: (n) => '',
        )
        .trim();
  }
}

extension FigmaTextWeght on TextStyle {
  /// bold
  TextStyle get w700 => bold;

  /// semiBold
  TextStyle get w600 => semiBold;

  /// medium
  TextStyle get w500 => medium;

  /// regular
  TextStyle get w400 => regular;
}

enum HeadingStyle {
  /// {@macro headlineLarge}
  h1,

  /// {@macro headlineSmall}
  h2,

  /// {@macro titleLarge}
  h3,

  /// {@macro titleMedium}
  h4,

}

enum BodyStyle {
  /// {@macro bodyLarge}
  b1,

  /// {@macro bodyMedium}
  b2,

  /// {@macro bodySmall}
  b3,

}

// extension TextStyleToCSS on TextStyle {
//   StringMap get css => {
//         'font-family': googleFontFamily,
//         'font-size': '${fontSize}px',
//         'font-style': fontStyle?.name ?? 'normal',
//         'font-weight': (fontWeight?.value ?? 400).toString(),
//         'line-height': '${heightInPixel}px',
//         'letter-spacing': '${letterSpacing}px',
//         'color': color?.toHex(alpha: false) ?? 'black',
//       };
// }
