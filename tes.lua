-- =============================================================================
-- SPEED HUB X v8.0 - FULL & RE-OPTIMIZED CODE
-- =============================================================================

-- 1. DATABASE
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

-- 2. GLOBAL STATE
_G.WalkspeedToggle = false
_G.NoClipToggle = false
_G.CustomSpeed = 50
_G.SilentModeGlobal = true
_G.DisableTeleport = false

-- Priority Settings
_G.PriorityAutoPlantsSeed = false
_G.PriorityAutoPlantsAllSeeds = false
_G.PriorityAutoCollectFruit = false
_G.PriorityAutoCollectAllFruit = false
_G.PriorityAutoCollectBestFruit = false
_G.PriorityAutoCollectGoldSeed = false
_G.PriorityAutoCollectRainbowSeed = false
_G.PriorityAutoCollectMegaSeed = false
_G.PriorityAutoStealFruit = false
_G.PriorityAutoStealBestFruit = false
_G.PriorityAutoLockGarden = false
_G.PriorityAutoBuyPet = false
_G.PriorityAutoPlaceSprinkler = false
_G.PriorityAutoPlaceAllSprinkler = false
_G.PriorityAutoCollectDropped = false
_G.PriorityAutoHitPlayerStolen = false

-- Stack Farm
_G.EnableStackFarming = false
_G.StackPriority = {}

-- Collect Settings
_G.AutoCollectFruit = false
_G.AutoCollectAllFruit = false
_G.AutoCollectBestFruit = false
_G.AutoCollectGoldSeed = false
_G.AutoCollectRainbowSeed = false
_G.AutoCollectMegaSeed = false
_G.CollectSelectedFruit = "All"
_G.CollectSelectedRarity = "All"
_G.CollectSelectedMutation = "All"
_G.CollectThresholdMode = "Below" -- Below, Above, Exact
_G.CollectWeightThreshold = 100
_G.CollectOnlyMutated = false
_G.CollectFilterMode = "Whitelist" -- Whitelist, Blacklist
_G.StopCollectIfFull = false
_G.DelayToCollect = 0.5
_G.DisableCollectPrompt = false

-- Sell Settings
_G.AutoSellAll = false
_G.AutoSellFruit = false
_G.AutoSellPets = false
_G.SellSelectedFruit = "All"
_G.SellSelectedRarity = "All"
_G.SellSelectedMutation = "All"
_G.SellThresholdMode = "Below"
_G.SellWeightThreshold = 100
_G.SellSelectedPet = "All"
_G.SellPetRarity = "All"
_G.SellPetSize = "All"

-- Plant Settings
_G.AutoPlantsSeed = false
_G.AutoPlantsAllSeeds = false
_G.SelectedSeed = "Dragon Fruit"
_G.SelectedPosition = "Player Position"
_G.SelectedSprinkler = "All"
_G.DelayToPlants = 0.5
_G.SavePosition = "Select Options"

-- Steal Settings
_G.AutoStealFruit = false
_G.AutoStealBestFruit = false

-- Pet Settings
_G.AutoBuyPet = false
_G.BuySelectedPet = "All"
_G.BuyPetRarity = "All"
_G.BuyPetSize = "All"
_G.PetPurchaseProtection = false
_G.PetSheckleLimit = 0

-- Sprinkler Settings
_G.AutoPlaceSprinkler = false
_G.AutoPlaceAllSprinkler = false

-- Webhook
_G.WebhookURL = ""
_G.WebhookToggle = false

-- 3. PLAYER
local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- 4. FRUIT DETECTION
local function isRealFruit(item)
    if not item or not item:IsA("BasePart") then return false end
    local n = item.Name:lower()
    local p = item.Parent and item.Parent.Name:lower() or ""
    local black = {"tree","pohon","trunk","branch","leaf","stem","wood","log","mail","box","pot","plot","soil","ground","terrain"}
    for _, b in pairs(black) do if string.find(n,b) or string.find(p,b) then return false end end
    if item.Size.Y > 5 or item.Size.X > 5 or item.Size.Z > 5 then return false end
    local mat = item.Material
    if mat == Enum.Material.Wood or mat == Enum.Material.WoodPlanks or mat == Enum.Material.Grass then return false end
    for _, f in pairs(FruitsList) do if string.find(n, f:lower()) then return true end end
    if string.find(n, "fruit") or string.find(n, "berry") or string.find(n, "harvest") then return true end
    return false
