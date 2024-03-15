import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const serverUrl = "https://fashion-time-backend-1dc9be6bb298.herokuapp.com";

var primary = Colors.pink.shade300;
var secondary = Color(0xff9ad9e9);
const tertiary = Color(0xffBBAED4);
const ascent = Colors.white;
const dark1 = Colors.black;
const gold=Color.fromARGB(255, 198,161 , 83);

const silver=Color.fromARGB(160, 155, 160, 160);
const String userID = "hassan4100348@cloud.neduet.edu.pk";
const String passID = "karachi94@@";

ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    accentColor: Colors.white,
    scaffoldBackgroundColor: Color(0xfff1f1f1)
);

ThemeData dark = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primary,
  accentColor: Colors.white,
);

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme";
  SharedPreferences? _prefs;
  bool? _darkTheme;
  int? index;

  bool get darkTheme => _darkTheme!;

  ThemeNotifier() {
    _darkTheme = false;
    _loadFromPrefs();
  }

  toggleTheme() {
    _darkTheme = !_darkTheme!;
    _saveToPrefs();
    notifyListeners();
  }

  _initPrefs() async {
    if(_prefs == null)
      _prefs = await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    _darkTheme = _prefs!.getBool(key) ?? true;
    notifyListeners();
  }

  _saveToPrefs()async {
    await _initPrefs();
    _prefs!.setBool(key, _darkTheme!);
  }

  saveColor(item) async{
    await _initPrefs();
    _prefs!.setInt("item", item);
  }

}