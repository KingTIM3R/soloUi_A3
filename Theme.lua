--[[
    Theme module for SystemUI
    
    Provides color schemes and styling options for the UI components.
]]

local Theme = {}
Theme.__index = Theme

-- Default themes
local Themes = {
    Dark = {
        -- Window elements
        Window = Color3.fromRGB(30, 30, 35),
        TitleBar = Color3.fromRGB(35, 35, 40),
        Content = Color3.fromRGB(30, 30, 35),
        TabBackground = Color3.fromRGB(25, 25, 29),
        TabActive = Color3.fromRGB(35, 35, 40),
        TabInactive = Color3.fromRGB(28, 28, 32),
        Border = Color3.fromRGB(60, 60, 65),
        
        -- Text colors
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(170, 170, 180),
        
        -- Interactive elements
        ElementBackground = Color3.fromRGB(40, 40, 45),
        ElementBackgroundHover = Color3.fromRGB(50, 50, 55),
        ElementBackgroundClick = Color3.fromRGB(60, 60, 65),
        
        -- Input elements
        InputBackground = Color3.fromRGB(35, 35, 40),
        InputBackgroundHover = Color3.fromRGB(45, 45, 50),
        InputBackgroundFocus = Color3.fromRGB(50, 50, 55),
        
        -- Slider elements
        SliderBackground = Color3.fromRGB(35, 35, 40),
        SliderIndicator = Color3.fromRGB(255, 255, 255),
        
        -- Toggle elements
        ToggleEnabled = Color3.fromRGB(114, 137, 218),
        ToggleDisabled = Color3.fromRGB(70, 70, 80),
        ToggleIndicator = Color3.fromRGB(255, 255, 255),
        
        -- Notification elements
        NotificationBackground = Color3.fromRGB(40, 40, 45),
        NotificationBackgroundHover = Color3.fromRGB(50, 50, 55),
        
        -- Misc
        ScrollBar = Color3.fromRGB(60, 60, 65),
        Accent = Color3.fromRGB(114, 137, 218),
    },
    
    Light = {
        -- Window elements
        Window = Color3.fromRGB(240, 240, 245),
        TitleBar = Color3.fromRGB(230, 230, 235),
        Content = Color3.fromRGB(240, 240, 245),
        TabBackground = Color3.fromRGB(230, 230, 235),
        TabActive = Color3.fromRGB(220, 220, 225),
        TabInactive = Color3.fromRGB(230, 230, 235),
        Border = Color3.fromRGB(200, 200, 205),
        
        -- Text colors
        Text = Color3.fromRGB(30, 30, 35),
        SubText = Color3.fromRGB(100, 100, 110),
        
        -- Interactive elements
        ElementBackground = Color3.fromRGB(225, 225, 230),
        ElementBackgroundHover = Color3.fromRGB(215, 215, 220),
        ElementBackgroundClick = Color3.fromRGB(205, 205, 210),
        
        -- Input elements
        InputBackground = Color3.fromRGB(220, 220, 225),
        InputBackgroundHover = Color3.fromRGB(210, 210, 215),
        InputBackgroundFocus = Color3.fromRGB(200, 200, 205),
        
        -- Slider elements
        SliderBackground = Color3.fromRGB(210, 210, 215),
        SliderIndicator = Color3.fromRGB(30, 30, 35),
        
        -- Toggle elements
        ToggleEnabled = Color3.fromRGB(114, 137, 218),
        ToggleDisabled = Color3.fromRGB(180, 180, 190),
        ToggleIndicator = Color3.fromRGB(255, 255, 255),
        
        -- Notification elements
        NotificationBackground = Color3.fromRGB(225, 225, 230),
        NotificationBackgroundHover = Color3.fromRGB(215, 215, 220),
        
        -- Misc
        ScrollBar = Color3.fromRGB(180, 180, 185),
        Accent = Color3.fromRGB(114, 137, 218),
    },
    
    System = {
        -- Window elements
        Window = Color3.fromRGB(40, 40, 45),
        TitleBar = Color3.fromRGB(45, 45, 50),
        Content = Color3.fromRGB(40, 40, 45),
        TabBackground = Color3.fromRGB(35, 35, 40),
        TabActive = Color3.fromRGB(50, 50, 55),
        TabInactive = Color3.fromRGB(40, 40, 45),
        Border = Color3.fromRGB(65, 65, 70),
        
        -- Text colors
        Text = Color3.fromRGB(235, 235, 240),
        SubText = Color3.fromRGB(160, 160, 170),
        
        -- Interactive elements
        ElementBackground = Color3.fromRGB(50, 50, 55),
        ElementBackgroundHover = Color3.fromRGB(60, 60, 65),
        ElementBackgroundClick = Color3.fromRGB(70, 70, 75),
        
        -- Input elements
        InputBackground = Color3.fromRGB(45, 45, 50),
        InputBackgroundHover = Color3.fromRGB(55, 55, 60),
        InputBackgroundFocus = Color3.fromRGB(60, 60, 65),
        
        -- Slider elements
        SliderBackground = Color3.fromRGB(45, 45, 50),
        SliderIndicator = Color3.fromRGB(235, 235, 240),
        
        -- Toggle elements
        ToggleEnabled = Color3.fromRGB(80, 168, 252),
        ToggleDisabled = Color3.fromRGB(75, 75, 85),
        ToggleIndicator = Color3.fromRGB(235, 235, 240),
        
        -- Notification elements
        NotificationBackground = Color3.fromRGB(50, 50, 55),
        NotificationBackgroundHover = Color3.fromRGB(60, 60, 65),
        
        -- Misc
        ScrollBar = Color3.fromRGB(70, 70, 75),
        Accent = Color3.fromRGB(80, 168, 252),
    },
    
    Blue = {
        -- Window elements
        Window = Color3.fromRGB(35, 40, 50),
        TitleBar = Color3.fromRGB(40, 45, 55),
        Content = Color3.fromRGB(35, 40, 50),
        TabBackground = Color3.fromRGB(30, 35, 45),
        TabActive = Color3.fromRGB(45, 50, 60),
        TabInactive = Color3.fromRGB(35, 40, 50),
        Border = Color3.fromRGB(60, 70, 80),
        
        -- Text colors
        Text = Color3.fromRGB(235, 235, 240),
        SubText = Color3.fromRGB(160, 170, 180),
        
        -- Interactive elements
        ElementBackground = Color3.fromRGB(45, 50, 60),
        ElementBackgroundHover = Color3.fromRGB(55, 60, 70),
        ElementBackgroundClick = Color3.fromRGB(65, 70, 80),
        
        -- Input elements
        InputBackground = Color3.fromRGB(40, 45, 55),
        InputBackgroundHover = Color3.fromRGB(50, 55, 65),
        InputBackgroundFocus = Color3.fromRGB(55, 60, 70),
        
        -- Slider elements
        SliderBackground = Color3.fromRGB(40, 45, 55),
        SliderIndicator = Color3.fromRGB(235, 235, 240),
        
        -- Toggle elements
        ToggleEnabled = Color3.fromRGB(80, 160, 255),
        ToggleDisabled = Color3.fromRGB(70, 75, 85),
        ToggleIndicator = Color3.fromRGB(235, 235, 240),
        
        -- Notification elements
        NotificationBackground = Color3.fromRGB(45, 50, 60),
        NotificationBackgroundHover = Color3.fromRGB(55, 60, 70),
        
        -- Misc
        ScrollBar = Color3.fromRGB(65, 70, 80),
        Accent = Color3.fromRGB(80, 160, 255),
    }
}