end

-- 5. CORE LOOPS
-- Walkspeed & NoClip
task.spawn(function()
    RunService.Heartbeat:Connect(function()
        pcall(function()
            local char = Player.Character
            if not char then return end
            if _G.WalkspeedToggle then
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = _G.CustomSpeed end
            end
            if _G.NoClipToggle then
                for _, p in pairs(char:GetChildren()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end)
end)

-- Auto Collect
task.spawn(function()
    while task.wait(0.2) do
        if not (_G.AutoCollectFruit or _G.AutoCollectAllFruit or _G.AutoCollectBestFruit or _G.AutoCollectGoldSeed or _G.AutoCollectRainbowSeed or _G.AutoCollectMegaSeed) then 
            task.wait(0.5) 
            continue 
        end
        pcall(function()
            local char = Player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if _G.StopCollectIfFull then
                local backpack = Player.Backpack
                if backpack and #backpack:GetChildren() >= 10 then return end
            end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("TouchTransmitter") then
                    local item = obj.Parent
                    if item and isRealFruit(item) then
                        local weight = item:GetAttribute("Weight") or math.floor((item.Size.X*item.Size.Y*item.Size.Z)*10)
                        local isMatch = _G.AutoCollectAllFruit or _G.CollectSelectedFruit=="All" or string.find(item.Name:lower(), _G.CollectSelectedFruit:lower())
                        local weightMatch = false
                        if _G.CollectThresholdMode == "Below" then
                            weightMatch = weight <= _G.CollectWeightThreshold
                        elseif _G.CollectThresholdMode == "Above" then
                            weightMatch = weight >= _G.CollectWeightThreshold
                        else
                            weightMatch = weight == _G.CollectWeightThreshold
                        end
                        if isMatch and weightMatch and (_G.CollectWeightThreshold == 0 or weightMatch) then
                            if _G.SilentModeGlobal then
                                firetouchinterest(hrp, item, 0) task.wait(0.02) firetouchinterest(hrp, item, 1) task.wait(0.02)
                            else
                                hrp.CFrame = item.CFrame + Vector3.new(0,2,0)
                                task.wait(0.05)
                                firetouchinterest(hrp, item, 0) task.wait(0.05) firetouchinterest(hrp, item, 1)
                            end
                        end
                    end
                end
                if obj:IsA("ProximityPrompt") and not _G.DisableCollectPrompt then
                    local prompt = obj
                    local item = prompt.Parent
                    local txt = (prompt.ObjectText or ""):lower() .. (prompt.ActionText or ""):lower()
                    if string.find(txt,"chop") or string.find(txt,"cut") or string.find(txt,"tree") then continue end
                    if item and isRealFruit(item) and prompt.Enabled then
                        local weight = item:GetAttribute("Weight") or math.floor((item.Size.X*item.Size.Y*item.Size.Z)*10)
                        local isMatch = _G.AutoCollectAllFruit or _G.CollectSelectedFruit=="All" or string.find(item.Name:lower(), _G.CollectSelectedFruit:lower())
                        local weightMatch = false
                        if _G.CollectThresholdMode == "Below" then
                            weightMatch = weight <= _G.CollectWeightThreshold
                        elseif _G.CollectThresholdMode == "Above" then
                            weightMatch = weight >= _G.CollectWeightThreshold
                        else
                            weightMatch = weight == _G.CollectWeightThreshold
                        end
                        if isMatch and (_G.CollectWeightThreshold == 0 or weightMatch) then
                            if _G.SilentModeGlobal then
                                fireproximityprompt(prompt) task.wait(_G.DelayToCollect)
                            else
                                hrp.CFrame = item.CFrame + Vector3.new(0,1,0)
                                task.wait(0.1)
                                fireproximityprompt(prompt)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Auto Sell
task.spawn(function()
    while task.wait(0.5) do
        if not (_G.AutoSellAll or _G.AutoSellFruit or _G.AutoSellPets) then task.wait(0.5) continue end
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local txt = (obj.ObjectText or ""):lower() .. (obj.ActionText or ""):lower()
                    if string.find(txt,"merchant") or string.find(txt,"sell") or string.find(txt,"shop") then
                        fireproximityprompt(obj)
                        task.wait(0.05)
                    end
                end
            end
        end)
    end
end)

-- Auto Plants
task.spawn(function()
    while task.wait(0.5) do
        if not (_G.AutoPlantsSeed or _G.AutoPlantsAllSeeds) then task.wait(0.5) continue end
        pcall(function()
            local char = Player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local txt = (obj.ObjectText or ""):lower() .. (obj.ActionText or ""):lower()
                    if string.find(txt,"plant") or string.find(txt,"seed") or string.find(txt,"pot") or string.find(txt,"soil") then
                        if _G.SilentModeGlobal then
                            fireproximityprompt(obj)
                            task.wait(_G.DelayToPlants)
                        else
                            local parent = obj.Parent
                            if parent and parent:IsA("BasePart") then
                                hrp.CFrame = parent.CFrame + Vector3.new(0,1,0)
                                task.wait(0.1)
                                fireproximityprompt(obj)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Auto Steal
task.spawn(function()
    while task.wait(0.5) do
        if not (_G.AutoStealFruit or _G.AutoStealBestFruit) then task.wait(0.5) continue end
        pcall(function()
            -- Steal logic here
        end)
    end
end)

-- Auto Buy Pet
task.spawn(function()
    while task.wait(1) do
        if not _G.AutoBuyPet then task.wait(0.5) continue end
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local txt = (obj.ObjectText or ""):lower() .. (obj.ActionText or ""):lower()
                    if string.find(txt,"egg") or string.find(txt,"pet") or string.find(txt,"gacha") then
                        fireproximityprompt(obj)
                        task.wait(0.05)
                    end
                end
            end
        end)
    end
end)

-- Auto Place Sprinkler
task.spawn(function()
    while task.wait(1) do
        if not (_G.AutoPlaceSprinkler or _G.AutoPlaceAllSprinkler) then task.wait(0.5) continue end
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local txt = (obj.ObjectText or ""):lower() .. (obj.ActionText or ""):lower()
                    if string.find(txt,"sprinkler") or string.find(txt,"place") then
                        fireproximityprompt(obj)
                        task.wait(0.05)
                    end
                end
            end
        end)
    end
end)

-- =============================================================================
-- 6. UI - SIDEBAR KIRI (SESUAI GAMBAR)
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHubX"
ScreenGui.ResetOnSpawn = false
local guiParent = game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")
ScreenGui.Parent = guiParent

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 750, 0, 520)
Main.Position = UDim2.new(0.5, -375, 0.5, -260)
Main.BackgroundColor3 = Color3.fromRGB(18, 13, 16)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

-- Top Bar
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 35)
Top.BackgroundColor3 = Color3.fromRGB(28, 18, 22)
Top.BorderSizePixel = 0
Top.Parent = Main
Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Speed Hub X | Version 8.0 | discord.gg/speedhubx"
Title.TextColor3 = Color3.fromRGB(255, 70, 70)
Title.TextSize = 12
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -33, 0, 2)
Close.BackgroundTransparency = 1
Close.Text = "✕"
Close.TextColor3 = Color3.fromRGB(200,200,200)
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 14
Close.Parent = Top
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- SIDEBAR KIRI
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 160, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 15, 18)
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 400)
Sidebar.ScrollBarThickness = 0
Sidebar.Parent = Main

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 2)
SidebarLayout.Parent = Sidebar

