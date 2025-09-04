-- src/Game/Abilities/Queen.lua
local Queen = {}
Queen.__index = Queen

function Queen.new()
    local self = setmetatable({}, Queen)
    self.Name = "Queen"
    self.Description = "Sovereign ruler with devastating elemental powers."
    self.Health = 120
    self.MaxHealth = 120
    self.Attack = 35
    self.Level = 1
    self.Cooldown = 15
    self.LastAbilityUse = 0
    self.elementalType = "Lightning" -- Changes each use
    return self
end

-- Passive: Royal Presence (nearby allies get attack bonus)
function Queen:GetRoyalBonus()
    return math.floor(self.Level * 5) -- +5 attack per level to nearby allies
end

-- Active: Elemental Sovereign - Massive AoE elemental attack
function Queen:UseAbility(board, targetTile)
    local currentTime = tick()
    
    -- Check cooldown
    if currentTime - self.LastAbilityUse < self.Cooldown then
        return false, "Ability on cooldown"
    end
    
    if not targetTile then
        return false, "Invalid target"
    end
    
    self.LastAbilityUse = currentTime
    
    -- Cycle through elemental types
    local elements = {"Lightning", "Fire", "Ice", "Shadow"}
    local currentIndex = 1
    for i, element in ipairs(elements) do
        if element == self.elementalType then
            currentIndex = i
            break
        end
    end
    
    local nextIndex = (currentIndex % #elements) + 1
    self.elementalType = elements[nextIndex]
    
    -- Execute elemental attack
    local targetsHit = self:ExecuteElementalAttack(board, targetTile)
    
    return true, self.elementalType .. " Sovereign hit " .. targetsHit .. " targets!"
end

function Queen:ExecuteElementalAttack(board, targetTile)
    local targetsHit = 0
    local baseDamage = self.Attack * 2
    
    -- Get all enemies in 2-tile radius
    local enemies = board:GetEnemiesInRadius(targetTile, 2)
    
    for _, enemy in ipairs(enemies) do
        local damage = baseDamage
        local effect = ""
        
        -- Apply elemental effects
        if self.elementalType == "Lightning" then
            damage = damage * 1.2
            effect = "⚡ STUNNED"
            enemy.stunned = true
        elseif self.elementalType == "Fire" then
            damage = damage * 1.1
            effect = "🔥 BURNING"
            enemy.burning = {damage = 10, duration = 3}
        elseif self.elementalType == "Ice" then
            damage = damage * 0.9
            effect = "🧊 FROZEN"
            enemy.frozen = true
            enemy.Health = enemy.Health - damage
        elseif self.elementalType == "Shadow" then
            damage = damage * 1.3
            effect = "👻 CURSED"
            enemy.cursed = {damageMultiplier = 1.5, duration = 2}
        end
        
        enemy:TakeDamage(damage)
        print(enemy.Name .. " hit by " .. self.elementalType .. " for " .. damage .. " damage! " .. effect)
        targetsHit = targetsHit + 1
    end
    
    -- Create elemental zone effect
    self:CreateElementalZone(board, targetTile)
    
    return targetsHit
end

function Queen:CreateElementalZone(board, tile)
    -- Create persistent elemental effect on tile
    tile.elementalZone = {
        type = self.elementalType,
        duration = 3,
        damage = 15,
        creator = self
    }
    
    print("✨ " .. self.elementalType .. " zone created!")
end

function Queen:TakeDamage(damage)
    -- Queen has natural magic resistance
    local actualDamage = damage * 0.85 -- 15% magic resistance
    self.Health = self.Health - actualDamage
    
    print(self.Name .. " took " .. actualDamage .. " damage (magic resist). Health: " .. self.Health)
    
    if self.Health <= 0 then
        print("The Queen has fallen! 👑")
        self:OnDeath()
    end
end

function Queen:OnDeath()
    -- Queen's death creates massive explosion
    if self.Board then
        print("💥 ROYAL EXPLOSION!")
        local enemies = self.Board:GetEnemiesInRadius(self.position, 3)
        for _, enemy in ipairs(enemies) do
            enemy:TakeDamage(50) -- Death explosion damage
        end
    end
end

function Queen:GetCooldownRemaining()
    local currentTime = tick()
    local remaining = self.Cooldown - (currentTime - self.LastAbilityUse)
    return math.max(0, remaining)
end

-- Special: Royal Command (ultimate ability at high level)
function Queen:RoyalCommand(board)
    if self.Level >= 5 then
        -- All allied pieces gain bonus turn
        print("👑 ROYAL COMMAND! All allies gain power!")
        return true
    end
    return false
end

-- Placeholder for future FX
function Queen:PlayElementalEffect()
    -- TODO: Add elemental particle effects based on current type
    print("✨ Queen " .. self.elementalType .. " effect!")
end

return Queen