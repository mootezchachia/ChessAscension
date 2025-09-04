-- src/Game/Abilities/Pawn.lua
local Pawn = {}
Pawn.__index = Pawn

function Pawn.new()
    local self = setmetatable({}, Pawn)
    self.Name = "Pawn"
    self.Type = "Pawn"
    self.Description = "Rookie soldier that grows stronger with battle."
    self.Health = 50
    self.MaxHealth = 50
    self.Attack = 10
    self.Level = 1
    self.XP = 0
    self.EvolutionStage = "Shadow Pawn"
    self.Cooldown = 5
    self.LastAbilityUse = 0
    self.unlockedAbilities = {}
    return self
end

-- Passive: Rookie's Will (gets stronger per kill)
function Pawn:OnKill()
    self.Attack = self.Attack + 5
    
    -- Gain XP for evolution system
    local ShadowSystem = require(script.Parent.Parent.ShadowSystem)
    local leveledUp = ShadowSystem:GainXP(self, 100)
    
    if leveledUp then
        print(self.EvolutionStage .. " leveled up! Attack: " .. self.Attack)
    end
end

-- Active: Charge - Move 2 tiles forward, deal bonus damage
function Pawn:UseAbility(board, targetTile)
    local currentTime = tick()
    
    -- Check cooldown
    if currentTime - self.LastAbilityUse < self.Cooldown then
        return false, "Ability on cooldown"
    end
    
    -- Evolution-enhanced abilities
    local moveDistance = 2
    local damageMultiplier = 2
    
    if self.EvolutionStage == "Shadow Soldier" then
        moveDistance = 3
        damageMultiplier = 2.5
    elseif self.EvolutionStage == "Shadow Warrior" then
        moveDistance = 4
        damageMultiplier = 3
    end
    
    -- Attempt to move
    local success = board:MovePiece(self, targetTile, moveDistance)
    
    if success then
        self.LastAbilityUse = currentTime
        
        -- Enhanced charge attack based on evolution
        if targetTile.occupied and targetTile.occupied ~= self then
            local damage = self.Attack * damageMultiplier
            targetTile.occupied:TakeDamage(damage)
            
            -- Special evolution abilities
            if self.EvolutionStage == "Shadow Soldier" and self:HasAbility("Shield Bash") then
                targetTile.occupied.stunned = true
                return true, "Shield Bash! Enemy stunned!"
            elseif self.EvolutionStage == "Shadow Warrior" and self:HasAbility("Battle Fury") then
                self.battleFury = 3 -- Extra turns
                return true, "Battle Fury activated!"
            end
            
            return true, self.EvolutionStage .. " charge attack!"
        else
            return true, "Shadow charged forward!"
        end
    end
    
    return false, "Cannot charge to that position"
end

function Pawn:HasAbility(abilityName)
    if not self.unlockedAbilities then return false end
    for _, ability in ipairs(self.unlockedAbilities) do
        if ability == abilityName then return true end
    end
    return false
end

function Pawn:TakeDamage(damage)
    self.Health = self.Health - damage
    print(self.Name .. " took " .. damage .. " damage. Health: " .. self.Health)
    
    if self.Health <= 0 then
        print(self.Name .. " has been defeated!")
    end
end

function Pawn:GetCooldownRemaining()
    local currentTime = tick()
    local remaining = self.Cooldown - (currentTime - self.LastAbilityUse)
    return math.max(0, remaining)
end

return Pawn