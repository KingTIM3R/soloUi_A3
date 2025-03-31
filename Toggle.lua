--[[
    Toggle component for SystemUI
    
    Represents a toggleable switch with on/off states and callback functionality.
]]

local TweenService = game:GetService("TweenService")

local Toggle = {}
Toggle.__index = Toggle

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingStyle.Out)

function Toggle.new(config)
    local self = setmetatable({}, Toggle)
    
    -- Default configuration
    self.Parent = config.Parent
    self.Theme = config.Theme
    self.Title = config.Title or "Toggle"
    self.Description = config.Description
    self.Default = config.Default or false
    self.Callback = config.Callback or function() end
    self.LayoutOrder = config.LayoutOrder or 0
    self.Value = self.Default
    
    -- Create toggle
    self:Create()
    
    return self
end

function Toggle:Create()
    -- Main toggle container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Toggle_" .. self.Title
    self.Container.Size = UDim2.new(1, 0, 0, self.Description and 60 or 40)
    self.Container.BackgroundColor3 = self.Theme:GetColor("ElementBackground")
    self.Container.BorderSizePixel = 0
    self.Container.LayoutOrder = self.LayoutOrder
    self.Container.Parent = self.Parent
    
    -- Rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = self.Container
    
    -- Button for interaction
    self.Button = Instance.new("TextButton")
    self.Button.Name = "Button"
    self.Button.Size = UDim2.new(1, 0, 1, 0)
    self.Button.BackgroundTransparency = 1
    self.Button.Text = ""
    self.Button.AutoButtonColor = false
    self.Button.Parent = self.Container
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -80, 0, self.Description and 25 or 40)
    self.TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextSize = 14
    self.TitleLabel.TextColor3 = self.Theme:GetColor("Text")
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Text = self.Title
    self.TitleLabel.Parent = self.Container
    
    -- Description (if provided)
    if self.Description then
        self.DescriptionLabel = Instance.new("TextLabel")
        self.DescriptionLabel.Name = "Description"
        self.DescriptionLabel.Size = UDim2.new(1, -80, 0, 25)
        self.DescriptionLabel.Position = UDim2.new(0, 10, 0, 30)
        self.DescriptionLabel.BackgroundTransparency = 1
        self.DescriptionLabel.Font = Enum.Font.Gotham
        self.DescriptionLabel.TextSize = 12
        self.DescriptionLabel.TextColor3 = self.Theme:GetColor("SubText")
        self.DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescriptionLabel.TextWrapped = true
        self.DescriptionLabel.Text = self.Description
        self.DescriptionLabel.Parent = self.Container
    end
    
    -- Toggle background
    self.ToggleBackground = Instance.new("Frame")
    self.ToggleBackground.Name = "ToggleBackground"
    self.ToggleBackground.Size = UDim2.new(0, 40, 0, 20)
    self.ToggleBackground.Position = UDim2.new(1, -50, 0.5, -10)
    self.ToggleBackground.BackgroundColor3 = self.Value and 
        self.Theme:GetColor("ToggleEnabled") or 
        self.Theme:GetColor("ToggleDisabled")
    self.ToggleBackground.BorderSizePixel = 0
    self.ToggleBackground.Parent = self.Container
    
    -- Rounded corners for toggle background
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = self.ToggleBackground
    
    -- Toggle indicator
    self.ToggleIndicator = Instance.new("Frame")
    self.ToggleIndicator.Name = "Indicator"
    self.ToggleIndicator.Size = UDim2.new(0, 16, 0, 16)
    self.ToggleIndicator.Position = UDim2.new(0, self.Value and 22 or 2, 0.5, -8)
    self.ToggleIndicator.BackgroundColor3 = self.Theme:GetColor("ToggleIndicator")
    self.ToggleIndicator.BorderSizePixel = 0
    self.ToggleIndicator.Parent = self.ToggleBackground
    
    -- Rounded corners for toggle indicator
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 8)
    indicatorCorner.Parent = self.ToggleIndicator
    
    -- Setup events
    self:SetupEvents()
    
    return self.Container
end

function Toggle:SetupEvents()
    -- Hover effect
    self.Button.MouseEnter:Connect(function()
        TweenService:Create(
            self.Container, 
            TWEEN_INFO, 
            {BackgroundColor3 = self.Theme:GetColor("ElementBackgroundHover")}
        ):Play()
    end)
    
    self.Button.MouseLeave:Connect(function()
        TweenService:Create(
            self.Container, 
            TWEEN_INFO, 
            {BackgroundColor3 = self.Theme:GetColor("ElementBackground")}
        ):Play()
    end)
    
    -- Toggle effect
    self.Button.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
end

-- Toggle the switch
function Toggle:Toggle()
    self.Value = not self.Value
    
    -- Update visuals
    TweenService:Create(
        self.ToggleBackground, 
        TWEEN_INFO, 
        {BackgroundColor3 = self.Value and 
            self.Theme:GetColor("ToggleEnabled") or 
            self.Theme:GetColor("ToggleDisabled")}
    ):Play()
    
    TweenService:Create(
        self.ToggleIndicator, 
        TWEEN_INFO, 
        {Position = UDim2.new(0, self.Value and 22 or 2, 0.5, -8)}
    ):Play()
    
    -- Execute callback
    self.Callback(self.Value)
end

-- Set toggle state
function Toggle:SetValue(value)
    if self.Value == value then return end
    
    self.Value = value
    
    -- Update visuals without animation
    self.ToggleBackground.BackgroundColor3 = self.Value and 
        self.Theme:GetColor("ToggleEnabled") or 
        self.Theme:GetColor("ToggleDisabled")
    
    self.ToggleIndicator.Position = UDim2.new(0, self.Value and 22 or 2, 0.5, -8)
    
    -- Execute callback
    self.Callback(self.Value)
end

-- Get current value
function Toggle:GetValue()
    return self.Value
end

-- Update toggle title
function Toggle:SetTitle(title)
    self.Title = title
    self.TitleLabel.Text = title
end

-- Update toggle description
function Toggle:SetDescription(description)
    self.Description = description
    
    if self.DescriptionLabel then
        self.DescriptionLabel.Text = description
    else
        -- Create description if it didn't exist before
        self.Container.Size = UDim2.new(1, 0, 0, 60)
        
        self.DescriptionLabel = Instance.new("TextLabel")
        self.DescriptionLabel.Name = "Description"
        self.DescriptionLabel.Size = UDim2.new(1, -80, 0, 25)
        self.DescriptionLabel.Position = UDim2.new(0, 10, 0, 30)
        self.DescriptionLabel.BackgroundTransparency = 1
        self.DescriptionLabel.Font = Enum.Font.Gotham
        self.DescriptionLabel.TextSize = 12
        self.DescriptionLabel.TextColor3 = self.Theme:GetColor("SubText")
        self.DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescriptionLabel.TextWrapped = true
        self.DescriptionLabel.Text = description
        self.DescriptionLabel.Parent = self.Container
    end
end

-- Update toggle callback
function Toggle:SetCallback(callback)
    self.Callback = callback or function() end
end

-- Destroy toggle
function Toggle:Destroy()
    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end
end

return Toggle
