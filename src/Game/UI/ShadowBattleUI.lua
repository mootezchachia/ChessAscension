-- src/Game/UI/ShadowBattleUI.lua
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ShadowBattleUI = {}

function ShadowBattleUI:Init()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create main battle UI
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "ShadowBattleUI"
    self.screenGui.ResetOnSpawn = false
    self.screenGui.Parent = playerGui
    
    self:CreateLoadoutPanel()
    self:CreateBattleHUD()
    self:CreateEvolutionPanel()
    
    print("🌟 Shadow Battle UI initialized!")
end

function ShadowBattleUI:CreateLoadoutPanel()
    -- Loadout selection panel
    self.loadoutFrame = Instance.new("Frame")
    self.loadoutFrame.Name = "LoadoutPanel"
    self.loadoutFrame.Size = UDim2.new(0, 400, 0, 300)
    self.loadoutFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    self.loadoutFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    self.loadoutFrame.BorderSizePixel = 0
    self.loadoutFrame.Visible = false
    self.loadoutFrame.Parent = self.screenGui
    
    -- Styling
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = self.loadoutFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 50, 200)
    stroke.Thickness = 3
    stroke.Parent = self.loadoutFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 10)
    title.Text = "🌟 Shadow Loadout"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Parent = self.loadoutFrame
    
    -- Shadow slots
    self.shadowSlots = {}
    for i = 1, 6 do
        local slot = self:CreateShadowSlot(i)
        slot.Parent = self.loadoutFrame
        table.insert(self.shadowSlots, slot)
    end
    
    -- Start Battle button
    local startButton = Instance.new("TextButton")
    startButton.Size = UDim2.new(0, 150, 0, 40)
    startButton.Position = UDim2.new(0.5, -75, 1, -60)
    startButton.Text = "⚔️ Enter Battle"
    startButton.Font = Enum.Font.GothamBold
    startButton.TextSize = 16
    startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    startButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    startButton.BorderSizePixel = 0
    startButton.Parent = self.loadoutFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = startButton
    
    startButton.MouseButton1Click:Connect(function()
        self:StartBattle()
    end)
end

function ShadowBattleUI:CreateShadowSlot(index)
    local slot = Instance.new("Frame")
    slot.Name = "ShadowSlot" .. index
    slot.Size = UDim2.new(0, 60, 0, 80)
    
    -- Position in 2x3 grid
    local row = math.ceil(index / 3) - 1
    local col = (index - 1) % 3
    slot.Position = UDim2.new(0, 20 + col * 80, 0, 70 + row * 100)
    
    slot.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    slot.BorderSizePixel = 0
    
    local slotCorner = Instance.new("UICorner")
    slotCorner.CornerRadius = UDim.new(0, 8)
    slotCorner.Parent = slot
    
    -- Shadow icon/info will be added here
    local slotLabel = Instance.new("TextLabel")
    slotLabel.Size = UDim2.new(1, 0, 0.6, 0)
    slotLabel.Position = UDim2.new(0, 0, 0, 0)
    slotLabel.Text = "Empty"
    slotLabel.Font = Enum.Font.Gotham
    slotLabel.TextSize = 10
    slotLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    slotLabel.BackgroundTransparency = 1
    slotLabel.Parent = slot
    
    return slot
end

