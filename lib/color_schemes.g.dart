import 'package:flutter/material.dart';

// TextTheme
const textTheme = TextTheme(
    displayLarge: TextStyle(
        fontFamily: "Lateef", fontSize: 127, fontWeight: FontWeight.w300),
    displayMedium: TextStyle(
        fontFamily: "Lateef", fontSize: 79, fontWeight: FontWeight.w300),
    displaySmall: TextStyle(
        fontFamily: "Lateef", fontSize: 64, fontWeight: FontWeight.w400),
    headlineMedium: TextStyle(
        fontFamily: "Lateef", fontSize: 45, fontWeight: FontWeight.w400),
    headlineSmall: TextStyle(
        fontFamily: "Lateef", fontSize: 32, fontWeight: FontWeight.w400),
    titleLarge: TextStyle(
        fontFamily: "Lateef", fontSize: 26, fontWeight: FontWeight.w500),
    titleMedium: TextStyle(
        fontFamily: "Lateef", fontSize: 21, fontWeight: FontWeight.w400),
    titleSmall: TextStyle(
        fontFamily: "Lateef", fontSize: 19, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(
        fontFamily: "Rubik", fontSize: 14, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(
        fontFamily: "Rubik", fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(
        fontFamily: "Rubik", fontSize: 12, fontWeight: FontWeight.w500),
    bodySmall: TextStyle(
        fontFamily: "Rubik", fontSize: 10, fontWeight: FontWeight.w400),
    labelSmall: TextStyle(
        fontFamily: "Rubik", fontSize: 8, fontWeight: FontWeight.w400));

// Purple

const purpleLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF7246B4),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFECDCFF),
  onPrimaryContainer: Color(0xFF280056),
  secondary: Color(0xFF99405C),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFFFD9E0),
  onSecondaryContainer: Color(0xFF3F001A),
  tertiary: Color(0xFF7F525B),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFD9DF),
  onTertiaryContainer: Color(0xFF32101A),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFFFBFF),
  onSurface: Color(0xFF1D1B1E),
  surfaceContainerHighest: Color(0xFFE8E0EB),
  onSurfaceVariant: Color(0xFF4A454E),
  outline: Color(0xFF7B757F),
  onInverseSurface: Color(0xFFF5EFF4),
  inverseSurface: Color(0xFF323033),
  inversePrimary: Color(0xFFD6BAFF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF7246B4),
  outlineVariant: Color(0xFFCBC4CF),
  scrim: Color(0xFF000000),
);

const purpleDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFD6BAFF),
  onPrimary: Color(0xFF420983),
  primaryContainer: Color(0xFF592B9A),
  onPrimaryContainer: Color(0xFFECDCFF),
  secondary: Color(0xFFFFB1C4),
  onSecondary: Color(0xFF5E112F),
  secondaryContainer: Color(0xFF7C2945),
  onSecondaryContainer: Color(0xFFFFD9E0),
  tertiary: Color(0xFFF1B7C3),
  onTertiary: Color(0xFF4B252E),
  tertiaryContainer: Color(0xFF643B44),
  onTertiaryContainer: Color(0xFFFFD9DF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF1D1B1E),
  onSurface: Color(0xFFE7E1E6),
  surfaceContainerHighest: Color(0xFF4A454E),
  onSurfaceVariant: Color(0xFFCBC4CF),
  outline: Color(0xFF958E99),
  onInverseSurface: Color(0xFF1D1B1E),
  inverseSurface: Color(0xFFE7E1E6),
  inversePrimary: Color(0xFF7246B4),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFD6BAFF),
  outlineVariant: Color(0xFF4A454E),
  scrim: Color(0xFF000000),
);

// Baige

const baigeLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF7E5700),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFDEAC),
  onPrimaryContainer: Color(0xFF281900),
  secondary: Color(0xFF6E5C40),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFF8DFBB),
  onSecondaryContainer: Color(0xFF261904),
  tertiary: Color(0xFF4E6542),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFD0EABF),
  onTertiaryContainer: Color(0xFF0D2005),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFFFBFF),
  onSurface: Color(0xFF1F1B16),
  surfaceContainerHighest: Color(0xFFEFE0CF),
  onSurfaceVariant: Color(0xFF4E4539),
  outline: Color(0xFF807567),
  onInverseSurface: Color(0xFFF8EFE7),
  inverseSurface: Color(0xFF34302A),
  inversePrimary: Color(0xFFFBBC49),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF7E5700),
  outlineVariant: Color(0xFFD2C5B4),
  scrim: Color(0xFF000000),
);

const baigeDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFFBBC49),
  onPrimary: Color(0xFF432C00),
  primaryContainer: Color(0xFF604100),
  onPrimaryContainer: Color(0xFFFFDEAC),
  secondary: Color(0xFFDBC3A1),
  onSecondary: Color(0xFF3D2E16),
  secondaryContainer: Color(0xFF55442A),
  onSecondaryContainer: Color(0xFFF8DFBB),
  tertiary: Color(0xFFB5CEA4),
  onTertiary: Color(0xFF213618),
  tertiaryContainer: Color(0xFF374C2D),
  onTertiaryContainer: Color(0xFFD0EABF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF1F1B16),
  onSurface: Color(0xFFEAE1D9),
  surfaceContainerHighest: Color(0xFF4E4539),
  onSurfaceVariant: Color(0xFFD2C5B4),
  outline: Color(0xFF9B8F80),
  onInverseSurface: Color(0xFF1F1B16),
  inverseSurface: Color(0xFFEAE1D9),
  inversePrimary: Color(0xFF7E5700),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFFBBC49),
  outlineVariant: Color(0xFF4E4539),
  scrim: Color(0xFF000000),
);

// Grey

const greyLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF000000),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF454545),
  onPrimaryContainer: Color(0xFF919191),
  secondary: Color(0xFF8A8B8B),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFCFE6F2),
  onSecondaryContainer: Color(0xFF081E26),
  tertiary: Color(0xFFBBBDBD),
  onTertiary: Color(0xFF000000),
  tertiaryContainer: Color(0xFFBBBDBD),
  onTertiaryContainer: Color(0xFF001F29),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFBFCFE),
  onSurface: Color(0xFF191C1E),
  surfaceContainerHighest: Color(0xFFDCE4E9),
  onSurfaceVariant: Color(0xFF40484C),
  outline: Color(0xFF70787D),
  onInverseSurface: Color(0xFFEFF1F3),
  inverseSurface: Color(0xFF2E3132),
  inversePrimary: Color(0xFF0D1E24),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF4B4B4B),
  outlineVariant: Color(0xFFC0C8CC),
  scrim: Color(0xFF000000),
);

const greyDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFFFFFFF),
  onPrimary: Color(0xFF000000),
  primaryContainer: Color(0xFF8A8A8A),
  onPrimaryContainer: Color(0xFF303030),
  secondary: Color(0xFFFFFFFF),
  onSecondary: Color(0xFF8A8B8B),
  secondaryContainer: Color(0xFF081E26),
  onSecondaryContainer: Color(0xFFCFE6F2),
  tertiary: Color(0xFFBBBDBD),
  onTertiary: Color(0xFF000000),
  tertiaryContainer: Color(0xFF001F29),
  onTertiaryContainer: Color(0xFFBAEAFF),
  error: Color(0xFFFFDAD6),
  errorContainer: Color(0xFFBA1A1A),
  onError: Color(0xFF410002),
  onErrorContainer: Color(0xFFFFFFFF),
  surface: Color(0xFF191C1E),
  onSurface: Color(0xFFFBFCFE),
  surfaceContainerHighest: Color(0xFF40484C),
  onSurfaceVariant: Color(0xFFDCE4E9),
  outline: Color(0xFF8A9296),
  onInverseSurface: Color(0xFF191C1E),
  inverseSurface: Color(0xFFE1E3E4),
  inversePrimary: Color(0xFF006782),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFD3D3D3),
  outlineVariant: Color(0xFF40484C),
  scrim: Color(0xFF000000),
);

// Green

const greenLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006D36),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF93F8AD),
  onPrimaryContainer: Color(0xFF00210C),
  secondary: Color(0xFF506352),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD3E8D3),
  onSecondaryContainer: Color(0xFF0E1F12),
  tertiary: Color(0xFF006A60),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF74F8E5),
  onTertiaryContainer: Color(0xFF00201C),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFCFDF7),
  onSurface: Color(0xFF191C19),
  surfaceContainerHighest: Color(0xFFDDE5DA),
  onSurfaceVariant: Color(0xFF414941),
  outline: Color(0xFF717971),
  onInverseSurface: Color(0xFFF0F1EC),
  inverseSurface: Color(0xFF2E312E),
  inversePrimary: Color(0xFF77DB93),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF006D36),
  outlineVariant: Color(0xFFC1C9BF),
  scrim: Color(0xFF000000),
);

const greenDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF77DB93),
  onPrimary: Color(0xFF003919),
  primaryContainer: Color(0xFF005227),
  onPrimaryContainer: Color(0xFF93F8AD),
  secondary: Color(0xFFB7CCB7),
  onSecondary: Color(0xFF233426),
  secondaryContainer: Color(0xFF394B3B),
  onSecondaryContainer: Color(0xFFD3E8D3),
  tertiary: Color(0xFF53DBC9),
  onTertiary: Color(0xFF003731),
  tertiaryContainer: Color(0xFF005048),
  onTertiaryContainer: Color(0xFF74F8E5),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF191C19),
  onSurface: Color(0xFFE2E3DE),
  surfaceContainerHighest: Color(0xFF414941),
  onSurfaceVariant: Color(0xFFC1C9BF),
  outline: Color(0xFF8B938A),
  onInverseSurface: Color(0xFF191C19),
  inverseSurface: Color(0xFFE2E3DE),
  inversePrimary: Color(0xFF006D36),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF77DB93),
  outlineVariant: Color(0xFF414941),
  scrim: Color(0xFF000000),
);

// Blue

const blueLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006782),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFBBE9FF),
  onPrimaryContainer: Color(0xFF001F29),
  secondary: Color(0xFF4C616B),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFCFE6F2),
  onSecondaryContainer: Color(0xFF081E26),
  tertiary: Color(0xFF006782),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFBAEAFF),
  onTertiaryContainer: Color(0xFF001F29),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFBFCFE),
  onSurface: Color(0xFF191C1E),
  surfaceContainerHighest: Color(0xFFDCE4E9),
  onSurfaceVariant: Color(0xFF40484C),
  outline: Color(0xFF70787D),
  onInverseSurface: Color(0xFFEFF1F3),
  inverseSurface: Color(0xFF2E3132),
  inversePrimary: Color(0xFF61D4FF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF006782),
  outlineVariant: Color(0xFFC0C8CC),
  scrim: Color(0xFF000000),
);

const blueDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF61D4FF),
  onPrimary: Color(0xFF003545),
  primaryContainer: Color(0xFF004D63),
  onPrimaryContainer: Color(0xFFBBE9FF),
  secondary: Color(0xFFB4CAD5),
  onSecondary: Color(0xFF1E333C),
  secondaryContainer: Color(0xFF354A53),
  onSecondaryContainer: Color(0xFFCFE6F2),
  tertiary: Color(0xFF60D4FE),
  onTertiary: Color(0xFF003545),
  tertiaryContainer: Color(0xFF004D62),
  onTertiaryContainer: Color(0xFFBAEAFF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF191C1E),
  onSurface: Color(0xFFE1E3E4),
  surfaceContainerHighest: Color(0xFF40484C),
  onSurfaceVariant: Color(0xFFC0C8CC),
  outline: Color(0xFF8A9296),
  onInverseSurface: Color(0xFF191C1E),
  inverseSurface: Color(0xFFE1E3E4),
  inversePrimary: Color(0xFF006782),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF61D4FF),
  outlineVariant: Color(0xFF40484C),
  scrim: Color(0xFF000000),
);

// Red

const redLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF984061),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFFFD9E2),
  onPrimaryContainer: Color(0xFF3E001D),
  secondary: Color(0xFF74565F),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFFFD9E2),
  onSecondaryContainer: Color(0xFF2B151C),
  tertiary: Color(0xFF7C5635),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFDCC2),
  onTertiaryContainer: Color(0xFF2E1500),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  surface: Color(0xFFFFFBFF),
  onSurface: Color(0xFF201A1B),
  surfaceContainerHighest: Color(0xFFF2DDE2),
  onSurfaceVariant: Color(0xFF514347),
  outline: Color(0xFF837377),
  onInverseSurface: Color(0xFFFAEEEF),
  inverseSurface: Color(0xFF352F30),
  inversePrimary: Color(0xFFFFB0C8),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF984061),
  outlineVariant: Color(0xFFD5C2C6),
  scrim: Color(0xFF000000),
);

const redDarkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFFFB0C8),
  onPrimary: Color(0xFF5E1133),
  primaryContainer: Color(0xFF7B2949),
  onPrimaryContainer: Color(0xFFFFD9E2),
  secondary: Color(0xFFE2BDC6),
  onSecondary: Color(0xFF422931),
  secondaryContainer: Color(0xFF5A3F47),
  onSecondaryContainer: Color(0xFFFFD9E2),
  tertiary: Color(0xFFEFBD94),
  onTertiary: Color(0xFF48290C),
  tertiaryContainer: Color(0xFF623F20),
  onTertiaryContainer: Color(0xFFFFDCC2),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF201A1B),
  onSurface: Color(0xFFEBE0E1),
  surfaceContainerHighest: Color(0xFF514347),
  onSurfaceVariant: Color(0xFFD5C2C6),
  outline: Color(0xFF9E8C90),
  onInverseSurface: Color(0xFF201A1B),
  inverseSurface: Color(0xFFEBE0E1),
  inversePrimary: Color(0xFF984061),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFFFB0C8),
  outlineVariant: Color(0xFF514347),
  scrim: Color(0xFF000000),
);
