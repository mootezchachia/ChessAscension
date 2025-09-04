-- src/Game/GameController.lua
local GameController = {}
local Board = require(script.Parent.Board)
local BoardRenderer = require(script.Parent.BoardRenderer)
local GameModes = require(script.Parent.GameModes)
local ShadowSystem = require(script.Parent.ShadowSystem)

function GameController:Initialize()
    self.gameState = nil
    self.board = nil
    self.boardRenderer = nil
    self.selectedPiece = nil
    self.selectedTile = nil
    
    print("🎮 Game Controller initialized!")
end

function GameController:StartGame(mode, playerLoadout)
    mode = mode or "PvE"
    
    -- Create logical board
    self.board = Board.new(4) -- 4x4 board
    
    -- Create visual board
    self.boardRenderer = BoardRenderer:CreateBoard(4)
    self.boardRenderer.OnTileClick = function(row, col, player)
        self:OnTileClicked(row, col, player)
    end
    
    -- Initialize game mode
    if mode == "PvE" then
        self.gameState = GameModes:InitializePvEMode(self.board, playerLoadout)
        self:SetupPvEGame()
    elseif mode == "PvP" then
        self.gameState = GameModes:InitializePvPMode(self.board, playerLoadout, {}) -- Add opponent loadout
        self:SetupPvPGame()
    end
    
    self:RenderBoard()
    
    print("🌟 Game started in " .. mode .. " mode!")
end

function GameController:SetupPvEGame()
    -- Place player shadows on board
    local playerLoadout = GameModes:CreateDefaultLoadout()
    
    for i, shadow in ipairs(playerLoadout.selectedShadows) do
        if i <= 4 then -- Fit within 4x4 board
            self.board:PlacePiece(shadow, 1, i)
            self.boardRenderer:CreatePiece(shadow, 1, i)
        end
    end
    
    -- Place boss
    if self.gameState.boss then
        self.board:PlacePiece(self.gameState.boss, 4, 2) -- Center back
        self.boardRenderer:CreatePiece(self.gameState.boss, 4, 2)
    end
end

function GameController:SetupPvPGame()
    -- Setup for PvP mode
    print("PvP mode setup - To be implemented")
end

function GameController:RenderBoard()
    -- Update visual representation to match logical board
    for row = 1, self.board.size do
        for col = 1, self.board.size do
            local tile = self.board:GetTile(row, col)
            if tile and tile.occupied then
                -- Create piece if doesn't exist
                if not self:FindVisualPiece(tile.occupied) then
                    self.boardRenderer:CreatePiece(tile.occupied, row, col)
                end
            end
        end
    end
end

function GameController:OnTileClicked(row, col, player)
    local tile = self.board:GetTile(row, col)
    if not tile then return end
    
    print("Tile clicked: " .. row .. ", " .. col)
    
    if self.selectedPiece then
        -- Try to move or use ability
        if tile.occupied then
            -- Attack enemy piece
            self:TryUseAbility(self.selectedPiece, tile)
        else
            -- Move to empty tile  
            self:TryMovePiece(self.selectedPiece, tile)
        end
        self.selectedPiece = nil
    else
        -- Select piece if it belongs to player
        if tile.occupied and tile.occupied.Team == "Player" then
            self.selectedPiece = tile.occupied
            print("Selected piece: " .. tile.occupied.Name)
            
            -- Highlight possible moves
            self:ShowPossibleMoves(tile.occupied)
        end
    end
end

function GameController:TryMovePiece(piece, targetTile)
    local success = self.board:MovePiece(piece, targetTile, 2)
    
    if success then
        -- Update visual
        local visualPiece = self:FindVisualPiece(piece)
        if visualPiece then
            self.boardRenderer:MovePiece(
                visualPiece,
                piece.position.row, piece.position.col,
                targetTile.row, targetTile.col
            )
        end
        
        self:EndPlayerTurn()
        print("✅ Piece moved successfully!")
    else
        print("❌ Cannot move piece there")
    end
end