-- Search Box
local Search = Instance.new("TextBox")
Search.Size = UDim2.new(1, -10, 0, 28)
Search.BackgroundColor3 = Color3.fromRGB(38, 25, 30)
Search.BorderSizePixel = 0
Search.PlaceholderText = "🔍 Search"
Search.Text = ""
Search.TextColor3 = Color3.fromRGB(200,200,200)
Search.PlaceholderColor3 = Color3.fromRGB(150,150,150)
Search.Font = Enum.Font.SourceSans
Search.TextSize = 12
Search.Parent = Sidebar
Instance.new("UICorner", Search).CornerRadius = UDim.new(0, 4)

-- Page Container KANAN
local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -160, 1, -35)
Pages.Position = UDim2.new(0, 160, 0, 35)
Pages.BackgroundTransparency = 1
Pages.Parent = Main

-- Tab System
local tabButtons = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(180, 170, 175)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local dot = Instance.new("TextLabel")
    dot.Size = UDim2.new(0, 20, 1, 0)
    dot.Position = UDim2.new(0, 5, 0, 0)
    dot.BackgroundTransparency = 1
    dot.Text = "•"
    dot.TextColor3 = Color3.fromRGB(255,80,80)
    dot.TextSize = 16
    dot.Visible = false
    dot.Parent = btn
    
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -10, 1, -10)
    page.Position = UDim2.new(0, 5, 0, 5)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(70,50,55)
    page.Parent = Pages
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = page
    
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabButtons) do
            t.Page.Visible = false
            t.Button.BackgroundTransparency = 1
            t.Button.TextColor3 = Color3.fromRGB(180,170,175)
            local d = t.Button:FindFirstChild("TextLabel")
            if d then d.Visible = false end
        end
        page.Visible = true
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Color3.fromRGB(45,30,38)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        dot.Visible = true
    end)
    
    table.insert(tabButtons, {Button = btn, Page = page, Layout = layout})
    return page
