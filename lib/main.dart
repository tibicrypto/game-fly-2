import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'state/game_state_manager.dart';
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
    ChangeNotifierProvider(
      create: (_) => GameStateManager(),
      child: const SkyHaulerApp(),
    ),
  );
}

class SkyHaulerApp extends StatelessWidget {
  const SkyHaulerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SKY HAULER: HEAVY FUEL',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF87CEEB),
        fontFamily: 'Courier',
      ),
      debugShowCheckedModeBanner: false,
      home: const GameNavigator(),
    );
  }
}

class GameNavigator extends StatelessWidget {
  const GameNavigator({Key? key}) : super(key: key);

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
