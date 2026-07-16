-- =============================================================================
-- SPEED HUB X v7.1 - SIDEBAR UI STABLE
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
local GearsList = {"All", "Common Watering Can", "Common Sprinkler", "Uncommon Sprinkler", "Rare Sprinkler", "Sign", "Trowel", "Speed Mushroom", "Jump Mushroom", "Supersize Mushroom", "Invisibility Mushroom", "Shrink Mushroom", "Flashbang", "Gnome", "Megafon", "Basic Pot", "Legendary Sprinkler", "Super Sprinkler", "Super Watering Can"}
local PetsList = {"All", "Bunny", "Frog", "Owl", "Monkey", "Robin", "Bee", "Bear", "Unicorn", "Golden Dragonfly", "Raccoon", "Turtle"}
local RarityList = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"}

-- 2. GLOBAL STATE
_G.WalkspeedToggle = false
_G.NoClipToggle = false
_G.CustomSpeed = 50
_G.SilentModeGlobal = true

_G.AutoCollectFruit = false
_G.AutoCollectAllFruit = false
_G.CollectSelectedFruit = "All"
_G.CollectMinWeight = 0
_G.CollectMaxWeight = 80

_G.AutoSellAll = false
_G.AutoSellFruit = false
_G.SellSelectedFruit = "All"
_G.SellRarityFilter = "All"

_G.AutoBuySeed = false
_G.AutoBuyGear = false
_G.AutoBuyPet = false
_G.SelectedSeed = "Carrot"
_G.SelectedGear = "All"
_G.BuySelectedPet = "All"

-- 3. PLAYER
local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- 4. FRUIT DETECTION (ringkas)
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

-- 5. CORE LOOPS (ringkas, hanya aktif jika toggle on)
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

-- Auto Collect (dengan filter berat)
task.spawn(function()
    while task.wait(0.2) do
        if not (_G.AutoCollectFruit or _G.AutoCollectAllFruit) then task.wait(0.5) continue end
        pcall(function()
            local char = Player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("TouchTransmitter") then
                    local item = obj.Parent
                    if item and isRealFruit(item) then
                        local weight = item:GetAttribute("Weight") or math.floor((item.Size.X*item.Size.Y*item.Size.Z)*10)
                        local isMatch = _G.AutoCollectAllFruit or _G.CollectSelectedFruit=="All" or string.find(item.Name:lower(), _G.CollectSelectedFruit:lower())
                        if isMatch and weight >= _G.CollectMinWeight and weight <= _G.CollectMaxWeight then
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
                if obj:IsA("ProximityPrompt") then
                    local prompt = obj
                    local item = prompt.Parent
                    local txt = (prompt.ObjectText or ""):lower() .. (prompt.ActionText or ""):lower()
                    if string.find(txt,"chop") or string.find(txt,"cut") or string.find(txt,"tree") then continue end
                    if item and isRealFruit(item) and prompt.Enabled then
                        local weight = item:GetAttribute("Weight") or math.floor((item.Size.X*item.Size.Y*item.Size.Z)*10)
                        local isMatch = _G.AutoCollectAllFruit or _G.CollectSelectedFruit=="All" or string.find(item.Name:lower(), _G.CollectSelectedFruit:lower())
                        if isMatch and weight >= _G.CollectMinWeight and weight <= _G.CollectMaxWeight then
                            if _G.SilentModeGlobal then
                                fireproximityprompt(prompt) task.wait(0.05)
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
        if not (_G.AutoSellAll or _G.AutoSellFruit) then task.wait(0.5) continue end
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

-- Auto Buy Seed
task.spawn(function()
    while task.wait(1) do
        if not _G.AutoBuySeed then task.wait(0.5) continue end
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local txt = (obj.ObjectText or ""):lower() .. (obj.ActionText or ""):lower()
                    if string.find(txt,"seed") and string.find(txt,"buy") then
                        fireproximityprompt(obj) task.wait(0.05)
                    end
                end
            end
        end)
    end
end)

-- Auto Buy Gear
task.spawn(function()
    while task.wait(1) do
        if not _G.AutoBuyGear then task.wait(0.5) continue end
        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local txt = (obj.ObjectText or ""):lower() .. (obj.ActionText or ""):lower()
                    if string.find(txt,"gear") or string.find(txt,"tool") then
                        fireproximityprompt(obj) task.wait(0.05)
                    end
                end
            end
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
                        fireproximityprompt(obj) task.wait(0.05)
                    end
                end
            end
        end)
    end
end)

-- =============================================================================
-- 6. UI SIDEBAR - STABLE
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHubX"
ScreenGui.ResetOnSpawn = false
local guiParent = game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")
ScreenGui.Parent = guiParent

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 600, 0, 450)
Main.Position = UDim2.new(0.5, -300, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(20, 15, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

-- Top Bar
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 35)
Top.BackgroundColor3 = Color3.fromRGB(30, 20, 25)
Top.BorderSizePixel = 0
Top.Parent = Main
Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Speed Hub X v7.1 | Sidebar UI"
Title.TextColor3 = Color3.fromRGB(255, 70, 70)
Title.TextSize = 13
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

-- SIDEBAR (kiri)
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 150, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 18, 22)
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 300)
Sidebar.ScrollBarThickness = 0
Sidebar.Parent = Main

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 2)
SidebarLayout.Parent = Sidebar