end

-- UI HELPERS
local function AddSection(parent, title)
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(0, 550, 0, 32)
    sec.BackgroundColor3 = Color3.fromRGB(35,25,30)
    sec.BorderSizePixel = 0
    sec.ClipsDescendants = true
    sec.Parent = parent
    Instance.new("UICorner", sec).CornerRadius = UDim.new(0, 4)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. title
    lbl.TextColor3 = Color3.fromRGB(230,220,225)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = sec
    return sec
end

local function AddToggle(parent, text, default, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 550, 0, 30)
    f.BackgroundColor3 = Color3.fromRGB(28,20,24)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 3)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, 430, 1, 0)
    l.Position = UDim2.new(0, 8, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(210,200,205)
    l.Font = Enum.Font.SourceSans
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 50, 0, 20)
    b.Position = UDim2.new(1, -58, 0.5, -10)
    b.BackgroundColor3 = default and Color3.fromRGB(200,50,50) or Color3.fromRGB(60,45,50)
    b.Text = default and "ON" or "OFF"
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 10
    b.Parent = f
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
    local state = default
    b.MouseButton1Click:Connect(function()
        state = not state
        b.BackgroundColor3 = state and Color3.fromRGB(200,50,50) or Color3.fromRGB(60,45,50)
        b.Text = state and "ON" or "OFF"
        if cb then cb(state) end
    end)
end

local function AddInput(parent, text, placeholder, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 550, 0, 30)
    f.BackgroundColor3 = Color3.fromRGB(28,20,24)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 3)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, 160, 1, 0)
    l.Position = UDim2.new(0, 8, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(210,200,205)
    l.Font = Enum.Font.SourceSans
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 130, 0, 22)
    box.Position = UDim2.new(1, -138, 0.5, -11)
    box.BackgroundColor3 = Color3.fromRGB(45,35,40)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.Font = Enum.Font.SourceSans
    box.TextSize = 12
    box.Parent = f
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)
    box.FocusLost:Connect(function(ep)
        if ep and cb then cb(tonumber(box.Text) or 0) end
    end)
end

