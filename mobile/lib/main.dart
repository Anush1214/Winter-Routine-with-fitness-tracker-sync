import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/solo_colors.dart';
import 'services/supabase_service.dart';
import 'services/notification_service.dart';
import 'presentation/screens/home_quest_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize native on-device notifications
  await NotificationService().init();
  
  runApp(const WinterArcMobileApp());
}

class WinterArcMobileApp extends StatelessWidget {
  const WinterArcMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
        home: const HomeQuestScreen(),
      ),
    );
  }
}
