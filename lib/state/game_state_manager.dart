import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
  List<GameRecord> _leaderboard = [];
  bool _isNewRecord = false;

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
  List<GameRecord> get leaderboard => _leaderboard;
  bool get isNewRecord => _isNewRecord;

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

    // Check if this is a new record
    _isNewRecord = _checkAndSaveRecord(distance);

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

  Future<void> loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final String? leaderboardJson = prefs.getString('leaderboard');
    if (leaderboardJson != null) {
      final List<dynamic> decoded = jsonDecode(leaderboardJson);
      _leaderboard = decoded.map((e) => GameRecord.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded =
        jsonEncode(_leaderboard.map((e) => e.toJson()).toList());
    await prefs.setString('leaderboard', encoded);
  }

  bool _checkAndSaveRecord(int distance) {
    // Create new record
    final newRecord = GameRecord(
      distance: distance,
      cargo: _selectedCargo?.name ?? 'None',
      plane: _selectedPlane.name,
      date: DateTime.now(),
    );

    // Add to leaderboard
    _leaderboard.add(newRecord);

    // Sort by distance (highest first)
    _leaderboard.sort((a, b) => b.distance.compareTo(a.distance));

    // Keep only top 5
    if (_leaderboard.length > 5) {
      _leaderboard = _leaderboard.sublist(0, 5);
    }

    // Save to SharedPreferences
    _saveLeaderboard();

    // Check if this is the new best record
    return _leaderboard.isNotEmpty && _leaderboard[0] == newRecord;
  }

  void clearNewRecordFlag() {
    _isNewRecord = false;
    notifyListeners();
  }
}

class GameRecord {
  final int distance;
  final String cargo;
  final String plane;
  final DateTime date;

  GameRecord({
    required this.distance,
    required this.cargo,
    required this.plane,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'distance': distance,
        'cargo': cargo,
        'plane': plane,
        'date': date.toIso8601String(),
      };

  factory GameRecord.fromJson(Map<String, dynamic> json) => GameRecord(
        distance: json['distance'] as int,
        cargo: json['cargo'] as String,
        plane: json['plane'] as String,
        date: DateTime.parse(json['date'] as String),
      );
}
