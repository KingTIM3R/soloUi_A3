--[[
    Dropdown component for SystemUI
    
    Represents a dropdown menu for selecting from a list of options.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Dropdown = {}
Dropdown.__index = Dropdown

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingStyle.Out)
local MAX_VISIBLE_ITEMS = 6

function Dropdown.new(config)
    local self = setmetatable({}, Dropdown)
    
    -- Default configuration
    self.Parent = config.Parent
    self.Theme = config.Theme
    self.Title = config.Title or "Dropdown"
    self.Description = config.Description
    self.Options = config.Options or {}
    self.Default = config.Default -- Can be string or number
    self.MultiSelect = config.MultiSelect or false
    self.Callback = config.Callback or function() end
    self.LayoutOrder = config.LayoutOrder or 0
    self.MaxVisibleItems = config.MaxVisibleItems or MAX_VISIBLE_ITEMS
    
    -- Current selection
    if self.MultiSelect then
        self.Selected = config.Default or {} -- Array of selected items
    else
        if config.Default and (type(config.Default) == "string" or type(config.Default) == "number") then
            self.Selected = config.Default
        else
            self.Selected = #self.Options > 0 and self.Options[1] or nil
        end
    end
    
    -- Open state
    self.IsOpen = false
    
    -- Create dropdown
    self:Create()
    
    return self
end

function Dropdown:Create()
    -- Main dropdown container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Dropdown_" .. self.Title
    self.Container.Size = UDim2.new(1, 0, 0, self.Description and 80 or 60)
    self.Container.BackgroundColor3 = self.Theme:GetColor("ElementBackground")
    self.Container.BorderSizePixel = 0
    self.Container.LayoutOrder = self.LayoutOrder
    self.Container.ClipsDescendants = true
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
        
        -- Adjust dropdown position if description is present
        self.DropdownY = 50
    else
        self.DropdownY = 30
    end
    
    -- Selection display
    self.DisplayFrame = Instance.new("Frame")
    self.DisplayFrame.Name = "Display"
    self.DisplayFrame.Size = UDim2.new(1, -20, 0, 30)
    self.DisplayFrame.Position = UDim2.new(0, 10, 0, self.DropdownY)
    self.DisplayFrame.BackgroundColor3 = self.Theme:GetColor("InputBackground")
    self.DisplayFrame.BorderSizePixel = 0
    self.DisplayFrame.Parent = self.Container
    
    -- Rounded corners for display frame
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 4)
    displayCorner.Parent = self.DisplayFrame
    
    -- Display text
    self.DisplayText = Instance.new("TextLabel")
    self.DisplayText.Name = "DisplayText"
    self.DisplayText.Size = UDim2.new(1, -30, 1, 0)
    self.DisplayText.Position = UDim2.new(0, 10, 0, 0)
    self.DisplayText.BackgroundTransparency = 1
    self.DisplayText.Font = Enum.Font.Gotham
    self.DisplayText.TextSize = 14
    self.DisplayText.TextColor3 = self.Theme:GetColor("Text")
    self.DisplayText.TextXAlignment = Enum.TextXAlignment.Left
    self.DisplayText.TextTruncate = Enum.TextTruncate.AtEnd
    self.DisplayText.Text = self:GetDisplayText()
    self.DisplayText.Parent = self.DisplayFrame
    
    -- Dropdown arrow
    self.Arrow = Instance.new("ImageLabel")
    self.Arrow.Name = "Arrow"
    self.Arrow.Size = UDim2.new(0, 16, 0, 16)
    self.Arrow.Position = UDim2.new(1, -20, 0.5, -8)
    self.Arrow.BackgroundTransparency = 1
    self.Arrow.Image = "rbxassetid://7072706663"
    self.Arrow.ImageColor3 = self.Theme:GetColor("Text")
    self.Arrow.Parent = self.DisplayFrame
    
    -- Dropdown button
    self.Button = Instance.new("TextButton")
    self.Button.Name = "Button"
    self.Button.Size = UDim2.new(1, 0, 1, 0)
    self.Button.BackgroundTransparency = 1
    self.Button.Text = ""
    self.Button.Parent = self.DisplayFrame
    
    -- Options container
    self.OptionsContainer = Instance.new("Frame")
    self.OptionsContainer.Name = "Options"
    self.OptionsContainer.Size = UDim2.new(1, -20, 0, 0) -- Will be resized when opened
    self.OptionsContainer.Position = UDim2.new(0, 10, 0, self.DropdownY + 35)
    self.OptionsContainer.BackgroundColor3 = self.Theme:GetColor("InputBackground")
    self.OptionsContainer.BorderSizePixel = 0
    self.OptionsContainer.Visible = false
    self.OptionsContainer.Parent = self.Container
    
    -- Rounded corners for options container
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 4)
    optionsCorner.Parent = self.OptionsContainer
    
    -- Options scrolling frame
    self.OptionsScrollFrame = Instance.new("ScrollingFrame")
    self.OptionsScrollFrame.Name = "OptionsScroll"
    self.OptionsScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    self.OptionsScrollFrame.BackgroundTransparency = 1
    self.OptionsScrollFrame.BorderSizePixel = 0
    self.OptionsScrollFrame.ScrollBarThickness = 2
    self.OptionsScrollFrame.ScrollBarImageColor3 = self.Theme:GetColor("ScrollBar")
    self.OptionsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.OptionsScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.OptionsScrollFrame.Parent = self.OptionsContainer
    
    -- Options list layout
    self.OptionsLayout = Instance.new("UIListLayout")
    self.OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    self.OptionsLayout.Padding = UDim.new(0, 1)
    self.OptionsLayout.Parent = self.OptionsScrollFrame
    
    -- Create option buttons
    self:CreateOptions()
    
    -- Setup events
    self:SetupEvents()
    
    return self.Container
