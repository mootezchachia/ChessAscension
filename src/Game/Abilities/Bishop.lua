-- src/Game/Abilities/Bishop.lua
local Bishop = {}
Bishop.__index = Bishop

function Bishop.new()
    local self = setmetatable({}, Bishop)
    self.Name = "Bishop"
    self.Description = "Holy healer that purifies the battlefield."
    self.Health = 80
    self.MaxHealth = 80
    self.Attack = 15
    self.Level = 1
    self.Cooldown = 10
    self.LastAbilityUse = 0
    return self
end

-- Passive: Divine Aura (heals nearby allies slowly over time)
function Bishop:OnTurnStart()
    -- Heal allies within 2 tiles
    if self.Board then
        local allies = self.Board:GetAlliesInRadius(self.position, 2)
        for _, ally in ipairs(allies) do
            if ally ~= self and ally.Health < ally.MaxHealth then
                ally:Heal(5)
            end
        end
    end
end

-- Active: Sacred Light - Powerful healing beam or damage to undead
function Bishop:UseAbility(board, targetTile)
    local currentTime = tick()
    
    -- Check cooldown
    if currentTime - self.LastAbilityUse < self.Cooldown then
        return false, "Ability on cooldown"
    end
    
    if not targetTile then
        return false, "Invalid target"
    end
    
    self.LastAbilityUse = currentTime
    
    if targetTile.occupied then
        local target = targetTile.occupied
        
        -- Check if target is ally or enemy
        if self:IsAlly(target) then
            -- Heal ally
            local healAmount = self.Attack * 3
            target:Heal(healAmount)
            return true, "Healed " .. target.Name .. " for " .. healAmount .. " HP!"
        else
            -- Damage enemy (extra damage to dark/undead types)
            local damage = self.Attack * 2
            if target.Type == "Undead" or target.Type == "Dark" then
                damage = damage * 1.5
            end
            target:TakeDamage(damage)
            return true, "Sacred Light dealt " .. damage .. " damage!"
        end
    else
        -- Create healing zone on empty tile
        self:CreateHealingZone(board, targetTile)
        return true, "Created healing sanctuary!"
    end
end

function Bishop:CreateHealingZone(board, tile)
    -- Mark tile as healing zone for 3 turns
    tile.healingZone = {
        duration = 3,
        healPerTurn = 10,
        creator = self
    }
    
    -- TODO: Add visual effect for healing zone
    print("✨ Healing zone created at (" .. tile.row .. ", " .. tile.col .. ")")
end

function Bishop:Heal(amount)
    local oldHealth = self.Health
    self.Health = math.min(self.Health + amount, self.MaxHealth)
    local actualHeal = self.Health - oldHealth
    print(self.Name .. " healed for " .. actualHeal .. " HP. Health: " .. self.Health)
end

function Bishop:TakeDamage(damage)
    self.Health = self.Health - damage
    print(self.Name .. " took " .. damage .. " damage. Health: " .. self.Health)
    
    if self.Health <= 0 then
        print(self.Name .. " has been defeated!")
    end
end

function Bishop:IsAlly(target)
    -- Simple team check - same team if same piece type or friendly AI
    return target.Team == self.Team
end

function Bishop:GetCooldownRemaining()
    local currentTime = tick()
    local remaining = self.Cooldown - (currentTime - self.LastAbilityUse)
    return math.max(0, remaining)
end

-- Placeholder for future FX
function Bishop:PlayHealingEffect()
    -- TODO: Add particle effects, sound, and animations
    print("✨ Bishop healing effect!")
end

return Bishop