-- Create a new theme
function Theme.new(themeName)
    local self = setmetatable({}, Theme)
    
    -- Set default theme if the provided name doesn't exist
    self.Name = themeName or "System"
    if not Themes[self.Name] then
        self.Name = "System"
    end
    
    -- Set colors from theme
    self.Colors = Themes[self.Name]
    
    -- Custom colors (if any)
    self.CustomColors = {}
    
    return self
end

-- Get color from theme
function Theme:GetColor(colorName)
    -- Return custom color if set
    if self.CustomColors[colorName] then
        return self.CustomColors[colorName]
    end
    
    -- Return theme color
    return self.Colors[colorName] or Color3.fromRGB(255, 0, 255) -- Pink for missing colors
end

-- Set custom color
function Theme:SetColor(colorName, color)
    self.CustomColors[colorName] = color
end

-- Reset custom color
function Theme:ResetColor(colorName)
    self.CustomColors[colorName] = nil
end

-- Switch to another theme
function Theme:SetTheme(themeName)
    if Themes[themeName] then
        self.Name = themeName
        self.Colors = Themes[themeName]
    end
end

-- Get all available theme names
function Theme:GetAvailableThemes()
    local themeNames = {}
    
    for name, _ in pairs(Themes) do
        table.insert(themeNames, name)
    end
    
    return themeNames
end

-- Create a new custom theme
function Theme:CreateCustomTheme(name, colors)
    if name and type(colors) == "table" then
        Themes[name] = colors
        return true
    end
    
    return false
end

return Theme