end

-- Create option buttons
function Dropdown:CreateOptions()
    -- Clear existing options
    for _, child in pairs(self.OptionsScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Create new option buttons
    for i, option in ipairs(self.Options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Option_" .. tostring(i)
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.BackgroundColor3 = self.Theme:GetColor("InputBackground")
        optionButton.BackgroundTransparency = 0
        optionButton.BorderSizePixel = 0
        optionButton.AutoButtonColor = false
        optionButton.Font = Enum.Font.Gotham
        optionButton.TextSize = 14
        optionButton.TextColor3 = self.Theme:GetColor("Text")
        optionButton.Text = ""
        optionButton.LayoutOrder = i
        optionButton.Parent = self.OptionsScrollFrame
        
        -- Option text
        local optionText = Instance.new("TextLabel")
        optionText.Name = "OptionText"
        optionText.Size = UDim2.new(1, -20, 1, 0)
        optionText.Position = UDim2.new(0, 10, 0, 0)
        optionText.BackgroundTransparency = 1
        optionText.Font = Enum.Font.Gotham
        optionText.TextSize = 14
        optionText.TextColor3 = self.Theme:GetColor("Text")
        optionText.TextXAlignment = Enum.TextXAlignment.Left
        optionText.Text = tostring(option)
        optionText.Parent = optionButton
        
        -- If multiselect, add a checkbox
        if self.MultiSelect then
            local checkbox = Instance.new("Frame")
            checkbox.Name = "Checkbox"
            checkbox.Size = UDim2.new(0, 16, 0, 16)
            checkbox.Position = UDim2.new(1, -26, 0.5, -8)
            checkbox.BackgroundColor3 = self.Theme:GetColor("ToggleDisabled")
            checkbox.BorderSizePixel = 0
            checkbox.Parent = optionButton
            
            local checkboxCorner = Instance.new("UICorner")
            checkboxCorner.CornerRadius = UDim.new(0, 2)
            checkboxCorner.Parent = checkbox
            
            local checkmark = Instance.new("ImageLabel")
            checkmark.Name = "Checkmark"
            checkmark.Size = UDim2.new(0, 12, 0, 12)
            checkmark.Position = UDim2.new(0.5, -6, 0.5, -6)
            checkmark.BackgroundTransparency = 1
            checkmark.Image = "rbxassetid://7733715400"
            checkmark.ImageColor3 = self.Theme:GetColor("Text")
            checkmark.Visible = table.find(self.Selected, option) ~= nil
            checkmark.Parent = checkbox
            
            -- Update checkbox state based on selection
            if table.find(self.Selected, option) then
                checkbox.BackgroundColor3 = self.Theme:GetColor("Accent")
            end
        end
        
        -- Hover effect
        optionButton.MouseEnter:Connect(function()
            TweenService:Create(
                optionButton, 
                TWEEN_INFO, 
                {BackgroundColor3 = self.Theme:GetColor("ElementBackgroundHover")}
            ):Play()
        end)
        
        optionButton.MouseLeave:Connect(function()
            TweenService:Create(
                optionButton, 
                TWEEN_INFO, 
                {BackgroundColor3 = self.Theme:GetColor("InputBackground")}
            ):Play()
        end)
        
        -- Click effect
        optionButton.MouseButton1Click:Connect(function()
            self:SelectOption(option)
        end)
    end
end

-- Get display text based on selection
function Dropdown:GetDisplayText()
    if self.MultiSelect then
        if #self.Selected == 0 then
            return "Select..."
        elseif #self.Selected == 1 then
            return tostring(self.Selected[1])
        else
            return tostring(#self.Selected) .. " selected"
        end
    else
        return self.Selected and tostring(self.Selected) or "Select..."
    end
end

-- Select an option
function Dropdown:SelectOption(option)
    if self.MultiSelect then
        -- Find the option in the selected list
        local index = table.find(self.Selected, option)
        
        if index then
            -- Remove from selected list
            table.remove(self.Selected, index)
        else
            -- Add to selected list
            table.insert(self.Selected, option)
        end
        
        -- Update checkboxes
        for _, child in pairs(self.OptionsScrollFrame:GetChildren()) do
            if child:IsA("TextButton") and child.OptionText.Text == tostring(option) and child:FindFirstChild("Checkbox") then
                local checkbox = child.Checkbox
                local checkmark = checkbox.Checkmark
                
                -- Update checkbox appearance
                if table.find(self.Selected, option) then
                    TweenService:Create(
                        checkbox, 
                        TWEEN_INFO, 
                        {BackgroundColor3 = self.Theme:GetColor("Accent")}
                    ):Play()
                    checkmark.Visible = true
                else
                    TweenService:Create(
                        checkbox, 
                        TWEEN_INFO, 
                        {BackgroundColor3 = self.Theme:GetColor("ToggleDisabled")}
                    ):Play()
                    checkmark.Visible = false
                end
            end
        end
    else
        -- Single select - just update the selected value
        self.Selected = option
        
        -- Close the dropdown after selection
        self:ToggleDropdown(false)
    end
    
    -- Update display text
    self.DisplayText.Text = self:GetDisplayText()
    
    -- Execute callback
    self.Callback(self.Selected)
end

-- Toggle dropdown state
function Dropdown:ToggleDropdown(state)
    if state ~= nil then
        self.IsOpen = state
    else
        self.IsOpen = not self.IsOpen
    end
    
    if self.IsOpen then
        -- Calculate height based on number of options, limited by MaxVisibleItems
        local optionHeight = 30
        local visibleOptions = math.min(#self.Options, self.MaxVisibleItems)
        local optionsHeight = visibleOptions * optionHeight + (visibleOptions - 1) * self.OptionsLayout.Padding.Offset
        
        -- Show options
        self.OptionsContainer.Visible = true
        
        -- Animate dropdown opening
        TweenService:Create(
            self.Container,
            TWEEN_INFO,
            {Size = UDim2.new(1, 0, 0, self.Description and 80 + optionsHeight + 5 or 60 + optionsHeight + 5)}
        ):Play()
        
        TweenService:Create(
            self.OptionsContainer,
            TWEEN_INFO,
            {Size = UDim2.new(1, -20, 0, optionsHeight)}
        ):Play()
        
        -- Rotate arrow
        TweenService:Create(
            self.Arrow,
            TWEEN_INFO,
            {Rotation = 180}
        ):Play()
    else
        -- Animate dropdown closing
        TweenService:Create(
            self.Container,
            TWEEN_INFO,
            {Size = UDim2.new(1, 0, 0, self.Description and 80 or 60)}
        ):Play()
        
        TweenService:Create(
            self.OptionsContainer,
            TWEEN_INFO,
            {Size = UDim2.new(1, -20, 0, 0)}
        ):Play()
        
        -- Reset arrow rotation
        TweenService:Create(
            self.Arrow,
            TWEEN_INFO,
            {Rotation = 0}
        ):Play()
        
        -- Hide options after tween
        task.delay(TWEEN_INFO.Time, function()
            if not self.IsOpen and self.OptionsContainer then
                self.OptionsContainer.Visible = false
            end
        end)
    end
end

function Dropdown:SetupEvents()
    -- Hover effect for display
    self.Button.MouseEnter:Connect(function()
        TweenService:Create(
            self.DisplayFrame, 
            TWEEN_INFO, 
            {BackgroundColor3 = self.Theme:GetColor("InputBackgroundHover")}
        ):Play()
    end)
    
    self.Button.MouseLeave:Connect(function()
        TweenService:Create(
            self.DisplayFrame, 
            TWEEN_INFO, 
            {BackgroundColor3 = self.Theme:GetColor("InputBackground")}
        ):Play()
    end)
    
    -- Toggle dropdown on click
    self.Button.MouseButton1Click:Connect(function()
        self:ToggleDropdown()
    end)
    
    -- Close dropdown when clicking outside
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.IsOpen then
            local mousePos = UserInputService:GetMouseLocation()
            local containerPos = self.Container.AbsolutePosition
            local containerSize = self.Container.AbsoluteSize
            
            -- Check if click is outside the container
            if mousePos.X < containerPos.X or mousePos.X > containerPos.X + containerSize.X or
               mousePos.Y < containerPos.Y or mousePos.Y > containerPos.Y + containerSize.Y then
                self:ToggleDropdown(false)
            end
        end
    end)
end

-- Set dropdown options
function Dropdown:SetOptions(options)
    self.Options = options
    
    -- Update selection if current selection is not in new options
    if not self.MultiSelect then
        local found = false
        for _, option in ipairs(options) do
            if option == self.Selected then
                found = true
                break
            end
        end
        
        if not found and #options > 0 then
            self.Selected = options[1]
        elseif not found then
            self.Selected = nil
        end
    else
        -- For multi-select, filter out selected options that are no longer available
        local newSelected = {}
        for _, selectedOption in ipairs(self.Selected) do
            for _, option in ipairs(options) do
                if option == selectedOption then
                    table.insert(newSelected, option)
                    break
                end
            end
        end
        self.Selected = newSelected
    end
    
    -- Update display text
    self.DisplayText.Text = self:GetDisplayText()
    
    -- Recreate options
    self:CreateOptions()
    
    -- Close dropdown
    self:ToggleDropdown(false)
end

-- Set dropdown title
function Dropdown:SetTitle(title)
    self.Title = title
    self.TitleLabel.Text = title
end

-- Set dropdown description
function Dropdown:SetDescription(description)
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
        
        -- Adjust dropdown position
        self.DropdownY = 50
        self.DisplayFrame.Position = UDim2.new(0, 10, 0, self.DropdownY)
        self.OptionsContainer.Position = UDim2.new(0, 10, 0, self.DropdownY + 35)
    end
end

-- Set dropdown value
function Dropdown:SetValue(value)
    if self.MultiSelect and type(value) == "table" then
        self.Selected = value
    elseif not self.MultiSelect then
        self.Selected = value
    end
    
    self.DisplayText.Text = self:GetDisplayText()
    self:CreateOptions() -- Refresh options to show selection
end

-- Get current value
function Dropdown:GetValue()
    return self.Selected
end

-- Set dropdown callback
function Dropdown:SetCallback(callback)
    self.Callback = callback or function() end
end

-- Clear dropdown selection
function Dropdown:Clear()
    if self.MultiSelect then
        self.Selected = {}
    else
        self.Selected = nil
    end
    
    self.DisplayText.Text = self:GetDisplayText()
    self:CreateOptions() -- Refresh options to show selection
    
    -- Execute callback
    self.Callback(self.Selected)
end

-- Destroy dropdown
function Dropdown:Destroy()
    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end
end

return Dropdown
