import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state_manager.dart';
import '../localization/app_localizations.dart';
import '../localization/language_provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateManager>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E90FF),
              Color(0xFF87CEEB),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.02),
                  // Language toggle button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => languageProvider.toggleLanguage(),
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.language, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            languageProvider.currentLanguage ==
                                    AppLanguage.english
                                ? 'EN'
                                : 'VI',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Title
                  Icon(
                    Icons.airplanemode_active,
                    size: size.width * 0.15,
                    color: Colors.white,
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    localizations.appTitle,
                    style: TextStyle(
                      fontSize: size.width * 0.1,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(3, 3),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    localizations.appSubtitle,
                    style: TextStyle(
                      fontSize: size.width * 0.055,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      localizations.appTagline,
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Stats
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                    padding: EdgeInsets.all(size.width * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localizations.money,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.045),
                            ),
                            Flexible(
                              child: Text(
                                '\$${gameState.money}',
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontSize: size.width * 0.055,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localizations.totalDistance,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: size.width * 0.04),
                            ),
                            Flexible(
                              child: Text(
                                '${gameState.totalDistance}m',
                                style: TextStyle(
                                  color: Colors.lightBlue,
                                  fontSize: size.width * 0.045,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Buttons
                  _buildMenuButton(
                    context,
                    localizations.startMission,
                    Icons.flight_takeoff,
                    Colors.green,
                    () => gameState.setState(GameState.selectCargo),
                  ),

                  SizedBox(height: size.height * 0.015),

                  _buildMenuButton(
                    context,
                    '${localizations.hangar} (${gameState.ownedPlanes.length} ${localizations.planes})',
                    Icons.shopping_cart,
                    Colors.blue,
                    () => gameState.setState(GameState.selectPlane),
                  ),

                  SizedBox(height: size.height * 0.015),

                  _buildMenuButton(
                    context,
                    localizations.howToPlay,
                    Icons.help_outline,
                    Colors.orange,
                    () => _showInstructions(context),
                  ),
                  SizedBox(height: size.height * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width * 0.85,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.018,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: size.width * 0.06),
            SizedBox(width: size.width * 0.02),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                    fontSize: size.width * 0.045, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInstructions(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.howToPlay),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.controls,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(localizations.controlsText1),
              Text(localizations.controlsText2),
              Text(localizations.controlsText3),
              SizedBox(height: 15),
              Text(
                localizations.physics,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(localizations.physicsText1),
              Text(localizations.physicsText2),
              Text(localizations.physicsText3),
              SizedBox(height: 15),
              Text(
                localizations.dangers,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(localizations.dangersText1),
              Text(localizations.dangersText2),
              Text(localizations.dangersText3),
              SizedBox(height: 15),
              Text(
                localizations.rewards,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(localizations.rewardsText1),
              Text(localizations.rewardsText2),
              Text(localizations.rewardsText3),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.gotIt),
          ),
        ],
      ),
    );
  }
}
