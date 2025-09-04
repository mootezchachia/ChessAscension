-- src/Game/Board.lua
local Board = {}
Board.__index = Board

function Board.new(size)
    local self = setmetatable({}, Board)
    self.size = size or 4 -- 4x4 for MVP
    self.tiles = {}
    self.pieces = {}
    self:InitializeBoard()
    return self
end

function Board:InitializeBoard()
    -- Create empty board tiles
    for row = 1, self.size do
        self.tiles[row] = {}
        for col = 1, self.size do
            self.tiles[row][col] = {
                row = row,
                col = col,
                occupied = nil,
                piece = nil
            }
        end
    end
end

function Board:GetTile(row, col)
    if row >= 1 and row <= self.size and col >= 1 and col <= self.size then
        return self.tiles[row][col]
    end
    return nil
end

function Board:PlacePiece(piece, row, col)
    local tile = self:GetTile(row, col)
    if tile and not tile.occupied then
        tile.occupied = piece
        tile.piece = piece
        piece.position = {row = row, col = col}
        table.insert(self.pieces, piece)
        return true
    end
    return false
end

function Board:MovePiece(piece, targetTile, maxDistance)
    maxDistance = maxDistance or 1
    
    if not targetTile or not piece.position then
        return false
    end
    
    local currentRow, currentCol = piece.position.row, piece.position.col
    local targetRow, targetCol = targetTile.row, targetTile.col
    
    -- Calculate distance
    local distance = math.abs(targetRow - currentRow) + math.abs(targetCol - currentCol)
    
    if distance > maxDistance then
        return false
    end
    
    -- Clear old position
    local oldTile = self:GetTile(currentRow, currentCol)
    if oldTile then
        oldTile.occupied = nil
        oldTile.piece = nil
    end
    
    -- Set new position
    if targetTile.occupied then
        -- Handle combat
        self:HandleCombat(piece, targetTile.occupied)
    end
    
    targetTile.occupied = piece
    targetTile.piece = piece
    piece.position = {row = targetRow, col = targetCol}
    
    return true
end

function Board:HandleCombat(attacker, defender)
    defender:TakeDamage(attacker.Attack)
    if defender.Health <= 0 then
        self:RemovePiece(defender)
        if attacker.OnKill then
            attacker:OnKill()
        end
    end
end

function Board:RemovePiece(piece)
    for i, p in ipairs(self.pieces) do
        if p == piece then
            table.remove(self.pieces, i)
            break
        end
    end
    
    if piece.position then
        local tile = self:GetTile(piece.position.row, piece.position.col)
        if tile then
            tile.occupied = nil
            tile.piece = nil
        end
    end
end

function Board:GetEnemiesInRadius(centerTile, radius)
    local enemies = {}
    local centerRow, centerCol = centerTile.row, centerTile.col
    
    for row = math.max(1, centerRow - radius), math.min(self.size, centerRow + radius) do
        for col = math.max(1, centerCol - radius), math.min(self.size, centerCol + radius) do
            local tile = self:GetTile(row, col)
            if tile and tile.occupied then
                table.insert(enemies, tile.occupied)
            end
        end
    end
    
    return enemies
end

return Board