import 'dart:math';
import 'package:fast_noise/fast_noise.dart';

class TerrainGenerator {
  final perlin = PerlinNoise(seed: Random().nextInt(10000));
  final double frequency;
  final double amplitude;
  final double baseHeight;
  
  // Cache for performance
  final Map<int, double> _heightCache = {};
  
  TerrainGenerator({
    required this.frequency,
    required this.amplitude,
    required this.baseHeight,
  });
  
  double getHeight(double x) {
    int cacheKey = (x ~/ 10) * 10;
    
    if (_heightCache.containsKey(cacheKey)) {
      return _heightCache[cacheKey]!;
    }
    
    // Generate height using Perlin noise
    double noiseValue = perlin.getPerlin2(x * frequency, 0);
    double height = baseHeight + (noiseValue * amplitude);
    
    // Ensure non-negative height
    height = max(height, 20);
    
    _heightCache[cacheKey] = height;
    
    // Limit cache size
    if (_heightCache.length > 1000) {
      var keys = _heightCache.keys.toList()..sort();
      _heightCache.remove(keys.first);
    }
    
    return height;
  }
  
  List<double> getHeightRange(double startX, double endX, {int samples = 50}) {
    List<double> heights = [];
    double step = (endX - startX) / samples;
    
    for (int i = 0; i <= samples; i++) {
      heights.add(getHeight(startX + (i * step)));
    }
    
    return heights;
  }
  
  void clearCache() {
    _heightCache.clear();
  }
}
