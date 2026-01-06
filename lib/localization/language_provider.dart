import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english;
  
  AppLanguage get currentLanguage => _currentLanguage;
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language') ?? 'en';
    _currentLanguage = languageCode == 'vi' ? AppLanguage.vietnamese : AppLanguage.english;
    notifyListeners();
  }
  
  Future<void> setLanguage(AppLanguage language) async {
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language == AppLanguage.vietnamese ? 'vi' : 'en');
    notifyListeners();
  }
  
  void toggleLanguage() {
    setLanguage(_currentLanguage == AppLanguage.english 
        ? AppLanguage.vietnamese 
        : AppLanguage.english);
  }
}
