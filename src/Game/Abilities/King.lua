-- src/Game/Abilities/King.lua
local King = {}
King.__index = King

function King.new()
    local self = setmetatable({}, King)
    self.Name = "King"
    self.Description = "Supreme commander with tactical mastery."
    self.Health = 200
    self.MaxHealth = 200
    self.Attack = 30
    self.Level = 1
    self.Cooldown = 20
    self.LastAbilityUse = 0
    self.isInCheck = false
    self.commandPoints = 3 -- Resource for abilities
    return self
end

-- Passive: Royal Authority (all allies get stat bonuses)
function King:GetLeadershipBonus()
    return {
        attack = math.floor(self.Level * 3),
        health = math.floor(self.Level * 10),
        moveSpeed = 1
    }
end

-- Active: Tactical Strike - Coordinate multiple pieces for massive attack
function King:UseAbility(board, targetTile)
    local currentTime = tick()
    
    -- Check cooldown
    if currentTime - self.LastAbilityUse < self.Cooldown then
        return false, "Ability on cooldown"
    end
    
    if self.commandPoints < 2 then
        return false, "Not enough command points"
    end
    
    if not targetTile then
        return false, "Invalid target"
    end
    
    self.LastAbilityUse = currentTime
    self.commandPoints = self.commandPoints - 2
    
    -- Execute tactical strike
    local result = self:ExecuteTacticalStrike(board, targetTile)
    
    return true, "Tactical Strike: " .. result
end

function King:ExecuteTacticalStrike(board, targetTile)
    local allies = board:GetAlliesInRadius(self.position, 4)
    local participatingAllies = 0
    
    -- Each ally in range contributes to the attack
    for _, ally in ipairs(allies) do
        if ally ~= self and ally.Health > 0 then
            participatingAllies = participatingAllies + 1
        end
    end
    
    if targetTile.occupied then
        local target = targetTile.occupied
        local totalDamage = self.Attack + (participatingAllies * 15)
        
        target:TakeDamage(totalDamage)
        print("👑 Tactical Strike with " .. participatingAllies .. " allies dealt " .. totalDamage .. " damage!")
        return participatingAllies .. " allies coordinated for " .. totalDamage .. " damage"
    else
        -- Area denial - create command zone
        self:CreateCommandZone(board, targetTile)
        return "Command zone established"
    end
end

function King:CreateCommandZone(board, tile)
    -- Create tactical advantage zone
    tile.commandZone = {
        duration = 4,
        bonusAttack = 20,
        bonusDefense = 15,
        creator = self
    }
    
    print("⚔️ Command zone created - allies gain tactical bonuses!")
end

-- Secondary Ability: Royal Guard (defensive ability)
function King:RoyalGuard(board)
    if self.commandPoints < 1 then
        return false, "Not enough command points"
    end
    
    self.commandPoints = self.commandPoints - 1
    
    -- All adjacent allies become immune to damage for 1 turn
    local allies = board:GetAlliesInRadius(self.position, 1)
    for _, ally in ipairs(allies) do
        if ally ~= self then
            ally.immuneToNextAttack = true
            print("🛡️ " .. ally.Name .. " protected by Royal Guard!")
        end
    end
    
    return true
end

function King:TakeDamage(damage)
    -- King has damage reduction based on nearby allies
    local allies = self.Board and self.Board:GetAlliesInRadius(self.position, 2) or {}
    local allyCount = #allies - 1 -- Don't count self
    
    local damageReduction = math.min(0.5, allyCount * 0.1) -- Max 50% reduction
    local actualDamage = damage * (1 - damageReduction)
    
    self.Health = self.Health - actualDamage
    
    local reductionText = damageReduction > 0 and " (reduced by " .. math.floor(damageReduction * 100) .. "%)" or ""
    print(self.Name .. " took " .. actualDamage .. " damage" .. reductionText .. ". Health: " .. self.Health)
    
    -- Check if this puts king in danger
    if self.Health <= 50 then
        self.isInCheck = true
        print("⚠️ THE KING IS IN DANGER!")
    end
    
    if self.Health <= 0 then
        print("💀 THE KING HAS FALLEN! GAME OVER!")
        self:OnDeath()
    end
end

function King:OnDeath()
    -- Game over condition
    print("👑 CHECKMATE! The kingdom falls...")
    -- TODO: Trigger game end sequence
end

function King:RestoreCommandPoints()
    self.commandPoints = math.min(3, self.commandPoints + 1)
end

function King:GetCooldownRemaining()
    local currentTime = tick()
    local remaining = self.Cooldown - (currentTime - self.LastAbilityUse)
    return math.max(0, remaining)
end

-- Special: Castle (traditional chess move)
function King:Castle(rook, board)
    if self.hasMoved or rook.hasMoved or self.isInCheck then
        return false, "Cannot castle"
    end
    
    -- Execute castling move
    print("🏰 CASTLING! King and Rook swap positions")
    return true
end

-- Ultimate: Divine Right (game-changing ability)
function King:DivineRight(board)
    if self.Level >= 10 then
        print("👑 DIVINE RIGHT ACTIVATED!")
        -- Resurrect fallen allies, full heal all pieces
        return true
    end
    return false
end

-- Placeholder for future FX
function King:PlayCommandEffect()
    -- TODO: Add royal command effects, golden aura
    print("👑 King command effect!")
end

return King