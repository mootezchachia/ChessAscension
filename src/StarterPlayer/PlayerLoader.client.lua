-- src/StarterPlayer/PlayerLoader.client.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Wait for game modules to load
local Game = ReplicatedStorage:WaitForChild("Game")

-- Load main modules
local MainUI = require(Game.UI.MainUI)
local ShadowBattleUI = require(Game.UI.ShadowBattleUI)
local Networking = require(Game.Networking)

print("Chess Ascension - Player Loading...")

-- Initialize networking
Networking:Init()

-- Wait a moment for everything to load
wait(1)

-- Initialize UIs
MainUI:Init()
ShadowBattleUI:Init()

-- Show loadout selection first
ShadowBattleUI:ShowLoadout()

-- Set up game state listeners
if Networking.Remotes.GameState then
    Networking.Remotes.GameState.OnClientEvent:Connect(function(eventType, data)
        if eventType == "AbilityUsed" then
            print("Someone used an ability:", data)
        elseif eventType == "PieceMoved" then
            print("Piece moved:", data)
        end
    end)
end

print("Chess Ascension - Player loaded successfully!")
print("🏁 Ready to play Chess Ascension!")

-- Optional: Create a simple welcome message
local function showWelcomeMessage()
    local playerGui = player:WaitForChild("PlayerGui")
    
    local welcomeGui = Instance.new("ScreenGui")
    welcomeGui.Name = "WelcomeMessage"
    welcomeGui.Parent = playerGui
    
    local welcomeFrame = Instance.new("Frame")
    welcomeFrame.Size = UDim2.new(0, 400, 0, 200)
    welcomeFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
    welcomeFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    welcomeFrame.BorderSizePixel = 0
    welcomeFrame.Parent = welcomeGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = welcomeFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 150, 255)
    stroke.Thickness = 2
    stroke.Parent = welcomeFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.4, 0)
    title.Position = UDim2.new(0, 0, 0.1, 0)
    title.Text = "⚔️ Chess Ascension"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Parent = welcomeFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0.3, 0)
    subtitle.Position = UDim2.new(0, 0, 0.5, 0)
    subtitle.Text = "Solo Leveling meets Chess"
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 16
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    subtitle.BackgroundTransparency = 1
    subtitle.Parent = welcomeFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 100, 0, 35)
    closeButton.Position = UDim2.new(0.5, -50, 0.8, -17)
    closeButton.Text = "Start Game"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    closeButton.BorderSizePixel = 0
    closeButton.Parent = welcomeFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        welcomeGui:Destroy()
    end)
    
    -- Auto-close after 5 seconds
    game:GetService("Debris"):AddItem(welcomeGui, 5)
end

-- Show welcome message
showWelcomeMessage()