function ShadowBattleUI:CreateBattleHUD()
    -- Battle HUD during combat
    self.battleHUD = Instance.new("Frame")
    self.battleHUD.Name = "BattleHUD"
    self.battleHUD.Size = UDim2.new(1, 0, 0, 120)
    self.battleHUD.Position = UDim2.new(0, 0, 1, -120)
    self.battleHUD.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    self.battleHUD.BorderSizePixel = 0
    self.battleHUD.Visible = false
    self.battleHUD.Parent = self.screenGui
    
    -- Shadow info panel
    self.shadowInfoFrame = Instance.new("Frame")
    self.shadowInfoFrame.Size = UDim2.new(0, 250, 1, 0)
    self.shadowInfoFrame.Position = UDim2.new(0, 10, 0, 0)
    self.shadowInfoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    self.shadowInfoFrame.BorderSizePixel = 0
    self.shadowInfoFrame.Parent = self.battleHUD
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 10)
    infoCorner.Parent = self.shadowInfoFrame
    
    -- Selected shadow name
    self.shadowNameLabel = Instance.new("TextLabel")
    self.shadowNameLabel.Size = UDim2.new(1, 0, 0, 30)
    self.shadowNameLabel.Position = UDim2.new(0, 0, 0, 5)
    self.shadowNameLabel.Text = "🌟 Shadow Pawn"
    self.shadowNameLabel.Font = Enum.Font.GothamBold
    self.shadowNameLabel.TextSize = 16
    self.shadowNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.shadowNameLabel.BackgroundTransparency = 1
    self.shadowNameLabel.Parent = self.shadowInfoFrame
    
    -- Health bar
    self.healthBar = self:CreateStatusBar("Health", Color3.fromRGB(100, 255, 100), UDim2.new(0, 10, 0, 40))
    self.healthBar.Parent = self.shadowInfoFrame
    
    -- XP bar
    self.xpBar = self:CreateStatusBar("XP", Color3.fromRGB(100, 150, 255), UDim2.new(0, 10, 0, 70))
    self.xpBar.Parent = self.shadowInfoFrame
    
    -- Battle actions
    self:CreateBattleActions()
end

function ShadowBattleUI:CreateStatusBar(labelText, barColor, position)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 25)
    container.Position = position
    container.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 40, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = labelText
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.BackgroundTransparency = 1
    label.Parent = container
    
    local barBG = Instance.new("Frame")
    barBG.Size = UDim2.new(1, -50, 0, 15)
    barBG.Position = UDim2.new(0, 45, 0.5, -7)
    barBG.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    barBG.BorderSizePixel = 0
    barBG.Parent = container
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 3)
    barCorner.Parent = barBG
    
    local bar = Instance.new("Frame")
    bar.Name = "Bar"
    bar.Size = UDim2.new(0.8, 0, 1, 0)
    bar.Position = UDim2.new(0, 0, 0, 0)
    bar.BackgroundColor3 = barColor
    bar.BorderSizePixel = 0
    bar.Parent = barBG
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = bar
    
    return container
end

function ShadowBattleUI:CreateBattleActions()
    -- Action buttons
    self.actionsFrame = Instance.new("Frame")
    self.actionsFrame.Size = UDim2.new(0, 300, 1, 0)
    self.actionsFrame.Position = UDim2.new(1, -310, 0, 0)
    self.actionsFrame.BackgroundTransparency = 1
    self.actionsFrame.Parent = self.battleHUD
    
    -- Ability button
    self.abilityButton = Instance.new("TextButton")
    self.abilityButton.Size = UDim2.new(0, 120, 0, 50)
    self.abilityButton.Position = UDim2.new(0, 10, 0.5, -25)
    self.abilityButton.Text = "⚡ Use Ability"
    self.abilityButton.Font = Enum.Font.GothamBold
    self.abilityButton.TextSize = 14
    self.abilityButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.abilityButton.BackgroundColor3 = Color3.fromRGB(80, 50, 150)
    self.abilityButton.BorderSizePixel = 0
    self.abilityButton.Parent = self.actionsFrame
    
    local abilityCorner = Instance.new("UICorner")
    abilityCorner.CornerRadius = UDim.new(0, 8)
    abilityCorner.Parent = self.abilityButton
    
    -- Evolution button
    self.evolveButton = Instance.new("TextButton")
    self.evolveButton.Size = UDim2.new(0, 120, 0, 40)
    self.evolveButton.Position = UDim2.new(0, 140, 0.5, -20)
    self.evolveButton.Text = "🌟 Evolve"
    self.evolveButton.Font = Enum.Font.GothamBold
    self.evolveButton.TextSize = 14
    self.evolveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.evolveButton.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    self.evolveButton.BorderSizePixel = 0
    self.evolveButton.Parent = self.actionsFrame
    
    local evolveCorner = Instance.new("UICorner")
    evolveCorner.CornerRadius = UDim.new(0, 8)
    evolveCorner.Parent = self.evolveButton
    
    self.evolveButton.MouseButton1Click:Connect(function()
        self:AttemptEvolution()
    end)
