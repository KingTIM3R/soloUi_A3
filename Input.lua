--[[
    Input component for SystemUI
    
    Represents a text input field for collecting user input.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Input = {}
Input.__index = Input

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingStyle.Out)

function Input.new(config)
    local self = setmetatable({}, Input)
    
    -- Default configuration
    self.Parent = config.Parent
    self.Theme = config.Theme
    self.Title = config.Title or "Input"
    self.Description = config.Description
    self.Placeholder = config.Placeholder or "Enter text..."
    self.Default = config.Default or ""
    self.Callback = config.Callback or function() end
    self.LayoutOrder = config.LayoutOrder or 0
    self.ClearOnFocus = config.ClearOnFocus or false
    self.MultiLine = config.MultiLine or false
    self.NumbersOnly = config.NumbersOnly or false
    self.MaxLength = config.MaxLength or 0
    
    -- Current value
    self.Value = self.Default
    
    -- Create input
    self:Create()
    
    return self
end

function Input:Create()
    -- Main input container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Input_" .. self.Title
    self.Container.Size = UDim2.new(1, 0, 0, self.Description and 80 or 60)
    self.Container.BackgroundColor3 = self.Theme:GetColor("ElementBackground")
    self.Container.BorderSizePixel = 0
    self.Container.LayoutOrder = self.LayoutOrder
    self.Container.Parent = self.Parent
    
    -- Rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = self.Container
    
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
        
        -- Adjust input position if description is present
        self.InputY = 50
    else
        self.InputY = 30
    end
    
    -- Input background
    self.InputBackground = Instance.new("Frame")
    self.InputBackground.Name = "InputBackground"
    self.InputBackground.Size = UDim2.new(1, -20, 0, 30)
    self.InputBackground.Position = UDim2.new(0, 10, 0, self.InputY)
    self.InputBackground.BackgroundColor3 = self.Theme:GetColor("InputBackground")
    self.InputBackground.BorderSizePixel = 0
    self.InputBackground.Parent = self.Container
    
    -- Rounded corners for input background
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = self.InputBackground
    
    -- Input text box
    self.InputBox = Instance.new(self.MultiLine and "TextBox" or "TextBox")
    self.InputBox.Name = "InputBox"
    self.InputBox.Size = UDim2.new(1, -10, 1, 0)
    self.InputBox.Position = UDim2.new(0, 5, 0, 0)
    self.InputBox.BackgroundTransparency = 1
    self.InputBox.ClearTextOnFocus = self.ClearOnFocus
    self.InputBox.Font = Enum.Font.Gotham
    self.InputBox.TextSize = 14
    self.InputBox.TextColor3 = self.Theme:GetColor("Text")
    self.InputBox.TextXAlignment = Enum.TextXAlignment.Left
    self.InputBox.PlaceholderText = self.Placeholder
    self.InputBox.PlaceholderColor3 = self.Theme:GetColor("SubText")
    self.InputBox.Text = self.Value
    
    -- If multi-line, adjust properties
    if self.MultiLine then
        self.InputBox.MultiLine = true
        self.InputBox.TextWrapped = true
        self.InputBox.TextYAlignment = Enum.TextYAlignment.Top
    end
    
    self.InputBox.Parent = self.InputBackground
    
    -- Setup events
    self:SetupEvents()
    
    return self.Container
end

function Input:SetupEvents()
    -- Hover effect
    self.InputBox.MouseEnter:Connect(function()
        TweenService:Create(
            self.InputBackground, 
            TWEEN_INFO, 
            {BackgroundColor3 = self.Theme:GetColor("InputBackgroundHover")}
        ):Play()
    end)
    
    self.InputBox.MouseLeave:Connect(function()
        if self.InputBox:IsFocused() then return end
        
        TweenService:Create(
            self.InputBackground, 
            TWEEN_INFO, 
            {BackgroundColor3 = self.Theme:GetColor("InputBackground")}
        ):Play()
    end)
    
    -- Focus effect
    self.InputBox.Focused:Connect(function()
        TweenService:Create(
            self.InputBackground, 
            TWEEN_INFO, 
            {BackgroundColor3 = self.Theme:GetColor("InputBackgroundFocus")}
        ):Play()
    end)
    
    self.InputBox.FocusLost:Connect(function(enterPressed)
        TweenService:Create(
            self.InputBackground, 
            TWEEN_INFO, 
            {BackgroundColor3 = self.Theme:GetColor("InputBackground")}
        ):Play()
        
        -- Update value
        self.Value = self.InputBox.Text
        
        -- Execute callback
        self.Callback(self.Value, enterPressed)
    end)
    
    -- Text changed validation
    self.InputBox:GetPropertyChangedSignal("Text"):Connect(function()
        local newText = self.InputBox.Text
        
        -- Apply number-only filter if needed
        if self.NumbersOnly then
            -- Remove non-numeric characters (except for decimal point and negative sign)
            newText = newText:gsub("[^%d%-%.]+", "")
            
            -- Ensure only one decimal point
            local decimalCount = 0
            for i = 1, #newText do
                if newText:sub(i, i) == "." then
                    decimalCount = decimalCount + 1
                    if decimalCount > 1 then
                        newText = newText:sub(1, i-1) .. newText:sub(i+1)
                        break
                    end
                end
            end
            
            -- Ensure only one negative sign at the beginning
            if newText:sub(1, 1) ~= "-" and newText:find("%-") then
                newText = newText:gsub("%-", "")
            elseif newText:sub(1, 1) == "-" and newText:sub(2):find("%-") then
                newText = "-" .. newText:sub(2):gsub("%-", "")
            end
        end
        
        -- Apply max length if needed
        if self.MaxLength > 0 and utf8.len(newText) > self.MaxLength then
            newText = utf8.sub(newText, 1, self.MaxLength)
        end
        
        -- Update text only if it was modified by validation
        if newText ~= self.InputBox.Text then
            self.InputBox.Text = newText
        end
    end)
end

-- Set input value
function Input:SetValue(value)
    self.Value = value
    self.InputBox.Text = value
end

-- Get current value
function Input:GetValue()
    return self.Value
end

-- Update input title
function Input:SetTitle(title)
    self.Title = title
    self.TitleLabel.Text = title
end

-- Update input description
function Input:SetDescription(description)
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
        
        -- Adjust input position
        self.InputY = 50
        self.InputBackground.Position = UDim2.new(0, 10, 0, self.InputY)
    end
end

-- Update input placeholder
function Input:SetPlaceholder(placeholder)
    self.Placeholder = placeholder
    self.InputBox.PlaceholderText = placeholder
end

-- Update input callback
function Input:SetCallback(callback)
    self.Callback = callback or function() end
end

-- Clear input
function Input:Clear()
    self.Value = ""
    self.InputBox.Text = ""
end

-- Destroy input
function Input:Destroy()
    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end
end

return Input
