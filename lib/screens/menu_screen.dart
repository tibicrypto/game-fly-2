import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state_manager.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateManager>(context);
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              const Icon(
                Icons.airplanemode_active,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'SKY HAULER',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(3, 3),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              const Text(
                'HEAVY FUEL',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Pump fuel to fly, but watch the weight!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 50),
              
              // Stats
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Money:',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          '\$${gameState.money}',
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Distance:',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          '${gameState.totalDistance}m',
                          style: const TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Buttons
              _buildMenuButton(
                context,
                'START MISSION',
                Icons.flight_takeoff,
                Colors.green,
                () => gameState.setState(GameState.selectCargo),
              ),
              
              const SizedBox(height: 15),
              
              _buildMenuButton(
                context,
                'HANGAR (${gameState.ownedPlanes.length} planes)',
                Icons.shopping_cart,
                Colors.blue,
                () => gameState.setState(GameState.selectPlane),
              ),
              
              const SizedBox(height: 15),
              
              _buildMenuButton(
                context,
                'HOW TO PLAY',
                Icons.help_outline,
                Colors.orange,
                () => _showInstructions(context),
              ),
            ],
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
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  
  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('HOW TO PLAY'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '🎮 CONTROLS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Text('• Hold 2 FINGERS to refuel & thrust'),
              Text('• Release to glide and save fuel'),
              Text('• Swipe DOWN to jettison cargo'),
              SizedBox(height: 15),
              Text(
                '⚖️ PHYSICS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Text('• More fuel = Heavier plane = Harder to fly'),
              Text('• Heavy cargo needs careful fuel management'),
              Text('• Balance thrust and weight to survive'),
              SizedBox(height: 15),
              Text(
                '⚠️ DANGERS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Text('• Crash into terrain = GAME OVER'),
              Text('• Run out of fuel = FALL'),
              Text('• Fly too high = Lightning damage'),
              SizedBox(height: 15),
              Text(
                '💰 REWARDS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Text('• Deliver cargo = Big money'),
              Text('• Jettison cargo = Only distance points'),
              Text('• Buy better planes in the hangar'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('GOT IT!'),
          ),
        ],
      ),
    );
  }
}
