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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.05),
                  // Title
                  Icon(
                    Icons.airplanemode_active,
                    size: size.width * 0.15,
                    color: Colors.white,
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    'SKY HAULER',
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
                    'HEAVY FUEL',
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
                      'Pump fuel to fly, but watch the weight!',
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
                              'Money:',
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
                              'Total Distance:',
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
                    'START MISSION',
                    Icons.flight_takeoff,
                    Colors.green,
                    () => gameState.setState(GameState.selectCargo),
                  ),

                  SizedBox(height: size.height * 0.015),

                  _buildMenuButton(
                    context,
                    'HANGAR (${gameState.ownedPlanes.length} planes)',
                    Icons.shopping_cart,
                    Colors.blue,
                    () => gameState.setState(GameState.selectPlane),
                  ),

                  SizedBox(height: size.height * 0.015),

                  _buildMenuButton(
                    context,
                    'HOW TO PLAY',
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
