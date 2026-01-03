import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state_manager.dart';
import '../config/game_config.dart';

class PlaneSelectionScreen extends StatelessWidget {
  const PlaneSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameStateManager>(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SELECT PLANE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => gameState.setState(GameState.selectCargo),
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
          child: Column(
            children: [
              // Current contract info
              if (gameState.selectedCargo != null)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contract: ${gameState.selectedCargo!.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${gameState.selectedCargo!.weight}kg • \$${gameState.selectedCargo!.reward}',
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Planes list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: PlaneStats.all.length,
                  itemBuilder: (context, index) {
                    final plane = PlaneStats.all[index];
                    final isOwned = gameState.ownedPlanes.contains(plane);
                    final isSelected = gameState.selectedPlane == plane;
                    final canBuy = gameState.canBuyPlane(plane);
                    
                    return _buildPlaneCard(
                      context,
                      plane,
                      gameState,
                      isOwned,
                      isSelected,
                      canBuy,
                    );
                  },
                ),
              ),
              
              // Start button
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => gameState.startGame(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.flight_takeoff, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'START FLIGHT',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPlaneCard(
    BuildContext context,
    PlaneStats plane,
    GameStateManager gameState,
    bool isOwned,
    bool isSelected,
    bool canBuy,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 10 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Colors.green, width: 3)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: isOwned
            ? () => gameState.selectPlane(plane)
            : canBuy
                ? () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Buy ${plane.name}?'),
                        content: Text(
                          'This will cost \$${plane.price}.\nYou have \$${gameState.money}.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (gameState.buyPlane(plane)) {
                                gameState.selectPlane(plane);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${plane.name} purchased!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            child: const Text('Buy'),
                          ),
                        ],
                      ),
                    );
                  }
                : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: isSelected
                  ? [Colors.green.withOpacity(0.2), Colors.white]
                  : [Colors.white, Colors.grey.withOpacity(0.1)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.airplanemode_active,
                        size: 32,
                        color: isOwned ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plane.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isOwned)
                            Text(
                              '\$${plane.price}',
                              style: TextStyle(
                                fontSize: 18,
                                color: canBuy ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (isOwned)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isSelected ? 'SELECTED' : 'OWNED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (!isOwned && !canBuy)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'LOCKED',
                        style: TextStyle(
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
                plane.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatBar('Weight', plane.baseWeight, 200, Colors.orange),
                  _buildStatBar('Power', plane.liftPower, 50, Colors.blue),
                  _buildStatBar('Fuel Cap', plane.maxFuelCapacity, 200, Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatBar(String label, double value, double max, Color color) {
    return SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (value / max).clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          Text(
            value.toStringAsFixed(0),
            style: const TextStyle(fontSize: 9),
          ),
        ],
      ),
    );
  }
}
