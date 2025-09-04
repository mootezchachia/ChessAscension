-- src/Game/Bosses/DungeonBoss.lua
local DungeonBoss = {}
DungeonBoss.__index = DungeonBoss

function DungeonBoss.new(bossType)
    local self = setmetatable({}, DungeonBoss)
    self.Type = bossType or "FireKing"
    self:InitializeBoss()
    return self
end

function DungeonBoss:InitializeBoss()
    if self.Type == "FireKing" then
        self.Name = "🔥 Fire King"
        self.Health = 500
        self.MaxHealth = 500
        self.Attack = 40
        self.Level = 5
        self.Abilities = {"Flame Burst", "Summon Minions", "Meteor Strike"}
        self.MinionSpawnRate = 3 -- Spawns minion every 3 turns
    elseif self.Type == "IceQueen" then
        self.Name = "❄️ Ice Queen"
        self.Health = 400
        self.MaxHealth = 400
        self.Attack = 35
        self.Level = 4
        self.Abilities = {"Frost Wave", "Ice Wall", "Blizzard"}
        self.MinionSpawnRate = 4
    elseif self.Type == "ShadowLord" then
        self.Name = "👤 Shadow Lord"
        self.Health = 600
        self.MaxHealth = 600
        self.Attack = 45
        self.Level = 6
        self.Abilities = {"Shadow Clone", "Void Strike", "Dark Portal"}
        self.MinionSpawnRate = 2
    end
    
    self.turnCount = 0
    self.minions = {}
    self.Cooldowns = {}
end

function DungeonBoss:TakeTurn(board)
    self.turnCount = self.turnCount + 1
    
    -- Spawn minions periodically
    if self.turnCount % self.MinionSpawnRate == 0 then
        self:SpawnMinion(board)
    end
    
    -- Use random ability
    local availableAbilities = {}
    for _, ability in ipairs(self.Abilities) do
        if not self.Cooldowns[ability] or self.Cooldowns[ability] <= 0 then
            table.insert(availableAbilities, ability)
        end
    end
    
    if #availableAbilities > 0 then
        local chosenAbility = availableAbilities[math.random(#availableAbilities)]
        self:UseAbility(chosenAbility, board)
    end
    
    -- Reduce cooldowns
    for ability, cooldown in pairs(self.Cooldowns) do
        if cooldown > 0 then
            self.Cooldowns[ability] = cooldown - 1
        end
    end
end

function DungeonBoss:UseAbility(abilityName, board)
    if abilityName == "Flame Burst" then
        self:FlameBurst(board)
        self.Cooldowns["Flame Burst"] = 4
    elseif abilityName == "Frost Wave" then
        self:FrostWave(board)
        self.Cooldowns["Frost Wave"] = 3
    elseif abilityName == "Shadow Clone" then
        self:ShadowClone(board)
        self.Cooldowns["Shadow Clone"] = 6
    elseif abilityName == "Summon Minions" then
        self:SpawnMinion(board)
        self:SpawnMinion(board)
        self.Cooldowns["Summon Minions"] = 5
    elseif abilityName == "Meteor Strike" then
        self:MeteorStrike(board)
        self.Cooldowns["Meteor Strike"] = 8
    end
end

function DungeonBoss:FlameBurst(board)
    print("🔥 " .. self.Name .. " uses Flame Burst!")
    
    -- Damage all player pieces in 3x3 area
    local centerRow, centerCol = math.ceil(board.size/2), math.ceil(board.size/2)
    
    for row = centerRow-1, centerRow+1 do
        for col = centerCol-1, centerCol+1 do
            local tile = board:GetTile(row, col)
            if tile and tile.occupied and tile.occupied.Team == "Player" then
                tile.occupied:TakeDamage(25)
            end
        end
    end
end

function DungeonBoss:FrostWave(board)
    print("❄️ " .. self.Name .. " uses Frost Wave!")
    
    -- Freeze all player pieces for 1 turn
    for _, piece in ipairs(board.pieces) do
        if piece.Team == "Player" then
            piece.frozen = true
            piece.freezeDuration = 1
        end
    end
end

function DungeonBoss:ShadowClone(board)
    print("👤 " .. self.Name .. " creates Shadow Clones!")
    
    -- Create 2 shadow clone minions
    for i = 1, 2 do
        self:SpawnMinion(board, "ShadowClone")
    end
end

function DungeonBoss:MeteorStrike(board)
    print("☄️ " .. self.Name .. " calls down Meteor Strike!")
    
    -- Massive damage to random player piece
    local playerPieces = {}
    for _, piece in ipairs(board.pieces) do
        if piece.Team == "Player" then
            table.insert(playerPieces, piece)
        end
    end
    
    if #playerPieces > 0 then
        local target = playerPieces[math.random(#playerPieces)]
        target:TakeDamage(60)
        print("☄️ Meteor strikes " .. target.Name .. "!")
    end
end

function DungeonBoss:SpawnMinion(board, minionType)
    minionType = minionType or "FireMinion"
    
    -- Find empty tile near boss
    local emptyTiles = {}
    for row = 1, board.size do
        for col = 1, board.size do
            local tile = board:GetTile(row, col)
            if tile and not tile.occupied then
                table.insert(emptyTiles, tile)
            end
        end
    end
    
    if #emptyTiles > 0 then
        local spawnTile = emptyTiles[math.random(#emptyTiles)]
        local minion = self:CreateMinion(minionType)
        board:PlacePiece(minion, spawnTile.row, spawnTile.col)
        table.insert(self.minions, minion)
        print("👹 " .. self.Name .. " spawns " .. minion.Name .. "!")
    end
end

function DungeonBoss:CreateMinion(minionType)
    local minion = {}
    minion.Team = "Boss"
    
    if minionType == "FireMinion" then
        minion.Name = "🔥 Fire Minion"
        minion.Health = 30
        minion.MaxHealth = 30
        minion.Attack = 15
    elseif minionType == "ShadowClone" then
        minion.Name = "👤 Shadow Clone"
        minion.Health = 40
        minion.MaxHealth = 40
        minion.Attack = 20
    else
        minion.Name = "👹 Dungeon Minion"
        minion.Health = 25
        minion.MaxHealth = 25
        minion.Attack = 12
    end
    
    function minion:TakeDamage(damage)
        self.Health = self.Health - damage
        print(self.Name .. " took " .. damage .. " damage. Health: " .. self.Health)
        if self.Health <= 0 then
            print(self.Name .. " defeated!")
        end
    end
    
    return minion
end

function DungeonBoss:TakeDamage(damage)
    self.Health = self.Health - damage
    print(self.Name .. " took " .. damage .. " damage. Health: " .. self.Health .. "/" .. self.MaxHealth)
    
    if self.Health <= 0 then
        print("🏆 " .. self.Name .. " has been defeated!")
        return true -- Boss defeated
    end
    
    return false
end

function DungeonBoss:GetReward()
    return {
        xp = 200 + (self.Level * 50),
        gold = 100 + (self.Level * 25),
        items = {"Evolution Crystal", "Ability Scroll"}
    }
end

return DungeonBoss