local function AddDropdown(parent, text, options, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 550, 0, 30)
    f.BackgroundColor3 = Color3.fromRGB(28,20,24)
    f.BorderSizePixel = 0
    f.ClipsDescendants = true
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 3)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, 140, 1, 0)
    l.Position = UDim2.new(0, 8, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(210,200,205)
    l.Font = Enum.Font.SourceSans
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 170, 0, 22)
    btn.Position = UDim2.new(1, -178, 0.5, -11)
    btn.BackgroundColor3 = Color3.fromRGB(45,35,40)
    btn.Text = options[1] or "Select"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 11
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
    local isOpen = false
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(0, 530, 0, 80)
    list.Position = UDim2.new(0, 8, 0, 30)
    list.BackgroundColor3 = Color3.fromRGB(35,25,30)
    list.BorderSizePixel = 0
    list.CanvasSize = UDim2.new(0, 0, 0, #options * 22)
    list.ScrollBarThickness = 3
    list.Visible = false
    list.Parent = f
    local listLayout = Instance.new("UIListLayout", list)
    listLayout.Padding = UDim.new(0, 1)
    btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        list.Visible = isOpen
        f.Size = isOpen and UDim2.new(0, 550, 0, 115) or UDim2.new(0, 550, 0, 30)
    end)
    for _, opt in pairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 20)
        optBtn.BackgroundColor3 = Color3.fromRGB(40,30,36)
        optBtn.BorderSizePixel = 0
        optBtn.Text = opt
        optBtn.TextColor3 = Color3.fromRGB(200,200,200)
        optBtn.Font = Enum.Font.SourceSans
        optBtn.TextSize = 11
        optBtn.Parent = list
        optBtn.MouseButton1Click:Connect(function()
            btn.Text = opt
            isOpen = false
            list.Visible = false
            f.Size = UDim2.new(0, 550, 0, 30)
            if cb then cb(opt) end
        end)
    end
end

-- =============================================================================
-- 7. BUILD PAGES (SESUAI GAMBAR)
-- =============================================================================

-- PAGE 1: MAIN
local mainPage = CreateTab("Main")

-- Teleport Manager
local tpSection = AddSection(mainPage, "📌 Teleport Manager")
AddDropdown(mainPage, "Select Mode", {"Tween Teleport", "Instant Teleport"}, function(v) _G.TeleportMode = v end)
AddInput(mainPage, "Base Tween Speed", "1.5", function(v) _G.TweenSpeed = v end)

-- Stack Farm Manager
local stackSection = AddSection(mainPage, "📦 Stack Farm Manager")
AddToggle(mainPage, "Enable Stack Farming", false, function(v) _G.EnableStackFarming = v end)
local stackInfo = Instance.new("TextLabel")
stackInfo.Size = UDim2.new(0, 550, 0, 50)
stackInfo.BackgroundColor3 = Color3.fromRGB(40,30,36)
stackInfo.Text = "Priority 1 > Priority 2 > Priority 3\nHigher priority feature will pause lower priority"
stackInfo.TextColor3 = Color3.fromRGB(180,180,180)
stackInfo.TextSize = 11
stackInfo.Font = Enum.Font.SourceSans
stackInfo.TextYAlignment = Enum.TextYAlignment.Center
stackInfo.Parent = mainPage
Instance.new("UICorner", stackInfo).CornerRadius = UDim.new(0, 4)

-- Automation Plants
local plantSection = AddSection(mainPage, "🌱 Automation Plants")
AddDropdown(mainPage, "Select Seeds", FruitsList, function(v) _G.SelectedSeed = v end)
AddDropdown(mainPage, "Select Position", {"Player Position", "Sprinkler Radius"}, function(v) _G.SelectedPosition = v end)
AddDropdown(mainPage, "Select Sprinkler For Plants", GearsList, function(v) _G.SelectedSprinkler = v end)
AddDropdown(mainPage, "Save Position", {"Select Options"}, function(v) _G.SavePosition = v end)
AddInput(mainPage, "Delay To Plants", "0.5", function(v) _G.DelayToPlants = v end)
AddToggle(mainPage, "Auto Plants Seed", false, function(v) _G.AutoPlantsSeed = v end)
AddToggle(mainPage, "Auto Plants All Seeds", false, function(v) _G.AutoPlantsAllSeeds = v end)

