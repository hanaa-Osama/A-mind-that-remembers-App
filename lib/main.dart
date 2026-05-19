import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'splash_page.dart';
import 'theme_provider.dart';
import 'language_provider.dart';
import 'translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // New calm, minimal color palette
  static const Color darkBackground = Color(0xFF0D0D0D);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color softWhite = Color(0xFFF5F5F5);
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF424242);
  static const Color accentColor = Color(0xFF2C2C2C);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => S.of(context, 'my_memories'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
        Locale('tr'),
      ],
      locale: languageProvider.locale, // يستخدم null تلقائياً لاتباع لغة النظام
      theme: ThemeData(
        scaffoldBackgroundColor: pureWhite,
        fontFamily: 'Tajawal',
        appBarTheme: const AppBarTheme(
          backgroundColor: pureWhite,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkGray,
          ),
          iconTheme: IconThemeData(color: darkGray),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: darkGray,
            fontSize: 16,
            fontFamily: 'Tajawal',
          ),
          bodyLarge: TextStyle(
            color: darkGray,
            fontSize: 18,
            fontFamily: 'Tajawal',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkGray,
            foregroundColor: pureWhite,
            textStyle: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: softWhite,
          hintStyle: const TextStyle(
            color: mediumGray,
            fontFamily: 'Tajawal',
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: lightGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: darkGray, width: 2),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: pureWhite,
          selectedItemColor: darkGray,
          unselectedItemColor: mediumGray,
          selectedLabelStyle: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Tajawal',
          ),
        ),
      ),
      home: const SplashPage(),
    );
  }
}
