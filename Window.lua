--[[
    Window component for SystemUI
    
    Represents a main window that contains tabs and other UI elements.
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Window = {}
Window.__index = Window

-- Load component modules
local Button = loadstring(game:HttpGet('https://raw.githubusercontent.com/KingTIM3R/soloUi_A3/refs/heads/main/Button.lua'))()
local Toggle = loadstring(game:HttpGet('https://raw.githubusercontent.com/KingTIM3R/soloUi_A3/refs/heads/main/Toggle.lua'))()
local Slider = loadstring(game:HttpGet('https://raw.githubusercontent.com/KingTIM3R/soloUi_A3/refs/heads/main/Slider.lua'))()
local Dropdown = loadstring(game:HttpGet('https://raw.githubusercontent.com/KingTIM3R/soloUi_A3/refs/heads/main/Dropdown.lua'))()
local Input = loadstring(game:HttpGet('https://raw.githubusercontent.com/KingTIM3R/soloUi_A3/refs/heads/main/Input.lua'))()

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingStyle.Out)
local DRAG_SPEED = 0.1

function Window.new(config)
    local self = setmetatable({}, Window)
    
    -- Default configuration
    self.Title = config.Title or "Window"
    self.Parent = config.Parent
    self.Theme = config.Theme
    self.Position = config.Position or UDim2.new(0.5, -300, 0.5, -200)
    self.Size = config.Size or UDim2.new(0, 600, 0, 400)
    self.Visible = true
    self.Draggable = true
    
    -- Elements
    self.Tabs = {}
    self.ActiveTab = nil
    
    -- Create main frame
    self:CreateWindowFrame()
    
    return self
end

-- Create the main window frame
function Window:CreateWindowFrame()
    -- Main window container
    self.Container = Instance.new("Frame")
    self.Container.Name = "Window_" .. self.Title
    self.Container.Size = self.Size
    self.Container.Position = self.Position
    self.Container.BackgroundColor3 = self.Theme:GetColor("Window")
    self.Container.BorderSizePixel = 0
    self.Container.ClipsDescendants = true
    self.Container.Parent = self.Parent
    
    -- Add rounded corners
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = self.Container
    
    -- Add subtle drop shadow
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = self.Theme:GetColor("Border")
    UIStroke.Thickness = 1
    UIStroke.Parent = self.Container
    
    -- Title bar
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Name = "TitleBar"
    self.TitleBar.Size = UDim2.new(1, 0, 0, 40)
    self.TitleBar.BackgroundColor3 = self.Theme:GetColor("TitleBar")
    self.TitleBar.BorderSizePixel = 0
    self.TitleBar.Parent = self.Container
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = self.TitleBar
    
    -- Only round the top corners
    local roundedCornersFix = Instance.new("Frame")
    roundedCornersFix.Name = "CornerFix"
    roundedCornersFix.Size = UDim2.new(1, 0, 0.5, 0)
    roundedCornersFix.Position = UDim2.new(0, 0, 0.5, 0)
    roundedCornersFix.BackgroundColor3 = self.Theme:GetColor("TitleBar")
    roundedCornersFix.BorderSizePixel = 0
    roundedCornersFix.Parent = self.TitleBar
    
    -- Title text
    self.TitleText = Instance.new("TextLabel")
    self.TitleText.Name = "Title"
    self.TitleText.Size = UDim2.new(1, -100, 1, 0)
    self.TitleText.Position = UDim2.new(0, 10, 0, 0)
    self.TitleText.BackgroundTransparency = 1
    self.TitleText.Font = Enum.Font.GothamBold
    self.TitleText.TextSize = 16
    self.TitleText.TextColor3 = self.Theme:GetColor("Text")
    self.TitleText.TextXAlignment = Enum.TextXAlignment.Left
    self.TitleText.Text = self.Title
    self.TitleText.Parent = self.TitleBar
    
    -- Close button
    self.CloseButton = Instance.new("ImageButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 16, 0, 16)
    self.CloseButton.Position = UDim2.new(1, -30, 0.5, -8)
    self.CloseButton.BackgroundTransparency = 1
    self.CloseButton.Image = "rbxassetid://7733658504"
    self.CloseButton.ImageColor3 = self.Theme:GetColor("Text")
    self.CloseButton.Parent = self.TitleBar
    
    -- Minimize button
    self.MinimizeButton = Instance.new("ImageButton")
    self.MinimizeButton.Name = "MinimizeButton"
    self.MinimizeButton.Size = UDim2.new(0, 16, 0, 16)
    self.MinimizeButton.Position = UDim2.new(1, -60, 0.5, -8)
    self.MinimizeButton.BackgroundTransparency = 1
    self.MinimizeButton.Image = "rbxassetid://7733715400"
    self.MinimizeButton.ImageColor3 = self.Theme:GetColor("Text")
    self.MinimizeButton.Parent = self.TitleBar
    
    -- Tab container
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Name = "TabContainer"
    self.TabContainer.Size = UDim2.new(0, 150, 1, -40)
    self.TabContainer.Position = UDim2.new(0, 0, 0, 40)
    self.TabContainer.BackgroundColor3 = self.Theme:GetColor("TabBackground")
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.Container
    
    -- Tab buttons container
    self.TabButtonContainer = Instance.new("ScrollingFrame")
    self.TabButtonContainer.Name = "TabButtons"
    self.TabButtonContainer.Size = UDim2.new(1, 0, 1, 0)
    self.TabButtonContainer.BackgroundTransparency = 1
    self.TabButtonContainer.BorderSizePixel = 0
    self.TabButtonContainer.ScrollBarThickness = 2
    self.TabButtonContainer.ScrollBarImageColor3 = self.Theme:GetColor("ScrollBar")
    self.TabButtonContainer.Parent = self.TabContainer
    
    -- Tab button layout
    local tabButtonLayout = Instance.new("UIListLayout")
    tabButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabButtonLayout.Padding = UDim.new(0, 1)
    tabButtonLayout.Parent = self.TabButtonContainer
    
    -- Content container
    self.ContentContainer = Instance.new("Frame")
    self.ContentContainer.Name = "ContentContainer"
    self.ContentContainer.Size = UDim2.new(1, -150, 1, -40)
    self.ContentContainer.Position = UDim2.new(0, 150, 0, 40)
    self.ContentContainer.BackgroundColor3 = self.Theme:GetColor("Content")
    self.ContentContainer.BorderSizePixel = 0
    self.ContentContainer.ClipsDescendants = true
    self.ContentContainer.Parent = self.Container
    
    -- Make window draggable
    if self.Draggable then
        self:MakeDraggable()
    end
    
    -- Setup button callbacks
    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    self.MinimizeButton.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
    
    return self.Container
end

-- Make window draggable
function Window:MakeDraggable()
    local isDragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                      startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        
        local tweenInfo = TweenInfo.new(DRAG_SPEED, Enum.EasingStyle.Sine, Enum.EasingStyle.Out)
        TweenService:Create(self.Container, tweenInfo, {Position = newPosition}):Play()
    end
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = self.Container.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)
    
    self.TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and isDragging then
            updateInput(input)
        end
    end)
