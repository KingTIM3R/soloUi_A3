--[[
    Button component for SystemUI
    
    Represents a clickable button with hover effects and callback functionality.
]]

local TweenService = game:GetService("TweenService")

local Button = {}
Button.__index = Button

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingStyle.Out)

function Button.new(config)
    local self = setmetatable({}, Button)
    
    -- Default configuration
    self.Parent = config.Parent
    self.Theme = config.Theme
    self.Title = config.Title or "Button"
    self.Description = config.Description
    self.Callback = config.Callback or function() end
    self.LayoutOrder = config.LayoutOrder or 0
    self.Icon = config.Icon
    
    -- Create button
    self:Create()
    
    return self
end

function Button:Create()
    -- Main button container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Button_" .. self.Title
    self.Container.Size = UDim2.new(1, 0, 0, self.Description and 60 or 40)
    self.Container.BackgroundColor3 = self.Theme:GetColor("ElementBackground")
    self.Container.BorderSizePixel = 0
    self.Container.LayoutOrder = self.LayoutOrder
    self.Container.Parent = self.Parent
    
    -- Rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = self.Container
    
    -- Button
    self.ButtonFrame = Instance.new("TextButton")
    self.ButtonFrame.Name = "Button"
    self.ButtonFrame.Size = UDim2.new(1, 0, 1, 0)
    self.ButtonFrame.BackgroundTransparency = 1
    self.ButtonFrame.Text = ""
    self.ButtonFrame.AutoButtonColor = false
    self.ButtonFrame.Parent = self.Container
    
    -- Icon (if provided)
    if self.Icon then
        self.IconLabel = Instance.new("ImageLabel")
        self.IconLabel.Name = "Icon"
        self.IconLabel.Size = UDim2.new(0, 20, 0, 20)
        self.IconLabel.Position = UDim2.new(0, 10, 0, 10)
        self.IconLabel.BackgroundTransparency = 1
        self.IconLabel.Image = self.Icon
        self.IconLabel.ImageColor3 = self.Theme:GetColor("Text")
        self.IconLabel.Parent = self.Container
    end
    
    -- Title
    self.TitleLabel = Instance.new("TextLabel")
    self.TitleLabel.Name = "Title"
    self.TitleLabel.Size = UDim2.new(1, (self.Icon and -40 or -20), 0, self.Description and 25 or 40)
    self.TitleLabel.Position = UDim2.new(0, (self.Icon and 40 or 10), 0, 0)
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
        self.DescriptionLabel.Size = UDim2.new(1, -20, 0, 25)
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
    
    -- Setup button events
    self:SetupEvents()
    
    return self.Container
end

function Button:SetupEvents()
    -- Hover effect
    self.ButtonFrame.MouseEnter:Connect(function()
        TweenService:Create(
            self.Container, 
            TWEEN_INFO, 
            {BackgroundColor3 = self.Theme:GetColor("ElementBackgroundHover")}
        ):Play()
    end)
    
    self.ButtonFrame.MouseLeave:Connect(function()
        TweenService:Create(
            self.Container, 
            TWEEN_INFO, 
            {BackgroundColor3 = self.Theme:GetColor("ElementBackground")}
        ):Play()
    end)
    
    -- Click effect
    self.ButtonFrame.MouseButton1Down:Connect(function()
        TweenService:Create(
            self.Container, 
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), 
            {BackgroundColor3 = self.Theme:GetColor("ElementBackgroundClick")}
        ):Play()
    end)
    
    self.ButtonFrame.MouseButton1Up:Connect(function()
        TweenService:Create(
            self.Container, 
            TWEEN_INFO, 
            {BackgroundColor3 = self.Theme:GetColor("ElementBackgroundHover")}
        ):Play()
    end)
    
    -- Callback
    self.ButtonFrame.MouseButton1Click:Connect(function()
        self.Callback()
    end)
end

-- Update button title
function Button:SetTitle(title)
    self.Title = title
    self.TitleLabel.Text = title
end

-- Update button description
function Button:SetDescription(description)
    self.Description = description
    
    if self.DescriptionLabel then
        self.DescriptionLabel.Text = description
    else
        -- Create description if it didn't exist before
        self.Container.Size = UDim2.new(1, 0, 0, 60)
        
        self.DescriptionLabel = Instance.new("TextLabel")
        self.DescriptionLabel.Name = "Description"
        self.DescriptionLabel.Size = UDim2.new(1, -20, 0, 25)
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

-- Update button callback
function Button:SetCallback(callback)
    self.Callback = callback or function() end
end

-- Destroy button
function Button:Destroy()
    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end
end

return Button
