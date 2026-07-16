-- =============================================================================
-- SPEED HUB X v8.5 - UKURAN KECIL + FITUR FIXED
-- =============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- ========================== DATABASE ==========================
local FruitsList = {"Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Bamboo", "Corn", "Apple", "Mango", "Mushroom", "Banana", "Grape", "Acorn", "Rocket Pop", "Pineapple", "Cactus", "Dragon Fruit", "Cherry", "Fire Fern", "Green Bean", "Coconut", "Sunflower", "Venus Fly Trap", "Poison Apple", "Pomegranate", "Venom Spritter", "Sun Bloom", "Moon Bloom", "Dragon's Breath", "Star Fruit"}

-- ========================== GLOBAL STATE ==========================
_G.WalkspeedToggle = false
_G.NoClipToggle = false
_G.CustomSpeed = 50
_G.SilentModeGlobal = true
_G.EnableStackFarming = false

_G.PriorityLevel = {
    AutoCollectAllFruit = 1, AutoCollectBestFruit = 2, AutoCollectFruit = 3,
    AutoPlantsAllSeeds = 4, AutoPlantsSeed = 5,
    AutoStealBestFruit = 4, AutoStealFruit = 6,
    AutoSellAll = 7, AutoBuyPet = 8
}

local function IsHigherPriorityActive(current)
    if not _G.EnableStackFarming then return false end
    local my = _G.PriorityLevel[current] or 10
    for feat, prio in pairs(_G.PriorityLevel) do
        if _G[feat] and prio < my then return true end
    end
    return false
end

-- ========================== FRUIT DETECTION ==========================
local function isRealFruit(item)
    if not item or not item:IsA("BasePart") then return false end
    local n = item.Name:lower()
    if item.Size.Magnitude > 15 then return false end
    for _, f in ipairs(FruitsList) do
        if n:find(f:lower()) then return true end
    end
    return n:find("fruit") or n:find("berry")
end

-- ========================== UI (UKURAN KECIL) ==========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHubX"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 680, 0, 480)  -- UKURAN DIBUAT LEBIH KECIL
Main.Position = UDim2.new(0.5, -340, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Top Bar
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 40)
Top.BackgroundColor3 = Color3.fromRGB(30, 25, 35)
Top.Parent = Main
Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Speed Hub X v8.5"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0.5, -15)
Close.BackgroundTransparency = 1
Close.Text = "✕"
Close.TextColor3 = Color3.fromRGB(220,220,220)
Close.TextSize = 16
Close.Font = Enum.Font.GothamBold
Close.Parent = Top
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Sidebar
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 160, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 22, 28)
Sidebar.ScrollBarThickness = 4
Sidebar.Parent = Main

local SBLayout = Instance.new("UIListLayout", Sidebar)
SBLayout.Padding = UDim.new(0, 2)

-- Pages
local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -160, 1, -40)
Pages.Position = UDim2.new(0, 160, 0, 40)
Pages.BackgroundTransparency = 1
Pages.Parent = Main

local tabButtons = {}

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 36)
    btn.BackgroundTransparency = 1
    btn.Text = "   " .. name
    btn.TextColor3 = Color3.fromRGB(200,200,200)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -15, 1, -15)
    page.Position = UDim2.new(0, 8, 0, 8)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.Visible = false
    page.Parent = Pages
    Instance.new("UIListLayout", page).Padding = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabButtons) do t.Page.Visible = false; t.Button.BackgroundTransparency = 1 end
        page.Visible = true
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Color3.fromRGB(45,40,55)
    end)

    table.insert(tabButtons, {Button = btn, Page = page})
    return page
end

local function AddToggle(parent, text, default, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 32)
    f.BackgroundColor3 = Color3.fromRGB(30, 28, 38)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.7, 0, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(220,220,230)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 45, 0, 22)
    b.Position = UDim2.new(1, -55, 0.5, -11)
    b.BackgroundColor3 = default and Color3.fromRGB(255,70,70) or Color3.fromRGB(60,55,70)
    b.Text = default and "ON" or "OFF"
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 11)

    local state = default
    b.MouseButton1Click:Connect(function()
        state = not state
        b.BackgroundColor3 = state and Color3.fromRGB(255,70,70) or Color3.fromRGB(60,55,70)
        b.Text = state and "ON" or "OFF"
        if cb then cb(state) end
    end)
end

-- ========================== TABS ==========================
local main = CreateTab("Main")
AddSection(main, "Stack Farm")
AddToggle(main, "Enable Stack Farming", false, function(v) _G.EnableStackFarming = v end)

AddSection(main, "Automation")
AddToggle(main, "Auto Collect Fruit", false, function(v) _G.AutoCollectFruit = v end)
AddToggle(main, "Auto Collect All", false, function(v) _G.AutoCollectAllFruit = v end)
AddToggle(main, "Auto Plant", false, function(v) _G.AutoPlantsSeed = v end)
AddToggle(main, "Auto Sell All", false, function(v) _G.AutoSellAll = v end)
AddToggle(main, "Auto Steal", false, function(v) _G.AutoStealFruit = v end)

AddSection(main, "Misc")
AddToggle(main, "WalkSpeed", false, function(v) _G.WalkspeedToggle = v end)
AddToggle(main, "NoClip", false, function(v) _G.NoClipToggle = v end)

-- Priority Tab
local pri = CreateTab("Priority")
AddSection(pri, "Priority Settings")
AddToggle(pri, "Enable Priority", false, function(v) _G.EnableStackFarming = v end)

if #tabButtons > 0 then tabButtons[1].Button:MouseButton1Click() end

-- ========================== LOOPS ==========================
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if not char then return end
    if _G.WalkspeedToggle then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = _G.CustomSpeed end
    end
    if _G.NoClipToggle then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- Auto Collect
task.spawn(function()
    while task.wait(0.25) do
        if not (_G.AutoCollectFruit or _G.AutoCollectAllFruit) then continue end
        if IsHigherPriorityActive("AutoCollectAllFruit") then continue end

        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("TouchTransmitter") then
                local item = obj.Parent
                if item and isRealFruit(item) then
                    firetouchinterest(root, item, 0)
                    task.wait(0.03)
                    firetouchinterest(root, item, 1)
                end
            end
        end
    end
end)

print("✅ Speed Hub X v8.5 - Ukuran Kecil & Siap Dipakai!")
