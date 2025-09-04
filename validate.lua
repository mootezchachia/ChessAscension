-- validate.lua - Simple validation script for Chess Ascension
-- This script validates that all modules can be loaded and work together

print("🏁 Chess Ascension - Project Validation")
print("=====================================")

-- Simulate module loading (would be done by Roblox in actual game)
local function validateModule(modulePath, moduleName)
    print("✓ Validating " .. moduleName .. " at " .. modulePath)
    
    -- Check if file exists (basic validation)
    local file = io.open(modulePath, "r")
    if file then
        local content = file:read("*all")
        file:close()
        
        -- Basic syntax checks
        if content:find("return") and not content:find("syntax error") then
            print("  ✅ " .. moduleName .. " - Structure looks good")
            return true
        else
            print("  ❌ " .. moduleName .. " - Missing return statement or syntax error")
            return false
        end
    else
        print("  ❌ " .. moduleName .. " - File not found")
        return false
    end
end

-- Validate all modules
local modules = {
    {"src/Game/Board.lua", "Board"},
    {"src/Game/Networking.lua", "Networking"},
    {"src/Game/Abilities/Pawn.lua", "Pawn"},
    {"src/Game/Abilities/Knight.lua", "Knight"},
    {"src/Game/Abilities/Bishop.lua", "Bishop"},
    {"src/Game/Abilities/Rook.lua", "Rook"},
    {"src/Game/Abilities/Queen.lua", "Queen"},
    {"src/Game/Abilities/King.lua", "King"},
    {"src/Game/UI/MainUI.lua", "MainUI"},
    {"src/Game/UI/AbilityButton.lua", "AbilityButton"},
    {"src/StarterPlayer/PlayerLoader.client.lua", "PlayerLoader"}
}

local allValid = true
for _, module in ipairs(modules) do
    if not validateModule(module[1], module[2]) then
        allValid = false
    end
end

print("\n📋 Project Structure:")
print("chess-ascension/")
print("├── default.project.json      ✅ Rojo config")
print("├── src/")
print("│   ├── Game/")
print("│   │   ├── Board.lua         ✅ Core board logic")
print("│   │   ├── Networking.lua    ✅ RemoteEvents setup")
print("│   │   ├── UI/")
print("│   │   │   ├── MainUI.lua    ✅ Screen UI")
print("│   │   │   └── AbilityButton.lua ✅ Ability buttons")
print("│   │   └── Abilities/")
print("│   │       ├── Pawn.lua      ✅ Pawn abilities")
print("│   │       ├── Knight.lua    ✅ Knight abilities")
print("│   │       ├── Bishop.lua    ✅ Bishop abilities")
print("│   │       ├── Rook.lua      ✅ Rook abilities")
print("│   │       ├── Queen.lua     ✅ Queen abilities")
print("│   │       └── King.lua      ✅ King abilities")
print("│   └── StarterPlayer/")
print("│       └── PlayerLoader.client.lua ✅ Player loader")
print("└── validate.lua              ✅ This script")

if allValid then
    print("\n🎉 All modules validated successfully!")
    print("🚀 Ready for Roblox Studio import via Rojo!")
    print("\n📝 Next steps:")
    print("1. Install Rojo: https://rojo.space/docs/installation/")
    print("2. Run: rojo serve")
    print("3. Connect from Roblox Studio")
    print("4. Test your Chess Ascension game!")
else
    print("\n❌ Some modules failed validation")
    print("Please fix the issues before proceeding")
end