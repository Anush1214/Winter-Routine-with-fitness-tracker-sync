import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/solo_colors.dart';
import 'services/supabase_service.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'presentation/screens/arise_splash_screen.dart';
import 'presentation/screens/home_quest_screen.dart';
import 'presentation/screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (required for OAuth)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    debugPrint('OAuth features will be unavailable. Guest mode still works.');
  }
  
  // Initialize native on-device notifications
  await NotificationService().init();
  
  // Initialize authentication state
  await AuthService().init();
  
  runApp(const WinterArcMobileApp());
}

class WinterArcMobileApp extends StatefulWidget {
  const WinterArcMobileApp({super.key});

  @override
  State<WinterArcMobileApp> createState() => _WinterArcMobileAppState();
}

class _WinterArcMobileAppState extends State<WinterArcMobileApp> {
  bool _splashComplete = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => SupabaseService()),
      ],
      child: MaterialApp(
        title: 'Winter Arc Protocol',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: SoloColors.obsidianVoid,
          primaryColor: SoloColors.neonCyan,
          colorScheme: const ColorScheme.dark(
            primary: SoloColors.neonCyan,
            secondary: SoloColors.manaBlue,
            surface: SoloColors.obsidianGlass,
          ),
          useMaterial3: true,
        ),
        home: !_splashComplete
            ? AriseSplashScreen(
                onComplete: () {
                  setState(() {
                    _splashComplete = true;
                  });
                },
              )
            : Consumer<AuthService>(
                builder: (context, auth, _) {
                  if (auth.isAuthenticated) {
                    return const HomeQuestScreen();
                  }
                  return const AuthScreen();
                },
              ),
      ),
    );
  }
}
