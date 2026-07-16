-- =============================================================================
-- SPEED HUB X REMAKE - ULTRA STRICT FRUIT DETECTION v6.1 (FIXED UI)
-- =============================================================================

-- 1. DATABASE DATA COMPLETE
local FruitsList = {
    "Carrot", "Strawberry", "Blueberry", "Tulip", "Tomato", "Bamboo", 
    "Corn", "Apple", "Mango", "Mushroom", "Banana", "Grape", "Acorn", 
    "Rocket Pop", "Pineapple", "Cactus", "Dragon Fruit", "Cherry", 
    "Fire Fern", "Green Bean", "Coconut", "Sunflower", "Venus Fly Trap", 
    "Poison Apple", "Pomegranate", "Venom Spritter", "Sun Bloom", 
    "Moon Bloom", "Dragon's Breath", "Star Fruit"
}

local PetsList = {"All", "Bunny", "Frog", "Owl", "Monkey", "Robin", "Bee", "Bear", "Unicorn", "Golden Dragonfly", "Raccoon", "Turtle"}

-- 2. GLOBAL STATES
_G.WalkspeedToggle = false
_G.NoClipToggle = false
_G.CustomSpeed = 50

_G.AutoPlantsSeed = false
_G.AutoPlantsAllSeeds = false
_G.AutoCollectFruit = false
_G.AutoCollectAllFruit = false
_G.AutoSellAll = false
_G.AutoSellFruit = false
_G.AutoBuyPet = false
_G.SilentModeGlobal = true 

_G.SelectedSeed = "Carrot"
_G.CollectSelectedFruit = "All"
_G.SellSelectedFruit = "All"
_G.BuySelectedPet = "All"

-- =============================================================================
-- 3. PLAYER SETUP
-- =============================================================================
local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- =============================================================================
-- 4. ULTRA STRICT FRUIT DETECTION
-- =============================================================================
local BLACKLIST_NAMES = {
    "tree", "pohon", "trunk", "branch", "leaf", "stem", "wood", "log", "bark",
    "mail", "box", "pot", "plot", "soil", "dirt", "ground", "terrain", 
    "wall", "floor", "roof", "door", "window", "fence", "gate", "sign", 
    "board", "plank", "wooden", "oak", "pine", "maple", "birch", "spruce",
    "bush", "shrub", "grass", "weed", "flower", "tulip", "rose", "daisy"
}

local WHITELIST_PATTERNS = {
    "fruit", "berry", "apple", "mango", "melon", "pear", "peach", "grape",
    "banana", "orange", "lemon", "lime", "coconut", "pineapple", "carrot",
    "tomato", "corn", "mushroom", "bean", "nut", "acorn", "cherry", "cactus",
    "sunflower", "pomegranate", "dragon", "venus", "bloom", "breath", "star"
}

local function isRealFruitOnly(item)
    if not item then return false end
    
    if not item:IsA("BasePart") then 
        if item.Parent and item.Parent:IsA("BasePart") then
            item = item.Parent
        else
            return false
        end
    end

    local name = item.Name:lower()
    local size = item.Size
    local parentName = item.Parent and item.Parent.Name:lower() or ""

    for _, black in pairs(BLACKLIST_NAMES) do
        if string.find(name, black) or string.find(parentName, black) then
            return false
        end
    end

    if size.X > 5 or size.Y > 5 or size.Z > 5 then
        return false
    end

    local material = item.Material
    if material == Enum.Material.Wood or material == Enum.Material.WoodPlanks or 
       material == Enum.Material.Grass or material == Enum.Material.Sandstone then
        return false
    end

    for _, fruit in pairs(FruitsList) do
        if string.find(name, fruit:lower()) then
            return true
        end
    end

    for _, pattern in pairs(WHITELIST_PATTERNS) do
        if string.find(name, pattern) then
            return true
        end
    end

    if string.find(name, "fruit") or string.find(name, "berry") or 
       string.find(name, "harvest") or string.find(name, "pick") then
        return true
    end

    return false
end

-- =============================================================================
-- 5. CORE LOGIC ENGINE
-- =============================================================================

