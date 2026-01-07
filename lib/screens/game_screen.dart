import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'dart:math';
import '../config/game_config.dart';
import '../engine/physics_engine.dart';
import '../engine/terrain_generator.dart';
import '../engine/obstacle_generator.dart';
import '../state/game_state_manager.dart';
import '../localization/app_localizations.dart';
import '../services/sound_manager.dart';
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
  GameState _lastState = GameState.playing;

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

    // Listen for state changes to handle continue
    gameState.addListener(_handleStateChange);
    
    // Play gameplay music
    SoundManager().playMusic(SoundManager.gameplayMusic);
  }

  void _handleStateChange() {
    final gameState = Provider.of<GameStateManager>(context, listen: false);

    // Check if we're resuming from game over (continue button)
    if (_lastState == GameState.gameOver &&
        gameState.state == GameState.playing) {
      // Reset physics for continue
      _physics.resetForContinue();
      _animationController.forward();
    }

    _lastState = gameState.state;
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
        SoundManager().playSfx(SoundManager.crash);
        _endGame(GameOverReason.crashed);
      }

      // Check collision with obstacles
      for (var obstacle in _obstacles.obstacles) {
        if (_physics.checkObstacleCollision(obstacle)) {
          obstacle.isActive = false;
          SoundManager().playSfx(SoundManager.crash);
          _endGame(GameOverReason.crashed);
          break;
        }
      }

      // Check out of fuel
      if (_physics.isOutOfFuel()) {
        SoundManager().playSfx(SoundManager.warning);
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
      SoundManager().playSfx(SoundManager.whoosh);
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
    final gameState = Provider.of<GameStateManager>(context, listen: false);
    gameState.removeListener(_handleStateChange);
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
    // Draw danger zone background
    final dangerZonePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.red.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 100));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 100), dangerZonePaint);

    // Draw detailed cloud layer
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final cloudShadowPaint = Paint()
      ..color = Colors.grey[400]!.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Draw multiple cloud puffs to create a cloud ceiling
    for (double x = -20; x < size.width + 20; x += 60) {
      double offset = (x / 60).floor() % 2 == 0 ? 10 : 0;

      // Cloud shadow
      canvas.drawCircle(Offset(x + 2, 72 + offset), 28, cloudShadowPaint);
      canvas.drawCircle(Offset(x + 32, 68 + offset), 25, cloudShadowPaint);
      canvas.drawCircle(Offset(x + 17, 82 + offset), 22, cloudShadowPaint);

      // Main cloud puffs
      canvas.drawCircle(Offset(x, 70 + offset), 28, cloudPaint);
      canvas.drawCircle(Offset(x + 30, 66 + offset), 25, cloudPaint);
      canvas.drawCircle(Offset(x + 15, 80 + offset), 22, cloudPaint);
      canvas.drawCircle(Offset(x + 45, 75 + offset), 20, cloudPaint);
    }

    // Draw warning line at cloud ceiling height
    final warningLinePaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dashWidth = 10.0;
    final dashSpace = 5.0;
    for (double x = 0; x < size.width; x += dashWidth + dashSpace) {
      canvas.drawLine(
        Offset(x, 95),
        Offset(x + dashWidth, 95),
        warningLinePaint,
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

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(screenX - 2, screenY + 3), width: 50, height: 15),
      shadowPaint,
    );

    final baseColor = physics.hasLightningDamage ? Colors.red : Colors.blue;

    // Fuselage (main body) with gradient
    final fuselagePaint = Paint()
      ..shader = LinearGradient(
        colors: [baseColor.shade700, baseColor.shade400],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(screenX - 30, screenY - 8, 35, 16));

    final fuselagePath = Path();
    fuselagePath.moveTo(screenX + 5, screenY); // Nose
    fuselagePath.quadraticBezierTo(
        screenX + 3, screenY - 8, screenX - 10, screenY - 8);
    fuselagePath.lineTo(screenX - 25, screenY - 6);
    fuselagePath.lineTo(screenX - 30, screenY);
    fuselagePath.lineTo(screenX - 25, screenY + 6);
    fuselagePath.lineTo(screenX - 10, screenY + 8);
    fuselagePath.quadraticBezierTo(
        screenX + 3, screenY + 8, screenX + 5, screenY);
    fuselagePath.close();
    canvas.drawPath(fuselagePath, fuselagePaint);

    // Windows
    final windowPaint = Paint()
      ..color = Colors.lightBlue.shade100.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(screenX - 8 - i * 7, screenY - 3),
          width: 4,
          height: 5,
        ),
        windowPaint,
      );
    }

    // Main wings
    final wingPaint = Paint()
      ..shader = LinearGradient(
        colors: [baseColor.shade600, baseColor.shade300],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(screenX - 20, screenY - 20, 10, 40));

    final wingPath = Path();
    wingPath.moveTo(screenX - 15, screenY);
    wingPath.lineTo(screenX - 18, screenY - 22);
    wingPath.lineTo(screenX - 12, screenY - 18);
    wingPath.lineTo(screenX - 10, screenY);
    wingPath.close();
    canvas.drawPath(wingPath, wingPaint);

    wingPath.reset();
    wingPath.moveTo(screenX - 15, screenY);
    wingPath.lineTo(screenX - 18, screenY + 22);
    wingPath.lineTo(screenX - 12, screenY + 18);
    wingPath.lineTo(screenX - 10, screenY);
    wingPath.close();
    canvas.drawPath(wingPath, wingPaint);

    // Tail
    final tailPath = Path();
    tailPath.moveTo(screenX - 28, screenY);
    tailPath.lineTo(screenX - 32, screenY - 12);
    tailPath.lineTo(screenX - 26, screenY - 10);
    tailPath.close();
    canvas.drawPath(tailPath, wingPaint);

    // Cockpit highlight
    final cockpitPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(screenX + 2, screenY - 4), width: 6, height: 8),
      cockpitPaint,
    );

    // Outline for definition
    final outlinePaint = Paint()
      ..color = baseColor.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(fuselagePath, outlinePaint);

    // Engine flame with particles
    if (isRefueling || physics.velocityY > 0) {
      final flamePaint = Paint()
        ..color = Colors.orange.withValues(alpha: 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(screenX - 32, screenY), width: 16, height: 12),
        flamePaint,
      );

      final innerFlamePaint = Paint()
        ..color = Colors.yellow.withValues(alpha: 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(screenX - 30, screenY), width: 10, height: 8),
        innerFlamePaint,
      );

      // Flame particles
      final particlePaint = Paint()
        ..color = Colors.orange.withValues(alpha: 0.5);
      for (int i = 0; i < 3; i++) {
        canvas.drawCircle(
          Offset(screenX - 38 - i * 3, screenY + (i % 2 == 0 ? 2 : -2)),
          2,
          particlePaint,
        );
      }
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
    // Bird body
    final bodyPaint = Paint()
      ..color = Colors.brown.shade800
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(x + width / 2, y),
          width: width * 0.3,
          height: height * 0.4),
      bodyPaint,
    );

    // Wings with gradient
    final wingPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.brown.shade700, Colors.brown.shade400],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(x, y - height / 2, width, height));

    final leftWingPath = Path();
    leftWingPath.moveTo(x + width / 2, y);
    leftWingPath.quadraticBezierTo(
        x + width * 0.2, y - height * 0.6, x, y - height * 0.4);
    leftWingPath.quadraticBezierTo(
        x + width * 0.15, y - height * 0.2, x + width / 2, y);
    leftWingPath.close();
    canvas.drawPath(leftWingPath, wingPaint);

    final rightWingPath = Path();
    rightWingPath.moveTo(x + width / 2, y);
    rightWingPath.quadraticBezierTo(
        x + width * 0.8, y - height * 0.6, x + width, y - height * 0.4);
    rightWingPath.quadraticBezierTo(
        x + width * 0.85, y - height * 0.2, x + width / 2, y);
    rightWingPath.close();
    canvas.drawPath(rightWingPath, wingPaint);

    // Wing outline
    final outlinePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(leftWingPath, outlinePaint);
    canvas.drawPath(rightWingPath, outlinePaint);

    // Beak
    final beakPaint = Paint()
      ..color = Colors.orange.shade700
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x + width / 2 + 3, y), 2, beakPaint);
  }

  void _drawMissile(
      Canvas canvas, double x, double y, double width, double height) {
    // Missile body with gradient
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.red.shade700, Colors.red.shade400],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(x, y - height / 2, width * 0.7, height));

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y - height / 2, width * 0.65, height),
      const Radius.circular(3),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Missile nose cone with gradient
    final nosePaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.yellow.shade700, Colors.yellow.shade300],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(
          x + width * 0.65, y - height / 2, width * 0.35, height));

    final nosePath = Path();
    nosePath.moveTo(x + width * 0.65, y - height / 2);
    nosePath.lineTo(x + width, y);
    nosePath.lineTo(x + width * 0.65, y + height / 2);
    nosePath.close();
    canvas.drawPath(nosePath, nosePaint);

    // Fins
    final finPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;

    final topFinPath = Path();
    topFinPath.moveTo(x + width * 0.3, y - height / 2);
    topFinPath.lineTo(x + width * 0.35, y - height * 0.8);
    topFinPath.lineTo(x + width * 0.45, y - height / 2);
    topFinPath.close();
    canvas.drawPath(topFinPath, finPaint);

    final bottomFinPath = Path();
    bottomFinPath.moveTo(x + width * 0.3, y + height / 2);
    bottomFinPath.lineTo(x + width * 0.35, y + height * 0.8);
    bottomFinPath.lineTo(x + width * 0.45, y + height / 2);
    bottomFinPath.close();
    canvas.drawPath(bottomFinPath, finPaint);

    // Enhanced flame trail
    final outerFlamePaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(x - 8, y), width: 20, height: height * 0.6),
      outerFlamePaint,
    );

    final innerFlamePaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(x - 5, y), width: 12, height: height * 0.4),
      innerFlamePaint,
    );

    // Flame particles
    final particlePaint = Paint()..color = Colors.orange.withValues(alpha: 0.5);
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(x - 15 - i * 4, y + (i % 2 == 0 ? 3 : -3)),
        2,
        particlePaint,
      );
    }

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(nosePath, outlinePaint);
  }

  void _drawOtherPlane(
      Canvas canvas, double x, double y, double width, double height) {
    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(x + width / 2 + 2, y + 2),
          width: width * 0.8,
          height: height * 0.3),
      shadowPaint,
    );

    // Plane body with gradient
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.grey.shade700, Colors.grey.shade400],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(x, y - height / 3, width, height * 0.66));

    final bodyPath = Path();
    bodyPath.moveTo(x + width, y);
    bodyPath.quadraticBezierTo(
        x + width * 0.8, y + height * 0.35, x + width * 0.2, y + height * 0.35);
    bodyPath.lineTo(x, y);
    bodyPath.lineTo(x + width * 0.2, y - height * 0.35);
    bodyPath.quadraticBezierTo(
        x + width * 0.8, y - height * 0.35, x + width, y);
    bodyPath.close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Wings with gradient
    final wingPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.grey.shade600, Colors.grey.shade300],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(
          Rect.fromLTWH(x + width * 0.3, y - height / 2, width * 0.15, height));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            x + width * 0.35, y - height * 0.55, width * 0.12, height * 1.1),
        const Radius.circular(2),
      ),
      wingPaint,
    );

    // Windows
    final windowPaint = Paint()
      ..color = Colors.lightBlue.shade100.withValues(alpha: 0.7);
    for (int i = 0; i < 2; i++) {
      canvas.drawCircle(
        Offset(x + width * 0.6 + i * width * 0.15, y),
        3,
        windowPaint,
      );
    }

    // Tail
    final tailPath = Path();
    tailPath.moveTo(x + width * 0.15, y);
    tailPath.lineTo(x, y - height * 0.4);
    tailPath.lineTo(x + width * 0.1, y - height * 0.35);
    tailPath.close();
    canvas.drawPath(tailPath, wingPaint);

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.grey.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(bodyPath, outlinePaint);
  }

  void _drawAlien(
      Canvas canvas, double x, double y, double width, double height) {
    // UFO dome with gradient
    final domePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.purple.shade300, Colors.purple.shade700],
        center: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(
          x + width * 0.2, y - height * 0.7, width * 0.6, height * 0.5));

    canvas.drawOval(
      Rect.fromLTWH(
          x + width * 0.2, y - height * 0.7, width * 0.6, height * 0.5),
      domePaint,
    );

    // Dome highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromLTWH(
          x + width * 0.35, y - height * 0.65, width * 0.2, height * 0.2),
      highlightPaint,
    );

    // UFO base with gradient
    final basePaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.purple.shade200, Colors.purple.shade500],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(x, y - height * 0.3, width, height * 0.4));

    canvas.drawOval(
      Rect.fromLTWH(x, y - height * 0.3, width, height * 0.4),
      basePaint,
    );

    // Metal ring
    final ringPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawOval(
      Rect.fromLTWH(
          x + width * 0.1, y - height * 0.25, width * 0.8, height * 0.2),
      ringPaint,
    );

    // Pulsing lights with glow
    for (int i = 0; i < 4; i++) {
      final glowPaint = Paint()
        ..color = Colors.yellow.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(
        Offset(x + width * (0.15 + i * 0.23), y - height * 0.1),
        6,
        glowPaint,
      );

      final lightPaint = Paint()
        ..color = i % 2 == 0 ? Colors.yellow : Colors.cyan
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(x + width * (0.15 + i * 0.23), y - height * 0.1),
        3,
        lightPaint,
      );
    }

    // Tractor beam
    final beamPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    final beamPath = Path();
    beamPath.moveTo(x + width * 0.4, y + height * 0.1);
    beamPath.lineTo(x + width * 0.6, y + height * 0.1);
    beamPath.lineTo(x + width * 0.7, y + height * 0.5);
    beamPath.lineTo(x + width * 0.3, y + height * 0.5);
    beamPath.close();
    canvas.drawPath(beamPath, beamPaint);

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.purple.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromLTWH(x, y - height * 0.3, width, height * 0.4),
      outlinePaint,
    );
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) => true;
}
