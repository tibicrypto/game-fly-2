import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state_manager.dart';
import '../config/game_config.dart';

class CargoSelectionScreen extends StatelessWidget {
  const CargoSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateManager>(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SELECT CONTRACT'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => gameState.returnToMenu(),
        ),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E90FF), Color(0xFF87CEEB)],
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: CargoClass.all.length,
            itemBuilder: (context, index) {
              final cargo = CargoClass.all[index];
              return _buildCargoCard(context, cargo, gameState);
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildCargoCard(BuildContext context, CargoClass cargo, GameStateManager gameState) {
    Color difficultyColor;
    String difficulty;
    
    switch (cargo.type) {
      case CargoType.mail:
        difficultyColor = Colors.green;
        difficulty = 'EASY';
        break;
      case CargoType.food:
        difficultyColor = Colors.yellow;
        difficulty = 'MEDIUM';
        break;
      case CargoType.gold:
        difficultyColor = Colors.orange;
        difficulty = 'HARD';
        break;
      case CargoType.uranium:
        difficultyColor = Colors.red;
        difficulty = 'EXTREME';
        break;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          gameState.selectCargo(cargo);
          gameState.setState(GameState.selectPlane);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [Colors.white, difficultyColor.withOpacity(0.1)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      cargo.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: difficultyColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      difficulty,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                cargo.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatChip(
                    Icons.scale,
                    '${cargo.weight.toInt()}kg',
                    Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    Icons.attach_money,
                    '${cargo.reward}',
                    Colors.green,
                  ),
                  if (cargo.explosive) ...[
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.warning,
                      'EXPLOSIVE',
                      Colors.red,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
