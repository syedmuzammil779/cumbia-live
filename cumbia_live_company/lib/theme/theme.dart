import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

part 'colors.dart';
part 'directionality.dart';
part 'text_styles.dart';

const kDefaultToolbarHeight = 64.0;

class AppTheme {
  AppTheme({
    required this.colors,
    AppTextStyles? textStyles,
  }) : textStyles = textStyles ??
            AppTextStyles(
              color: colors.colorScheme.onSurface,
            );

  factory AppTheme.light() => AppTheme(colors: const AppColors.light());

  factory AppTheme.dark() => AppTheme(colors: const AppColors.dark());

  final AppColors colors;
  final AppTextStyles textStyles;

  ThemeData data(BuildContext context) => _builder(
        mediaQuery: MediaQuery.of(context),
        colors: colors,
        textStyles: textStyles,
      );

  ThemeData _builder({
    required MediaQueryData mediaQuery,
    required AppColors colors,
    required AppTextStyles textStyles,
  }) {
    final colorScheme = colors.colorScheme;
    final extendedColorScheme = colors.extendedColorScheme;
    final topBarColorScheme = colors.topBarColorScheme;
    final iconTheme = IconThemeData(
      size: 24,
      color: colorScheme.primary,
    );
    const grey50 = Color(0xFFF4F5F6);
    final timeBackgroundColor = WidgetStateColor.resolveWith(
      (states) {
        if (states.isNotEmpty) return colorScheme.primary;
        return grey50;
      },
    );
    final timeTextColor = WidgetStateColor.resolveWith(
      (states) {
        if (states.isNotEmpty) return colorScheme.onPrimary;
        return colorScheme.onSurface;
      },
    );
    return ThemeData(
      useMaterial3: true,
      canvasColor: colorScheme.surface,
      scaffoldBackgroundColor: colorScheme.surface,
      colorScheme: colorScheme,
      extensions: [extendedColorScheme, topBarColorScheme],
      hintColor: colorScheme.outlineVariant,
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.transparent,
        headerHeadlineStyle:
            textStyles.bodySmall.withColor(colorScheme.onSurface),
        // headerBackgroundColor: colorScheme.onSurface,
        // headerForegroundColor: colorScheme.surface,
        weekdayStyle: textStyles.textSmall.withColor(colorScheme.onSurface),
        // surfaceTintColor: colorScheme.primary,
        dayStyle: textStyles.bodySmall.withColor(colorScheme.onSurface),
        // dayBackgroundColor: WidgetStatePropertyAll(colorScheme.onSurface),
        // dayShape: const WidgetStatePropertyAll(CircleBorder()),
        // rangePickerBackgroundColor: colorScheme.onSurface,
        rangePickerHeaderHeadlineStyle:
            textStyles.bodySmall.withColor(colorScheme.onSurface),
        // rangePickerShape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.vertical(
        //     top: Radius.circular(16),
        //   ),
        // ),
        // rangePickerElevation: 2,
        // rangePickerSurfaceTintColor: colorScheme.primary,
        /*inputDecorationTheme: InputDecorationTheme(
          filled: false,
          fillColor: colorScheme.onSurfaceVariant,
          contentPadding: EdgeInsets.zero,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),*/
      ),
      timePickerTheme: TimePickerThemeData(
        hourMinuteColor: timeBackgroundColor,
        hourMinuteTextColor: timeTextColor,
        dayPeriodColor: timeBackgroundColor,
        dayPeriodTextColor: timeTextColor,
        dialHandColor: colorScheme.primary,
        dialTextColor: timeTextColor,
        dialBackgroundColor: grey50,
        entryModeIconColor: const Color(0xFF3B4B59),
        padding: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        shadowColor: colorScheme.shadow,
        surfaceTintColor: topBarColorScheme.background,
        backgroundColor: topBarColorScheme.background,
        foregroundColor: topBarColorScheme.foreground,
        actionsIconTheme: iconTheme.copyWith(color: topBarColorScheme.controls),
        iconTheme: iconTheme.copyWith(color: topBarColorScheme.controls),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: topBarColorScheme.brightness,
          statusBarIconBrightness: topBarColorScheme.brightness.inverse,
          systemNavigationBarColor: colorScheme.surface,
          systemNavigationBarIconBrightness: colorScheme.brightness.inverse,
        ),
      ),
      iconTheme: iconTheme,
      primaryIconTheme: iconTheme,
      navigationBarTheme: NavigationBarThemeData(
        height: 56,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        surfaceTintColor: colorScheme.surface,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.isNotEmpty) {
            return textStyles.bodySmall.withColor(colorScheme.primary);
          }
          return textStyles.bodySmall.withColor(colorScheme.onSurfaceVariant);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.isNotEmpty) {
            return iconTheme;
          }
          return iconTheme.copyWith(color: colorScheme.onSurfaceVariant);
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        // selectedLabelStyle: textStyles.bodySmall,
        // unselectedLabelStyle: textStyles.bodySmall,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      bottomAppBarTheme: BottomAppBarTheme(
        elevation: 0,
        color: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        modalBackgroundColor: colorScheme.surface,
        modalElevation: 0,
        clipBehavior: Clip.antiAlias,
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height -
              (mediaQuery.padding.top + kDefaultToolbarHeight),
        ),
        dragHandleColor: const Color(0xff79747E),
        dragHandleSize: const Size(32, 4),
        showDragHandle: false,
        surfaceTintColor: colorScheme.surface,
        shadowColor: colorScheme.shadow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 1,
        space: 0,
        color: colorScheme.outline,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        insetPadding: EdgeInsets.fromLTRB(16, 16, 16, 32),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) return null;
            return const Color(0xff3B4B59);
          },
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) return null;
            return const Color(0xff3B4B59);
          },
        ),
      ),
      textTheme: TextTheme(
        displayLarge: textStyles.heading,
        displayMedium: textStyles.displayMedium,
        displaySmall: textStyles.bodySmall,
        headlineLarge: textStyles.heading,
        headlineMedium: textStyles.subHeadingLarge,
        headlineSmall: textStyles.subHeadingSmall,
        titleLarge: textStyles.title,
        titleMedium: textStyles.title,
        titleSmall: textStyles.title,
        labelLarge: textStyles.labelMedium,
        labelMedium: textStyles.labelMedium,
        labelSmall: textStyles.labelSmall,
        bodyLarge: textStyles.bodyLarge,
        bodyMedium: textStyles.bodyLarge,
        bodySmall: textStyles.bodySmall,
      ),
      fontFamily: textStyles.base.googleFontFamily,
    );
  }
}

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  IconThemeData get iconTheme => IconTheme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  ExtendedColorScheme get extendedColorScheme =>
      theme.extensions[ExtendedColorScheme]! as ExtendedColorScheme;

  TopBarColorScheme get topBarColorScheme =>
      theme.extensions[TopBarColorScheme]! as TopBarColorScheme;

  TextTheme get textTheme => theme.textTheme;

  TargetPlatform get platform => theme.platform;

  bool get isDarkMode =>
      theme.brightness == Brightness.dark ||
          MediaQuery.of(this).platformBrightness == Brightness.dark;

  bool get isIOS => platform == TargetPlatform.iOS;

  bool get isAndroid => platform == TargetPlatform.android;

  AppBarTheme get appBarTheme => theme.appBarTheme;

  SystemUiOverlayStyle? get systemOverlayStyle =>
      appBarTheme.systemOverlayStyle;

  SystemUiOverlayStyle? get transparentBars => systemOverlayStyle?.copyWith(
        statusBarBrightness: theme.brightness.inverse,
        statusBarIconBrightness: theme.brightness,
        systemNavigationBarColor: scrim,
        systemNavigationBarIconBrightness: theme.brightness,
      );

  SystemUiOverlayStyle? get lightStatusBar => systemOverlayStyle?.copyWith(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      );

  SystemUiOverlayStyle? get darkStatusBar => systemOverlayStyle?.copyWith(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      );

  SystemUiOverlayStyle? get darkSystemOverlay => darkStatusBar?.copyWith(
        systemNavigationBarColor: primaryVariant,
        systemNavigationBarIconBrightness: Brightness.light,
      );

  ThemeData get transparentBarsTheme => theme.copyWith(
        appBarTheme: appBarTheme.copyWith(
          systemOverlayStyle: transparentBars,
        ),
      );

  ThemeData get lightBackgroundTheme => theme.copyWith(
        appBarTheme: appBarTheme.copyWith(
          backgroundColor: background,
        ),
      );
}

extension BrightnessX on Brightness {
  Brightness get inverse =>
      this == Brightness.dark ? Brightness.light : Brightness.dark;
}
