-- =============================================================================
-- SPEED HUB X - STEAL AN EGG (AUTO TAKE & AUTO FARM EGG)
-- =============================================================================

-- 1. SETTING & STATE
_G.AutoTakeEgg = false
_G.AutoSecretEgg = false
_G.TakeDistance = 150 -- Radius jarak pencarian telur (m)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 2. HELPER FUNCTIONS
local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Deteksi Seluruh Telur di Workspace
local function findEggs()
    local eggList = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            local lowerName = string.lower(obj.Name)
            if string.find(lowerName, "egg") or string.find(lowerName, "telur") then
                -- Pastikan objek bukan bagian dari UI atau karakter pemain
                if not obj:IsDescendantOf(LocalPlayer.Character) and not obj:FindFirstAncestorOfClass("ScreenGui") then
                    table.insert(eggList, obj)
                end
            end
        end
    end
    return eggList
end

-- Memicu Pengambilan Telur (Proximity Prompt / Touch)
local function interactWithEgg(eggObj)
    local root = getRoot()
    if not root or not eggObj then return end
    
    local targetPos = eggObj:IsA("Model") and eggObj:GetPivot().Position or eggObj.Position
    
    -- 1. Teleport Mikro ke Posisi Telur
    root.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0))
    task.wait(0.05)
    
    -- 2. Cek ProximityPrompt (jika sistem game memakai tombol tekan)
    for _, prompt in pairs(eggObj:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                prompt.RequiresLineOfSight = false
                prompt.MaxActivationDistance = 9999
                if fireproximityprompt then
                    fireproximityprompt(prompt)
                else
                    prompt:InputHoldBegin()
                    task.wait(prompt.HoldDuration + 0.05)
                    prompt:InputHoldEnd()
                end
            end)
        end
    end
    
    -- 3. Cek TouchInterest (jika sistem game memakai sentuhan)
    if eggObj:IsA("BasePart") then
        pcall(function()
            firetouchinterest(root, eggObj, 0)
            task.wait(0.01)
            firetouchinterest(root, eggObj, 1)
        end)
    else
        for _, part in pairs(eggObj:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    firetouchinterest(root, part, 0)
                    task.wait(0.01)
                    firetouchinterest(root, part, 1)
                end)
            end
        end
    end
end

-- 3. LOOP UTAMA AUTO TAKE EGG
task.spawn(function()
    while task.wait(0.2) do
        if _G.AutoTakeEgg then
            pcall(function()
                local root = getRoot()
                if not root then return end
                
                local eggs = findEggs()
                for _, egg in ipairs(eggs) do
                    if not _G.AutoTakeEgg then break end
                    
                    local pos = egg:IsA("Model") and egg:GetPivot().Position or egg.Position
                    local dist = (root.Position - pos).Magnitude
                    
                    if dist <= _G.TakeDistance then
                        interactWithEgg(egg)
                        task.wait(0.15)
                    end
                end
            end)
        end
    end
end)

-- 4. GUI INTERFACE (SPEED HUB MINI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealEggHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 220, 0, 160)
Main.Position = UDim2.new(0.05, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Steal an Egg | Auto Hub"
Title.TextColor3 = Color3.fromRGB(255, 200, 50)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.Parent = Main

local function CreateToggle(text, pos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = pos
    btn.AnchorPoint = Vector2.new(0.5, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
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
        btn.BackgroundColor3 = state and Color3.fromRGB(40, 180, 80) or Color3.fromRGB(40, 40, 50)
        btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
        callback(state)
    end)
end

CreateToggle("Auto Take Egg", UDim2.new(0.5, 0, 0, 38), function(v)
    _G.AutoTakeEgg = v
end)

CreateToggle("Auto Secret Egg TP", UDim2.new(0.5, 0, 0, 78), function(v)
    _G.AutoSecretEgg = v
end)
