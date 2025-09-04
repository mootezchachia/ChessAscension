-- src/Game/GameModes.lua
local GameModes = {}
local ShadowSystem = require(script.Parent.ShadowSystem)
local DungeonBoss = require(script.Parent.Bosses.DungeonBoss)

function GameModes:InitializePvEMode(board, playerLoadout)
    -- Set up dungeon battle
    local boss = DungeonBoss.new("FireKing") -- Random boss later
    
    -- Place boss at center-back of board
    local bossRow = board.size
    local bossCol = math.ceil(board.size / 2)
    board:PlacePiece(boss, bossRow, bossCol)
    
    -- Place player shadows
    self:PlacePlayerShadows(board, playerLoadout)
    
    return {
        mode = "PvE",
        boss = boss,
        turnCount = 0,
        playerTurn = true
    }
end

function GameModes:InitializePvPMode(board, player1Loadout, player2Loadout)
    -- Set up player vs player battle
    self:PlacePlayerShadows(board, player1Loadout, "Player1")
    self:PlacePlayerShadows(board, player2Loadout, "Player2")
    
    return {
        mode = "PvP",
        currentPlayer = "Player1",
        turnCount = 0
    }
end

function GameModes:PlacePlayerShadows(board, loadout, team)
    team = team or "Player"
    local startRow = team == "Player1" and 1 or (team == "Player2" and board.size or 1)
    
    -- Place selected shadows from loadout
    for i, shadow in ipairs(loadout.selectedShadows) do
        local col = i
        if col <= board.size then
            shadow.Team = team
            board:PlacePiece(shadow, startRow, col)
        end
    end
end

function GameModes:ProcessTurn(gameState, board, action)
    if gameState.mode == "PvE" then
        return self:ProcessPvETurn(gameState, board, action)
    elseif gameState.mode == "PvP" then
        return self:ProcessPvPTurn(gameState, board, action)
    end
end

function GameModes:ProcessPvETurn(gameState, board, action)
    if gameState.playerTurn then
        -- Player's turn
        local result = self:ExecutePlayerAction(board, action)
        
        if result.turnComplete then
            gameState.playerTurn = false
            gameState.turnCount = gameState.turnCount + 1
        end
        
        return result
    else
        -- Boss turn
        gameState.boss:TakeTurn(board)
        gameState.playerTurn = true
        
        -- Check win/lose conditions
        return self:CheckPvEConditions(gameState, board)
    end
end

function GameModes:CheckPvEConditions(gameState, board)
    -- Check if boss is defeated
    if gameState.boss.Health <= 0 then
        local rewards = gameState.boss:GetReward()
        return {
            gameOver = true,
            winner = "Player",
            rewards = rewards
        }
    end
    
    -- Check if all player pieces are defeated
    local playerPieces = 0
    for _, piece in ipairs(board.pieces) do
        if piece.Team == "Player" and piece.Health > 0 then
            playerPieces = playerPieces + 1
        end
    end
    
    if playerPieces == 0 then
        return {
            gameOver = true,
            winner = "Boss",
            rewards = {xp = 25, gold = 10} -- Consolation prize
        }
    end
    
    return {gameOver = false}
end

function GameModes:ExecutePlayerAction(board, action)
    if action.type == "move" then
        local success = board:MovePiece(action.piece, action.targetTile)
        return {success = success, turnComplete = true}
    elseif action.type == "ability" then
        local success, message = action.piece:UseAbility(board, action.targetTile)
        return {success = success, message = message, turnComplete = true}
    end
    
    return {success = false, turnComplete = false}
end

function GameModes:CreateDefaultLoadout()
    -- Create starting shadow loadout
    local Pawn = require(script.Parent.Abilities.Pawn)
    local Knight = require(script.Parent.Abilities.Knight)
    local Bishop = require(script.Parent.Abilities.Bishop)
    
    local loadout = {
        selectedShadows = {
            Pawn.new(),
            Knight.new(),
            Bishop.new()
        }
    }
    
    -- Initialize shadow properties
    for _, shadow in ipairs(loadout.selectedShadows) do
        shadow.Level = 1
        shadow.XP = 0
        shadow.EvolutionStage = "Shadow " .. shadow.Name
        shadow.Team = "Player"
        shadow.Type = shadow.Name -- For evolution system
    end
    
    return loadout
end

function GameModes:DistributeRewards(players, rewards)
    for _, player in ipairs(players) do
        for _, shadow in ipairs(player.loadout.selectedShadows) do
            if shadow.Health > 0 then -- Only living shadows get XP
                ShadowSystem:GainXP(shadow, rewards.xp)
            end
        end
        
        -- Give player resources
        player.gold = (player.gold or 0) + rewards.gold
        print("Player gained " .. rewards.xp .. " XP and " .. rewards.gold .. " gold!")
    end
end

return GameModes