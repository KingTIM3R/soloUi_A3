--[[
    Tween utility for SystemUI
    
    Provides common tweening functions and presets for consistent animations.
]]

local TweenService = game:GetService("TweenService")

local Tween = {}

-- Common tween info presets
Tween.Presets = {
    -- Standard UI animations
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingStyle.Out),
    Default = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingStyle.Out),
    Slow = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingStyle.Out),
    
    -- Specialized animations
    Bounce = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingStyle.Out),
    Smooth = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingStyle.InOut),
    Spring = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingStyle.Out, 0, false, 0),
    
    -- Progress animations
    Linear = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingStyle.InOut),
    
    -- Fade animations
    FadeIn = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingStyle.Out),
    FadeOut = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingStyle.In),
}

-- Create and play a tween immediately
function Tween.Create(instance, properties, tweenInfo)
    tweenInfo = tweenInfo or Tween.Presets.Default
    
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    
    return tween
end

-- Fade in an object (change transparency)
function Tween.FadeIn(instance, targetTransparency, duration)
    targetTransparency = targetTransparency or 0
    duration = duration or 0.2
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingStyle.Out)
    
    if instance:IsA("GuiObject") then
        Tween.Create(instance, {BackgroundTransparency = targetTransparency}, tweenInfo)
        
        -- Also fade text if applicable
        if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            Tween.Create(instance, {TextTransparency = targetTransparency}, tweenInfo)
        end
        
        -- Also fade image if applicable
        if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            Tween.Create(instance, {ImageTransparency = targetTransparency}, tweenInfo)
        end
    end
end

-- Fade out an object (change transparency)
function Tween.FadeOut(instance, targetTransparency, duration)
    targetTransparency = targetTransparency or 1
    duration = duration or 0.2
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingStyle.In)
    
    if instance:IsA("GuiObject") then
        Tween.Create(instance, {BackgroundTransparency = targetTransparency}, tweenInfo)
        
        -- Also fade text if applicable
        if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
            Tween.Create(instance, {TextTransparency = targetTransparency}, tweenInfo)
        end
        
        -- Also fade image if applicable
        if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
            Tween.Create(instance, {ImageTransparency = targetTransparency}, tweenInfo)
        end
    end
end

-- Slide an object from one position to another
function Tween.Slide(instance, targetPosition, tweenInfo)
    tweenInfo = tweenInfo or Tween.Presets.Default
    
    return Tween.Create(instance, {Position = targetPosition}, tweenInfo)
end

-- Scale an object's size
function Tween.Scale(instance, targetSize, tweenInfo)
    tweenInfo = tweenInfo or Tween.Presets.Default
    
    return Tween.Create(instance, {Size = targetSize}, tweenInfo)
end

-- Change object's background color
function Tween.Color(instance, targetColor, tweenInfo)
    tweenInfo = tweenInfo or Tween.Presets.Default
    
    return Tween.Create(instance, {BackgroundColor3 = targetColor}, tweenInfo)
end

-- Pulse an object (temporary size increase and decrease)
function Tween.Pulse(instance, scaleFactor)
    scaleFactor = scaleFactor or 1.1
    
    local originalSize = instance.Size
    local targetSize = UDim2.new(
        originalSize.X.Scale * scaleFactor,
        originalSize.X.Offset * scaleFactor,
        originalSize.Y.Scale * scaleFactor,
        originalSize.Y.Offset * scaleFactor
    )
    
    -- Grow
    local growTween = Tween.Create(instance, {Size = targetSize}, Tween.Presets.Fast)
    
    -- Shrink back to original size after growing
    growTween.Completed:Connect(function()
        Tween.Create(instance, {Size = originalSize}, Tween.Presets.Slow)
    end)
    
    return growTween
end

-- Create a sequence of tweens that play one after another
function Tween.Sequence(tweens)
    if #tweens == 0 then
        return
    end
    
    for i = 1, #tweens - 1 do
        local currentTween = tweens[i]
        local nextTween = tweens[i + 1]
        
        currentTween.Completed:Connect(function()
            nextTween:Play()
        end)
    end
    
    -- Play the first tween to start the sequence
    tweens[1]:Play()
end

-- Chain multiple property changes for an instance
function Tween.Chain(instance, propertySequence, tweenInfo)
    tweenInfo = tweenInfo or Tween.Presets.Default
    
    local tweens = {}
    for _, properties in ipairs(propertySequence) do
        table.insert(tweens, TweenService:Create(instance, tweenInfo, properties))
    end
    
    Tween.Sequence(tweens)
    return tweens
end

return Tween