-- Walkspeed & NoClip
task.spawn(function()
    RunService.Heartbeat:Connect(function()
        pcall(function()
            local character = Player.Character
            if not character then return end

            if _G.WalkspeedToggle then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = _G.CustomSpeed
                end
            end

            if _G.NoClipToggle then
                for _, part in pairs(character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end)
end)

-- Auto Collect
task.spawn(function()
    while task.wait(0.15) do
        if not (_G.AutoCollectFruit or _G.AutoCollectAllFruit) then 
            task.wait(0.5)
            continue 
        end

        pcall(function()
            local char = Player.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local validTargets = {}

            for _, obj in pairs(Workspace:GetDescendants()) do
                if not (_G.AutoCollectFruit or _G.AutoCollectAllFruit) then break end

                local objName = (obj.Name or ""):lower()
                local parentName = (obj.Parent and obj.Parent.Name or ""):lower()

                local skipKeywords = {"tree", "pohon", "trunk", "branch", "leaf", "stem", "wood", "log"}
                local shouldSkip = false
                for _, keyword in pairs(skipKeywords) do
                    if string.find(objName, keyword) or string.find(parentName, keyword) then
                        shouldSkip = true
                        break
                    end
                end
                if shouldSkip then continue end

                if obj:IsA("TouchTransmitter") then
                    local item = obj.Parent
                    if item and isRealFruitOnly(item) then
                        local fruitName = item.Name
                        local isMatch = _G.AutoCollectAllFruit or 
                                       _G.CollectSelectedFruit == "All" or 
                                       string.find(fruitName:lower(), _G.CollectSelectedFruit:lower())

                        if isMatch then
                            table.insert(validTargets, {type = "touch", item = item})
                        end
                    end
                end

                if obj:IsA("ProximityPrompt") then
                    local prompt = obj
                    local item = prompt.Parent

                    local promptText = (prompt.ObjectText or "") .. (prompt.ActionText or "")
                    promptText = promptText:lower()

                    local promptSkip = {"chop", "cut", "tree", "pohon", "wood", "log", "branch"}
                    local isTreePrompt = false
                    for _, keyword in pairs(promptSkip) do
                        if string.find(promptText, keyword) then
                            isTreePrompt = true
                            break
                        end
                    end
                    if isTreePrompt then continue end

                    if item and isRealFruitOnly(item) then
                        local fruitName = item.Name
                        local isMatch = _G.AutoCollectAllFruit or 
                                       _G.CollectSelectedFruit == "All" or 
                                       string.find(fruitName:lower(), _G.CollectSelectedFruit:lower())

                        if isMatch and prompt.Enabled then
                            table.insert(validTargets, {type = "prompt", prompt = prompt, item = item})
                        end
                    end
                end
            end

            for _, target in pairs(validTargets) do
                if target.type == "touch" then
                    if _G.SilentModeGlobal then
                        firetouchinterest(hrp, target.item, 0)
                        task.wait(0.02)
                        firetouchinterest(hrp, target.item, 1)
                        task.wait(0.02)
                    else
                        hrp.CFrame = target.item.CFrame + Vector3.new(0, 2, 0)
                        task.wait(0.05)
                        firetouchinterest(hrp, target.item, 0)
                        task.wait(0.05)
                        firetouchinterest(hrp, target.item, 1)
                    end
                elseif target.type == "prompt" then
                    if _G.SilentModeGlobal then
                        fireproximityprompt(target.prompt)
                        task.wait(0.05)
                    else
                        hrp.CFrame = target.item.CFrame + Vector3.new(0, 1, 0)
                        task.wait(0.1)
                        fireproximityprompt(target.prompt)
                    end
                end
            end
        end)
    end
end)

-- Auto Plants
task.spawn(function()
    while task.wait(0.5) do
        if not (_G.AutoPlantsSeed or _G.AutoPlantsAllSeeds) then 
            task.wait(0.5)
            continue 
        end

        pcall(function()
            local char = Player.Character
            if not char then return end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            for _, obj in pairs(Workspace:GetDescendants()) do
                if not (_G.AutoPlantsSeed or _G.AutoPlantsAllSeeds) then break end

                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local promptText = (obj.ObjectText or "") .. (obj.ActionText or "")
                    promptText = promptText:lower()

                    if string.find(promptText, "plant") or 
                       string.find(promptText, "seed") or
                       string.find(promptText, "pot") or
                       string.find(promptText, "soil") then

                        if _G.SilentModeGlobal then
                            fireproximityprompt(obj)
                            task.wait(0.05)
                        else
                            local parent = obj.Parent
                            if parent and parent:IsA("BasePart") then
                                hrp.CFrame = parent.CFrame + Vector3.new(0, 1, 0)
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

-- Auto Sell
task.spawn(function()
    while task.wait(0.5) do
        if not (_G.AutoSellAll or _G.AutoSellFruit) then 
            task.wait(0.5)
            continue 
        end

        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local promptText = (obj.ObjectText or "") .. (obj.ActionText or "")
                    promptText = promptText:lower()

                    if string.find(promptText, "merchant") or 
                       string.find(promptText, "sell") or 
                       string.find(promptText, "shop") or
                       string.find(promptText, "trade") then

                        fireproximityprompt(obj)
                        task.wait(0.05)
                    end
                end
            end
        end)
    end
end)

-- Auto Buy Pet
task.spawn(function()
    while task.wait(1) do
        if not _G.AutoBuyPet then 
            task.wait(0.5)
            continue 
        end

        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local promptText = (obj.ObjectText or "") .. (obj.ActionText or "")
                    promptText = promptText:lower()

                    if string.find(promptText, "egg") or 
                       string.find(promptText, "pet") or 
                       string.find(promptText, "gacha") or
                       string.find(promptText, "hatch") then

                        fireproximityprompt(obj)
                        task.wait(0.05)
                    end
                end
            end
        end)
    end
end)

-- =============================================================================
-- 6. UI GENERATOR - FIXED & STABLE
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHubX_V6"
ScreenGui.ResetOnSpawn = false

local guiParent = game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")
pcall(function() ScreenGui.Parent = guiParent end)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 480, 0, 420)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 13, 13)
MainFrame.BorderSizePixel = 0
MainFrame.BackgroundTransparency = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -70, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Text = "Speed Hub X v6.1 - ANTI POHON"
TitleLabel.TextColor3 = Color3.fromRGB(255, 70, 70)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -33, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() 
    ScreenGui:Destroy() 
