-- src/Game/BoardRenderer.lua
local BoardRenderer = {}
local TweenService = game:GetService("TweenService")

function BoardRenderer:CreateBoard(size)
    size = size or 4 -- 4x4 board for MVP
    
    -- Create board model
    local boardModel = Instance.new("Model")
    boardModel.Name = "ChessBoard"
    boardModel.Parent = workspace
    
    -- Board base
    local boardBase = Instance.new("Part")
    boardBase.Name = "BoardBase"
    boardBase.Size = Vector3.new(size * 4 + 2, 0.5, size * 4 + 2)
    boardBase.Position = Vector3.new(0, 0, 0)
    boardBase.Anchored = true
    boardBase.BrickColor = BrickColor.new("Dark stone grey")
    boardBase.Material = Enum.Material.Marble
    boardBase.Parent = boardModel
    
    -- Create tiles
    self.tiles = {}
    for row = 1, size do
        self.tiles[row] = {}
        for col = 1, size do
            local tile = self:CreateTile(row, col, size)
            tile.Parent = boardModel
            self.tiles[row][col] = tile
        end
    end
    
    self.boardModel = boardModel
    self.size = size
    
    return boardModel
end

function BoardRenderer:CreateTile(row, col, boardSize)
    local tile = Instance.new("Part")
    tile.Name = "Tile_" .. row .. "_" .. col
    tile.Size = Vector3.new(3.5, 0.2, 3.5)
    
    -- Position tiles
    local startX = -(boardSize * 4) / 2 + 2
    local startZ = -(boardSize * 4) / 2 + 2
    tile.Position = Vector3.new(
        startX + (col - 1) * 4,
        0.35,
        startZ + (row - 1) * 4
    )
    
    tile.Anchored = true
    
    -- Checkerboard pattern
    if (row + col) % 2 == 0 then
        tile.BrickColor = BrickColor.new("Institutional white")
    else
        tile.BrickColor = BrickColor.new("Really black")
    end
    
    tile.Material = Enum.Material.SmoothPlastic
    
    -- Add selection highlight
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Name = "SelectionHighlight"
    selectionBox.Adornee = tile
    selectionBox.Color3 = Color3.fromRGB(100, 150, 255)
    selectionBox.LineThickness = 0.2
    selectionBox.Transparency = 1 -- Hidden by default
    selectionBox.Parent = tile
    
    -- Store tile data
    tile:SetAttribute("Row", row)
    tile:SetAttribute("Col", col)
    tile:SetAttribute("Occupied", false)
    
    -- Click detection
    local clickDetector = Instance.new("ClickDetector")
    clickDetector.MaxActivationDistance = 50
    clickDetector.Parent = tile
    
    clickDetector.MouseClick:Connect(function(player)
        self:OnTileClicked(tile, player)
    end)
    
    return tile
end

