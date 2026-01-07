import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'state/game_state_manager.dart';
import 'localization/language_provider.dart';
import 'localization/app_localizations.dart';
import 'screens/menu_screen.dart';
import 'screens/cargo_selection_screen.dart';
import 'screens/plane_selection_screen.dart';
import 'screens/game_screen.dart';
import 'screens/game_over_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode and hide system UI
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameStateManager()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const SkyHaulerApp(),
    ),
  );
}

class SkyHaulerApp extends StatefulWidget {
  const SkyHaulerApp({super.key});

  @override
  State<SkyHaulerApp> createState() => _SkyHaulerAppState();
}

class _SkyHaulerAppState extends State<SkyHaulerApp> {
  String _appTitle = 'fly';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appTitle = 'fly${packageInfo.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: _appTitle,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFF87CEEB),
            textTheme: GoogleFonts.robotoTextTheme(),
          ),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            AppLocalizationsDelegate(languageProvider.currentLanguage),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('vi', ''),
          ],
          home: const GameNavigator(),
        );
      },
    );
  }
}

class GameNavigator extends StatelessWidget {
  const GameNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateManager>(
      builder: (context, gameState, child) {
        switch (gameState.state) {
          case GameState.menu:
            return const MenuScreen();
          case GameState.selectCargo:
            return const CargoSelectionScreen();
          case GameState.selectPlane:
            return const PlaneSelectionScreen();
          case GameState.playing:
          case GameState.paused:
            return const GameScreen();
          case GameState.gameOver:
            return const GameOverScreen();
        }
      },
    );
  }
}
