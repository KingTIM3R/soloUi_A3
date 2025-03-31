--[[
    SystemUI - A modern, Rayfield-inspired UI library for Roblox
    
    Core module that provides the main API for creating and managing UI elements.
    Inspired by Rayfield but with a system-like appearance and intuitive API.
]]

local SystemUI = {}
SystemUI.__index = SystemUI

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Modules
local Window = require(script.Components.Window)
local Theme = require(script.Util.Theme)

-- Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ActiveWindow = nil
local Windows = {}

-- Constants
local TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingStyle.Out)

-- Initialize the UI
function SystemUI.new(config)
    config = config or {}
    
    local self = setmetatable({}, SystemUI)
    
    -- Default configuration
    self.Title = config.Title or "SystemUI"
    self.Theme = config.Theme or "Dark"
    self.Key = config.Key -- Keybind to toggle the UI
    self.KeyCode = config.KeyCode or Enum.KeyCode.RightShift
    
    -- Initialize theme
    self.ThemeModule = Theme.new(self.Theme)
    
    -- Create ScreenGui
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "SystemUI_" .. self.Title
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Handle parent 
    if syn and syn.protect_gui then
        syn.protect_gui(self.ScreenGui)
        self.ScreenGui.Parent = CoreGui
    elseif gethui then
        self.ScreenGui.Parent = gethui()
    else
        self.ScreenGui.Parent = CoreGui
    end
    
    -- Create container for notifications
    self.NotificationContainer = Instance.new("Frame")
    self.NotificationContainer.Name = "NotificationContainer"
    self.NotificationContainer.Size = UDim2.new(0, 300, 1, 0)
    self.NotificationContainer.Position = UDim2.new(1, -310, 0, 10)
    self.NotificationContainer.BackgroundTransparency = 1
    self.NotificationContainer.Parent = self.ScreenGui
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.Parent = self.NotificationContainer
    
    -- Setup toggle keybind
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == self.KeyCode then
            self:ToggleVisibility()
        end
    end)
    
    return self
end

-- Create a new window
function SystemUI:CreateWindow(config)
    config = config or {}
    config.Parent = self.ScreenGui
    config.Theme = self.ThemeModule
    
    local newWindow = Window.new(config)
    table.insert(Windows, newWindow)
    
    if not ActiveWindow then
        ActiveWindow = newWindow
    end
    
    return newWindow
end

-- Toggle visibility of all windows
function SystemUI:ToggleVisibility()
    for _, window in ipairs(Windows) do
        window:ToggleVisibility()
    end
end

-- Show a notification
function SystemUI:Notify(config)
    config = config or {}
    
    local title = config.Title or "Notification"
    local content = config.Content or ""
    local duration = config.Duration or 3
    local type = config.Type or "Info" -- Info, Success, Warning, Error
    
    -- Create notification frame
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(1, -10, 0, 80)
    notif.BackgroundColor3 = self.ThemeModule:GetColor("Background")
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.Parent = self.NotificationContainer
    
    -- Styling
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = notif
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = self.ThemeModule:GetColor("Border")
    UIStroke.Thickness = 1
    UIStroke.Parent = notif
    
    -- Icon based on type
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 10, 0, 10)
    icon.BackgroundTransparency = 1
    
    -- Set icon based on type
    if type == "Info" then
        icon.Image = "rbxassetid://7733658133"
        icon.ImageColor3 = Color3.fromRGB(91, 154, 255)
    elseif type == "Success" then
        icon.Image = "rbxassetid://7733715400"
        icon.ImageColor3 = Color3.fromRGB(91, 255, 91)
    elseif type == "Warning" then
        icon.Image = "rbxassetid://7733715400"
        icon.ImageColor3 = Color3.fromRGB(255, 223, 91)
    elseif type == "Error" then
        icon.Image = "rbxassetid://7733658803"
        icon.ImageColor3 = Color3.fromRGB(255, 91, 91)
    end
    
    icon.Parent = notif
    
    -- Title
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.Size = UDim2.new(1, -60, 0, 25)
    titleText.Position = UDim2.new(0, 50, 0, 10)
    titleText.BackgroundTransparency = 1
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.TextColor3 = self.ThemeModule:GetColor("Text")
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Text = title
    titleText.Parent = notif
    
    -- Content
    local contentText = Instance.new("TextLabel")
    contentText.Name = "Content"
    contentText.Size = UDim2.new(1, -20, 0, 35)
    contentText.Position = UDim2.new(0, 10, 0, 40)
    contentText.BackgroundTransparency = 1
    contentText.Font = Enum.Font.Gotham
    contentText.TextSize = 14
    contentText.TextColor3 = self.ThemeModule:GetColor("SubText")
    contentText.TextXAlignment = Enum.TextXAlignment.Left
    contentText.TextWrapped = true
    contentText.Text = content
    contentText.Parent = notif
    
    -- Animations
    notif.Size = UDim2.new(1, -10, 0, 0)
    local showTween = TweenService:Create(notif, TWEEN_INFO, {Size = UDim2.new(1, -10, 0, 80)})
    showTween:Play()
    
    -- Remove after duration
    task.delay(duration, function()
        local hideTween = TweenService:Create(notif, TWEEN_INFO, {Size = UDim2.new(1, -10, 0, 0)})
        hideTween:Play()
        hideTween.Completed:Connect(function()
            notif:Destroy()
        end)
    end)
    
    return notif
end

-- Cleanup function
function SystemUI:Destroy()
    for _, window in ipairs(Windows) do
        window:Destroy()
    end
    
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    
    -- Clear tables
    Windows = {}
    ActiveWindow = nil
end

return SystemUI
