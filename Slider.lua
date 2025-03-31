--[[
    Slider component for SystemUI
    
    Represents a slider for selecting numerical values within a range.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Slider = {}
Slider.__index = Slider

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingStyle.Out)

function Slider.new(config)
    local self = setmetatable({}, Slider)
    
    -- Default configuration
    self.Parent = config.Parent
    self.Theme = config.Theme
    self.Title = config.Title or "Slider"
    self.Description = config.Description
    self.Min = config.Min or 0
    self.Max = config.Max or 100
    self.Default = math.clamp(config.Default or self.Min, self.Min, self.Max)
    self.Increment = config.Increment or 1
    self.Suffix = config.Suffix or ""
    self.Callback = config.Callback or function() end
    self.LayoutOrder = config.LayoutOrder or 0
    self.Value = self.Default
    
    -- Calculate default position
    self.Percent = (self.Value - self.Min) / (self.Max - self.Min)
    
    -- Create slider
    self:Create()
    
    return self
end

function Slider:Create()
    -- Main slider container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Slider_" .. self.Title
    self.Container.Size = UDim2.new(1, 0, 0, self.Description and 80 or 60)
    self.Container.BackgroundColor3 = self.Theme:GetColor("ElementBackground")
    self.Container.BorderSizePixel = 0
    self.Container.LayoutOrder = self.LayoutOrder
    self.Container.Parent = self.Parent
    
    -- Rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = self.Container
    
    -- Interaction button
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
    self.TitleLabel.Size = UDim2.new(1, -20, 0, 20)
    self.TitleLabel.Position = UDim2.new(0, 10, 0, 5)
    self.TitleLabel.BackgroundTransparency = 1
    self.TitleLabel.Font = Enum.Font.GothamBold
    self.TitleLabel.TextSize = 14
    self.TitleLabel.TextColor3 = self.Theme:GetColor("Text")
    self.TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleLabel.Text = self.Title
    self.TitleLabel.Parent = self.Container
    
    -- Value display
    self.ValueLabel = Instance.new("TextLabel")
    self.ValueLabel.Name = "Value"
    self.ValueLabel.Size = UDim2.new(0, 60, 0, 20)
    self.ValueLabel.Position = UDim2.new(1, -70, 0, 5)
    self.ValueLabel.BackgroundTransparency = 1
    self.ValueLabel.Font = Enum.Font.GothamBold
    self.ValueLabel.TextSize = 14
    self.ValueLabel.TextColor3 = self.Theme:GetColor("Text")
    self.ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.ValueLabel.Text = tostring(self.Value) .. self.Suffix
    self.ValueLabel.Parent = self.Container
    
    -- Description (if provided)
    if self.Description then
        self.DescriptionLabel = Instance.new("TextLabel")
        self.DescriptionLabel.Name = "Description"
        self.DescriptionLabel.Size = UDim2.new(1, -20, 0, 20)
        self.DescriptionLabel.Position = UDim2.new(0, 10, 0, 25)
        self.DescriptionLabel.BackgroundTransparency = 1
        self.DescriptionLabel.Font = Enum.Font.Gotham
        self.DescriptionLabel.TextSize = 12
        self.DescriptionLabel.TextColor3 = self.Theme:GetColor("SubText")
        self.DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescriptionLabel.TextWrapped = true
        self.DescriptionLabel.Text = self.Description
        self.DescriptionLabel.Parent = self.Container
        
        -- Adjust slider position if description is present
        self.SliderY = 50
    else
        self.SliderY = 30
    end
    
    -- Slider background
    self.SliderBackground = Instance.new("Frame")
    self.SliderBackground.Name = "SliderBackground"
    self.SliderBackground.Size = UDim2.new(1, -20, 0, 8)
    self.SliderBackground.Position = UDim2.new(0, 10, 0, self.SliderY)
    self.SliderBackground.BackgroundColor3 = self.Theme:GetColor("SliderBackground")
    self.SliderBackground.BorderSizePixel = 0
    self.SliderBackground.Parent = self.Container
    
    -- Rounded corners for slider background
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = self.SliderBackground
    
    -- Slider fill
    self.SliderFill = Instance.new("Frame")
    self.SliderFill.Name = "SliderFill"
    self.SliderFill.Size = UDim2.new(self.Percent, 0, 1, 0)
    self.SliderFill.BackgroundColor3 = self.Theme:GetColor("Accent")
    self.SliderFill.BorderSizePixel = 0
    self.SliderFill.Parent = self.SliderBackground
    
    -- Rounded corners for slider fill
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = self.SliderFill
    
    -- Slider indicator
    self.SliderIndicator = Instance.new("Frame")
    self.SliderIndicator.Name = "SliderIndicator"
    self.SliderIndicator.Size = UDim2.new(0, 16, 0, 16)
    self.SliderIndicator.Position = UDim2.new(self.Percent, -8, 0.5, -8)
    self.SliderIndicator.BackgroundColor3 = self.Theme:GetColor("SliderIndicator")
    self.SliderIndicator.BorderSizePixel = 0
    self.SliderIndicator.ZIndex = 2
    self.SliderIndicator.Parent = self.SliderBackground
    
    -- Rounded corners for slider indicator
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 8)
    indicatorCorner.Parent = self.SliderIndicator
    
    -- Min label
    self.MinLabel = Instance.new("TextLabel")
    self.MinLabel.Name = "MinLabel"
    self.MinLabel.Size = UDim2.new(0, 40, 0, 16)
    self.MinLabel.Position = UDim2.new(0, 5, 0, self.SliderY + 13)
    self.MinLabel.BackgroundTransparency = 1
    self.MinLabel.Font = Enum.Font.Gotham
    self.MinLabel.TextSize = 10
    self.MinLabel.TextColor3 = self.Theme:GetColor("SubText")
    self.MinLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.MinLabel.Text = tostring(self.Min) .. self.Suffix
    self.MinLabel.Parent = self.Container
    
    -- Max label
    self.MaxLabel = Instance.new("TextLabel")
    self.MaxLabel.Name = "MaxLabel"
    self.MaxLabel.Size = UDim2.new(0, 40, 0, 16)
    self.MaxLabel.Position = UDim2.new(1, -45, 0, self.SliderY + 13)
    self.MaxLabel.BackgroundTransparency = 1
    self.MaxLabel.Font = Enum.Font.Gotham
    self.MaxLabel.TextSize = 10
    self.MaxLabel.TextColor3 = self.Theme:GetColor("SubText")
    self.MaxLabel.TextXAlignment = Enum.TextXAlignment.Right
    self.MaxLabel.Text = tostring(self.Max) .. self.Suffix
    self.MaxLabel.Parent = self.Container
    
    -- Setup events
    self:SetupEvents()
    
    return self.Container
