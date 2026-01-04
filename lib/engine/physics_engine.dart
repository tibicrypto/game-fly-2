import 'dart:math';
import '../config/game_config.dart';

class PhysicsEngine {
  double planeX = 0.0;
  double planeY = 400.0;
  double velocityX = 0.0;
  double velocityY = 0.0;
  double fuel = 0.0;
  
  final PlaneStats planeStats;
  final CargoClass? cargo;
  
  bool isRefueling = false;
  bool hasLightningDamage = false;
  double lightningDamageTimer = 0.0;
  
  PhysicsEngine({
    required this.planeStats,
    this.cargo,
    double initialFuel = 20.0,
  }) {
    fuel = initialFuel;
  }
  
  double getTotalWeight() {
    double cargoWeight = cargo?.weight ?? 0.0;
    double fuelWeight = fuel * GameConfig.fuelWeightRatio;
    return planeStats.baseWeight + cargoWeight + fuelWeight;
  }
  
  double getThrust() {
    if (hasLightningDamage) {
      return GameConfig.idleThrust * 0.3;
    }
    
    if (isRefueling) {
      return planeStats.liftPower * GameConfig.maxThrust;
    }
    return GameConfig.idleThrust;
  }
  
  void update(double deltaTime) {
    // Update lightning damage
    if (hasLightningDamage) {
      lightningDamageTimer -= deltaTime;
      if (lightningDamageTimer <= 0) {
        hasLightningDamage = false;
      }
    }
    
    // Refuel logic
    if (isRefueling && fuel < planeStats.maxFuelCapacity) {
      fuel += GameConfig.refuelSpeed * deltaTime;
      fuel = min(fuel, planeStats.maxFuelCapacity);
    }
    
    // Fuel consumption
    if (!isRefueling) {
      double consumption = planeStats.fuelEfficiency * GameConfig.fuelBurnRate * deltaTime;
      fuel -= consumption;
      fuel = max(fuel, 0.0);
    }
    
    // Physics calculation
    double totalWeight = getTotalWeight();
    double thrust = getThrust();
    
    // Vertical force: Thrust - Weight*Gravity
    double verticalForce = thrust - (totalWeight * GameConfig.gravity * 0.1);
    
    // Apply wind force
    velocityX += GameConfig.windForce * deltaTime;
    
    // Update velocity
    velocityY += verticalForce * deltaTime;
    
    // Apply air resistance
    velocityY *= 0.99;
    
    // Horizontal movement (constant forward)
    velocityX = GameConfig.horizontalSpeed;
    
    // Update position
    planeX += velocityX * deltaTime;
    planeY += velocityY * deltaTime;
    
    // Cloud ceiling check
    if (planeY > GameConfig.cloudCeilingHeight) {
      hitLightning();
      planeY = GameConfig.cloudCeilingHeight;
      velocityY = -velocityY.abs() * 0.5; // Bounce down
    }
    
    // Prevent going below ground (temporary check)
    if (planeY < 50) {
      planeY = 50;
      velocityY = 0;
    }
  }
  
  void startRefueling() {
    isRefueling = true;
  }
  
  void stopRefueling() {
    isRefueling = false;
  }
  
  void hitLightning() {
    if (!hasLightningDamage) {
      hasLightningDamage = true;
      lightningDamageTimer = GameConfig.lightningDamage;
    }
  }
  
  bool isCrashed(double groundHeight) {
    return planeY <= groundHeight + 20;
  }
  
  bool isOutOfFuel() {
    return fuel <= 0 && velocityY < -50;
  }
}
