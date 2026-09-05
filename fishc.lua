-- =============================================================================
-- SPEED HUB X - FISCH (AUTO FISHING FARM)
-- =============================================================================

_G.AutoCast = false
_G.AutoShake = false
_G.AutoReel = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 1. HELPER FUNCTIONS
local function getRod()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, item in pairs(char:GetChildren()) do
        if item:IsA("Tool") and (string.find(string.lower(item.Name), "rod") or item:FindFirstChild("Bobber")) then
            return item
        end
    end
    return nil
end

-- 2. AUTO CAST LOOP
task.spawn(function()
    while task.wait(1) do
        if _G.AutoCast then
            pcall(function()
                local rod = getRod()
                if rod and rod:FindFirstChild("events") and rod.events:FindFirstChild("cast") then
                    rod.events.cast:FireServer(100, 1)
                end
            end)
        end
    end
end)

-- 3. AUTO SHAKE LOOP
task.spawn(function()
    while task.wait(0.05) do
        if _G.AutoShake then
            pcall(function()
                local playerGui = LocalPlayer:WaitForChild("PlayerGui")
                local shakeUI = playerGui:FindFirstChild("shakeui") or playerGui:FindFirstChild("Shake")
                
                if shakeUI and shakeUI.Enabled then
                    local button = shakeUI:FindFirstChild("safezone") and shakeUI.safezone:FindFirstChild("button")
                    if button and button.Visible then
                        local pos = button.AbsolutePosition
                        local size = button.AbsoluteSize
                        VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2 + 36, 0, true, game, 0)
                        VirtualInputManager:SendMouseButtonEvent(pos.X + size.X/2, pos.Y + size.Y/2 + 36, 0, false, game, 0)
                    end
                end
            end)
        end
    end
end)

-- 4. AUTO REEL LOOP
task.spawn(function()
    while task.wait(0.1) do
        if _G.AutoReel then
            pcall(function()
                local reelEvent = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("reelfinished")
                if reelEvent then
                    reelEvent:FireServer(100, true)
                end
            end)
        end
    end
end)

-- 5. GUI INTERFACE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FischHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 220, 0, 180)
Main.Position = UDim2.new(0.05, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Fisch | Auto Farm Hub"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.Parent = Main

local function CreateToggle(text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = pos
    btn.AnchorPoint = Vector2.new(0.5, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 40, 50)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.Parent = Main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 160, 100) or Color3.fromRGB(35, 40, 50)
        btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        callback(state)
    end)
end

CreateToggle("Auto Cast", UDim2.new(0.5, 0, 0, 38), function(v) _G.AutoCast = v end)
CreateToggle("Auto Shake", UDim2.new(0.5, 0, 0, 78), function(v) _G.AutoShake = v end)
CreateToggle("Auto Reel", UDim2.new(0.5, 0, 0, 118), function(v) _G.AutoReel = v end)
