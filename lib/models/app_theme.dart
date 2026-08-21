import 'package:flutter/material.dart';

/// 이 앱 전용 팔레트. 무채색(오프화이트/차콜) 바탕에 포인트 컬러 하나만
/// 쓴다 — 사주를 예측형 운세가 아니라 자기 성찰 도구로 쓰는 앱이라, 화려한
/// 신비주의색(보라/금색 계열) 대신 절제된 잉크블루/인디고 한 가지로
/// 포인트를 준다. habit_streak의 app_theme.dart와 같은 라이트/다크 팔레트
/// 구조를 참고했지만 이 앱만을 위해 새로 만든 색이다(재사용 아님).
class _Palette {
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color card;
  final Color error;
  final Color border;

  const _Palette({
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.card,
    required this.error,
    required this.border,
  });
}

// 오프화이트 바탕 + 차콜 텍스트 + 잉크블루 포인트.
const _light = _Palette(
  textPrimary: Color(0xFF23241F),
  textSecondary: Color(0xFF6F7066),
  accent: Color(0xFF3A4C9C),
  background: Color(0xFFF6F4EE),
  surface: Color(0xFFFFFFFF),
  card: Color(0xFFFFFFFF),
  error: Color(0xFFA23B36),
  border: Color(0xFFE2DFD4),
);

// 차콜 바탕 + 오프화이트 텍스트 + 살짝 밝힌 인디고 포인트(다크 배경 대비용).
const _dark = _Palette(
  textPrimary: Color(0xFFEFEDE4),
  textSecondary: Color(0xFFA5A79A),
  accent: Color(0xFF8C97D6),
  background: Color(0xFF1B1C18),
  surface: Color(0xFF232420),
  card: Color(0xFF292A25),
  error: Color(0xFFE0958F),
  border: Color(0x1FEFEDE4),
);

/// [brightness]에 맞는 [ThemeData]를 만든다. 팔레트 하나뿐이라
/// habit_streak처럼 이름으로 테마를 고르는 구조는 두지 않고, 설정 화면에서
/// 라이트/다크/시스템만 고르게 한다.
ThemeData buildAppTheme(Brightness brightness) {
  final palette = brightness == Brightness.light ? _light : _dark;

  final scheme = ColorScheme.fromSeed(
    seedColor: palette.accent,
    brightness: brightness,
  ).copyWith(
    primary: palette.accent,
    surface: palette.surface,
    onSurface: palette.textPrimary,
    onSurfaceVariant: palette.textSecondary,
    error: palette.error,
    outline: palette.border,
  );

  final baseText = ThemeData(brightness: brightness).textTheme.apply(
        fontFamily: 'Pretendard',
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      );
  final textTheme = baseText.copyWith(
    titleLarge: baseText.titleLarge
        ?.copyWith(fontSize: 25, fontWeight: FontWeight.w700, letterSpacing: -0.3),
    titleMedium: baseText.titleMedium
        ?.copyWith(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.2),
    titleSmall:
        baseText.titleSmall?.copyWith(fontSize: 15.5, fontWeight: FontWeight.w700),
    bodyLarge:
        baseText.bodyLarge?.copyWith(fontSize: 17, fontWeight: FontWeight.w500, height: 1.5),
    bodyMedium:
        baseText.bodyMedium?.copyWith(fontSize: 15.5, fontWeight: FontWeight.w500, height: 1.5),
    bodySmall: baseText.bodySmall?.copyWith(
        fontSize: 13.5, fontWeight: FontWeight.w500, color: palette.textSecondary),
    labelLarge: baseText.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
  );

  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
  final outlinedSide = BorderSide(color: palette.textSecondary.withValues(alpha: 0.35));

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: 'Pretendard',
    scaffoldBackgroundColor: palette.background,
    cardColor: palette.card,
    dividerColor: palette.border,
    visualDensity: VisualDensity.comfortable,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: palette.background,
      foregroundColor: palette.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleMedium,
    ),
    cardTheme: CardThemeData(
      color: palette.card,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: palette.border),
      ),
    ),
    dividerTheme: DividerThemeData(color: palette.border, thickness: 1, space: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: buttonShape,
        minimumSize: const Size(64, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: buttonShape,
        minimumSize: const Size(64, 48),
        foregroundColor: palette.textPrimary,
        side: outlinedSide,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: buttonShape,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide(color: palette.border),
      backgroundColor: palette.surface,
      selectedColor: palette.accent.withValues(alpha: 0.16),
      checkmarkColor: palette.accent,
      labelStyle: textTheme.bodyMedium?.copyWith(fontSize: 13.5, fontWeight: FontWeight.w500),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: palette.accent, width: 1.6),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: palette.border),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
      labelStyle: textTheme.bodyMedium?.copyWith(color: palette.textSecondary),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      titleTextStyle: textTheme.titleMedium,
      contentTextStyle: textTheme.bodyMedium,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      dragHandleColor: palette.textSecondary.withValues(alpha: 0.4),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: palette.textPrimary,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: palette.background),
    ),
    listTileTheme: ListTileThemeData(iconColor: palette.textSecondary),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: palette.accent,
      linearTrackColor: palette.accent.withValues(alpha: 0.12),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.surface,
      indicatorColor: palette.accent.withValues(alpha: 0.16),
      labelTextStyle: WidgetStatePropertyAll(
        textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
