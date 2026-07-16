-- =============================================================================
-- SPEED HUB X v8.3 - FULL SCRIPT + PRIORITY SYSTEM
-- =============================================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- ========================== DATABASE ==========================
local FruitsList = {
    "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Bamboo", 
    "Corn", "Apple", "Mango", "Mushroom", "Banana", "Grape", "Acorn", 
    "Rocket Pop", "Pineapple", "Cactus", "Dragon Fruit", "Cherry", 
    "Fire Fern", "Green Bean", "Coconut", "Sunflower", "Venus Fly Trap", 
    "Poison Apple", "Pomegranate", "Venom Spritter", "Sun Bloom", 
    "Moon Bloom", "Dragon's Breath", "Star Fruit"
}

local RarityList = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Super"}
local MutationList = {"All", "None", "Frozen", "Gold", "Electric", "Rainbow", "Starstruck", "Bloodlit", "Glow", "Eclipsed", "Aurora"}
local PetsList = {"All", "Bunny", "Frog", "Owl", "Monkey", "Robin", "Bee", "Bear", "Unicorn", "Golden Dragonfly", "Raccoon", "Turtle"}
local GearsList = {"All", "Common Watering Can", "Common Sprinkler", "Uncommon Sprinkler", "Rare Sprinkler", "Sign", "Trowel", "Speed Mushroom", "Jump Mushroom", "Supersize Mushroom", "Invisibility Mushroom", "Shrink Mushroom", "Flashbang", "Gnome", "Megafon", "Basic Pot", "Legendary Sprinkler", "Super Sprinkler", "Super Watering Can"}

-- ========================== GLOBAL STATE ==========================
_G.WalkspeedToggle = false
_G.NoClipToggle = false
_G.CustomSpeed = 50
_G.SilentModeGlobal = true
_G.DisableTeleport = false
_G.DelayToCollect = 0.5
_G.DelayToPlants = 0.5
_G.StopCollectIfFull = false

-- Priority System
_G.EnableStackFarming = false
_G.PriorityLevel = {
    AutoCollectAllFruit = 1,
    AutoCollectBestFruit = 2,
    AutoCollectFruit = 3,
    AutoPlantsAllSeeds = 4,
    AutoPlantsSeed = 5,
    AutoStealBestFruit = 3,
    AutoStealFruit = 5,
    AutoSellAll = 6,
    AutoBuyPet = 7,
    AutoPlaceSprinkler = 5,
}

local function IsHigherPriorityActive(currentFeature)
    if not _G.EnableStackFarming then return false end
    local myPrio = _G.PriorityLevel[currentFeature] or 10
    for feature, prio in pairs(_G.PriorityLevel) do
        if _G[feature] and prio < myPrio then
            return true
        end
    end
    return false
end

-- ========================== FRUIT DETECTION ==========================
local function isRealFruit(item)
    if not item or not item:IsA("BasePart") then return false end
    local name = item.Name:lower()
    local blackList = {"tree","trunk","branch","leaf","stem","wood","log","mail","box","pot","plot","soil","ground","terrain"}
    for _, v in ipairs(blackList) do
        if name:find(v) then return false end
    end
    if item.Size.Magnitude > 15 then return false end
    for _, f in ipairs(FruitsList) do
        if name:find(f:lower()) then return true end
    end
    return name:find("fruit") or name:find("berry") or name:find("harvest")
end

-- ========================== UI ==========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHubX_v8_3"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 780, 0, 560)
Main.Position = UDim2.new(0.5, -390, 0.5, -280)
Main.BackgroundColor3 = Color3.fromRGB(18, 13, 16)
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

-- Top Bar
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 40)
Top.BackgroundColor3 = Color3.fromRGB(28, 18, 22)
Top.Parent = Main
Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🚀 Speed Hub X | v8.3"
Title.TextColor3 = Color3.fromRGB(255, 70, 70)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -40, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Top
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Sidebar
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 170, 1, -40)
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 15, 18)
Sidebar.ScrollBarThickness = 4
Sidebar.Parent = Main

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 4)

