import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/solo_colors.dart';
import 'services/supabase_service.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';
import 'presentation/screens/arise_splash_screen.dart';
import 'presentation/screens/main_shell_screen.dart';
import 'presentation/screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (required for OAuth across Web, Android, iOS)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('⚠️ Firebase initialization info: $e');
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
                    return const MainShellScreen();
                  }
                  return const AuthScreen();
                },
              ),
      ),
    );
  }
}
