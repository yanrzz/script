-- =============================================================================
-- SPEED HUB X - STEAL AN EGG V3 (KHUSUS TELUR LAPANGAN / PUBLIC FIELD ONLY)
-- =============================================================================

_G.AutoStealLapangan = false
_G.TweenSpeed = 70 -- Kecepatan pergerakan

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Daftar folder/model milik Garden/Base player (UNTUK DIABAIKAN)
local BlacklistedParents = {
    "plot", "garden", "base", "claim", "player", "house", "kandang", "fence", "farm", "paddock"
}

-- Cek apakah telur berada di dalam garden/base pemain
local function isInsidePlayerGarden(obj)
    local current = obj
    while current and current ~= Workspace do
        local name = string.lower(current.Name)
        for _, blacklisted in ipairs(BlacklistedParents) do
            if string.find(name, blacklisted) then
                return true -- Telur ada di dalam garden orang! (Diabaikan)
            end
        end
        current = current.Parent
    end
    return false
end

local function getRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Memindai HANYA telur liar yang ada di lapangan tengah / area publik
local function getLapanganEggs()
    local targets = {}
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") or v:IsA("ProximityPrompt") or string.find(string.lower(v.Name), "egg") then
            local parent = v:IsA("BasePart") and v or v.Parent
            
            if parent and not parent:IsDescendantOf(LocalPlayer.Character) then
                -- FILTER 1: ABAIKAN jika telur berada di dalam Garden/Plot Player
                if not isInsidePlayerGarden(parent) then
                    local name = string.lower(parent.Name)
                    -- FILTER 2: Pastikan itu objek telur/secret/event di lapangan
                    if string.find(name, "egg") or string.find(name, "telur") or string.find(name, "secret") or string.find(name, "kraken") or v:IsA("TouchTransmitter") then
                        table.insert(targets, parent)
                    end
                end
            end
        end
    end
    return targets
end

-- Teleport Halus ke Lapangan
local function moveToPos(targetCFrame)
    local root = getRoot()
    if not root then return end
    
    local dist = (root.Position - targetCFrame.Position).Magnitude
    if dist < 12 then
        root.CFrame = targetCFrame
    else
        local travelTime = dist / _G.TweenSpeed
        local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
    end
end

-- Ambil Telur
local function stealLapanganEgg(obj)
    local root = getRoot()
    if not root or not obj then return end
    
    local targetCFrame = obj:IsA("Model") and obj:GetPivot() or obj.CFrame
    moveToPos(targetCFrame + Vector3.new(0, 2, 0))
    
    -- Prompt & Touch
    for _, prompt in pairs(obj:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
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
    
    if obj:IsA("BasePart") then
        pcall(function()
            firetouchinterest(root, obj, 0)
            task.wait(0.01)
            firetouchinterest(root, obj, 1)
        end)
    end
end

-- Loop Utama Khusus Lapangan
task.spawn(function()
    while task.wait(0.3) do
        if _G.AutoStealLapangan then
            pcall(function()
                local eggs = getLapanganEggs()
                for _, egg in ipairs(eggs) do
                    if not _G.AutoStealLapangan then break end
                    stealLapanganEgg(egg)
                    task.wait(0.1)
                end
            end)
        end
    end
end)

-- UI Kontrol Mini
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "StealEggLapanganUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 210, 0, 110)
Main.Position = UDim2.new(0.05, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 25, 30)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "Curi Telur Lapangan Only"
Title.TextColor3 = Color3.fromRGB(0, 220, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 13
Title.Parent = Main

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0.85, 0, 0, 35)
Btn.Position = UDim2.new(0.075, 0, 0, 45)
Btn.BackgroundColor3 = Color3.fromRGB(40, 45, 55)
Btn.Text = "Auto Lapangan: OFF"
Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
Btn.Font = Enum.Font.SourceSansBold
Btn.TextSize = 12
Btn.Parent = Main
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

Btn.MouseButton1Click:Connect(function()
    _G.AutoStealLapangan = not _G.AutoStealLapangan
    Btn.Text = "Auto Lapangan: " .. (_G.AutoStealLapangan and "ON" or "OFF")
    Btn.BackgroundColor3 = _G.AutoStealLapangan and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(40, 45, 55)
    Btn.TextColor3 = _G.AutoStealLapangan and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
end)
