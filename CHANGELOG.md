# Changelog

## [Phase 2 - Step 1 Complete] - 2025-07-22

### Added
- **Weapon System Foundation**: Complete weapon and projectile system
  - Base Weapon class with 5 weapon types (Missile, Laser, Explosive, Defensive, Special)
  - Configurable weapon properties: damage, cost, fire rate, speed, range, ammo
  - Fire rate limiting and ammunition management
  - Weapon firing mechanics with direction and positioning
- **Projectile System**: Physics-based projectile implementation
  - RigidBody2D projectiles with collision detection
  - Damage application on impact with tanks
  - Range limiting and auto-expiration system
  - Visual representation with colored sprites
- **WeaponManager**: Weapon equipment and management system
  - Support for up to 7 weapons per tank
  - Basic weapon creation and primary weapon firing
  - Weapon addition/removal with signal notifications
- **Tank Combat Integration**: Tank weapon system integration
  - Weapon system setup in Tank initialization
  - Fire input handling (spacebar for Player 1)
  - Weapon firing from tank position with proper rotation
  - Self-damage prevention in collision detection

### Technical Details
- Basic weapon: 15 damage, 2.0 fire rate, 400 speed, 600 range, unlimited ammo
- Projectile collision: 3-pixel radius CircleShape2D
- Fire input: InputManager.get_fire_input() using is_action_just_pressed
- Weapon positioning: 20 pixels forward from tank center

### Files Modified
- `scripts/weapons/Weapon.gd` - Complete weapon class implementation
- `scripts/weapons/WeaponManager.gd` - Weapon management system
- `scripts/tanks/Tank.gd` - Weapon system integration and firing controls
- `scripts/core/InputManager.gd` - Added get_fire_input() method

### Files Added
- `scripts/weapons/Projectile.gd` - Physics-based projectile system

## [Bug Fix] - 2025-07-22

### Fixed
- **EconomyManager Signal Error**: Fixed missing money_changed signal
  - Added money_changed signal definition to EconomyManager
  - Implemented basic money management functions (add_money, spend_money, get_money, set_money)
  - Resolved "Invalid access to property or key 'money_changed'" error

### Files Modified
- `scripts/managers/EconomyManager.gd` - Added signal and money management functions

## [Phase 1 Complete] - 2025-07-22

### Added
- **Tank System**: Complete tank implementation with CharacterBody2D
  - Basic movement using WASD/Arrow keys via InputManager
  - Physics-based movement with acceleration and friction
  - Tank rotation with QE keys
  - Arena boundary detection and collision prevention
  - Health system and tank destruction mechanics
- **Arena Scene**: Test arena with tank instance for gameplay testing
- **Tank Scene**: Proper scene structure with collision shape and sprite placeholder

### Technical Details
- Tank movement speed: 200 units/sec with 500 acceleration and 300 friction
- Rotation speed: 3 radians/sec
- Boundary margin: 16 pixels from screen edges
- Health system: 100 HP with damage and destruction handling

### Files Modified
- `scripts/tanks/Tank.gd` - Complete tank functionality implementation
- `scenes/tanks/Tank.tscn` - Tank scene structure with CharacterBody2D
- `scenes/arena/Arena.tscn` - Test arena with tank instance

## [Initial Setup] - 2025-07-22

### Added
- Project structure and core systems architecture
- Input management system for multi-player support
- Game manager, scene manager, and event bus singletons
- Asset directories and development tooling

Created: Tue Jul 22 06:41:51 PM EDT 2025