end

-- Create a new tab
function Window:CreateTab(name, icon)
    -- Tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "Button"
    tabButton.Size = UDim2.new(1, 0, 0, 40)
    tabButton.BackgroundColor3 = self.Theme:GetColor("TabInactive")
    tabButton.BorderSizePixel = 0
    tabButton.AutoButtonColor = false
    tabButton.Text = ""
    tabButton.Parent = self.TabButtonContainer
    
    -- Tab icon
    local tabIcon
    if icon then
        tabIcon = Instance.new("ImageLabel")
        tabIcon.Name = "Icon"
        tabIcon.Size = UDim2.new(0, 20, 0, 20)
        tabIcon.Position = UDim2.new(0, 10, 0.5, -10)
        tabIcon.BackgroundTransparency = 1
        tabIcon.Image = icon
        tabIcon.ImageColor3 = self.Theme:GetColor("SubText")
        tabIcon.Parent = tabButton
    end
    
    -- Tab text
    local tabText = Instance.new("TextLabel")
    tabText.Name = "Title"
    tabText.Size = UDim2.new(1, (icon and -40 or -20), 1, 0)
    tabText.Position = UDim2.new(0, (icon and 40 or 10), 0, 0)
    tabText.BackgroundTransparency = 1
    tabText.Font = Enum.Font.Gotham
    tabText.TextSize = 14
    tabText.TextColor3 = self.Theme:GetColor("SubText")
    tabText.TextXAlignment = Enum.TextXAlignment.Left
    tabText.Text = name
    tabText.Parent = tabButton
    
    -- Tab container for elements
    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Name = name .. "Container"
    tabContainer.Size = UDim2.new(1, 0, 1, 0)
    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0
    tabContainer.ScrollBarThickness = 2
    tabContainer.ScrollBarImageColor3 = self.Theme:GetColor("ScrollBar")
    tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContainer.Visible = false
    tabContainer.Parent = self.ContentContainer
    
    -- Container padding
    local containerPadding = Instance.new("UIPadding")
    containerPadding.PaddingLeft = UDim.new(0, 10)
    containerPadding.PaddingRight = UDim.new(0, 10)
    containerPadding.PaddingTop = UDim.new(0, 10)
    containerPadding.PaddingBottom = UDim.new(0, 10)
    containerPadding.Parent = tabContainer
    
    -- Element layout
    local elementLayout = Instance.new("UIListLayout")
    elementLayout.SortOrder = Enum.SortOrder.LayoutOrder
    elementLayout.Padding = UDim.new(0, 8)
    elementLayout.Parent = tabContainer
    
    -- Create tab object
    local tab = {
        Name = name,
        Button = tabButton,
        Container = tabContainer,
        Icon = tabIcon,
        Text = tabText,
        Elements = {}
    }
    
    -- Add to tabs table
    table.insert(self.Tabs, tab)
    
    -- Tab button click handler
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
    
    -- Select first tab automatically
    if #self.Tabs == 1 then
        self:SelectTab(name)
    end
    
    -- Tab methods
    local methods = {}
    
    -- Create a section header
    function methods:CreateSection(sectionName)
        local section = Instance.new("Frame")
        section.Name = sectionName .. "Section"
        section.Size = UDim2.new(1, 0, 0, 35)
        section.BackgroundTransparency = 1
        section.LayoutOrder = #tab.Elements + 1
        section.Parent = tabContainer
        
        local sectionTitle = Instance.new("TextLabel")
        sectionTitle.Name = "SectionTitle"
        sectionTitle.Size = UDim2.new(1, 0, 0, 20)
        sectionTitle.Position = UDim2.new(0, 0, 0, 0)
        sectionTitle.BackgroundTransparency = 1
        sectionTitle.Font = Enum.Font.GothamBold
        sectionTitle.TextSize = 14
        sectionTitle.TextColor3 = self.Theme:GetColor("Text")
        sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
        sectionTitle.Text = sectionName
        sectionTitle.Parent = section
        
        local sectionDivider = Instance.new("Frame")
        sectionDivider.Name = "Divider"
        sectionDivider.Size = UDim2.new(1, 0, 0, 1)
        sectionDivider.Position = UDim2.new(0, 0, 0, 25)
        sectionDivider.BackgroundColor3 = self.Theme:GetColor("Border")
        sectionDivider.BorderSizePixel = 0
        sectionDivider.Parent = section
        
        table.insert(tab.Elements, section)
        return section
    end
    
    -- Create a button
    function methods:CreateButton(config)
        config = config or {}
        config.Parent = tabContainer
        config.LayoutOrder = #tab.Elements + 1
        config.Theme = self.Theme
        
        local button = Button.new(config)
        table.insert(tab.Elements, button)
        return button
    end
    
    -- Create a toggle
    function methods:CreateToggle(config)
        config = config or {}
        config.Parent = tabContainer
        config.LayoutOrder = #tab.Elements + 1
        config.Theme = self.Theme
        
        local toggle = Toggle.new(config)
        table.insert(tab.Elements, toggle)
        return toggle
    end
    
    -- Create a slider
    function methods:CreateSlider(config)
        config = config or {}
        config.Parent = tabContainer
        config.LayoutOrder = #tab.Elements + 1
        config.Theme = self.Theme
        
        local slider = Slider.new(config)
        table.insert(tab.Elements, slider)
        return slider
    end
    
    -- Create a dropdown
    function methods:CreateDropdown(config)
        config = config or {}
        config.Parent = tabContainer
        config.LayoutOrder = #tab.Elements + 1
        config.Theme = self.Theme
        
        local dropdown = Dropdown.new(config)
        table.insert(tab.Elements, dropdown)
        return dropdown
    end
    
    -- Create a text input
    function methods:CreateInput(config)
        config = config or {}
        config.Parent = tabContainer
        config.LayoutOrder = #tab.Elements + 1
        config.Theme = self.Theme
        
        local input = Input.new(config)
        table.insert(tab.Elements, input)
        return input
    end
    
    return methods