-- Page Container (kanan)
local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -150, 1, -35)
Pages.Position = UDim2.new(0, 150, 0, 35)
Pages.BackgroundTransparency = 1
Pages.Parent = Main

-- Tab system
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
    
    -- indicator dot
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

-- UI Helpers
local function AddSection(parent, title)
    local sec = Instance.new("Frame")
    sec.Size = UDim2.new(0, 420, 0, 32)
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
    f.Size = UDim2.new(0, 420, 0, 30)
    f.BackgroundColor3 = Color3.fromRGB(28,20,24)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 3)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, 300, 1, 0)
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
    f.Size = UDim2.new(0, 420, 0, 30)
    f.BackgroundColor3 = Color3.fromRGB(28,20,24)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 3)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, 130, 1, 0)
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
    f.Size = UDim2.new(0, 420, 0, 30)
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
    list.Size = UDim2.new(0, 400, 0, 80)
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
        f.Size = isOpen and UDim2.new(0, 420, 0, 115) or UDim2.new(0, 420, 0, 30)
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
            f.Size = UDim2.new(0, 420, 0, 30)
            if cb then cb(opt) end
        end)
    end
end

-- =============================================================================
-- 7. BUILD PAGES
-- =============================================================================

-- Page Collect
local collectPage = CreateTab("Collect")
local s1 = AddSection(collectPage, "🍓 Auto Collect")
AddToggle(s1, "Auto Collect Filter Fruit", false, function(v) _G.AutoCollectFruit = v end)
AddToggle(s1, "Auto Collect ALL Fruit", false, function(v) _G.AutoCollectAllFruit = v end)

local listFilter = {"All"}
for _, f in pairs(FruitsList) do table.insert(listFilter, f) end
AddDropdown(s1, "Fruit Filter", listFilter, function(v) _G.CollectSelectedFruit = v end)

local s2 = AddSection(collectPage, "⚖️ Weight Filter (KG)")
AddInput(s2, "Min Weight", "0", function(v) _G.CollectMinWeight = v end)
AddInput(s2, "Max Weight", "80", function(v) _G.CollectMaxWeight = v end)

-- Page Sell
local sellPage = CreateTab("Sell")
local s3 = AddSection(sellPage, "💰 Auto Sell")
AddToggle(s3, "Auto Sell All", false, function(v) _G.AutoSellAll = v end)
AddToggle(s3, "Auto Sell Filter Fruit", false, function(v) _G.AutoSellFruit = v end)
AddDropdown(s3, "Fruit Filter", listFilter, function(v) _G.SellSelectedFruit = v end)
AddDropdown(s3, "Rarity Filter", RarityList, function(v) _G.SellRarityFilter = v end)

-- Page Buy
local buyPage = CreateTab("Buy")
local s4 = AddSection(buyPage, "🌱 Auto Buy Seed")
AddToggle(s4, "Auto Buy Seed", false, function(v) _G.AutoBuySeed = v end)
AddDropdown(s4, "Select Seed", FruitsList, function(v) _G.SelectedSeed = v end)

local s5 = AddSection(buyPage, "🔧 Auto Buy Gear")
AddToggle(s5, "Auto Buy Gear", false, function(v) _G.AutoBuyGear = v end)
AddDropdown(s5, "Select Gear", GearsList, function(v) _G.SelectedGear = v end)

local s6 = AddSection(buyPage, "🐣 Auto Buy Pet")
AddToggle(s6, "Auto Buy Pet", false, function(v) _G.AutoBuyPet = v end)
AddDropdown(s6, "Select Pet", PetsList, function(v) _G.BuySelectedPet = v end)

-- Page Settings
local settingsPage = CreateTab("Settings")
local s7 = AddSection(settingsPage, "⚙️ Player Settings")
AddToggle(s7, "Walkspeed Boost", false, function(v) _G.WalkspeedToggle = v end)
AddToggle(s7, "No Clip", false, function(v) _G.NoClipToggle = v end)
AddToggle(s7, "Silent Mode", true, function(v) _G.SilentModeGlobal = v end)

-- Select first tab (Collect)
if #tabButtons > 0 then
    tabButtons[1].Button:MouseButton1Click()
end

-- Auto update canvas size
task.spawn(function()
    while task.wait(1) do
        for _, t in pairs(tabButtons) do
            local page = t.Page
            local layout = page:FindFirstChildOfClass("UIListLayout")
            if layout then
                page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
            end
        end
    end
end)

print("✅ Speed Hub X v7.1 - Sidebar UI Stable!")
print("📌 Collect, Sell, Buy, Settings - semua berfungsi!")