function BoardRenderer:CreatePiece(pieceData, row, col)
    local piece = Instance.new("Model")
    piece.Name = pieceData.EvolutionStage or pieceData.Name
    
    -- Main piece part
    local piecePart = Instance.new("Part")
    piecePart.Name = "PiecePart"
    piecePart.Size = Vector3.new(2, 3, 2)
    piecePart.Shape = Enum.PartType.Cylinder
    piecePart.Anchored = true
    piecePart.CanCollide = false
    piecePart.Parent = piece
    
    -- Color based on team
    if pieceData.Team == "Player" then
        piecePart.BrickColor = BrickColor.new("Bright blue")
    elseif pieceData.Team == "Boss" then
        piecePart.BrickColor = BrickColor.new("Really red")
    else
        piecePart.BrickColor = BrickColor.new("Medium stone grey")
    end
    
    piecePart.Material = Enum.Material.Neon
    
    -- Piece label
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = piecePart
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.Text = pieceData.EvolutionStage or pieceData.Name
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 12
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.BackgroundTransparency = 1
    nameLabel.Parent = billboard
    
    -- Health bar
    local healthFrame = Instance.new("Frame")
    healthFrame.Size = UDim2.new(1, 0, 0.4, 0)
    healthFrame.Position = UDim2.new(0, 0, 0.6, 0)
    healthFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    healthFrame.BorderSizePixel = 0
    healthFrame.Parent = billboard
    
    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(pieceData.Health / pieceData.MaxHealth, 0, 1, 0)
    healthBar.Position = UDim2.new(0, 0, 0, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Parent = healthFrame
    
    -- Position piece on board
    self:PositionPiece(piece, row, col)
    
    -- Store piece data
    piece:SetAttribute("PieceData", game:GetService("HttpService"):JSONEncode({
        Name = pieceData.Name,
        Type = pieceData.Type,
        Team = pieceData.Team,
        Row = row,
        Col = col
    }))
    
    piece.Parent = self.boardModel
    return piece
end

function BoardRenderer:PositionPiece(piece, row, col)
    local tile = self.tiles[row] and self.tiles[row][col]
    if tile and piece.PiecePart then
        piece.PiecePart.Position = Vector3.new(
            tile.Position.X,
            tile.Position.Y + 2,
            tile.Position.Z
        )
    end
end

function BoardRenderer:MovePiece(piece, fromRow, fromCol, toRow, toCol)
    -- Animate piece movement
    local targetTile = self.tiles[toRow] and self.tiles[toRow][toCol]
    if targetTile and piece.PiecePart then
        local targetPosition = Vector3.new(
            targetTile.Position.X,
            targetTile.Position.Y + 2,
            targetTile.Position.Z
        )
        
        local moveTween = TweenService:Create(
            piece.PiecePart,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = targetPosition}
        )
        
        moveTween:Play()
        
        -- Update tile occupancy
        if self.tiles[fromRow] and self.tiles[fromRow][fromCol] then
            self.tiles[fromRow][fromCol]:SetAttribute("Occupied", false)
        end
        if targetTile then
            targetTile:SetAttribute("Occupied", true)
        end
    end
end

function BoardRenderer:HighlightTile(row, col, highlight)
    local tile = self.tiles[row] and self.tiles[row][col]
    if tile and tile.SelectionHighlight then
        tile.SelectionHighlight.Transparency = highlight and 0 or 1
    end
end

function BoardRenderer:OnTileClicked(tile, player)
    local row = tile:GetAttribute("Row")
    local col = tile:GetAttribute("Col")
    
    print("Tile clicked:", row, col)
    
    -- Highlight clicked tile
    self:ClearHighlights()
    self:HighlightTile(row, col, true)
    
    -- Fire tile click event
    if self.OnTileClick then
        self.OnTileClick(row, col, player)
    end
end

function BoardRenderer:ClearHighlights()
    for row = 1, self.size do
        for col = 1, self.size do
            self:HighlightTile(row, col, false)
        end
    end
end

function BoardRenderer:UpdatePieceHealth(piece, health, maxHealth)
    if piece and piece.PiecePart and piece.PiecePart.BillboardGui then
        local healthBar = piece.PiecePart.BillboardGui.Frame.HealthBar
        if healthBar then
            local healthPercent = health / maxHealth
            local tween = TweenService:Create(
                healthBar,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad),
                {Size = UDim2.new(healthPercent, 0, 1, 0)}
            )
            tween:Play()
        end
    end
end

function BoardRenderer:PlayAbilityEffect(piece, effectType)
    if not piece or not piece.PiecePart then return end
    
    local effect = Instance.new("Explosion")
    effect.Position = piece.PiecePart.Position
    effect.BlastRadius = 10
    effect.BlastPressure = 0
    effect.Parent = workspace
    
    -- Add particle effect
    local attachment = Instance.new("Attachment")
    attachment.Parent = piece.PiecePart
    
    local particles = Instance.new("ParticleEmitter")
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Color = ColorSequence.new(Color3.fromRGB(100, 150, 255))
    particles.Lifetime = NumberRange.new(0.5, 1)
    particles.Rate = 50
    particles.SpreadAngle = Vector2.new(45, 45)
    particles.Speed = NumberRange.new(5)
    particles.Parent = attachment
    
    -- Stop particles after 2 seconds
    game:GetService("Debris"):AddItem(particles, 2)
end

return BoardRenderer