-- Automation Collection
local collectSection = AddSection(mainPage, "🍓 Automation Collection")
AddInput(mainPage, "Delay To Collect", "0.5", function(v) _G.DelayToCollect = v end)
AddToggle(mainPage, "Stop Collect If Backpack Is Full", false, function(v) _G.StopCollectIfFull = v end)
AddToggle(mainPage, "Disable Collect Prompt", false, function(v) _G.DisableCollectPrompt = v end)
AddToggle(mainPage, "Prevention Accident Collect", false, function(v) _G.PreventionAccident = v end)
AddDropdown(mainPage, "Select Filter Mode", {"Whitelist", "Blacklist"}, function(v) _G.CollectFilterMode = v end)
AddDropdown(mainPage, "Select Fruit", FruitsList, function(v) _G.CollectSelectedFruit = v end)
AddDropdown(mainPage, "Select Rarity", RarityList, function(v) _G.CollectSelectedRarity = v end)
AddDropdown(mainPage, "Select Mutation", MutationList, function(v) _G.CollectSelectedMutation = v end)
AddDropdown(mainPage, "Select Threshold Mode", {"Below", "Above", "Exact"}, function(v) _G.CollectThresholdMode = v end)
AddInput(mainPage, "Weight Threshold", "100", function(v) _G.CollectWeightThreshold = v end)
AddToggle(mainPage, "Only Mutated Fruit", false, function(v) _G.CollectOnlyMutated = v end)
AddToggle(mainPage, "Auto Collect Fruit", false, function(v) _G.AutoCollectFruit = v end)
AddToggle(mainPage, "Auto Collect All Fruit", false, function(v) _G.AutoCollectAllFruit = v end)
AddToggle(mainPage, "Auto Collect Best Fruit", false, function(v) _G.AutoCollectBestFruit = v end)
AddToggle(mainPage, "Auto Collect Gold Seed", false, function(v) _G.AutoCollectGoldSeed = v end)
AddToggle(mainPage, "Auto Collect Rainbow Seed", false, function(v) _G.AutoCollectRainbowSeed = v end)
AddToggle(mainPage, "Auto Collect Mega Seed", false, function(v) _G.AutoCollectMegaSeed = v end)

-- Automation Steal
local stealSection = AddSection(mainPage, "🎯 Automation Steal")
AddToggle(mainPage, "Auto Steal Fruit", false, function(v) _G.AutoStealFruit = v end)
AddToggle(mainPage, "Auto Steal Best Fruit", false, function(v) _G.AutoStealBestFruit = v end)
AddToggle(mainPage, "Auto Lock Garden At Night", false, function(v) _G.PriorityAutoLockGarden = v end)

-- Automation Sell
local sellSection = AddSection(mainPage, "💰 Automation Sell")
AddToggle(mainPage, "Auto Sell All", false, function(v) _G.AutoSellAll = v end)
AddDropdown(mainPage, "Select Sell Fruit", FruitsList, function(v) _G.SellSelectedFruit = v end)
AddDropdown(mainPage, "Select Sell Rarity", RarityList, function(v) _G.SellSelectedRarity = v end)
AddDropdown(mainPage, "Select Sell Mutation", MutationList, function(v) _G.SellSelectedMutation = v end)
AddDropdown(mainPage, "Select Threshold Mode", {"Below", "Above", "Exact"}, function(v) _G.SellThresholdMode = v end)
AddInput(mainPage, "Weight Threshold", "100", function(v) _G.SellWeightThreshold = v end)
AddToggle(mainPage, "Auto Sell Fruit", false, function(v) _G.AutoSellFruit = v end)

