import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/dna_match_screen.dart';

// ── Global notifiers — readable from anywhere in the app ─────────────
final darkModeNotifier    = ValueNotifier<bool>(false);
final localeNotifier      = ValueNotifier<Locale>(const Locale('en'));

// ── Language code map ─────────────────────────────────────────────────
const Map<String, Locale> languageLocales = {
  'English':    Locale('en'),
  'Hindi':      Locale('hi'),
  'Spanish':    Locale('es'),
  'French':     Locale('fr'),
  'German':     Locale('de'),
  'Japanese':   Locale('ja'),
  'Portuguese': Locale('pt'),
  'Arabic':     Locale('ar'),
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Rebuild MaterialApp whenever dark mode or locale changes
    darkModeNotifier.addListener(_rebuild);
    localeNotifier.addListener(_rebuild);
  }

  @override
  void dispose() {
    darkModeNotifier.removeListener(_rebuild);
    localeNotifier.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoamEase',

      // ── Theme ──────────────────────────────────────────────────────
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
        cardColor: const Color(0xFF1E1E1E),
        dividerColor: Colors.white12,
      ),
      themeMode: darkModeNotifier.value ? ThemeMode.dark : ThemeMode.light,

      // ── Locale ─────────────────────────────────────────────────────
      locale: localeNotifier.value,
      supportedLocales: languageLocales.values.toList(),
      // Required — without these, changing locale crashes with "No MaterialLocalizations found"
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const HomeScreen(),
      routes: {
        '/quests': (context) => const QuestScreen(),
      },
    );
  }
}