end

function ShadowBattleUI:CreateEvolutionPanel()
    -- Evolution animation panel
    self.evolutionPanel = Instance.new("Frame")
    self.evolutionPanel.Name = "EvolutionPanel"
    self.evolutionPanel.Size = UDim2.new(0, 500, 0, 300)
    self.evolutionPanel.Position = UDim2.new(0.5, -250, 0.5, -150)
    self.evolutionPanel.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    self.evolutionPanel.BorderSizePixel = 0
    self.evolutionPanel.Visible = false
    self.evolutionPanel.Parent = self.screenGui
    
    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 15)
    panelCorner.Parent = self.evolutionPanel
    
    local evolutionStroke = Instance.new("UIStroke")
    evolutionStroke.Color = Color3.fromRGB(255, 200, 50)
    evolutionStroke.Thickness = 4
    evolutionStroke.Parent = self.evolutionPanel
    
    -- Evolution text
    self.evolutionText = Instance.new("TextLabel")
    self.evolutionText.Size = UDim2.new(1, 0, 0, 80)
    self.evolutionText.Position = UDim2.new(0, 0, 0.5, -40)
    self.evolutionText.Text = "🌟 EVOLUTION! 🌟"
    self.evolutionText.Font = Enum.Font.GothamBold
    self.evolutionText.TextSize = 36
    self.evolutionText.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.evolutionText.BackgroundTransparency = 1
    self.evolutionText.Parent = self.evolutionPanel
end

function ShadowBattleUI:ShowLoadout()
    self.loadoutFrame.Visible = true
    self.battleHUD.Visible = false
end

function ShadowBattleUI:ShowBattle()
    self.loadoutFrame.Visible = false
    self.battleHUD.Visible = true
end

function ShadowBattleUI:UpdateShadowInfo(shadow)
    if shadow then
        self.shadowNameLabel.Text = "🌟 " .. (shadow.EvolutionStage or shadow.Name)
        
        -- Update health bar
        local healthPercent = shadow.Health / shadow.MaxHealth
        self.healthBar.Bar.Size = UDim2.new(healthPercent, 0, 1, 0)
        
        -- Update XP bar
        local xpForNextLevel = shadow.Level * 100
        local xpPercent = (shadow.XP or 0) / xpForNextLevel
        self.xpBar.Bar.Size = UDim2.new(xpPercent, 0, 1, 0)
    end
end

function ShadowBattleUI:PlayEvolutionAnimation(shadowName, newStage)
    self.evolutionPanel.Visible = true
    self.evolutionText.Text = shadowName .. " evolved to " .. newStage .. "!"
    
    -- Evolution animation
    local flashTween = TweenService:Create(
        self.evolutionPanel.UIStroke,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 3, true),
        {Transparency = 0.3}
    )
    flashTween:Play()
    
    -- Hide after 3 seconds
    wait(3)
    self.evolutionPanel.Visible = false
end

function ShadowBattleUI:StartBattle()
    print("🌟 Starting Shadow Battle!")
    self:ShowBattle()
    
    -- TODO: Connect to game mode system
end

function ShadowBattleUI:AttemptEvolution()
    print("🌟 Attempting evolution...")
    
    -- TODO: Connect to shadow system
    -- local ShadowSystem = require(...)
    -- ShadowSystem:EvolvePiece(selectedShadow)
end

return ShadowBattleUI