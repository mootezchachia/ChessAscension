-- src/Game/UI/AbilityButton.lua
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local AbilityButton = {}
AbilityButton.__index = AbilityButton

function AbilityButton.new(parent, abilityName, cooldownTime)
    local self = setmetatable({}, AbilityButton)
    
    self.abilityName = abilityName or "Ability"
    self.cooldownTime = cooldownTime or 5
    self.isOnCooldown = false
    
    self:CreateButton(parent)
    self:SetupEvents()
    
    return self
end

function AbilityButton:CreateButton(parent)
    -- Main button frame
    self.button = Instance.new("TextButton")
    self.button.Name = self.abilityName .. "Button"
    self.button.Size = UDim2.new(0, 120, 0, 40)
    self.button.Text = self.abilityName
    self.button.Font = Enum.Font.GothamBold
    self.button.TextSize = 14
    self.button.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.button.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    self.button.BorderSizePixel = 0
    self.button.Parent = parent
    
    -- Styling
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = self.button
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 150, 255)
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = self.button
    
    -- Cooldown overlay
    self.cooldownOverlay = Instance.new("Frame")
    self.cooldownOverlay.Name = "CooldownOverlay"
    self.cooldownOverlay.Size = UDim2.new(1, 0, 1, 0)
    self.cooldownOverlay.Position = UDim2.new(0, 0, 0, 0)
    self.cooldownOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    self.cooldownOverlay.BackgroundTransparency = 0.6
    self.cooldownOverlay.BorderSizePixel = 0
    self.cooldownOverlay.Visible = false
    self.cooldownOverlay.Parent = self.button
    
    local overlayCorner = Instance.new("UICorner")
    overlayCorner.CornerRadius = UDim.new(0, 6)
    overlayCorner.Parent = self.cooldownOverlay
    
    -- Cooldown progress bar
    self.progressBar = Instance.new("Frame")
    self.progressBar.Name = "ProgressBar"
    self.progressBar.Size = UDim2.new(1, 0, 0, 3)
    self.progressBar.Position = UDim2.new(0, 0, 1, -3)
    self.progressBar.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    self.progressBar.BorderSizePixel = 0
    self.progressBar.Visible = false
    self.progressBar.Parent = self.button
    
    -- Cooldown text
    self.cooldownText = Instance.new("TextLabel")
    self.cooldownText.Name = "CooldownText"
    self.cooldownText.Size = UDim2.new(1, 0, 1, 0)
    self.cooldownText.Position = UDim2.new(0, 0, 0, 0)
    self.cooldownText.Text = ""
    self.cooldownText.Font = Enum.Font.GothamBold
    self.cooldownText.TextSize = 16
    self.cooldownText.TextColor3 = Color3.fromRGB(255, 150, 150)
    self.cooldownText.BackgroundTransparency = 1
    self.cooldownText.Parent = self.cooldownOverlay
end

function AbilityButton:SetupEvents()
    -- Hover effects
    self.button.MouseEnter:Connect(function()
        if not self.isOnCooldown then
            self:AnimateHover(true)
        end
    end)
    
    self.button.MouseLeave:Connect(function()
        if not self.isOnCooldown then
            self:AnimateHover(false)
        end
    end)
    
    -- Click handler
    self.button.MouseButton1Click:Connect(function()
        if not self.isOnCooldown then
            self:OnClick()
        end
    end)
end

function AbilityButton:AnimateHover(isHovering)
    local targetColor = isHovering and Color3.fromRGB(70, 70, 110) or Color3.fromRGB(50, 50, 80)
    local targetStroke = isHovering and 0.2 or 0.5
    
    local colorTween = TweenService:Create(
        self.button,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = targetColor}
    )
    
    local strokeTween = TweenService:Create(
        self.button.UIStroke,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Transparency = targetStroke}
    )
    
    colorTween:Play()
    strokeTween:Play()
end

function AbilityButton:OnClick()
    print(self.abilityName .. " ability used!")
    
    -- Start cooldown
    self:StartCooldown()
    
    -- Trigger ability use event
    if self.OnAbilityUse then
        self.OnAbilityUse()
    end
end

function AbilityButton:StartCooldown()
    self.isOnCooldown = true
    self.cooldownOverlay.Visible = true
    self.progressBar.Visible = true
    self.button.Text = ""
    
    local startTime = tick()
    local connection
    
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = tick() - startTime
        local remaining = self.cooldownTime - elapsed
        local progress = elapsed / self.cooldownTime
        
        if remaining <= 0 then
            -- Cooldown finished
            self:EndCooldown()
            connection:Disconnect()
        else
            -- Update display
            self.cooldownText.Text = string.format("%.1f", remaining)
            
            -- Update progress bar
            local progressSize = UDim2.new(1 - progress, 0, 0, 3)
            self.progressBar.Size = progressSize
        end
    end)
end

function AbilityButton:EndCooldown()
    self.isOnCooldown = false
    self.cooldownOverlay.Visible = false
    self.progressBar.Visible = false
    self.button.Text = self.abilityName
    self.cooldownText.Text = ""
    
    -- Ready animation
    local readyTween = TweenService:Create(
        self.button.UIStroke,
        TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
        {Color = Color3.fromRGB(100, 255, 100)}
    )
    readyTween:Play()
    
    -- Reset stroke color after animation
    wait(0.5)
    local resetTween = TweenService:Create(
        self.button.UIStroke,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Color = Color3.fromRGB(100, 150, 255)}
    )
    resetTween:Play()
end

function AbilityButton:SetPosition(position)
    self.button.Position = position
end

function AbilityButton:SetCallback(callback)
    self.OnAbilityUse = callback
end

function AbilityButton:Destroy()
    if self.button then
        self.button:Destroy()
    end
end

return AbilityButton