-- Pages
local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -170, 1, -40)
Pages.Position = UDim2.new(0, 170, 0, 40)
Pages.BackgroundTransparency = 1
Pages.Parent = Main

local tabButtons = {}

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 36)
    btn.BackgroundTransparency = 1
    btn.Text = "   " .. name
    btn.TextColor3 = Color3.fromRGB(180, 170, 175)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 5
    page.Visible = false
    page.Parent = Pages

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabButtons) do 
            t.Page.Visible = false
            t.Button.BackgroundTransparency = 1 
        end
        page.Visible = true
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Color3.fromRGB(45, 30, 38)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
    end)

    table.insert(tabButtons, {Button = btn, Page = page})
    return page
end

local function AddSection(parent, title)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 36)
    f.BackgroundColor3 = Color3.fromRGB(32, 23, 28)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.Text = "  " .. title
    l.TextColor3 = Color3.fromRGB(255, 200, 200)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    return f
end

local function AddToggle(parent, text, default, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 32)
    f.BackgroundColor3 = Color3.fromRGB(28, 20, 24)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.7, 0, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(220, 210, 215)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.Parent = f

    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 48, 0, 22)
    b.Position = UDim2.new(1, -58, 0.5, -11)
    b.BackgroundColor3 = default and Color3.fromRGB(220,60,60) or Color3.fromRGB(60,45,50)
    b.Text = default and "ON" or "OFF"
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 11)

    local state = default
    b.MouseButton1Click:Connect(function()
        state = not state
        b.BackgroundColor3 = state and Color3.fromRGB(220,60,60) or Color3.fromRGB(60,45,50)
        b.Text = state and "ON" or "OFF"
        if cb then cb(state) end
    end)
end

local function AddDropdown(parent, text, options, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 32)
    f.BackgroundColor3 = Color3.fromRGB(28, 20, 24)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.4, 0, 1, 0)
    l.Position = UDim2.new(0,12,0,0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(220, 210, 215)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.Parent = f

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.55, 0, 0, 24)
    btn.Position = UDim2.new(0.42, 0, 0.5, -12)
    btn.BackgroundColor3 = Color3.fromRGB(45,35,40)
    btn.Text = options[1] or "Select"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        local idx = table.find(options, btn.Text) or 1
        idx = idx % #options + 1
        btn.Text = options[idx]
        if cb then cb(options[idx]) end
    end)
end

-- ========================== BUILD PAGES ==========================
local mainPage = CreateTab("Main")
AddSection(mainPage, "🌱 Planting")
AddDropdown(mainPage, "Selected Seed", FruitsList, function(v) _G.SelectedSeed = v end)
AddToggle(mainPage, "Auto Plant Selected", false, function(v) _G.AutoPlantsSeed = v end)
AddToggle(mainPage, "Auto Plant All Seeds", false, function(v) _G.AutoPlantsAllSeeds = v end)

AddSection(mainPage, "🍓 Collection")
AddDropdown(mainPage, "Selected Fruit", FruitsList, function(v) _G.CollectSelectedFruit = v end)
AddToggle(mainPage, "Auto Collect", false, function(v) _G.AutoCollectFruit = v end)
AddToggle(mainPage, "Auto Collect All", false, function(v) _G.AutoCollectAllFruit = v end)
AddToggle(mainPage, "Auto Collect Best", false, function(v) _G.AutoCollectBestFruit = v end)
AddToggle(mainPage, "Stop if Full", false, function(v) _G.StopCollectIfFull = v end)

AddSection(mainPage, "💰 Sell")
AddToggle(mainPage, "Auto Sell All", false, function(v) _G.AutoSellAll = v end)

AddSection(mainPage, "🎯 Steal")
AddToggle(mainPage, "Auto Steal Fruit", false, function(v) _G.AutoStealFruit = v end)
AddToggle(mainPage, "Auto Steal Best", false, function(v) _G.AutoStealBestFruit = v end)