end

-- Select a tab
function Window:SelectTab(name)
    for _, tab in ipairs(self.Tabs) do
        if tab.Name == name then
            -- Set active tab
            tab.Container.Visible = true
            tab.Button.BackgroundColor3 = self.Theme:GetColor("TabActive")
            tab.Text.TextColor3 = self.Theme:GetColor("Text")
            if tab.Icon then
                tab.Icon.ImageColor3 = self.Theme:GetColor("Text")
            end
            self.ActiveTab = tab
        else
            -- Hide other tabs
            tab.Container.Visible = false
            tab.Button.BackgroundColor3 = self.Theme:GetColor("TabInactive")
            tab.Text.TextColor3 = self.Theme:GetColor("SubText")
            if tab.Icon then
                tab.Icon.ImageColor3 = self.Theme:GetColor("SubText")
            end
        end
    end
end

-- Minimize window
function Window:Minimize()
    if self.Minimized then
        -- Restore window
        local expandTween = TweenService:Create(
            self.Container, 
            TWEEN_INFO, 
            {Size = self.Size}
        )
        expandTween:Play()
        self.Minimized = false
    else
        -- Minimize window
        local minimizeTween = TweenService:Create(
            self.Container, 
            TWEEN_INFO, 
            {Size = UDim2.new(self.Size.X.Scale, self.Size.X.Offset, 0, 40)}
        )
        minimizeTween:Play()
        self.Minimized = true
    end
end

-- Toggle visibility
function Window:ToggleVisibility()
    self.Visible = not self.Visible
    self.Container.Visible = self.Visible
end

-- Destroy the window
function Window:Destroy()
    if self.Container then
        self.Container:Destroy()
        self.Container = nil
    end
end

return Window
