import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  
  static const Color darkBgPrimary = Color(0xFF0D1117);
  static const Color darkBgSecondary = Color(0xFF161B22);
  static const Color darkBgTertiary = Color(0xFF21262D);
  static const Color darkBorder = Color(0xFF30363D);
  static const Color darkBorderMuted = Color(0xFF21262D);
  static const Color darkTextPrimary = Color(0xFFF0F6FC);
  static const Color darkTextSecondary = Color(0xFF8B949E);
  static const Color darkTextMuted = Color(0xFF6E7681);
  static const Color darkAccentBlue = Color(0xFF58A6FF);
  static const Color darkAccentGreen = Color(0xFF238636);
  static const Color darkAccentGreenBright = Color(0xFF3FB950);
  static const Color darkAccentOrange = Color(0xFFD29922);
  static const Color darkAccentPurple = Color(0xFFBC8CFF);
  static const Color darkAccentRed = Color(0xFFF85149);

  
  static const Color lightBgPrimary = Color(0xFFFFFFFF);
  static const Color lightBgSecondary = Color(0xFFF6F8FA);
  static const Color lightBgTertiary = Color(0xFFEAEEF2);
  static const Color lightBorder = Color(0xFFD0D7DE);
  static const Color lightBorderMuted = Color(0xFFE1E4E8);
  static const Color lightTextPrimary = Color(0xFF1F2328);
  static const Color lightTextSecondary = Color(0xFF656D76);
  static const Color lightTextMuted = Color(0xFF8C959F);
  static const Color lightAccentBlue = Color(0xFF0969DA);
  static const Color lightAccentGreen = Color(0xFF1A7F37);
  static const Color lightAccentGreenBright = Color(0xFF2DA44E);
  static const Color lightAccentOrange = Color(0xFF9A6700);
  static const Color lightAccentPurple = Color(0xFF8250DF);
  static const Color lightAccentRed = Color(0xFFCF222E);

  // GitHub Language Colors
  static const Map<String, Color> languageColors = {
    'Dart': Color(0xFF00B4AB),
    'JavaScript': Color(0xFFF1E05A),
    'TypeScript': Color(0xFF3178C6),
    'Python': Color(0xFF3572A5),
    'Java': Color(0xFFB07219),
    'Kotlin': Color(0xFFA97BFF),
    'Swift': Color(0xFFF05138),
    'Rust': Color(0xFFDEA584),
    'Go': Color(0xFF00ADD8),
    'C++': Color(0xFFF34B7D),
    'C': Color(0xFF555555),
    'C#': Color(0xFF178600),
    'Ruby': Color(0xFF701516),
    'PHP': Color(0xFF4F5D95),
    'HTML': Color(0xFFE34C26),
    'CSS': Color(0xFF563D7C),
    'Shell': Color(0xFF89E051),
    'Vue': Color(0xFF41B883),
    'Flutter': Color(0xFF02569B),
    'Scala': Color(0xFFC22D40),
    'R': Color(0xFF198CE7),
    'Elixir': Color(0xFF6E4A7E),
    'Clojure': Color(0xFFDB5855),
    'Haskell': Color(0xFF5E5086),
    'Lua': Color(0xFF000080),
    'Perl': Color(0xFF0298C3),
    'Jupyter Notebook': Color(0xFFDA5B0B),
  };

  static Color getLanguageColor(String? language) {
    if (language == null || language.isEmpty) {
      return const Color(0xFF8B949E);
    }
    return languageColors[language] ?? const Color(0xFF8B949E);
  }
}