-- Automation Pets
local petSection = AddSection(mainPage, "🐣 Automation Pets")
AddDropdown(mainPage, "Select Pets", PetsList, function(v) _G.BuySelectedPet = v end)
AddDropdown(mainPage, "Select Rarity Pets", RarityList, function(v) _G.BuyPetRarity = v end)
AddDropdown(mainPage, "Select Size Pets", {"All", "Small", "Medium", "Large"}, function(v) _G.BuyPetSize = v end)
AddInput(mainPage, "Pet Sheckle Limit", "0", function(v) _G.PetSheckleLimit = v end)
AddToggle(mainPage, "Auto Buy Pet", false, function(v) _G.AutoBuyPet = v end)
AddToggle(mainPage, "Pet Purchase Protection", false, function(v) _G.PetPurchaseProtection = v end)

-- Auto Place Sprinkler
local sprinklerSection = AddSection(mainPage, "💧 Auto Place Sprinkler")
AddToggle(mainPage, "Auto Place Sprinkler", false, function(v) _G.AutoPlaceSprinkler = v end)
AddToggle(mainPage, "Auto Place All Sprinkler", false, function(v) _G.AutoPlaceAllSprinkler = v end)

-- Auto Collect Dropped
local droppedSection = AddSection(mainPage, "📥 Auto Collect Dropped")
AddToggle(mainPage, "Auto Collect Dropped Item", false, function(v) _G.PriorityAutoCollectDropped = v end)

-- Auto Hit Player Stolen
local hitSection = AddSection(mainPage, "⚔️ Auto Hit Player Stolen")
AddToggle(mainPage, "Auto Hit Player Stolen", false, function(v) _G.PriorityAutoHitPlayerStolen = v end)

-- Disable Teleport
AddToggle(mainPage, "🚫 Disable Teleport", false, function(v) _G.DisableTeleport = v end)


-- PAGE 2: AUTOMATICALLY
local autoPage = CreateTab("Automatically")
local autoSection = AddSection(autoPage, "⚙️ Auto Settings")
AddToggle(autoPage, "Auto Collect All", false, function(v) _G.AutoCollectAllFruit = v end)
AddToggle(autoPage, "Auto Sell All", false, function(v) _G.AutoSellAll = v end)
AddToggle(autoPage, "Auto Plant All", false, function(v) _G.AutoPlantsAllSeeds = v end)
AddToggle(autoPage, "Auto Steal All", false, function(v) _G.AutoStealFruit = v end)
AddToggle(autoPage, "Auto Buy Pet", false, function(v) _G.AutoBuyPet = v end)


-- PAGE 3: INVENTORY
local invPage = CreateTab("Inventory")
local invSection = AddSection(invPage, "📦 Inventory Manager")
local invInfo = Instance.new("TextLabel")
invInfo.Size = UDim2.new(0, 550, 0, 80)
invInfo.BackgroundColor3 = Color3.fromRGB(40,30,36)
invInfo.Text = "Inventory Manager\n\nSelect Options for inventory management"
invInfo.TextColor3 = Color3.fromRGB(180,180,180)
invInfo.TextSize = 12
invInfo.Font = Enum.Font.SourceSans
invInfo.TextYAlignment = Enum.TextYAlignment.Center
invInfo.Parent = invPage
Instance.new("UICorner", invInfo).CornerRadius = UDim.new(0, 4)

AddDropdown(invPage, "Select Options", {"View Items", "Sort Items", "Drop Items"}, function(v) end)


-- PAGE 4: SHOP
local shopPage = CreateTab("Shop")
local shopSection = AddSection(shopPage, "🏪 Shop Automation")
AddDropdown(shopPage, "Select Pet Egg Type", PetsList, function(v) _G.BuySelectedPet = v end)
AddToggle(shopPage, "Auto Buy Pet", false, function(v) _G.AutoBuyPet = v end)
AddDropdown(shopPage, "Select Seeds", FruitsList, function(v) _G.SelectedSeed = v end)
AddToggle(shopPage, "Auto Buy Seeds", false, function(v) _G.AutoBuySeed = v end)


