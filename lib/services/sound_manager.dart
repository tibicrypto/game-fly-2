import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sound Manager to handle all game audio
class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  // Audio players
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  
  // Volume settings
  double _musicVolume = 0.5;
  double _sfxVolume = 0.7;
  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;

  // Getters
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;

  /// Initialize sound manager and load settings
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _musicVolume = prefs.getDouble('music_volume') ?? 0.5;
      _sfxVolume = prefs.getDouble('sfx_volume') ?? 0.7;
      _isMusicEnabled = prefs.getBool('music_enabled') ?? true;
      _isSfxEnabled = prefs.getBool('sfx_enabled') ?? true;

      // Set initial volumes
      await _musicPlayer.setVolume(_isMusicEnabled ? _musicVolume : 0);
      await _sfxPlayer.setVolume(_isSfxEnabled ? _sfxVolume : 0);
    } catch (e) {
      // Silently fail and use defaults
    }
  }

  /// Play sound effect
  Future<void> playSfx(String soundName) async {
    if (!_isSfxEnabled) return;
    
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('sounds/$soundName.mp3'));
    } catch (e) {
      // Silently fail if sound file doesn't exist
    }
  }

  /// Play background music in loop
  Future<void> playMusic(String musicName) async {
    if (!_isMusicEnabled) return;
    
    try {
      await _musicPlayer.stop();
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('sounds/$musicName.mp3'));
    } catch (e) {
      // Silently fail if music file doesn't exist
    }
  }

  /// Stop background music
  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      // Silently fail
    }
  }

  /// Pause background music
  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (e) {
      // Silently fail
    }
  }

  /// Resume background music
  Future<void> resumeMusic() async {
    try {
      await _musicPlayer.resume();
    } catch (e) {
      // Silently fail
    }
  }

  /// Set music volume (0.0 to 1.0)
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _musicPlayer.setVolume(_isMusicEnabled ? _musicVolume : 0);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('music_volume', _musicVolume);
  }

  /// Set sound effects volume (0.0 to 1.0)
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _sfxPlayer.setVolume(_isSfxEnabled ? _sfxVolume : 0);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sfx_volume', _sfxVolume);
  }

  /// Toggle music on/off
  Future<void> toggleMusic() async {
    _isMusicEnabled = !_isMusicEnabled;
    await _musicPlayer.setVolume(_isMusicEnabled ? _musicVolume : 0);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('music_enabled', _isMusicEnabled);

    if (!_isMusicEnabled) {
      await stopMusic();
    }
  }

  /// Toggle sound effects on/off
  Future<void> toggleSfx() async {
    _isSfxEnabled = !_isSfxEnabled;
    await _sfxPlayer.setVolume(_isSfxEnabled ? _sfxVolume : 0);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sfx_enabled', _isSfxEnabled);
  }

  /// Dispose audio players
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }

  // Sound effect names constants
  static const String buttonClick = 'button_click';
  static const String planeEngine = 'plane_engine';
  static const String cargoPickup = 'cargo_pickup';
  static const String cargoDelivery = 'cargo_delivery';
  static const String crash = 'crash';
  static const String achievement = 'achievement';
  static const String whoosh = 'whoosh';
  static const String coinCollect = 'coin_collect';
  static const String levelUp = 'level_up';
  static const String warning = 'warning';
  
  // Music names constants
  static const String menuMusic = 'menu_music';
  static const String gameplayMusic = 'gameplay_music';
}
