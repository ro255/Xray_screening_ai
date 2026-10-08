import 'package:diesease_ai_app/core/setting.dart';
import 'package:diesease_ai_app/core/app_language.dart';
import 'package:diesease_ai_app/core/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    withAppProviders(
      settings: Settings(prefs),
      languageController: AppLanguageController(preferences: prefs),
      child: const App(),
    ),
  );
}