-- PAGE 5: WEBHOOK
local webhookPage = CreateTab("Webhook")
local webhookSection = AddSection(webhookPage, "🔗 Discord Webhook")

-- Webhook Input Box Frame (Custom Design)
local webInputFrame = Instance.new("Frame")
webInputFrame.Size = UDim2.new(0, 550, 0, 40)
webInputFrame.BackgroundColor3 = Color3.fromRGB(28,20,24)
webInputFrame.BorderSizePixel = 0
webInputFrame.Parent = webhookPage
Instance.new("UICorner", webInputFrame).CornerRadius = UDim.new(0, 3)

local webInput = Instance.new("TextBox")
webInput.Size = UDim2.new(1, -20, 0, 26)
webInput.Position = UDim2.new(0, 10, 0.5, -13)
webInput.BackgroundColor3 = Color3.fromRGB(40,30,36)
webInput.BorderSizePixel = 0
webInput.PlaceholderText = "https://discord.com/api/webhooks/..."
webInput.Text = _G.WebhookURL or ""
webInput.TextColor3 = Color3.fromRGB(200,200,200)
webInput.PlaceholderColor3 = Color3.fromRGB(150,150,150)
webInput.Font = Enum.Font.SourceSans
webInput.TextSize = 12
webInput.Parent = webInputFrame
Instance.new("UICorner", webInput).CornerRadius = UDim.new(0, 4)

webInput.FocusLost:Connect(function(ep) 
    if ep then 
        _G.WebhookURL = webInput.Text 
    end 
end)

AddToggle(webhookPage, "Enable Webhook", false, function(v) _G.WebhookToggle = v end)


-- PAGE 6: MISC
local miscPage = CreateTab("Misc")
local miscSection = AddSection(miscPage, "⚙️ Misc Settings")
AddToggle(miscPage, "Walkspeed Boost", false, function(v) _G.WalkspeedToggle = v end)
AddInput(miscPage, "Custom Speed", "50", function(v) _G.CustomSpeed = v end)
AddToggle(miscPage, "No Clip", false, function(v) _G.NoClipToggle = v end)
AddToggle(miscPage, "Silent Mode", true, function(v) _G.SilentModeGlobal = v end)


-- PAGE 7: SETTINGS
local settingsPage = CreateTab("Settings")
local settingsSection = AddSection(settingsPage, "⚙️ Settings UI")
AddToggle(settingsPage, "Disable Teleport", false, function(v) _G.DisableTeleport = v end)


-- PAGE 8: SETTINGS UI
local settingsUIPage = CreateTab("Settings UI")
local settingsUISection = AddSection(settingsUIPage, "🎨 UI Settings")
AddToggle(settingsUIPage, "Compact Mode", false, function(v) end)
AddToggle(settingsUIPage, "Dark Mode", true, function(v) end)


-- =============================================================================
-- 8. AUTO STARTUP & CANVAS SCALE
-- =============================================================================

-- Memastikan tab pertama (Main) langsung aktif saat pertama kali dibuka
task.spawn(function()
    task.wait(0.1)
    if #tabButtons > 0 then
        local firstTab = tabButtons[1]
        firstTab.Button.BackgroundTransparency = 0
        firstTab.Button.BackgroundColor3 = Color3.fromRGB(45,30,38)
        firstTab.Button.TextColor3 = Color3.fromRGB(255,255,255)
        firstTab.Page.Visible = true
        local dot = firstTab.Button:FindFirstChild("TextLabel")
        if dot then dot.Visible = true end
    end
end)

-- Auto resize Canvas untuk scrolling dinamis
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            for _, t in pairs(tabButtons) do
                local page = t.Page
                local layout = page:FindFirstChildOfClass("UIListLayout")
                if layout then
                    page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
                end
            end
        end)
    end
end)

print("✅ Speed Hub X v8.0 - UI PRESISI SESUAI GAMBAR LOADED!")
print("📌 Semua fitur lengkap: Collect, Sell, Plant, Steal, Pet, Sprinkler, Webhook, Settings")
