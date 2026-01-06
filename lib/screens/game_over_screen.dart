import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state_manager.dart';
import '../localization/app_localizations.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateManager>(context);
    final localizations = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    String title;
    String message;
    Color titleColor;
    IconData icon;

    switch (gameState.gameOverReason) {
      case GameOverReason.crashed:
        title = localizations.crashed;
        message = localizations.crashedMessage;
        titleColor = Colors.red;
        icon = Icons.terrain;
        break;
      case GameOverReason.outOfFuel:
        title = localizations.outOfFuel;
        message = localizations.outOfFuelMessage;
        titleColor = Colors.orange;
        icon = Icons.local_gas_station;
        break;
      case GameOverReason.explosion:
        title = localizations.explosion;
        message = localizations.explosionMessage;
        titleColor = Colors.deepOrange;
        icon = Icons.warning;
        break;
      default:
        title = localizations.gameOver;
        message = '';
        titleColor = Colors.grey;
        icon = Icons.cancel;
    }

    int earnedMoney = 0;
    if (!gameState.cargoJettisoned &&
        gameState.selectedCargo != null &&
        gameState.gameOverReason != GameOverReason.explosion) {
      earnedMoney = gameState.selectedCargo!.reward;
    }

    int distanceMoney = (gameState.currentDistance / 10).floor();

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A5F), Color(0xFF2C5F8D)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
                vertical: size.height * 0.03,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.05),
                  // Game Over Icon
                  Icon(icon, size: size.width * 0.2, color: titleColor),
                  SizedBox(height: size.height * 0.02),

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: size.width * 0.1,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(2, 2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: size.height * 0.01),

                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

                  // Stats Container
                  Container(
                    width: size.width * 0.9,
                    margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    padding: EdgeInsets.all(size.width * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          localizations.flightReport,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Divider(
                            color: Colors.white30, height: size.height * 0.03),
                        _buildStatRow(context, localizations.distanceTraveled,
                            '${gameState.currentDistance}m', Colors.lightBlue),
                        SizedBox(height: size.height * 0.01),
                        _buildStatRow(context, localizations.distanceBonus,
                            '\$$distanceMoney', Colors.green),
                        if (earnedMoney > 0) ...[
                          SizedBox(height: size.height * 0.01),
                          _buildStatRow(context, localizations.cargoDelivered,
                              '\$$earnedMoney', Colors.yellow),
                        ],
                        if (gameState.cargoJettisoned) ...[
                          SizedBox(height: size.height * 0.01),
                          _buildStatRow(context, localizations.cargoStatus,
                              localizations.jettisoned, Colors.red),
                        ],
                        Divider(
                            color: Colors.white30, height: size.height * 0.03),
                        _buildStatRow(
                          context,
                          localizations.totalEarned,
                          '\$${earnedMoney + distanceMoney}',
                          Colors.yellow,
                          isTotal: true,
                        ),
                        SizedBox(height: size.height * 0.01),
                        _buildStatRow(
                          context,
                          localizations.totalMoney,
                          '\$${gameState.money}',
                          Colors.green,
                          isTotal: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Buttons
                  SizedBox(
                    width: size.width * 0.7,
                    child: ElevatedButton(
                      onPressed: () =>
                          gameState.setState(GameState.selectCargo),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.08,
                          vertical: size.height * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.replay, size: size.width * 0.06),
                          SizedBox(width: size.width * 0.02),
                          Text(
                            localizations.tryAgain,
                            style: TextStyle(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.015),

                  SizedBox(
                    width: size.width * 0.7,
                    child: ElevatedButton(
                      onPressed: () => gameState.returnToMenu(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.08,
                          vertical: size.height * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        localizations.mainMenu,
                        style: TextStyle(fontSize: size.width * 0.04),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
      BuildContext context, String label, String value, Color valueColor,
      {bool isTotal = false}) {
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTotal ? size.width * 0.045 : size.width * 0.037,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: size.width * 0.02),
        Flexible(
          flex: 2,
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: isTotal ? size.width * 0.055 : size.width * 0.042,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