function GameController:TryUseAbility(piece, targetTile)
    local success, message = piece:UseAbility(self.board, targetTile)
    
    if success then
        print("⚡ " .. message)
        
        -- Visual effects
        local visualPiece = self:FindVisualPiece(piece)
        if visualPiece then
            self.boardRenderer:PlayAbilityEffect(visualPiece, "ability")
        end
        
        -- Update health bars for affected pieces
        if targetTile.occupied then
            local targetVisual = self:FindVisualPiece(targetTile.occupied)
            if targetVisual then
                self.boardRenderer:UpdatePieceHealth(
                    targetVisual,
                    targetTile.occupied.Health,
                    targetTile.occupied.MaxHealth
                )
            end
        end
        
        self:EndPlayerTurn()
    else
        print("❌ " .. message)
    end
end

function GameController:ShowPossibleMoves(piece)
    -- Clear previous highlights
    self.boardRenderer:ClearHighlights()
    
    -- Show possible move tiles (simple 2-tile radius for now)
    local currentRow, currentCol = piece.position.row, piece.position.col
    
    for row = math.max(1, currentRow - 2), math.min(self.board.size, currentRow + 2) do
        for col = math.max(1, currentCol - 2), math.min(self.board.size, currentCol + 2) do
            if row ~= currentRow or col ~= currentCol then
                self.boardRenderer:HighlightTile(row, col, true)
            end
        end
    end
end

function GameController:EndPlayerTurn()
    self.boardRenderer:ClearHighlights()
    
    if self.gameState.mode == "PvE" then
        -- Boss turn
        wait(1) -- Brief pause
        self:ProcessBossTurn()
    end
end

function GameController:ProcessBossTurn()
    if self.gameState.boss and self.gameState.boss.Health > 0 then
        self.gameState.boss:TakeTurn(self.board)
        
        -- Update all piece visuals after boss turn
        self:UpdateAllPieceVisuals()
        
        -- Check win/lose conditions
        local result = GameModes:CheckPvEConditions(self.gameState, self.board)
        if result.gameOver then
            self:EndGame(result)
        end
    end
end

function GameController:UpdateAllPieceVisuals()
    for _, piece in ipairs(self.board.pieces) do
        local visualPiece = self:FindVisualPiece(piece)
        if visualPiece then
            self.boardRenderer:UpdatePieceHealth(visualPiece, piece.Health, piece.MaxHealth)
        end
    end
end

function GameController:FindVisualPiece(logicalPiece)
    -- Find the visual piece model that corresponds to logical piece
    if not self.boardRenderer.boardModel then return nil end
    
    for _, child in ipairs(self.boardRenderer.boardModel:GetChildren()) do
        if child:IsA("Model") and child.Name == (logicalPiece.EvolutionStage or logicalPiece.Name) then
            -- Additional check could compare position data
            return child
        end
    end
    
    return nil
end

function GameController:EndGame(result)
    print("🎉 Game Over! Winner: " .. result.winner)
    
    if result.rewards then
        print("🏆 Rewards: " .. result.rewards.xp .. " XP, " .. result.rewards.gold .. " Gold")
        
        -- Distribute rewards to living pieces
        GameModes:DistributeRewards({
            {loadout = {selectedShadows = self:GetPlayerPieces()}}
        }, result.rewards)
    end
    
    -- Show game over UI
    self:ShowGameOverScreen(result)
end

function GameController:GetPlayerPieces()
    local playerPieces = {}
    for _, piece in ipairs(self.board.pieces) do
        if piece.Team == "Player" then
            table.insert(playerPieces, piece)
        end
    end
    return playerPieces
end

function GameController:ShowGameOverScreen(result)
    -- TODO: Create game over UI
    print("Game over screen would appear here")
    
    -- For now, just restart after 5 seconds
    wait(5)
    self:RestartGame()
end

function GameController:RestartGame()
    -- Clean up current game
    if self.boardRenderer and self.boardRenderer.boardModel then
        self.boardRenderer.boardModel:Destroy()
    end
    
    -- Start new game
    wait(1)
    self:StartGame("PvE")
end

return GameController