end

function Slider:SetupEvents()
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
    
    -- Slider interaction
    local isDragging = false
    
    self.Button.MouseButton1Down:Connect(function()
        isDragging = true
        self:UpdateSlider(self.Button)
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    self.Button.MouseMoved:Connect(function()
        if isDragging then
            self:UpdateSlider(self.Button)
        end
    end)
end

-- Update slider position and value
function Slider:UpdateSlider(button)
    local mousePos = UserInputService:GetMouseLocation().X
    local sliderPos = self.SliderBackground.AbsolutePosition.X
    local sliderSize = self.SliderBackground.AbsoluteSize.X
    
    -- Calculate percentage
    local percent = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
    
    -- Calculate value based on percentage
    local exactValue = self.Min + ((self.Max - self.Min) * percent)
    
    -- Apply increment if specified
    if self.Increment > 0 then
        exactValue = math.floor(exactValue / self.Increment + 0.5) * self.Increment
    end
    
    -- Update value
    self:SetValue(exactValue)
end

-- Set slider value
function Slider:SetValue(value)
    -- Clamp value within range
    self.Value = math.clamp(value, self.Min, self.Max)
    
    -- Calculate percentage
    self.Percent = (self.Value - self.Min) / (self.Max - self.Min)
    
    -- Update UI
    self.SliderFill.Size = UDim2.new(self.Percent, 0, 1, 0)
    self.SliderIndicator.Position = UDim2.new(self.Percent, -8, 0.5, -8)
    self.ValueLabel.Text = tostring(math.floor(self.Value * 100) / 100) .. self.Suffix
    
    -- Execute callback
    self.Callback(self.Value)
end

-- Get current value
function Slider:GetValue()
    return self.Value
end

-- Update slider title
function Slider:SetTitle(title)
    self.Title = title
    self.TitleLabel.Text = title
end

-- Update slider description
function Slider:SetDescription(description)
    self.Description = description
    
    if self.DescriptionLabel then
        self.DescriptionLabel.Text = description
    else
        -- Create description if it didn't exist before
        self.Container.Size = UDim2.new(1, 0, 0, 80)
        
        self.DescriptionLabel = Instance.new("TextLabel")
        self.DescriptionLabel.Name = "Description"
        self.DescriptionLabel.Size = UDim2.new(1, -20, 0, 20)
        self.DescriptionLabel.Position = UDim2.new(0, 10, 0, 25)
        self.DescriptionLabel.BackgroundTransparency = 1
        self.DescriptionLabel.Font = Enum.Font.Gotham
        self.DescriptionLabel.TextSize = 12
        self.DescriptionLabel.TextColor3 = self.Theme:GetColor("SubText")
        self.DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        self.DescriptionLabel.TextWrapped = true
        self.DescriptionLabel.Text = description
        self.DescriptionLabel.Parent = self.Container
        
        -- Adjust slider position
        self.SliderY = 50
        self.SliderBackground.Position = UDim2.new(0, 10, 0, self.SliderY)
        self.MinLabel.Position = UDim2.new(0, 5, 0, self.SliderY + 13)
        self.MaxLabel.Position = UDim2.new(1, -45, 0, self.SliderY + 13)
    end
end

-- Update slider range
function Slider:SetRange(min, max)
    self.Min = min
    self.Max = max
    self.MinLabel.Text = tostring(min) .. self.Suffix
    self.MaxLabel.Text = tostring(max) .. self.Suffix
    
    -- Update value to stay within new range
    self:SetValue(math.clamp(self.Value, min, max))
end

-- Update slider callback
function Slider:SetCallback(callback)
    self.Callback = callback or function() end
end

-- Destroy slider
function Slider:Destroy()
    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end
end

return Slider
