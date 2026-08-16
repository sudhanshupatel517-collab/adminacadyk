import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  
  // Theme Color Presets
  int _lightPresetIndex = 0; // 0: Default Blue, 1: Amber, 2: Crimson, 3: Emerald, 4: Midnight, 5: Purple, 6: Dark Grey
  int _darkPresetIndex = 0;  // 0: GitHub Dark (#0D1117), 1: OLED Black (#000000), 2: Midnight Slate (#0F172A), 3: Deep Purple (#1E1B4B), 4: Forest (#064E3B)
  
  bool _highContrastLight = false;
  bool _highContrastDark = false;
  
  // Emoji Skin Tone Preference: 0: Default, 1: Light, 2: Medium-Light, 3: Medium, 4: Medium-Dark, 5: Dark
  int _emojiSkinToneIndex = 0;
  
  // Tab size preference
  int _tabSize = 4;
  
  // Markdown editor font preference
  bool _useMonospaceMarkdown = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  int get lightPresetIndex => _lightPresetIndex;
  int get darkPresetIndex => _darkPresetIndex;
  bool get highContrastLight => _highContrastLight;
  bool get highContrastDark => _highContrastDark;
  int get emojiSkinToneIndex => _emojiSkinToneIndex;
  int get tabSize => _tabSize;
  bool get useMonospaceMarkdown => _useMonospaceMarkdown;

  // Accent Colors
  static const List<Color> accentColors = [
    Color(0xFF0A66C2), // Default Acadyk Blue
    Color(0xFFD97706), // Amber
    Color(0xFFDC2626), // Crimson
    Color(0xFF059669), // Emerald
    Color(0xFF4F46E5), // Indigo / Midnight
    Color(0xFF9333EA), // Purple
    Color(0xFF374151), // Dark Slate
  ];

  static const List<Color> darkBackgrounds = [
    Color(0xFF0D1117), // GitHub Dark
    Color(0xFF000000), // OLED Pitch Black
    Color(0xFF0F172A), // Midnight Slate
    Color(0xFF1E1B4B), // Deep Indigo
    Color(0xFF064E3B), // Forest Dark
  ];

  Color get activeAccentColor => accentColors[_lightPresetIndex % accentColors.length];
  Color get activeDarkBackgroundColor => darkBackgrounds[_darkPresetIndex % darkBackgrounds.length];

  // Theme Data Builders
  ThemeData get lightThemeData {
    final primary = activeAccentColor;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: primary,
        surface: _highContrastLight ? Colors.white : const Color(0xFFFFFFFF),
        background: _highContrastLight ? const Color(0xFFF9FAFB) : const Color(0xFFF3F4F6),
        onSurface: _highContrastLight ? Colors.black : const Color(0xFF191919),
        error: const Color(0xFFD93025),
      ),
      scaffoldBackgroundColor: _highContrastLight ? Colors.white : const Color(0xFFFFFFFF),
      fontFamily: 'Inter',
      dividerTheme: DividerThemeData(
        color: _highContrastLight ? const Color(0xFF000000) : const Color(0xFFE0E0E0),
        thickness: _highContrastLight ? 1.5 : 1.0,
      ),
    );
  }

  ThemeData get darkThemeData {
    final bg = activeDarkBackgroundColor;
    final primary = activeAccentColor;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: primary,
        surface: _highContrastDark ? const Color(0xFF161B22) : bg,
        background: bg,
        onSurface: _highContrastDark ? Colors.white : const Color(0xFFF7F9F9),
        error: const Color(0xFFF87171),
      ),
      scaffoldBackgroundColor: bg,
      fontFamily: 'Inter',
      dividerTheme: DividerThemeData(
        color: _highContrastDark ? const Color(0xFF484F58) : const Color(0xFF30363D),
        thickness: _highContrastDark ? 1.5 : 1.0,
      ),
    );
  }

  // Actions
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setLightPresetIndex(int index) {
    _lightPresetIndex = index;
    notifyListeners();
  }

  void setDarkPresetIndex(int index) {
    _darkPresetIndex = index;
    notifyListeners();
  }

  void setHighContrastLight(bool val) {
    _highContrastLight = val;
    notifyListeners();
  }

  void setHighContrastDark(bool val) {
    _highContrastDark = val;
    notifyListeners();
  }

  void setEmojiSkinToneIndex(int index) {
    _emojiSkinToneIndex = index;
    notifyListeners();
  }

  void setTabSize(int size) {
    _tabSize = size;
    notifyListeners();
  }

  void setUseMonospaceMarkdown(bool val) {
    _useMonospaceMarkdown = val;
    notifyListeners();
  }

  // Emoji Skin Tone Helper
  String getFormattedEmoji(String baseEmoji) {
    if (_emojiSkinToneIndex == 0) return baseEmoji;
    const modifiers = ['\u{1F3FB}', '\u{1F3FC}', '\u{1F3FD}', '\u{1F3FE}', '\u{1F3FF}'];
    if (_emojiSkinToneIndex >= 1 && _emojiSkinToneIndex <= 5) {
      return '$baseEmoji${modifiers[_emojiSkinToneIndex - 1]}';
    }
    return baseEmoji;
  }
}
