-- src/Game/ShadowSystem.lua
local ShadowSystem = {}

-- Shadow evolution data
ShadowSystem.Evolutions = {
    Pawn = {
        {name = "Shadow Pawn", level = 1, maxLevel = 3},
        {name = "Shadow Soldier", level = 4, maxLevel = 7, unlocks = "Shield Bash"},
        {name = "Shadow Warrior", level = 8, maxLevel = 10, unlocks = "Battle Fury"}
    },
    Knight = {
        {name = "Shadow Knight", level = 1, maxLevel = 3},
        {name = "Phantom Cavalry", level = 4, maxLevel = 7, unlocks = "Spectral Charge"},
        {name = "Death Knight", level = 8, maxLevel = 10, unlocks = "Soul Reap"}
    },
    Bishop = {
        {name = "Shadow Bishop", level = 1, maxLevel = 3},
        {name = "Lightborne Cleric", level = 4, maxLevel = 7, unlocks = "Divine Protection"},
        {name = "Shadow Sage", level = 8, maxLevel = 10, unlocks = "Mass Resurrection"}
    },
    Rook = {
        {name = "Shadow Rook", level = 1, maxLevel = 3},
        {name = "Fortress Guardian", level = 4, maxLevel = 7, unlocks = "Immovable Object"},
        {name = "Shadow Citadel", level = 8, maxLevel = 10, unlocks = "Absolute Defense"}
    },
    Queen = {
        {name = "Shadow Queen", level = 1, maxLevel = 3},
        {name = "Elemental Sovereign", level = 4, maxLevel = 7, unlocks = "Elemental Mastery"},
        {name = "Shadow Empress", level = 8, maxLevel = 10, unlocks = "Reality Tear"}
    },
    King = {
        {name = "Shadow King", level = 1, maxLevel = 3},
        {name = "Battle Lord", level = 4, maxLevel = 7, unlocks = "Army Command"},
        {name = "Shadow Emperor", level = 8, maxLevel = 10, unlocks = "Divine Authority"}
    }
}

function ShadowSystem:GetEvolutionStage(pieceType, level)
    local evolutions = self.Evolutions[pieceType]
    if not evolutions then return nil end
    
    for _, evolution in ipairs(evolutions) do
        if level >= evolution.level and level <= evolution.maxLevel then
            return evolution
        end
    end
    
    return evolutions[#evolutions] -- Return highest evolution if over max
end

function ShadowSystem:CanEvolve(piece)
    local currentStage = self:GetEvolutionStage(piece.Type, piece.Level)
    local nextStageIndex = nil
    
    local evolutions = self.Evolutions[piece.Type]
    for i, evolution in ipairs(evolutions) do
        if evolution == currentStage then
            nextStageIndex = i + 1
            break
        end
    end
    
    if nextStageIndex and evolutions[nextStageIndex] then
        return piece.Level >= evolutions[nextStageIndex].level
    end
    
    return false
end

function ShadowSystem:EvolvePiece(piece)
    if not self:CanEvolve(piece) then
        return false, "Cannot evolve yet"
    end
    
    local newStage = self:GetEvolutionStage(piece.Type, piece.Level + 1)
    piece.EvolutionStage = newStage.name
    
    -- Boost stats on evolution
    piece.MaxHealth = piece.MaxHealth + 20
    piece.Health = piece.MaxHealth
    piece.Attack = piece.Attack + 10
    
    -- Unlock new abilities
    if newStage.unlocks then
        piece.unlockedAbilities = piece.unlockedAbilities or {}
        table.insert(piece.unlockedAbilities, newStage.unlocks)
    end
    
    return true, "Evolved to " .. newStage.name .. "!"
end

function ShadowSystem:GainXP(piece, amount)
    piece.XP = (piece.XP or 0) + amount
    local xpNeeded = piece.Level * 100 -- 100 XP per level
    
    local leveledUp = false
    while piece.XP >= xpNeeded do
        piece.XP = piece.XP - xpNeeded
        piece.Level = piece.Level + 1
        leveledUp = true
        
        -- Check for evolution
        if self:CanEvolve(piece) then
            self:EvolvePiece(piece)
        end
        
        xpNeeded = piece.Level * 100
    end
    
    return leveledUp
end

function ShadowSystem:CreateLoadout(player)
    -- Player can select 3-6 shadows for battle
    return {
        shadows = {},
        maxShadows = 6,
        selectedShadows = {}
    }
end

return ShadowSystem