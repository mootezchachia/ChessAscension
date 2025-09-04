-- src/Game/Abilities/Rook.lua
local Rook = {}
Rook.__index = Rook

function Rook.new()
    local self = setmetatable({}, Rook)
    self.Name = "Rook"
    self.Description = "Fortress guardian with unbreakable defense."
    self.Health = 150
    self.MaxHealth = 150
    self.Attack = 25
    self.Level = 1
    self.Cooldown = 12
    self.LastAbilityUse = 0
    self.isDefending = false
    self.defenseMultiplier = 1
    return self
end

-- Passive: Fortress Stance (reduced damage when not moving)
function Rook:OnTurnEnd()
    if not self.movedThisTurn then
        self.defenseMultiplier = 0.5 -- 50% damage reduction
        self.isDefending = true
    else
        self.defenseMultiplier = 1
        self.isDefending = false
    end
    self.movedThisTurn = false
end

-- Active: Castle Wall - Create protective barriers
function Rook:UseAbility(board, targetTile)
    local currentTime = tick()
    
    -- Check cooldown
    if currentTime - self.LastAbilityUse < self.Cooldown then
        return false, "Ability on cooldown"
    end
    
    if not targetTile then
        return false, "Invalid target"
    end
    
    self.LastAbilityUse = currentTime
    
    -- Create wall of barriers in a line
    local walls = self:CreateWallLine(board, targetTile)
    
    if walls > 0 then
        return true, "Castle Wall created " .. walls .. " barriers!"
    else
        return false, "Cannot create walls there"
    end
end

function Rook:CreateWallLine(board, targetTile)
    local wallsCreated = 0
    local startRow, startCol = self.position.row, self.position.col
    local targetRow, targetCol = targetTile.row, targetTile.col
    
    -- Determine direction (horizontal or vertical)
    local deltaRow = targetRow - startRow
    local deltaCol = targetCol - startCol
    
    local stepRow = deltaRow == 0 and 0 or (deltaRow > 0 and 1 or -1)
    local stepCol = deltaCol == 0 and 0 or (deltaCol > 0 and 1 or -1)
    
    -- Create up to 3 wall tiles in that direction
    local currentRow, currentCol = startRow + stepRow, startCol + stepCol
    
    for i = 1, 3 do
        local tile = board:GetTile(currentRow, currentCol)
        if tile and not tile.occupied then
            tile.wall = {
                health = 50,
                duration = 5, -- 5 turns
                creator = self
            }
            wallsCreated = wallsCreated + 1
            print("🧱 Wall created at (" .. currentRow .. ", " .. currentCol .. ")")
        end
        
        currentRow = currentRow + stepRow
        currentCol = currentCol + stepCol
        
        -- Stop if we go out of bounds
        if currentRow < 1 or currentRow > board.size or currentCol < 1 or currentCol > board.size then
            break
        end
    end
    
    return wallsCreated
end

function Rook:TakeDamage(damage)
    local actualDamage = damage * self.defenseMultiplier
    self.Health = self.Health - actualDamage
    
    local defenseText = self.isDefending and " (DEFENDING)" or ""
    print(self.Name .. " took " .. actualDamage .. " damage" .. defenseText .. ". Health: " .. self.Health)
    
    if self.Health <= 0 then
        print(self.Name .. " fortress has fallen!")
    end
end

function Rook:MoveTo(newPosition)
    self.position = newPosition
    self.movedThisTurn = true
    -- Lose defensive bonus when moving
    self.defenseMultiplier = 1
    self.isDefending = false
end

function Rook:GetCooldownRemaining()
    local currentTime = tick()
    local remaining = self.Cooldown - (currentTime - self.LastAbilityUse)
    return math.max(0, remaining)
end

-- Check if Rook can castle (special chess move)
function Rook:CanCastle(king)
    -- Traditional castling rules
    return not self.hasMoved and not king.hasMoved and not king.isInCheck
end

-- Placeholder for future FX
function Rook:PlayWallEffect()
    -- TODO: Add stone/metal barrier effects
    print("🧱 Rook wall creation effect!")
end

return Rook