end)

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.Position = UDim2.new(0, 0, 0, 32)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 18, 18)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local tabs = {}
local currentTab = nil

local function CreateTab(name)
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 80, 1, 0)
    TabBtn.Position = UDim2.new(0, #tabs * 80, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 25)
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = name
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.SourceSans
    TabBtn.TextSize = 12
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 0)
    
    -- Content Frame
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -10, 1, -75)
    Content.Position = UDim2.new(0, 5, 0, 67)
    Content.BackgroundTransparency = 1
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.ScrollBarThickness = 4
    Content.ScrollBarImageColor3 = Color3.fromRGB(70, 35, 35)
    Content.Visible = false
    Content.Parent = MainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = Content
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(tabs) do
            tab.Content.Visible = false
            tab.Button.BackgroundColor3 = Color3.fromRGB(35, 25, 25)
            tab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        Content.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(55, 35, 35)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        currentTab = name
    end)
    
    table.insert(tabs, {Button = TabBtn, Content = Content, Layout = layout})
    return Content
end

-- Helper Functions
local function AddSection(parent, title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(0, 450, 0, 35)
    Section.BackgroundColor3 = Color3.fromRGB(35, 25, 25)
    Section.BorderSizePixel = 0
    Section.ClipsDescendants = true
    Section.Parent = parent
    Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 4)
    
    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, 0, 1, 0)
    Header.BackgroundTransparency = 1
    Header.Text = "  " .. title
    Header.TextColor3 = Color3.fromRGB(230, 230, 230)
    Header.Font = Enum.Font.SourceSansBold
    Header.TextSize = 13
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Section
    
    return Section
end

local function AddToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 450, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 3)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 340, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 210)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 48, 0, 20)
    Btn.Position = UDim2.new(1, -56, 0.5, -10)
    Btn.BackgroundColor3 = default and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 45, 45)
    Btn.Text = default and "ON" or "OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 10
    Btn.Parent = Frame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 3)
    
    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 45, 45)
        Btn.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end)
end

