import 'package:detektif_hoaks/core/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/game_provider.dart';
import 'providers/setting_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'services/sound_manager.dart';
import 'dart:async'; 

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await AudioService.instance.init();

  final results = await Future.wait([
    Supabase.initialize(
      url: 'https://nafsedhgifawzalagszu.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5hZnNlZGhnaWZhd3phbGFnc3p1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0MDk2MjksImV4cCI6MjA5MTk4NTYyOX0.idBrBD1qZpwWtopx5RFqvgFAHr-7L4yequRAu85qhig',
    ),
    SharedPreferences.getInstance(),
  ]);

  final prefs = results[1] as SharedPreferences;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettingsFromPrefs(prefs),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AudioService.instance.disposeAll();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    AudioService.instance.onAppLifecycleChanged(state);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Detektif Hoaks',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isInitializing = true;
  // FIX #2: Simpan subscription agar bisa di-cancel saat dispose
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _setupAuthListener();
  }

  @override
  void dispose() {
    // FIX #2: Selalu cancel subscription saat widget dispose
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      await gameProvider.loadGameData();
      if (!mounted) return;
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  void _setupAuthListener() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    // FIX #2: Simpan subscription ke variabel
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange
        .listen((data) async {
      final AuthChangeEvent event = data.event;

      if (event == AuthChangeEvent.signedIn) {
        // FIX #1: Hanya AuthGate yang handle navigasi ke HomeScreen.
        // LoginScreen TIDAK boleh navigate sendiri setelah sign-in/sign-up.
        await gameProvider.loadGameData();
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else if (event == AuthChangeEvent.signedOut) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null && !_isInitializing) {
      return const WelcomeScreen();
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security,
                  size: isLandscape ? 72 : 120, color: Colors.amber),
              SizedBox(height: isLandscape ? 12 : 32),
              Text(
                'DETEKTIF HOAKS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'BebasNeue',
                  fontSize: isLandscape ? 36 : 48,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                'Asah Kritis, Lawan Hoaks',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: isLandscape ? 24 : 48),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: Colors.amber, strokeWidth: 2.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}