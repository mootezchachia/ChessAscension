-- src/Game/UI/MainUI.lua
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MainUI = {}

function MainUI:Init()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create main screen GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ChessAscensionUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Main UI container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.Position = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = screenGui
    
    -- Ability UI container
    local abilityFrame = Instance.new("Frame")
    abilityFrame.Name = "AbilityFrame"
    abilityFrame.Size = UDim2.new(0, 300, 0, 80)
    abilityFrame.Position = UDim2.new(0.5, -150, 1, -100)
    abilityFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    abilityFrame.BorderSizePixel = 0
    abilityFrame.Parent = mainFrame
    
    -- Add gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    }
    gradient.Rotation = 90
    gradient.Parent = abilityFrame
    
    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = abilityFrame
    
    -- Add glowing border effect
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 150, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = abilityFrame
    
    -- Ability button
    local abilityButton = Instance.new("TextButton")
    abilityButton.Name = "AbilityButton"
    abilityButton.Size = UDim2.new(0, 200, 0, 50)
    abilityButton.Position = UDim2.new(0, 15, 0.5, -25)
    abilityButton.Text = "Use Ability"
    abilityButton.Font = Enum.Font.GothamBold
    abilityButton.TextSize = 16
    abilityButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    abilityButton.BackgroundColor3 = Color3.fromRGB(60, 60, 100)
    abilityButton.BorderSizePixel = 0
    abilityButton.Parent = abilityFrame
    
    -- Button styling
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = abilityButton
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(120, 170, 255)
    buttonStroke.Thickness = 1
    buttonStroke.Parent = abilityButton
    
    -- Cooldown overlay
    local cooldownFrame = Instance.new("Frame")
    cooldownFrame.Name = "CooldownOverlay"
    cooldownFrame.Size = UDim2.new(1, 0, 1, 0)
    cooldownFrame.Position = UDim2.new(0, 0, 0, 0)
    cooldownFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    cooldownFrame.BackgroundTransparency = 0.7
    cooldownFrame.BorderSizePixel = 0
    cooldownFrame.Visible = false
    cooldownFrame.Parent = abilityButton
    
    local cooldownCorner = Instance.new("UICorner")
    cooldownCorner.CornerRadius = UDim.new(0, 8)
    cooldownCorner.Parent = cooldownFrame
    
    -- Cooldown text
    local cooldownText = Instance.new("TextLabel")
    cooldownText.Name = "CooldownText"
    cooldownText.Size = UDim2.new(1, 0, 1, 0)
    cooldownText.Position = UDim2.new(0, 0, 0, 0)
    cooldownText.Text = "5"
    cooldownText.Font = Enum.Font.GothamBold
    cooldownText.TextSize = 20
    cooldownText.TextColor3 = Color3.fromRGB(255, 100, 100)
    cooldownText.BackgroundTransparency = 1
    cooldownText.Parent = cooldownFrame
    
    -- Health display
    local healthFrame = Instance.new("Frame")
    healthFrame.Name = "HealthFrame"
    healthFrame.Size = UDim2.new(0, 70, 0, 60)
    healthFrame.Position = UDim2.new(1, -80, 0, 10)
    healthFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    healthFrame.BorderSizePixel = 0
    healthFrame.Parent = abilityFrame
    
    local healthCorner = Instance.new("UICorner")
    healthCorner.CornerRadius = UDim.new(0, 8)
    healthCorner.Parent = healthFrame
    
    local healthLabel = Instance.new("TextLabel")
    healthLabel.Name = "HealthLabel"
    healthLabel.Size = UDim2.new(1, 0, 0.4, 0)
    healthLabel.Position = UDim2.new(0, 0, 0, 5)
    healthLabel.Text = "HP"
    healthLabel.Font = Enum.Font.Gotham
    healthLabel.TextSize = 12
    healthLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Parent = healthFrame
    
    local healthValue = Instance.new("TextLabel")
    healthValue.Name = "HealthValue"
    healthValue.Size = UDim2.new(1, 0, 0.6, 0)
    healthValue.Position = UDim2.new(0, 0, 0.4, 0)
    healthValue.Text = "100/100"
    healthValue.Font = Enum.Font.GothamBold
    healthValue.TextSize = 14
    healthValue.TextColor3 = Color3.fromRGB(100, 255, 100)
    healthValue.BackgroundTransparency = 1
    healthValue.Parent = healthFrame
    
    -- Store references
    self.screenGui = screenGui
    self.abilityButton = abilityButton
    self.cooldownFrame = cooldownFrame
    self.cooldownText = cooldownText
    self.healthValue = healthValue
    
    -- Set up button interactions
    self:SetupButtonEvents()
    
    print("Chess Ascension UI initialized!")
end

function MainUI:SetupButtonEvents()
    -- Hover effects
    self.abilityButton.MouseEnter:Connect(function()
        local tween = TweenService:Create(
            self.abilityButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(80, 80, 140)}
        )
        tween:Play()
    end)
    
    self.abilityButton.MouseLeave:Connect(function()
        local tween = TweenService:Create(
            self.abilityButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(60, 60, 100)}
        )
        tween:Play()
    end)
    
    -- Click handler
    self.abilityButton.MouseButton1Click:Connect(function()
        self:OnAbilityButtonClicked()
    end)
end

function MainUI:OnAbilityButtonClicked()
    print("Ability button clicked!")
    
    -- Start cooldown animation
    self:StartCooldown(5) -- 5 second cooldown for demo
    
    -- TODO: Connect to networking to actually use ability
    -- local networking = require(ReplicatedStorage.Game.Networking)
    -- networking:UseAbility("selectedPiece", "targetPosition")
end

function MainUI:StartCooldown(duration)
    self.cooldownFrame.Visible = true
    self.abilityButton.Text = "Recharging..."
    
    local startTime = tick()
    local connection
    
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        local remaining = duration - elapsed
        
        if remaining <= 0 then
            -- Cooldown finished
            self.cooldownFrame.Visible = false
            self.abilityButton.Text = "Use Ability"
            connection:Disconnect()
        else
            -- Update cooldown display
            self.cooldownText.Text = tostring(math.ceil(remaining))
        end
    end)
end

function MainUI:UpdateHealth(current, max)
    self.healthValue.Text = current .. "/" .. max
    
    -- Change color based on health percentage
    local percentage = current / max
    if percentage > 0.6 then
        self.healthValue.TextColor3 = Color3.fromRGB(100, 255, 100) -- Green
    elseif percentage > 0.3 then
        self.healthValue.TextColor3 = Color3.fromRGB(255, 255, 100) -- Yellow
    else
        self.healthValue.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red
    end
end

return MainUI