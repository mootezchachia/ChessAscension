-- src/Game/Networking.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Networking = {}
Networking.Remotes = {}

function Networking:Init()
    local folder = Instance.new("Folder")
    folder.Name = "Remotes"
    folder.Parent = ReplicatedStorage

    -- Create RemoteEvents
    self.Remotes.UseAbility = Instance.new("RemoteEvent")
    self.Remotes.UseAbility.Name = "UseAbility"
    self.Remotes.UseAbility.Parent = folder

    self.Remotes.MovePiece = Instance.new("RemoteEvent")
    self.Remotes.MovePiece.Name = "MovePiece"
    self.Remotes.MovePiece.Parent = folder

    self.Remotes.GameState = Instance.new("RemoteEvent")
    self.Remotes.GameState.Name = "GameState"
    self.Remotes.GameState.Parent = folder

    -- Only set up server handlers if on server
    if RunService:IsServer() then
        self:SetupServerHandlers()
    end
end

function Networking:SetupServerHandlers()
    self.Remotes.UseAbility.OnServerEvent:Connect(function(player, pieceId, targetPosition)
        self:HandleAbilityUse(player, pieceId, targetPosition)
    end)

    self.Remotes.MovePiece.OnServerEvent:Connect(function(player, pieceId, targetPosition)
        self:HandlePieceMove(player, pieceId, targetPosition)
    end)
end

function Networking:HandleAbilityUse(player, pieceId, targetPosition)
    -- Validate player owns the piece
    -- Validate ability is off cooldown
    -- Execute ability
    -- Broadcast result to all players
    print("Player", player.Name, "used ability on piece", pieceId, "at", targetPosition)
    
    -- Broadcast to all clients
    self.Remotes.GameState:FireAllClients("AbilityUsed", {
        player = player,
        pieceId = pieceId,
        targetPosition = targetPosition
    })
end

function Networking:HandlePieceMove(player, pieceId, targetPosition)
    -- Validate move is legal
    -- Update server game state
    -- Broadcast to all players
    print("Player", player.Name, "moved piece", pieceId, "to", targetPosition)
    
    -- Broadcast to all clients
    self.Remotes.GameState:FireAllClients("PieceMoved", {
        player = player,
        pieceId = pieceId,
        targetPosition = targetPosition
    })
end

-- Client methods
function Networking:UseAbility(pieceId, targetPosition)
    if self.Remotes.UseAbility then
        self.Remotes.UseAbility:FireServer(pieceId, targetPosition)
    end
end

function Networking:MovePiece(pieceId, targetPosition)
    if self.Remotes.MovePiece then
        self.Remotes.MovePiece:FireServer(pieceId, targetPosition)
    end
end

return Networking