# Chess Ascension - Roblox Game Project

## Overview
Chess Ascension is a Roblox game that combines classic chess with Solo Leveling-style abilities and progression. Built using Rojo for development workflow.

## Project Architecture
- **Platform**: Roblox
- **Development**: Replit + Rojo sync
- **Structure**: Modular Lua modules with Rojo project mapping

## Core Features
- 4x4 chess board (MVP)
- Piece abilities (Pawn: Charge, Knight: Leap Strike)
- Modern anime-inspired UI with cooldowns
- Multiplayer support via RemoteEvents
- Health system and combat mechanics

## File Structure
```
chess-ascension/
├── default.project.json      # Rojo configuration
├── src/Game/                 # Core game logic
│   ├── Board.lua            # Chess board management
│   ├── Networking.lua       # RemoteEvents for multiplayer
│   ├── UI/                  # User interface modules
│   └── Abilities/           # Piece ability definitions
└── src/StarterPlayer/       # Client-side initialization
```

## Development Status
- ✅ Core project structure created
- ✅ Board logic implemented
- ✅ Ability system (Pawn, Knight)
- ✅ UI framework with animations
- ✅ Networking setup for multiplayer
- ✅ Client loader with welcome screen

## Technical Details
- Uses proper Roblox services (Players, ReplicatedStorage, TweenService)
- Modular architecture for easy expansion
- Security through server-side validation
- Responsive UI with hover effects and cooldowns

## Next Steps for Production
1. Install Rojo locally
2. Run `rojo serve` to start development server
3. Connect from Roblox Studio
4. Test gameplay mechanics
5. Add more pieces and abilities
6. Implement XP/leveling system
7. Add particle effects and sounds

## User Preferences
- Focus on clean, modular code structure
- Prioritize Roblox compatibility and best practices
- Maintain anime/Solo Leveling aesthetic
- Ensure smooth multiplayer functionality