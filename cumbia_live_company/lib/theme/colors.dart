part of 'theme.dart';

const _kLightColor = Color(0xFFFFFFFF);
const _kDarkColor = Color(0xFF000000);

class AppColors {
  const AppColors({
    required this.colorScheme,
    required this.extendedColorScheme,
    this.topBarColorScheme = lightTopBarColorScheme,
  });

  const AppColors.light()
      : colorScheme = lightColorScheme,
        extendedColorScheme = lightExtendedColorScheme,
        topBarColorScheme = lightTopBarColorScheme;

  const AppColors.dark()
      : colorScheme = darkColorScheme,
        extendedColorScheme = darkExtendedColorScheme,
        topBarColorScheme = darkTopBarColorScheme;

  factory AppColors.fromBrightness(Brightness? brightness) =>
      brightness == Brightness.dark
          ? const AppColors.dark()
          : const AppColors.light();

  final ColorScheme colorScheme;
  final ExtendedColorScheme extendedColorScheme;
  final TopBarColorScheme topBarColorScheme;

  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFEB7847),
    inversePrimary: Color(0xFFE9F1FF),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF212121),
    onPrimaryContainer: Color(0x80FFFFFF),
    secondary: Color(0xB2212121),
    onSecondary: Color(0xFF757575),
    secondaryContainer: Color(0xFFE4D9FF),
    onSecondaryContainer: Color(0xFF232329),
    tertiary: Color(0xFF232329),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFC9CACB),
    onTertiaryContainer: Color(0xFF888888),
    error: Color(0xFFFF0404),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFB4AB),
    onErrorContainer: Color(0xFF232329),
    surface: Color(0xFF080808),
    surfaceContainer: Color(0xFF121212),
    surfaceTint: Color(0xFFFFFFFF),
    onSurface: Color(0xFFFFFFFF),
    surfaceDim: Color(0xFFE7E8E9),
    onSurfaceVariant: Color(0xFFAAAAAA),
    inverseSurface: Color(0xFF5D5D6B),
    onInverseSurface: Color(0xFFFFFFFF),
    outline: Color(0x80FFFFFF),
    outlineVariant: Color(0xFF888888),
    shadow: Color(0xFFDADADA),
    scrim: Color(0xCC000000),
  );

  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFE9F1FF),
    inversePrimary: Color(0xFF0F186C),
    onPrimary: Color(0xFF000000),
    primaryContainer: Color(0xFF0F186C),
    onPrimaryContainer: Color(0xFFFFFFFF),
    secondary: Color(0xFFE4D9FF),
    onSecondary: Color(0xFF000000),
    secondaryContainer: Color(0xFF316EE4),
    onSecondaryContainer: Color(0xFFFFFFFF),
    tertiary: Color(0xFFC9CACB),
    onTertiary: Color(0xFF888888),
    tertiaryContainer: Color(0xFF000000),
    onTertiaryContainer: Color(0xFFFFFFFF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF000000),
    errorContainer: Color(0xFFBA1A1A),
    onErrorContainer: Color(0xFFFFFFFF),
    surface: Color(0xFF000000),
    surfaceContainer: Color(0xFF121212),
    surfaceTint: Color(0xFF000000),
    onSurface: Color(0xFFFFFFFF),
    surfaceDim: Color(0xFF5D5D6B),
    onSurfaceVariant: Color(0xFFE7E8E9),
    inverseSurface: Color(0xFFFFFFFF),
    onInverseSurface: Color(0xFF000000),
    outline: Color(0xFF888888),
    outlineVariant: Color(0xFFDADADA),
    shadow: Color(0xFF000000),
    scrim: Color(0xCCFFFFFF),
  );

  static const lightExtendedColorScheme = ExtendedColorScheme(
    primaryVariant: Color(0xFF061937),
    onPrimaryVariant: Color(0xFFFFFFFF),
    onContainerVariant: Color(0xFFFFFFFF),
    containerVariant: Color(0xFF2A2A2A),
    success: Color(0xFF00AC47),
    successVariant: Color(0xFF30702B),
    inactive: Color(0xFFF7F7F7),
    buttonGradient: LinearGradient(
      colors: [
        Color(0xFFF27C4A),
        Color(0xFF922B00),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const darkExtendedColorScheme = ExtendedColorScheme(
    primaryVariant: Color(0xFF061937),
    onPrimaryVariant: Color(0xFFFFFFFF),
    onContainerVariant: Color(0xFFFFFFFF),
    containerVariant: Color(0xFF2A2A2A),
    success: Color(0xFF00AC47),
    successVariant: Color(0xFF30702B),
    inactive: Color(0xFF2C2C2C),
    buttonGradient: LinearGradient(
      colors: [
        Color(0xFFF27C4A),
        Color(0xFF922B00),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const lightTopBarColorScheme = TopBarColorScheme(
    brightness: Brightness.dark,
    background: Color(0xffE2F4F7),
    foreground: Color(0xFFFFFFFF),
    controls: Color(0xFFFFFFFF),
    onControls: Color(0xFF061937),
    disabled: Color(0xFFC9CACB),
    onDisabled: Color(0xFF384456),
  );

  static const darkTopBarColorScheme = TopBarColorScheme(
    brightness: Brightness.dark,
    background: Color(0xffE2F4F7),
    foreground: Color(0xFFFFFFFF),
    controls: Color(0xFFFFFFFF),
    onControls: Color(0xFF061937),
    disabled: Color(0xFFC9CACB),
    onDisabled: Color(0xFF384456),
  );
}

@immutable
class ExtendedColorScheme extends ThemeExtension<ExtendedColorScheme> {
  const ExtendedColorScheme({
    required this.primaryVariant,
    required this.onPrimaryVariant,
    required this.onContainerVariant,
    required this.containerVariant,
    required this.success,
    required this.successVariant,
    required this.inactive,
    required this.buttonGradient,
  });

  final Color primaryVariant;
  final Color onPrimaryVariant;
  final Color onContainerVariant;
  final Color success;
  final Color successVariant;
  final Color inactive;
  final Color containerVariant;
  final LinearGradient buttonGradient;

  @override
  ExtendedColorScheme copyWith({
    Color? primaryVariant,
    Color? onPrimaryVariant,
    Color? success,
    Color? successVariant,
    Color? inactive,
    Color? containerVariant,
    Color? onContainerVariant,
    LinearGradient? buttonGradient,
  }) {
    return ExtendedColorScheme(
      primaryVariant: primaryVariant ?? this.primaryVariant,
      onPrimaryVariant: onPrimaryVariant ?? this.onPrimaryVariant,
      onContainerVariant: onContainerVariant ?? this.onContainerVariant,
      containerVariant: containerVariant ?? this.containerVariant,
      success: success ?? this.success,
      successVariant: successVariant ?? this.successVariant,
      inactive: inactive ?? this.inactive,
      buttonGradient: buttonGradient ?? this.buttonGradient,
    );
  }

  @override
  ExtendedColorScheme lerp(
    ThemeExtension<ExtendedColorScheme>? other,
    double t,
  ) {
    if (other is! ExtendedColorScheme) {
      return this;
    }
    return ExtendedColorScheme(
      primaryVariant: Color.lerp(primaryVariant, other.primaryVariant, t)!,
      onPrimaryVariant:
          Color.lerp(onPrimaryVariant, other.onPrimaryVariant, t)!,
      onContainerVariant:
          Color.lerp(onContainerVariant, other.onContainerVariant, t)!,
      containerVariant:
          Color.lerp(containerVariant, other.containerVariant, t)!,
      success: Color.lerp(success, other.success, t)!,
      successVariant: Color.lerp(successVariant, other.successVariant, t)!,
      inactive: Color.lerp(inactive, other.inactive, t)!,
      buttonGradient: const LinearGradient(
        colors: [
          Color(0xFFF27C4A),
          Color(0xFF922B00),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}

@immutable
class TopBarColorScheme extends ThemeExtension<TopBarColorScheme> {
  const TopBarColorScheme({
    required this.brightness,
    required this.background,
    required this.foreground,
    required this.controls,
    required this.onControls,
    required this.disabled,
    required this.onDisabled,
  });

  final Brightness brightness;
  final Color background;
  final Color foreground;
  final Color controls;
  final Color onControls;
  final Color disabled;
  final Color onDisabled;

  @override
  TopBarColorScheme copyWith({
    Brightness? brightness,
    Color? background,
    Color? foreground,
    Color? controls,
    Color? onControls,
    Color? disabled,
    Color? onDisabled,
  }) {
    return TopBarColorScheme(
      brightness: brightness ?? this.brightness,
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      controls: controls ?? this.controls,
      onControls: onControls ?? this.onControls,
      disabled: disabled ?? this.disabled,
      onDisabled: onDisabled ?? this.onDisabled,
    );
  }

  @override
  TopBarColorScheme lerp(ThemeExtension<TopBarColorScheme>? other, double t) {
    if (other is! TopBarColorScheme) {
      return this;
    }
    return TopBarColorScheme(
      brightness: brightness,
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      controls: Color.lerp(controls, other.controls, t)!,
      onControls: Color.lerp(onControls, other.onControls, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      onDisabled: Color.lerp(onDisabled, other.onDisabled, t)!,
    );
  }
}

extension ColorSchemeContext on BuildContext {

  Color get primary => colorScheme.primary;

  Color get onPrimary => colorScheme.onPrimary;

  Color get container => colorScheme.primaryContainer;

  Color get onContainer => colorScheme.onPrimaryContainer;

  Color get onContainerVariant => extendedColorScheme.onContainerVariant;

  Color get containerVariant => extendedColorScheme.containerVariant;

  Color get secondary => colorScheme.secondary;

  Color get onSecondary => colorScheme.onSecondary;

  Color get secondaryContainer => colorScheme.secondaryContainer;

  Color get onSecondaryContainer => colorScheme.onSecondaryContainer;

  Color get tertiary => colorScheme.tertiary;

  Color get onTertiary => colorScheme.onTertiary;

  Color get tertiaryContainer => colorScheme.tertiaryContainer;

  Color get onTertiaryContainer => colorScheme.onTertiaryContainer;

  Color get error => colorScheme.error;

  Color get onError => colorScheme.onError;

  Color get errorContainer => colorScheme.errorContainer;

  Color get onErrorContainer => colorScheme.onErrorContainer;

  Color get background => colorScheme.surface;

  Color get onBackground => colorScheme.onSurface;

  Color get surface => colorScheme.surface;

  Color get surfaceContainer => colorScheme.surfaceContainer;

  Color get onSurface => colorScheme.onSurface;

  Color get surfaceVariant => colorScheme.surfaceDim;

  Color get onSurfaceVariant => colorScheme.onSurfaceVariant;

  Color get inverseSurface => colorScheme.inverseSurface;

  Color get onInverseSurface => colorScheme.onInverseSurface;

  Color get outline => colorScheme.outline;

  Color get outlineVariant => colorScheme.outlineVariant;

  Color get shadow => colorScheme.shadow;

  Color get scrim => colorScheme.scrim;

  Color get primaryVariant => extendedColorScheme.primaryVariant;

  Color get onPrimaryVariant => extendedColorScheme.onPrimaryVariant;

  Color get success => extendedColorScheme.success;

  Color get inactive => extendedColorScheme.inactive;

  Color get topBarBackground => topBarColorScheme.background;

  Color get topBarForeground => topBarColorScheme.foreground;

  Color get topBarControls => topBarColorScheme.controls;

  Color get topBarOnControls => topBarColorScheme.onControls;

  Color get hint => colorScheme.outlineVariant;

  Color get subtitle => colorScheme.onSurfaceVariant;

  Color get dark => _kDarkColor;

  Color get onDark => _kLightColor;

  Color get light => _kLightColor;

  Color get onLight => _kDarkColor;

  LinearGradient get buttonGradient => extendedColorScheme.buttonGradient;
}

extension TextStyleColor on TextStyle {
  TextStyle withColor(Color? color) => withGoogleFont(color: color);

  TextStyle primary(BuildContext context) => withColor(context.primary);

  TextStyle onPrimary(BuildContext context) => withColor(context.onPrimary);

  TextStyle primaryContainer(BuildContext context) =>
      withColor(context.container);

  TextStyle onPrimaryContainer(BuildContext context) =>
      withColor(context.onContainer);

  TextStyle secondary(BuildContext context) => withColor(context.secondary);

  TextStyle onSecondary(BuildContext context) => withColor(context.onSecondary);

  TextStyle secondaryContainer(BuildContext context) =>
      withColor(context.secondaryContainer);

  TextStyle onSecondaryContainer(BuildContext context) =>
      withColor(context.onSecondaryContainer);

  TextStyle tertiary(BuildContext context) => withColor(context.tertiary);

  TextStyle onTertiary(BuildContext context) => withColor(context.onTertiary);

  TextStyle tertiaryContainer(BuildContext context) =>
      withColor(context.tertiaryContainer);

  TextStyle onTertiaryContainer(BuildContext context) =>
      withColor(context.onTertiaryContainer);

  TextStyle error(BuildContext context) => withColor(context.error);

  TextStyle onError(BuildContext context) => withColor(context.onError);

  TextStyle errorContainer(BuildContext context) =>
      withColor(context.errorContainer);

  TextStyle onErrorContainer(BuildContext context) =>
      withColor(context.onErrorContainer);

  TextStyle background(BuildContext context) => withColor(context.onBackground);

  TextStyle onBackground(BuildContext context) =>
      withColor(context.onBackground);

  TextStyle surface(BuildContext context) => withColor(context.surface);

  TextStyle onSurface(BuildContext context) => withColor(context.onSurface);

  TextStyle surfaceVariant(BuildContext context) =>
      withColor(context.surfaceVariant);

  TextStyle onSurfaceVariant(BuildContext context) =>
      withColor(context.onSurfaceVariant);

  TextStyle inverseSurface(BuildContext context) =>
      withColor(context.inverseSurface);

  TextStyle onInverseSurface(BuildContext context) =>
      withColor(context.onInverseSurface);

  TextStyle outline(BuildContext context) => withColor(context.outline);

  TextStyle outlineVariant(BuildContext context) =>
      withColor(context.outlineVariant);

  TextStyle primaryVariant(BuildContext context) =>
      withColor(context.primaryVariant);

  TextStyle onPrimaryVariant(BuildContext context) =>
      withColor(context.onPrimaryVariant);

  TextStyle success(BuildContext context) => withColor(context.success);

  TextStyle inactive(BuildContext context) => withColor(context.inactive);

  TextStyle topBarBackground(BuildContext context) =>
      withColor(context.topBarBackground);

  TextStyle topBarForeground(BuildContext context) =>
      withColor(context.topBarForeground);

  TextStyle topBarControls(BuildContext context) =>
      withColor(context.topBarControls);

  TextStyle topBarOnControls(BuildContext context) =>
      withColor(context.topBarOnControls);

  TextStyle hint([BuildContext? context]) =>
      withColor(context?.hint ?? color?.hint);

  TextStyle subtitle(BuildContext context) => withColor(context.subtitle);

  TextStyle highlight() => withColor(color?.highlight);

  TextStyle onDark(BuildContext context) => withColor(context.onDark);

  TextStyle onLight(BuildContext context) => withColor(context.onLight);
}

extension ColorOpacity on Color {
  Color get highlight => withValues(alpha: 0.7);
  Color get hint => withValues(alpha: 0.6);
  Color get outline => withValues(alpha: 0.4);
  Color get pressed => withValues(alpha: 0.3);
  Color get splash => withValues(alpha: 0.05);

  /// Returns the color with 15% opacity.
  Color get lighted => withValues(alpha: 0.15);

  /// Returns the color with 55% opacity.
  Color get subbed => withValues(alpha: 0.55);
}

extension ColorContrast on Color {
  bool get isDark => (299 * red + 587 * green + 114 * blue) / 1000 < 162;

  bool get isLight => !isDark;

  Color get contrast => isDark ? Colors.white : Colors.black;

  Color? get notDark => isDark ? null : this;

  Brightness get brightness => isDark ? Brightness.light : Brightness.dark;

  Color get darker => withBlue(max(blue - 50, 0))
      .withGreen(max(green - 50, 0))
      .withRed(max(red - 50, 0));
}

extension RandomObject on Object {
  /// Returns random integer seeded with [hashCode] and less than [max]
  int random(int max) => Random(hashCode).nextInt(max);
}

extension StringColor on String {
  /// Returns random color seeded with [hashCode] of the string
  Color get color => _Colors.random(this);
}

class _Colors {
  const _Colors._();

  static const charcoal = Color(0xff252525);
  static const livid = Color(0xff395b74);
  static const lividLight = Color(0xff78909c);
  static const lividDark = Color(0xff2d495e);
  static const amber = Color(0xffffca28);
  static const orange = Color(0xffe5680f);
  static const orangeEve = Color(0xffe84d01);
  static const brown = Color(0xff795548);
  static const red = Color(0xffd50000);
  static const redLight = Color(0xffef5350);
  static const redDark = Color(0xffb40000);
  static const cherry = Color(0xffc72349);
  static const cherryDark = Color(0xffaf1e40);
  static const pink = Color(0xffad1457);
  static const pinkLight = Color(0xffec407a);
  static const pinkDark = Color(0xff790e3c);
  static const sky = Color(0xff1E88E5);
  static const skyLight = Color(0xff42a5f5);
  static const blue = Color(0xff1769aa);
  static const blueDark = Color(0xff14578c);
  static const indigoLight = Color(0xff5c6bc0);
  static const indigoDark = Color(0xff2c387e);
  static const purple = Color(0xff9c27b0);
  static const purpleDark = Color(0xff6d1b7b);
  static const purpleEve = Color(0xff723b48);
  static const violet = Color(0xff673ab7);
  static const violetDark = Color(0xff482880);
  static const plum = Color(0xff625b91);
  static const plumDark = Color(0xff514a78);
  static const teal = Color(0xff039694);
  static const tealDark = Color(0xff006974);
  static const green = Color(0xff0F9D58);
  static const greenLight = Color(0xff7cb342);
  static const greenLighter = Color(0xff66bb6a);
  static const greenDark = Color(0xff0d844a);

  static Color random(String seed) => colors[seed.random(colors.length)];

  static const colors = [
    charcoal,
    Colors.lightBlueAccent,
    livid,
    Colors.teal,
    amber,
    pinkDark,
    orange,
    Colors.indigoAccent,
    pinkLight,
    Colors.lightBlue,
    redLight,
    Colors.green,
    cherry,
    Colors.lightGreen,
    purpleEve,
    greenDark,
    Colors.blueAccent,
    violet,
    Colors.blueGrey,
    greenLighter,
    Colors.deepOrangeAccent,
    cherryDark,
    lividDark,
    Colors.blue,
    pink,
    skyLight,
    Colors.greenAccent,
    indigoDark,
    green,
    Colors.pinkAccent,
    plum,
    Colors.orange,
    indigoLight,
    Colors.pink,
    orangeEve,
    Colors.amber,
    sky,
    red,
    Colors.orangeAccent,
    purpleDark,
    greenLight,
    blue,
    Colors.deepPurple,
    redDark,
    Colors.purple,
    plumDark,
    purple,
    teal,
    Colors.indigo,
    violetDark,
    tealDark,
    Colors.purpleAccent,
    blueDark,
    lividLight,
    Colors.deepPurpleAccent,
    brown,
  ];
}
