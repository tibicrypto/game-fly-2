import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state_manager.dart';

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateManager>(context);
    final size = MediaQuery.of(context).size;
    
    String title;
    String message;
    Color titleColor;
    IconData icon;
    
    switch (gameState.gameOverReason) {
      case GameOverReason.crashed:
        title = 'CRASHED!';
        message = 'You hit the terrain!';
        titleColor = Colors.red;
        icon = Icons.terrain;
        break;
      case GameOverReason.outOfFuel:
        title = 'OUT OF FUEL!';
        message = 'Your plane ran out of fuel!';
        titleColor = Colors.orange;
        icon = Icons.local_gas_station;
        break;
      case GameOverReason.explosion:
        title = 'EXPLOSION!';
        message = 'The explosive cargo detonated!';
        titleColor = Colors.deepOrange;
        icon = Icons.warning;
        break;
      default:
        title = 'GAME OVER';
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Game Over Icon
              Icon(icon, size: 100, color: titleColor),
              const SizedBox(height: 20),
              
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 48,
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
              ),
              
              const SizedBox(height: 10),
              
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Stats Container
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'FLIGHT REPORT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(color: Colors.white30, height: 30),
                    
                    _buildStatRow('Distance Traveled', '${gameState.currentDistance}m', Colors.lightBlue),
                    const SizedBox(height: 10),
                    _buildStatRow('Distance Bonus', '\$$distanceMoney', Colors.green),
                    
                    if (earnedMoney > 0) ...[
                      const SizedBox(height: 10),
                      _buildStatRow('Cargo Delivered ✓', '\$$earnedMoney', Colors.yellow),
                    ],
                    
                    if (gameState.cargoJettisoned) ...[
                      const SizedBox(height: 10),
                      _buildStatRow('Cargo Status', 'JETTISONED', Colors.red),
                    ],
                    
                    const Divider(color: Colors.white30, height: 30),
                    
                    _buildStatRow(
                      'TOTAL EARNED',
                      '\$${earnedMoney + distanceMoney}',
                      Colors.yellow,
                      isTotal: true,
                    ),
                    
                    const SizedBox(height: 10),
                    
                    _buildStatRow(
                      'Total Money',
                      '\$${gameState.money}',
                      Colors.green,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Buttons
              ElevatedButton(
                onPressed: () => gameState.setState(GameState.selectCargo),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.replay, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'TRY AGAIN',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 15),
              
              ElevatedButton(
                onPressed: () => gameState.returnToMenu(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'MAIN MENU',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value, Color valueColor, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: isTotal ? 24 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