AddSection(mainPage, "Misc")
AddToggle(mainPage, "WalkSpeed", false, function(v) _G.WalkspeedToggle = v end)
AddToggle(mainPage, "NoClip", false, function(v) _G.NoClipToggle = v end)
AddToggle(mainPage, "Silent Mode", true, function(v) _G.SilentModeGlobal = v end)

-- Priority Page
local priPage = CreateTab("Priority")
AddSection(priPage, "⚡ Priority Manager")
AddToggle(priPage, "Enable Stack Farming", false, function(v) _G.EnableStackFarming = v end)

local priFeatures = {
    {"Auto Collect All", "AutoCollectAllFruit"},
    {"Auto Collect Best", "AutoCollectBestFruit"},
    {"Auto Collect", "AutoCollectFruit"},
    {"Auto Plant All", "AutoPlantsAllSeeds"},
    {"Auto Plant", "AutoPlantsSeed"},
    {"Auto Steal Best", "AutoStealBestFruit"},
    {"Auto Steal", "AutoStealFruit"},
    {"Auto Sell All", "AutoSellAll"},
    {"Auto Buy Pet", "AutoBuyPet"},
    {"Auto Place Sprinkler", "AutoPlaceSprinkler"},
}

for _, data in ipairs(priFeatures) do
    AddDropdown(priPage, data[1] .. " Priority", {"1 (Highest)","2","3","4","5","6","7","8","9","10 (Lowest)"}, function(val)
        local lvl = tonumber(val:match("%d+")) or 5
        _G.PriorityLevel[data[2]] = lvl
    end)
end

if #tabButtons > 0 then tabButtons[1].Button:MouseButton1Click() end

-- ========================== CORE LOOPS ==========================
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if _G.WalkspeedToggle and hum then hum.WalkSpeed = _G.CustomSpeed end
    if _G.NoClipToggle then
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- Auto Collect
task.spawn(function()
    while task.wait(0.2) do
        if not (_G.AutoCollectFruit or _G.AutoCollectAllFruit or _G.AutoCollectBestFruit) then continue end
        if IsHigherPriorityActive("AutoCollectAllFruit") then continue end

        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        if _G.StopCollectIfFull and #Player.Backpack:GetChildren() >= 10 then continue end

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("TouchTransmitter") then
                local item = obj.Parent
                if item and isRealFruit(item) then
                    if _G.SilentModeGlobal then
                        firetouchinterest(root, item, 0)
                        task.wait(0.02)
                        firetouchinterest(root, item, 1)
                    else
                        root.CFrame = item.CFrame + Vector3.new(0,3,0)
                        task.wait(0.08)
                    end
                end
            end
        end
    end
end)

-- Auto Plant
task.spawn(function()
    while task.wait(0.5) do
        if not (_G.AutoPlantsSeed or _G.AutoPlantsAllSeeds) then continue end
        if IsHigherPriorityActive("AutoPlantsAllSeeds") then continue end

        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local txt = (obj.ObjectText or ""):lower() .. (obj.ActionText or ""):lower()
                if txt:find("plant") or txt:find("seed") then
                    if _G.SilentModeGlobal then
                        fireproximityprompt(obj)
                        task.wait(_G.DelayToPlants)
                    else
                        local p = obj.Parent
                        if p and p:IsA("BasePart") then
                            root.CFrame = p.CFrame + Vector3.new(0,2,0)
                            task.wait(0.1)
                            fireproximityprompt(obj)
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Sell
task.spawn(function()
    while task.wait(0.8) do
        if not _G.AutoSellAll then continue end
        if IsHigherPriorityActive("AutoSellAll") then continue end

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local txt = (obj.ObjectText or ""):lower() .. (obj.ActionText or ""):lower()
                if txt:find("sell") or txt:find("merchant") then
                    fireproximityprompt(obj)
                    task.wait(0.3)
                end
            end
        end
    end
end)

print("✅ Speed Hub X v8.3 FULLY LOADED!")
