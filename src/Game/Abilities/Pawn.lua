-- src/Game/Abilities/Pawn.lua
local Pawn = {}
Pawn.__index = Pawn

function Pawn.new()
    local self = setmetatable({}, Pawn)
    self.Name = "Pawn"
    self.Description = "Rookie soldier that grows stronger with battle."
    self.Health = 50
    self.MaxHealth = 50
    self.Attack = 10
    self.Level = 1
    self.Cooldown = 5
    self.LastAbilityUse = 0
    return self
end

-- Passive: Rookie's Will (gets stronger per kill)
function Pawn:OnKill()
    self.Attack = self.Attack + 5
    self.Level = self.Level + 1
    print(self.Name .. " leveled up! Attack: " .. self.Attack)
end

-- Active: Charge - Move 2 tiles forward, deal bonus damage
function Pawn:UseAbility(board, targetTile)
    local currentTime = tick()
    
    -- Check cooldown
    if currentTime - self.LastAbilityUse < self.Cooldown then
        return false, "Ability on cooldown"
    end
    
    -- Attempt to move up to 2 tiles
    local success = board:MovePiece(self, targetTile, 2)
    
    if success then
        self.LastAbilityUse = currentTime
        
        -- If there was an enemy on the target tile, deal bonus damage
        if targetTile.occupied and targetTile.occupied ~= self then
            targetTile.occupied:TakeDamage(self.Attack * 2)
            return true, "Charge attack successful!"
        else
            return true, "Charged forward!"
        end
    end
    
    return false, "Cannot charge to that position"
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