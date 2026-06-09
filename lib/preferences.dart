import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Dark/Light Theme

class TheThemePreference {
  // ignore: constant_identifier_names
  static const THEME_STATUS = "THEMESTATUS";
  static const FONT_SIZE = "FONTSIZE";
  static const COUNTER_FONT_SIZE = "COUNTERFONTSIZE";
  static const UILANGUAGE = "UILANGUAGE";
  static const ANIMATIONS_STATUS = "ANIMATIONSSTATUS";
  static const VIBRATE_ON_TAP = "VIBRATEONTAP";
  static const VIBRATE_ON_COMPLETE = "VIBRATEONCOMPLETE";
  static const CONFIRM_RESET = "CONFIRMRESET";
  static const CONFIRM_INCREMENT = "CONFIRMINCREMENT";
  static const CONFIRM_DECREMENT = "CONFIRMDECREMENT";
  static const AUDIO_STATUS = "AUDIOSTATUS";
  static const MISBAH_AUDIO_STATUS = "MISBAHAUDIOSTATUS";

  setDarkTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(THEME_STATUS, value);
  }

  Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(THEME_STATUS) ?? false;
  }

  setAudioTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(AUDIO_STATUS, value);
  }

  Future<bool> getAudioTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AUDIO_STATUS) ?? true;
  }

  setMisbahAudioTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(MISBAH_AUDIO_STATUS, value);
  }

  Future<bool> getMisbahAudioTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(MISBAH_AUDIO_STATUS) ?? true;
  }

  setFontSize(double size) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(FONT_SIZE, size);
  }

  Future<double> getFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(FONT_SIZE) ?? 27;
  }

  setCounterFontSize(double size) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble(COUNTER_FONT_SIZE, size);
  }

  Future<double> getCounterFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(COUNTER_FONT_SIZE) ?? 20.0;
  }

  setAnimationsTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(ANIMATIONS_STATUS, value);
  }

  Future<bool> getAnimationsTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(ANIMATIONS_STATUS) ?? true;
  }

  setVibrateOnTap(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(VIBRATE_ON_TAP, value);
  }

  Future<bool> getVibrateOnTap() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(VIBRATE_ON_TAP) ?? true;
  }

  setVibrateOnComplete(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(VIBRATE_ON_COMPLETE, value);
  }

  Future<bool> getVibrateOnComplete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(VIBRATE_ON_COMPLETE) ?? true;
  }

  setConfirmReset(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(CONFIRM_RESET, value);
  }

  Future<bool> getConfirmReset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(CONFIRM_RESET) ?? true;
  }

  setConfirmIncrement(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(CONFIRM_INCREMENT, value);
  }

  Future<bool> getConfirmIncrement() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(CONFIRM_INCREMENT) ?? false;
  }

  setConfirmDecrement(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(CONFIRM_DECREMENT, value);
  }

  Future<bool> getConfirmDecrement() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(CONFIRM_DECREMENT) ?? true;
  }

  setUILanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(UILANGUAGE, language);
  }

  Future<String> getUILanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(UILANGUAGE) ?? 'ar';
  }
}

class TheThemeProvider with ChangeNotifier {
  TheThemePreference preference = TheThemePreference();
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    preference.setDarkTheme(value);
    notifyListeners();
  }

  double _fontSize = 27;
  double get fontSize => _fontSize;

  set fontSize(double value) {
    _fontSize = value;
    preference.setFontSize(value);
    notifyListeners();
  }

  double _counterFontSize = 20;
  double get counterFontSize => _counterFontSize;

  set counterFontSize(double value) {
    _counterFontSize = value;
    preference.setCounterFontSize(value);
    notifyListeners();
  }

  bool _enableAnimations = true;
  bool get enableAnimations => _enableAnimations;

  set enableAnimations(bool value) {
    _enableAnimations = value;
    preference.setAnimationsTheme(value);
    notifyListeners();
  }

  bool _vibrateOnTap = true;
  bool get vibrateOnTap => _vibrateOnTap;

  set vibrateOnTap(bool value) {
    _vibrateOnTap = value;
    preference.setVibrateOnTap(value);
    notifyListeners();
  }

  bool _vibrateOnComplete = true;
  bool get vibrateOnComplete => _vibrateOnComplete;

  set vibrateOnComplete(bool value) {
    _vibrateOnComplete = value;
    preference.setVibrateOnComplete(value);
    notifyListeners();
  }

  bool _confirmReset = true;
  bool get confirmReset => _confirmReset;

  set confirmReset(bool value) {
    _confirmReset = value;
    preference.setConfirmReset(value);
    notifyListeners();
  }

  bool _confirmIncrement = false;
  bool get confirmIncrement => _confirmIncrement;

  set confirmIncrement(bool value) {
    _confirmIncrement = value;
    preference.setConfirmIncrement(value);
    notifyListeners();
  }

  bool _confirmDecrement = true;
  bool get confirmDecrement => _confirmDecrement;

  set confirmDecrement(bool value) {
    _confirmDecrement = value;
    preference.setConfirmDecrement(value);
    notifyListeners();
  }

  String _language = 'ar';
  String get language => _language;

  set language(String language) {
    _language = language;
    preference.setUILanguage(language);
    notifyListeners();
  }

  bool _enableAudio = true;
  bool get enableAudio => _enableAudio;

  set enableAudio(bool value) {
    _enableAudio = value;
    preference.setAudioTheme(value);
    notifyListeners();
  }

  bool _enableMisbahAudio = true;
  bool get enableMisbahAudio => _enableMisbahAudio;

  set enableMisbahAudio(bool value) {
    _enableMisbahAudio = value;
    preference.setMisbahAudioTheme(value);
    notifyListeners();
  }
}

// Color Theme

class TheColorThemePreference {
  // ignore: constant_identifier_names
  static const THEME_COLOR = "THEMECOLOR";

  setThemeColor(int color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(THEME_COLOR, color);
  }

  Future<int> getThemeColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(THEME_COLOR) ?? 0;
  }
}

class ThemeColorProvider with ChangeNotifier {
  TheColorThemePreference colorThemePreference = TheColorThemePreference();
  int _colorTheme = 0;

  int get colorTheme => _colorTheme;

  set colorTheme(int color) {
    _colorTheme = color;
    colorThemePreference.setThemeColor(color);
    notifyListeners();
  }
}
