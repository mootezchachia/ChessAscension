-- src/Game/Abilities/Knight.lua
local Knight = {}
Knight.__index = Knight

function Knight.new()
    local self = setmetatable({}, Knight)
    self.Name = "Knight"
    self.Description = "Agile warrior that leaps into battle."
    self.Health = 100
    self.MaxHealth = 100
    self.Attack = 20
    self.Level = 1
    self.Cooldown = 8
    self.LastAbilityUse = 0
    return self
end

-- Active: Leap Strike - Jump to target and deal AoE damage
function Knight:UseAbility(board, targetTile)
    local currentTime = tick()
    
    -- Check cooldown
    if currentTime - self.LastAbilityUse < self.Cooldown then
        return false, "Ability on cooldown"
    end
    
    -- Knights can leap over pieces (ignore distance restrictions)
    if not targetTile then
        return false, "Invalid target"
    end
    
    -- Move to target position
    local oldPosition = self.position
    local success = board:MovePiece(self, targetTile, math.huge) -- Allow any distance
    
    if success then
        self.LastAbilityUse = currentTime
        
        -- Deal AoE damage to all enemies in 1-tile radius
        local enemies = board:GetEnemiesInRadius(targetTile, 1)
        local damageDealt = 0
        
        for _, enemy in ipairs(enemies) do
            if enemy ~= self then -- Don't damage self
                enemy:TakeDamage(self.Attack)
                damageDealt = damageDealt + 1
            end
        end
        
        -- TODO: Add particle FX + sound hooks here
        -- self:PlayLeapEffect()
        
        return true, "Leap Strike hit " .. damageDealt .. " enemies!"
    end
    
    return false, "Cannot leap to that position"
end

function Knight:TakeDamage(damage)
    self.Health = self.Health - damage
    print(self.Name .. " took " .. damage .. " damage. Health: " .. self.Health)
    
    if self.Health <= 0 then
        print(self.Name .. " has been defeated!")
    end
end

function Knight:GetCooldownRemaining()
    local currentTime = tick()
    local remaining = self.Cooldown - (currentTime - self.LastAbilityUse)
    return math.max(0, remaining)
end

-- Placeholder for future FX
function Knight:PlayLeapEffect()
    -- TODO: Add TweenService animation + particle effects
    print("🐎 Knight leap effect!")
end

return Knight