import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'dart:math';
import '../config/game_config.dart';
import '../engine/physics_engine.dart';
import '../engine/terrain_generator.dart';
import '../engine/obstacle_generator.dart';
import '../state/game_state_manager.dart';
import '../localization/app_localizations.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late PhysicsEngine _physics;
  late TerrainGenerator _terrain;
  late ObstacleGenerator _obstacles;

  int _activeTouches = 0;
  bool _isRefueling = false;
  double _cameraX = 0;
  int _distance = 0;

  @override
  void initState() {
    super.initState();

    final gameState = Provider.of<GameStateManager>(context, listen: false);

    _physics = PhysicsEngine(
      planeStats: gameState.selectedPlane,
      cargo: gameState.selectedCargo,
    );

    _terrain = TerrainGenerator(
      frequency: GameConfig.noiseFrequency,
      amplitude: GameConfig.noiseAmplitude,
      baseHeight: GameConfig.groundBaseHeight,
    );

    _obstacles = ObstacleGenerator(startX: 500.0);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(days: 365),
    )..addListener(_gameLoop);

    _animationController.forward();
  }

  void _gameLoop() {
    if (!mounted) return;

    final gameState = Provider.of<GameStateManager>(context, listen: false);
    if (gameState.state != GameState.playing) return;

    setState(() {
      // Update physics (60 FPS target)
      _physics.update(1 / 60);

      // Update obstacles
      _obstacles.update(_physics.planeX, 1000.0);

      // Update camera to follow plane
      _cameraX = _physics.planeX - 200;

      // Update distance
      _distance = (_physics.planeX / 10).floor();
      gameState.updateDistance(_distance);

      // Check collision with terrain
      double groundHeight = _terrain.getHeight(_physics.planeX);
      if (_physics.isCrashed(groundHeight)) {
        _endGame(GameOverReason.crashed);
      }

      // Check collision with obstacles
      for (var obstacle in _obstacles.obstacles) {
        if (_physics.checkObstacleCollision(obstacle)) {
          obstacle.isActive = false;
          _endGame(GameOverReason.crashed);
          break;
        }
      }

      // Check out of fuel
      if (_physics.isOutOfFuel()) {
        _endGame(GameOverReason.outOfFuel);
      }

      // Check explosion (if carrying explosive cargo and crashed)
      if (gameState.selectedCargo?.explosive == true &&
          _physics.isCrashed(groundHeight)) {
        _endGame(GameOverReason.explosion);
      }
    });
  }

  void _handleTouchUpdate(int touches) {
    setState(() {
      _activeTouches = touches;

      if (touches >= 2 && !_isRefueling) {
        _isRefueling = true;
        _physics.startRefueling();
        _vibrate();
      } else if (touches < 2 && _isRefueling) {
        _isRefueling = false;
        _physics.stopRefueling();
      }
    });
  }

  void _handleJettison() {
    final gameState = Provider.of<GameStateManager>(context, listen: false);
    if (gameState.selectedCargo != null && !gameState.cargoJettisoned) {
      setState(() {
        gameState.jettisonCargo();
        _physics = PhysicsEngine(
          planeStats: gameState.selectedPlane,
          cargo: null,
          initialFuel: _physics.fuel,
        );
        _physics.planeX = (_physics).planeX;
        _physics.planeY = (_physics).planeY;
        _physics.velocityY = (_physics).velocityY;
      });
      _vibrate(duration: 300);
    }
  }

  void _vibrate({int duration = 100}) {
    if (GameConfig.enableVibration) {
      Vibration.vibrate(duration: duration);
    }
  }

  void _endGame(GameOverReason reason) {
    _animationController.stop();
    final gameState = Provider.of<GameStateManager>(context, listen: false);
    gameState.endGame(reason, _distance);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Listener(
        onPointerDown: (_) => _handleTouchUpdate(_activeTouches + 1),
        onPointerUp: (_) => _handleTouchUpdate(max(0, _activeTouches - 1)),
        onPointerCancel: (_) => _handleTouchUpdate(0),
        child: GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! > 500) {
              _handleJettison();
            }
          },
          child: Container(
            width: size.width,
            height: size.height,
            color: const Color(0xFF87CEEB),
            child: Stack(
              children: [
                // Game world
                CustomPaint(
                  size: Size(size.width, size.height),
                  painter: GamePainter(
                    physics: _physics,
                    terrain: _terrain,
                    obstacles: _obstacles,
                    cameraX: _cameraX,
                    screenSize: size,
                    isRefueling: _isRefueling,
                  ),
                ),

                // HUD
                _buildHUD(context),

                // Pause overlay
                Consumer<GameStateManager>(
                  builder: (context, gameState, child) {
                    if (gameState.state == GameState.paused) {
                      return _buildPauseOverlay(context);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHUD(BuildContext context) {
    final gameState = Provider.of<GameStateManager>(context);
    final localizations = AppLocalizations.of(context);

    final screenSize = MediaQuery.of(context).size;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(screenSize.width * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.025,
                      vertical: screenSize.height * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${localizations.distance}: ${_distance}m',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenSize.width * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${localizations.money} \$${gameState.money}',
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: screenSize.width * 0.032,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Pause button
                IconButton(
                  icon: Icon(Icons.pause,
                      color: Colors.white, size: screenSize.width * 0.08),
                  onPressed: () => gameState.pauseGame(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            SizedBox(height: screenSize.height * 0.015),

            // Fuel gauge
            Container(
              width: screenSize.width * 0.45,
              padding: EdgeInsets.all(screenSize.width * 0.02),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localizations.fuel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenSize.width * 0.028,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.004),
                  Stack(
                    children: [
                      Container(
                        height: screenSize.height * 0.02,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (_physics.fuel /
                                _physics.planeStats.maxFuelCapacity)
                            .clamp(0.0, 1.0),
                        child: Container(
                          height: screenSize.height * 0.02,
                          decoration: BoxDecoration(
                            color:
                                _physics.fuel < 10 ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${_physics.fuel.toStringAsFixed(1)}/${_physics.planeStats.maxFuelCapacity}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenSize.width * 0.025,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Controls hint
            if (!_isRefueling && _distance < 100)
              Center(
                child: Container(
                  constraints:
                      BoxConstraints(maxWidth: screenSize.width * 0.85),
                  padding: EdgeInsets.all(screenSize.width * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app,
                          color: Colors.white, size: screenSize.width * 0.1),
                      SizedBox(height: screenSize.height * 0.008),
                      Text(
                        localizations.holdTwoFingers,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenSize.width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        localizations.toRefuelThrust,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: screenSize.width * 0.032,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.015),
                      Icon(Icons.arrow_downward,
                          color: Colors.orange, size: screenSize.width * 0.07),
                      Text(
                        localizations.swipeDown,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenSize.width * 0.038,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        localizations.toJettisonCargo,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: screenSize.width * 0.028,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Refueling indicator
            if (_isRefueling)
              Center(
                child: Container(
                  padding: EdgeInsets.all(screenSize.width * 0.025),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '⛽ REFUELING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenSize.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Lightning warning
            if (_physics.hasLightningDamage)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⚡ ENGINE DAMAGED!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseOverlay(BuildContext context) {
    final gameState = Provider.of<GameStateManager>(context, listen: false);
    final localizations = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      color: Colors.black54,
      child: Center(
        child: Container(
          width: size.width * 0.8,
          padding: EdgeInsets.all(size.width * 0.05),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white30, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pause_circle_filled,
                size: size.width * 0.15,
                color: Colors.white,
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                localizations.paused,
                style: TextStyle(
                  fontSize: size.width * 0.08,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: size.height * 0.04),

              // Resume button
              SizedBox(
                width: size.width * 0.6,
                child: ElevatedButton(
                  onPressed: () => gameState.resumeGame(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow, size: size.width * 0.06),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        localizations.resume,
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

              // Main menu button
              SizedBox(
                width: size.width * 0.6,
                child: ElevatedButton(
                  onPressed: () => gameState.returnToMenu(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    localizations.mainMenu,
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final PhysicsEngine physics;
  final TerrainGenerator terrain;
  final ObstacleGenerator obstacles;
  final double cameraX;
  final Size screenSize;
  final bool isRefueling;

  GamePainter({
    required this.physics,
    required this.terrain,
    required this.obstacles,
    required this.cameraX,
    required this.screenSize,
    required this.isRefueling,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Scale factor for responsive design
    double scaleX = size.width / GameConfig.gameWorldWidth;
    double scaleY = size.height / GameConfig.gameWorldHeight;

    // Draw clouds (ceiling)
    _drawClouds(canvas, size);

    // Draw terrain
    _drawTerrain(canvas, size, scaleX, scaleY);

    // Draw obstacles
    _drawObstacles(canvas, size, scaleX, scaleY);

    // Draw plane
    _drawPlane(canvas, size, scaleX, scaleY);

    // Draw refueling effect
    if (isRefueling) {
      _drawRefuelingEffect(canvas, size, scaleX, scaleY);
    }
  }

  void _drawClouds(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Draw cloud layer at top
    for (double x = 0; x < size.width; x += 80) {
      canvas.drawCircle(
        Offset(x, 50),
        30,
        paint,
      );
    }
  }

  void _drawTerrain(Canvas canvas, Size size, double scaleX, double scaleY) {
    final paint = Paint()
      ..color = const Color(0xFF228B22)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    // Draw visible terrain
    for (double x = 0; x < size.width; x += 10) {
      double worldX = cameraX + (x / scaleX);
      double height = terrain.getHeight(worldX);
      double screenY = size.height - (height * scaleY);
      path.lineTo(x, screenY);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawPlane(Canvas canvas, Size size, double scaleX, double scaleY) {
    // Convert world coordinates to screen coordinates
    double screenX = (physics.planeX - cameraX) * scaleX;
    double screenY = size.height - (physics.planeY * scaleY);

    final planePaint = Paint()
      ..color = physics.hasLightningDamage ? Colors.red : Colors.blue
      ..style = PaintingStyle.fill;

    // Draw simple plane shape
    final planePath = Path();
    planePath.moveTo(screenX, screenY);
    planePath.lineTo(screenX - 20, screenY + 5);
    planePath.lineTo(screenX - 25, screenY);
    planePath.lineTo(screenX - 20, screenY - 5);
    planePath.close();

    // Wings
    planePath.moveTo(screenX - 15, screenY);
    planePath.lineTo(screenX - 15, screenY - 15);
    planePath.lineTo(screenX - 12, screenY);
    planePath.lineTo(screenX - 15, screenY + 15);
    planePath.close();

    canvas.drawPath(planePath, planePaint);

    // Engine flame
    if (isRefueling || physics.velocityY > 0) {
      final flamePaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(screenX - 25, screenY), 8, flamePaint);
      canvas.drawCircle(
          Offset(screenX - 30, screenY), 6, Paint()..color = Colors.yellow);
    }
  }

  void _drawRefuelingEffect(
      Canvas canvas, Size size, double scaleX, double scaleY) {
    double screenX = (physics.planeX - cameraX) * scaleX;
    double screenY = size.height - (physics.planeY * scaleY);

    final fuelPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Fuel hose animation
    canvas.drawLine(
      Offset(screenX, screenY - 30),
      Offset(screenX, screenY),
      fuelPaint,
    );
  }

  void _drawObstacles(Canvas canvas, Size size, double scaleX, double scaleY) {
    // Get obstacles in visible range
    double viewMinX = cameraX - 100;
    double viewMaxX = cameraX + (size.width / scaleX) + 100;

    var visibleObstacles = obstacles.getObstaclesInRange(viewMinX, viewMaxX);

    for (var obstacle in visibleObstacles) {
      if (!obstacle.isActive) continue;

      double screenX = (obstacle.x - cameraX) * scaleX;
      double screenY = size.height - (obstacle.y * scaleY);
      double screenWidth = obstacle.width * scaleX;
      double screenHeight = obstacle.height * scaleY;

      switch (obstacle.type) {
        case ObstacleType.mountain:
          _drawMountain(canvas, screenX, screenY, screenWidth, screenHeight);
          break;
        case ObstacleType.bird:
          _drawBird(canvas, screenX, screenY, screenWidth, screenHeight);
          break;
        case ObstacleType.missile:
          _drawMissile(canvas, screenX, screenY, screenWidth, screenHeight);
          break;
        case ObstacleType.plane:
          _drawOtherPlane(canvas, screenX, screenY, screenWidth, screenHeight);
          break;
        case ObstacleType.alien:
          _drawAlien(canvas, screenX, screenY, screenWidth, screenHeight);
          break;
      }
    }
  }

  void _drawMountain(
      Canvas canvas, double x, double y, double width, double height) {
    final paint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(x, y);
    path.lineTo(x + width / 2, y - height);
    path.lineTo(x + width, y);
    path.close();

    canvas.drawPath(path, paint);

    // Snow cap
    final snowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final snowPath = Path();
    snowPath.moveTo(x + width / 2 - 15, y - height + 30);
    snowPath.lineTo(x + width / 2, y - height);
    snowPath.lineTo(x + width / 2 + 15, y - height + 30);
    snowPath.close();

    canvas.drawPath(snowPath, snowPaint);
  }

  void _drawBird(
      Canvas canvas, double x, double y, double width, double height) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Bird "V" shape
    final path = Path();
    path.moveTo(x, y - height / 2);
    path.lineTo(x + width / 2, y);
    path.lineTo(x + width, y - height / 2);

    canvas.drawPath(path, paint);
  }

  void _drawMissile(
      Canvas canvas, double x, double y, double width, double height) {
    final bodyPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Missile body
    canvas.drawRect(
      Rect.fromLTWH(x, y - height / 2, width * 0.7, height),
      bodyPaint,
    );

    // Missile nose cone
    final nosePaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    final nosePath = Path();
    nosePath.moveTo(x + width * 0.7, y - height / 2);
    nosePath.lineTo(x + width, y);
    nosePath.lineTo(x + width * 0.7, y + height / 2);
    nosePath.close();

    canvas.drawPath(nosePath, nosePaint);

    // Flame trail
    final flamePaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x - 5, y), 8, flamePaint);
  }

  void _drawOtherPlane(
      Canvas canvas, double x, double y, double width, double height) {
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    // Plane body
    final path = Path();
    path.moveTo(x + width, y);
    path.lineTo(x + width * 0.2, y + height / 3);
    path.lineTo(x, y);
    path.lineTo(x + width * 0.2, y - height / 3);
    path.close();

    canvas.drawPath(path, paint);

    // Wings
    canvas.drawRect(
      Rect.fromLTWH(x + width * 0.3, y - height / 2, width * 0.1, height),
      paint,
    );
  }

  void _drawAlien(
      Canvas canvas, double x, double y, double width, double height) {
    final ufoBodyPaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.fill;

    // UFO dome
    canvas.drawOval(
      Rect.fromLTWH(
          x + width * 0.2, y - height * 0.7, width * 0.6, height * 0.5),
      ufoBodyPaint,
    );

    // UFO base
    final basePaint = Paint()
      ..color = Colors.purple[300]!
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromLTWH(x, y - height * 0.3, width, height * 0.4),
      basePaint,
    );

    // Lights
    final lightPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(x + width * (0.25 + i * 0.25), y),
        3,
        lightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) => true;
}
