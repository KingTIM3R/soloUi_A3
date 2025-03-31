--[[
    Notification component for SystemUI
    
    Represents a notification that appears temporarily to provide feedback to the user.
]]

local TweenService = game:GetService("TweenService")

local Notification = {}
Notification.__index = Notification

-- Constants
local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingStyle.Out)

function Notification.new(config)
    local self = setmetatable({}, Notification)
    
    -- Default configuration
    self.Parent = config.Parent
    self.Theme = config.Theme
    self.Title = config.Title or "Notification"
    self.Content = config.Content or ""
    self.Duration = config.Duration or 3
    self.Position = config.Position or UDim2.new(1, -320, 1, -110)
    self.Size = config.Size or UDim2.new(0, 300, 0, 100)
    self.Type = config.Type or "Info" -- Info, Success, Warning, Error
    
    -- Create notification
    self:Create()
    
    return self
end

function Notification:Create()
    -- Main notification container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Notification"
    self.Container.Size = self.Size
    self.Container.Position = self.Position
    self.Container.BackgroundColor3 = self.Theme:GetColor("NotificationBackground")
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = true
    self.Container.Parent = self.Parent
    
    -- Rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = self.Container
    
    -- Add subtle drop shadow
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = self.Theme:GetColor("Border")
    UIStroke.Thickness = 1
    UIStroke.Parent = self.Container
    
    -- Color indicator based on type
    self.TypeIndicator = Instance.new("Frame")
    self.TypeIndicator.Name = "TypeIndicator"
    self.TypeIndicator.Size = UDim2.new(0, 4, 1, 0)
    self.TypeIndicator.Position = UDim2.new(0, 0, 0, 0)
    self.TypeIndicator.BorderSizePixel = 0
    
    -- Set color based on type
    if self.Type == "Info" then
        self.TypeIndicator.BackgroundColor3 = Color3.fromRGB(91, 154, 255)
    elseif self.Type == "Success" then
        self.TypeIndicator.BackgroundColor3 = Color3.fromRGB(91, 255, 91)
    elseif self.Type == "Warning" then
        self.TypeIndicator.BackgroundColor3 = Color3.fromRGB(255, 223, 91)
    elseif self.Type == "Error" then
        self.TypeIndicator.BackgroundColor3 = Color3.fromRGB(255, 91, 91)
    end
    
    self.TypeIndicator.Parent = self.Container
    
    -- Icon based on type
    self.Icon = Instance.new("ImageLabel")
    self.Icon.Name = "Icon"
    self.Icon.Size = UDim2.new(0, 24, 0, 24)
    self.Icon.Position = UDim2.new(0, 14, 0, 10)
    self.Icon.BackgroundTransparency = 1
    
    -- Set icon based on type
    if self.Type == "Info" then
        self.Icon.Image = "rbxassetid://7733658133"
        self.Icon.ImageColor3 = Color3.fromRGB(91, 154, 255)
    elseif self.Type == "Success" then
        self.Icon.Image = "rbxassetid://7733715400"
        self.Icon.ImageColor3 = Color3.fromRGB(91, 255, 91)
    elseif self.Type == "Warning" then
        self.Icon.Image = "rbxassetid://7733658803"
        self.Icon.ImageColor3 = Color3.fromRGB(255, 223, 91)
    elseif self.Type == "Error" then
        self.Icon.Image = "rbxassetid://7733658803"
        self.Icon.ImageColor3 = Color3.fromRGB(255, 91, 91)
    end
    
    self.Icon.Parent = self.Container
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, -80, 0, 20)
    self.TitleLabel.Position = UDim2.new(0, 48, 0, 12)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextSize = 16
    self.TitleLabel.TextColor3 = self.Theme:GetColor("Text")
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Text = self.Title
    self.TitleLabel.Parent = self.Container
    
    -- Close button
    self.CloseButton = Instance.new("ImageButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 20, 0, 20)
    self.CloseButton.Position = UDim2.new(1, -30, 0, 12)
    self.CloseButton.BackgroundTransparency = 1
    self.CloseButton.Image = "rbxassetid://7733658504"
    self.CloseButton.ImageColor3 = self.Theme:GetColor("SubText")
    self.CloseButton.Parent = self.Container
    
    -- Content
    self.ContentLabel = Instance.new("TextLabel")
    self.ContentLabel.Name = "Content"
    self.ContentLabel.Size = UDim2.new(1, -60, 0, 0)
    self.ContentLabel.Position = UDim2.new(0, 48, 0, 40)
    self.ContentLabel.BackgroundTransparency = 1
    self.ContentLabel.Font = Enum.Font.Gotham
    self.ContentLabel.TextSize = 14
    self.ContentLabel.TextColor3 = self.Theme:GetColor("SubText")
    self.ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
    self.ContentLabel.TextWrapped = true
    self.ContentLabel.Text = self.Content
    self.ContentLabel.AutomaticSize = Enum.AutomaticSize.Y
    self.ContentLabel.Parent = self.Container
    
    -- Progress bar
    self.ProgressBar = Instance.new("Frame")
    self.ProgressBar.Name = "ProgressBar"
    self.ProgressBar.Size = UDim2.new(1, 0, 0, 2)
    self.ProgressBar.Position = UDim2.new(0, 0, 1, -2)
    self.ProgressBar.BackgroundColor3 = self.TypeIndicator.BackgroundColor3
    self.ProgressBar.BorderSizePixel = 0
    self.ProgressBar.Parent = self.Container
    
    -- Setup animations and events
    self:SetupEvents()
    
    -- Start animations
    self:Show()
    
    return self.Container
end

function Notification:SetupEvents()
    -- Close on button click
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    
    -- Progress bar animation
    local progressTween = TweenService:Create(
        self.ProgressBar,
        TweenInfo.new(self.Duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 0, 2)}
    )
    progressTween:Play()
    
    -- Hide after duration
    task.delay(self.Duration, function()
        if self.Container and self.Container.Parent then
            self:Hide()
        end
    end)
    
    -- Hover effect
    self.Container.MouseEnter:Connect(function()
        TweenService:Create(
            self.Container,
            TWEEN_INFO,
            {BackgroundColor3 = self.Theme:GetColor("NotificationBackgroundHover")}
        ):Play()
    end)
    
    self.Container.MouseLeave:Connect(function()
        TweenService:Create(
            self.Container,
            TWEEN_INFO,
            {BackgroundColor3 = self.Theme:GetColor("NotificationBackground")}
        ):Play()
    end)
end

-- Show notification with animation
function Notification:Show()
    -- Start offscreen to the right
    self.Container.Position = UDim2.new(1, 0, self.Position.Y.Scale, self.Position.Y.Offset)
    
    -- Animate in
    local showTween = TweenService:Create(
        self.Container,
        TWEEN_INFO,
        {Position = self.Position}
    )
    showTween:Play()
end

-- Hide notification with animation
function Notification:Hide()
    -- Animate out
    local hideTween = TweenService:Create(
        self.Container,
        TWEEN_INFO,
        {Position = UDim2.new(1, 0, self.Position.Y.Scale, self.Position.Y.Offset)}
    )
    hideTween:Play()
    
    -- Destroy after animation
    hideTween.Completed:Connect(function()
        self:Destroy()
    end)
end

-- Destroy notification
function Notification:Destroy()
    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end
end

return Notification