local function AddDropdown(parent, text, options, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 450, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 3)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 200, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 210, 210)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0, 160, 0, 22)
    DropBtn.Position = UDim2.new(1, -168, 0.5, -11)
    DropBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 35)
    DropBtn.Text = options[1] or "Select"
    DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropBtn.Font = Enum.Font.SourceSans
    DropBtn.TextSize = 11
    DropBtn.Parent = Frame
    Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 3)
    
    local isOpen = false
    local List = Instance.new("ScrollingFrame")
    List.Size = UDim2.new(0, 430, 0, 80)
    List.Position = UDim2.new(0, 8, 0, 30)
    List.BackgroundColor3 = Color3.fromRGB(35, 25, 25)
    List.BorderSizePixel = 0
    List.CanvasSize = UDim2.new(0, 0, 0, #options * 22)
    List.ScrollBarThickness = 3
    List.Visible = false
    List.Parent = Frame
    
    local ListLayout = Instance.new("UIListLayout", List)
    ListLayout.Padding = UDim.new(0, 1)
    
    DropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        List.Visible = isOpen
        Frame.Size = isOpen and UDim2.new(0, 450, 0, 115) or UDim2.new(0, 450, 0, 30)
    end)
    
    for _, opt in pairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 20)
        OptBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
        OptBtn.BorderSizePixel = 0
        OptBtn.Text = opt
        OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        OptBtn.Font = Enum.Font.SourceSans
        OptBtn.TextSize = 11
        OptBtn.Parent = List
        
        OptBtn.MouseButton1Click:Connect(function()
            DropBtn.Text = opt
            isOpen = false
            List.Visible = false
            Frame.Size = UDim2.new(0, 450, 0, 30)
            if callback then callback(opt) end
        end)
    end
end

-- =============================================================================
-- 7. BUILD UI TABS
-- =============================================================================

-- TAB 1: HOME
local homeTab = CreateTab("Home")
local homeSection = AddSection(homeTab, "⚙️ Player Settings")
AddToggle(homeSection, "Walkspeed Boost", false, function(v) _G.WalkspeedToggle = v end)
AddToggle(homeSection, "No Clip", false, function(v) _G.NoClipToggle = v end)
AddToggle(homeSection, "Silent Mode", true, function(v) _G.SilentModeGlobal = v end)

-- TAB 2: COLLECT
local collectTab = CreateTab("Collect")
local collectSection = AddSection(collectTab, "🍓 Auto Collect")
local listFilter = {"All"}
for _, f in pairs(FruitsList) do 
    table.insert(listFilter, f) 
end
AddDropdown(collectSection, "Fruit Filter", listFilter, function(v) _G.CollectSelectedFruit = v end)
AddToggle(collectSection, "Auto Collect Filter Fruit", false, function(v) _G.AutoCollectFruit = v end)
AddToggle(collectSection, "Auto Collect ALL Fruit", false, function(v) _G.AutoCollectAllFruit = v end)

-- TAB 3: PLANT
local plantTab = CreateTab("Plant")
local plantSection = AddSection(plantTab, "🌱 Auto Plant")
AddDropdown(plantSection, "Select Seed", FruitsList, function(v) _G.SelectedSeed = v end)
AddToggle(plantSection, "Auto Plant Selected Seed", false, function(v) _G.AutoPlantsSeed = v end)
AddToggle(plantSection, "Auto Plant All Seeds", false, function(v) _G.AutoPlantsAllSeeds = v end)

-- TAB 4: SELL
local sellTab = CreateTab("Sell")
local sellSection = AddSection(sellTab, "💰 Auto Sell")
AddDropdown(sellSection, "Sell Filter", listFilter, function(v) _G.SellSelectedFruit = v end)
AddToggle(sellSection, "Auto Sell All", false, function(v) _G.AutoSellAll = v end)
AddToggle(sellSection, "Auto Sell Filter Fruit", false, function(v) _G.AutoSellFruit = v end)

-- TAB 5: PET
local petTab = CreateTab("Pet")
local petSection = AddSection(petTab, "🐣 Auto Pet")
AddDropdown(petSection, "Pet Type", PetsList, function(v) _G.BuySelectedPet = v end)
AddToggle(petSection, "Auto Buy Pet", false, function(v) _G.AutoBuyPet = v end)

-- Select first tab by default
if #tabs > 0 then
    tabs[1].Button:MouseButton1Click()
end

-- Update CanvasSize for each tab
task.spawn(function()
    while task.wait(1) do
        for _, tab in pairs(tabs) do
            local content = tab.Content
            local layout = content:FindFirstChildOfClass("UIListLayout")
            if layout then
                content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
            end
        end
    end
end)

print("✅ Speed Hub X v6.1 - ANTI POHON Loaded!")
print("📌 100% Tidak akan mengcollect pohon!")
print("📌 UI telah diperbaiki dan stabil!")
