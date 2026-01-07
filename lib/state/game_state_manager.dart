import 'package:flutter/foundation.dart';
import '../config/game_config.dart';

enum GameState {
  menu,
  selectCargo,
  selectPlane,
  playing,
  paused,
  gameOver,
}

enum GameOverReason {
  crashed,
  outOfFuel,
  explosion,
}

class GameStateManager extends ChangeNotifier {
  GameState _state = GameState.menu;
  int _money = 0;
  int _totalDistance = 0;
  int _currentDistance = 0;
  PlaneStats _selectedPlane = PlaneStats.all[0];
  CargoClass? _selectedCargo;
  List<PlaneStats> _ownedPlanes = [PlaneStats.all[0]];
  GameOverReason? _gameOverReason;
  bool _cargoJettisoned = false;
  bool _hasUsedContinue = false;

  // Getters
  GameState get state => _state;
  int get money => _money;
  int get totalDistance => _totalDistance;
  int get currentDistance => _currentDistance;
  PlaneStats get selectedPlane => _selectedPlane;
  CargoClass? get selectedCargo => _selectedCargo;
  List<PlaneStats> get ownedPlanes => _ownedPlanes;
  GameOverReason? get gameOverReason => _gameOverReason;
  bool get cargoJettisoned => _cargoJettisoned;
  bool get hasUsedContinue => _hasUsedContinue;

  void setState(GameState newState) {
    _state = newState;
    notifyListeners();
  }

  void selectCargo(CargoClass cargo) {
    _selectedCargo = cargo;
    notifyListeners();
  }

  void selectPlane(PlaneStats plane) {
    _selectedPlane = plane;
    notifyListeners();
  }

  void startGame() {
    _state = GameState.playing;
    _currentDistance = 0;
    _cargoJettisoned = false;
    _gameOverReason = null;
    _hasUsedContinue = false;
    notifyListeners();
  }

  void pauseGame() {
    if (_state == GameState.playing) {
      _state = GameState.paused;
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_state == GameState.paused) {
      _state = GameState.playing;
      notifyListeners();
    }
  }

  void updateDistance(int distance) {
    _currentDistance = distance;
    notifyListeners();
  }

  void jettisonCargo() {
    _cargoJettisoned = true;
    _selectedCargo = null;
    notifyListeners();
  }

  void endGame(GameOverReason reason, int distance) {
    _state = GameState.gameOver;
    _gameOverReason = reason;
    _currentDistance = distance;
    _totalDistance += distance;

    // Calculate rewards
    int distanceReward = (distance / 10).floor();

    if (!_cargoJettisoned &&
        _selectedCargo != null &&
        reason != GameOverReason.explosion) {
      // Successful delivery
      int cargoReward =
          (_selectedCargo!.reward * GameConfig.bonusGoldMultiplier).floor();
      _money += cargoReward + distanceReward;
    } else {
      // Only distance reward
      _money += distanceReward;
    }

    notifyListeners();
  }

  bool canBuyPlane(PlaneStats plane) {
    return _money >= plane.price && !_ownedPlanes.contains(plane);
  }

  bool buyPlane(PlaneStats plane) {
    if (canBuyPlane(plane)) {
      _money -= plane.price;
      _ownedPlanes.add(plane);
      notifyListeners();
      return true;
    }
    return false;
  }

  void returnToMenu() {
    _state = GameState.menu;
    _selectedCargo = null;
    notifyListeners();
  }

  void continueGame() {
    if (!_hasUsedContinue && _gameOverReason == GameOverReason.crashed) {
      _hasUsedContinue = true;
      _state = GameState.playing;
      _gameOverReason = null;
      notifyListeners();
    }
  }

  void reset() {
    _money = 0;
    _totalDistance = 0;
    _currentDistance = 0;
    _selectedPlane = PlaneStats.all[0];
    _selectedCargo = null;
    _ownedPlanes = [PlaneStats.all[0]];
    _state = GameState.menu;
    notifyListeners();
  }
}
