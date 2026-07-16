-- =============================================================================
-- SPEED HUB X v7.0 - ULTRA STABLE UI (FIXED)
-- =============================================================================

-- 1. DATABASE DATA
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

-- 2. GLOBAL STATES
_G.WalkspeedToggle = false
_G.NoClipToggle = false
_G.CustomSpeed = 50

-- Auto Collect Settings
_G.AutoCollectFruit = false
_G.AutoCollectAllFruit = false
_G.CollectSelectedFruit = "All"
_G.CollectMinWeight = 0  -- Minimal berat (kg)
_G.CollectMaxWeight = 80 -- Maksimal berat (kg)

-- Auto Sell Settings
_G.AutoSellAll = false
_G.AutoSellFruit = false
_G.SellSelectedFruit = "All"
_G.AutoSellFilter = "All" -- All, Common, Uncommon, Rare, Epic, Legendary, Mythic

-- Auto Buy Settings
_G.AutoBuySeed = false
_G.AutoBuyGear = false
_G.SelectedSeed = "Carrot"
_G.SelectedGear = "All"

_G.AutoBuyPet = false
_G.BuySelectedPet = "All"
_G.SilentModeGlobal = true 

-- =============================================================================
-- 3. PLAYER SETUP
-- =============================================================================
local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- =============================================================================
-- 4. FRUIT DETECTION
-- =============================================================================
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

    local blacklist = {"tree", "pohon", "trunk", "branch", "leaf", "stem", "wood", "log", "bark", "mail", "box", "pot", "plot", "soil", "dirt", "ground", "terrain", "wall", "floor", "roof", "door", "window", "fence", "gate", "sign", "board", "plank", "wooden"}
    for _, black in pairs(blacklist) do
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

    if string.find(name, "fruit") or string.find(name, "berry") or 
       string.find(name, "harvest") or string.find(name, "pick") then
        return true
    end

    return false
end

-- =============================================================================
-- 5. CORE LOGIC
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

-- Auto Collect with Weight Filter
task.spawn(function()
    while task.wait(0.2) do
        if not (_G.AutoCollectFruit or _G.AutoCollectAllFruit) then 
            task.wait(0.5)
            continue 
        end

        pcall(function()
            local char = Player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            for _, obj in pairs(Workspace:GetDescendants()) do
                if not (_G.AutoCollectFruit or _G.AutoCollectAllFruit) then break end

                if obj:IsA("TouchTransmitter") then
                    local item = obj.Parent
                    if item and isRealFruitOnly(item) then
                        local fruitName = item.Name
                        
                        -- Cek berat (kg) - ambil dari attribute atau ukuran
                        local weight = item:GetAttribute("Weight") or 0
                        if weight == 0 then
                            -- Estimasi berat dari ukuran
                            weight = math.floor((item.Size.X * item.Size.Y * item.Size.Z) * 10)
                        end
                        
                        -- Filter berdasarkan berat
                        local isMatch = _G.AutoCollectAllFruit or 
                                       _G.CollectSelectedFruit == "All" or 
                                       string.find(fruitName:lower(), _G.CollectSelectedFruit:lower())
                        
                        -- Cek weight range
                        local weightMatch = (weight >= _G.CollectMinWeight and weight <= _G.CollectMaxWeight)
                        
                        if isMatch and weightMatch then
                            if _G.SilentModeGlobal then
                                firetouchinterest(hrp, item, 0)
                                task.wait(0.02)
                                firetouchinterest(hrp, item, 1)
                                task.wait(0.02)
                            else
                                hrp.CFrame = item.CFrame + Vector3.new(0, 2, 0)
                                task.wait(0.05)
                                firetouchinterest(hrp, item, 0)
                                task.wait(0.05)
                                firetouchinterest(hrp, item, 1)
                            end
                        end
                    end
                end

                if obj:IsA("ProximityPrompt") then
                    local prompt = obj
                    local item = prompt.Parent
                    local promptText = (prompt.ObjectText or "") .. (prompt.ActionText or "")
                    promptText = promptText:lower()

                    local promptSkip = {"chop", "cut", "tree", "pohon", "wood", "log"}
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
                        local weight = item:GetAttribute("Weight") or 0
                        if weight == 0 then
                            weight = math.floor((item.Size.X * item.Size.Y * item.Size.Z) * 10)
                        end
                        
                        local isMatch = _G.AutoCollectAllFruit or 
                                       _G.CollectSelectedFruit == "All" or 
                                       string.find(fruitName:lower(), _G.CollectSelectedFruit:lower())
                        
                        local weightMatch = (weight >= _G.CollectMinWeight and weight <= _G.CollectMaxWeight)

                        if isMatch and weightMatch and prompt.Enabled then
                            if _G.SilentModeGlobal then
                                fireproximityprompt(prompt)
                                task.wait(0.05)
                            else
                                hrp.CFrame = item.CFrame + Vector3.new(0, 1, 0)
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

-- Auto Sell with Filter
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
                       string.find(promptText, "shop") then

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
        if not _G.AutoBuySeed then 
            task.wait(0.5)
            continue 
        end

        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local promptText = (obj.ObjectText or "") .. (obj.ActionText or "")
                    promptText = promptText:lower()

                    if string.find(promptText, "seed") or 
                       string.find(promptText, "buy") and string.find(promptText, "seed") then
                        fireproximityprompt(obj)
                        task.wait(0.05)
                    end
                end
            end
        end)
    end
end)

-- Auto Buy Gear
task.spawn(function()
    while task.wait(1) do
        if not _G.AutoBuyGear then 
            task.wait(0.5)
            continue 
        end

        pcall(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled then
                    local promptText = (obj.ObjectText or "") .. (obj.ActionText or "")
                    promptText = promptText:lower()

                    if string.find(promptText, "gear") or 
                       string.find(promptText, "tool") or
                       string.find(promptText, "buy") and string.find(promptText, "gear") then
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
                       string.find(promptText, "gacha") then
                        fireproximityprompt(obj)
                        task.wait(0.05)
                    end
                end
            end
        end)
    end
end)

-- =============================================================================
-- 6. UI GENERATOR - STABLE & CLEAN
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHubX_V7"
ScreenGui.ResetOnSpawn = false

local guiParent = game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")
ScreenGui.Parent = guiParent

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 460)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -230)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 13, 15)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(60, 40, 45)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Speed Hub X v7.0 | Anti Pohon"
Title.TextColor3 = Color3.fromRGB(255, 70, 70)
Title.TextSize = 13
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -33, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Tab Bar
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 30)
TabBar.Position = UDim2.new(0, 0, 0, 35)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 18, 22)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

-- Tab System
local tabs = {}
local currentTab = nil

local function CreateTab(tabName)
    -- Tab Button
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 65, 1, 0)
    TabBtn.Position = UDim2.new(0, #tabs * 65, 0, 0)
    TabBtn.BackgroundColor3 = Color3.fromRGB(35, 25, 30)
    TabBtn.BorderSizePixel = 0
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Color3.fromRGB(180, 170, 175)
    TabBtn.Font = Enum.Font.SourceSans
    TabBtn.TextSize = 12
    TabBtn.Parent = TabBar
    
    -- Content Page
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -10, 1, -75)
    Page.Position = UDim2.new(0, 5, 0, 70)
    Page.BackgroundTransparency = 1
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(70, 50, 55)
    Page.Visible = false
    Page.Parent = MainFrame
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 4)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageLayout.Parent = Page
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(tabs) do
            tab.Page.Visible = false
            tab.Button.BackgroundColor3 = Color3.fromRGB(35, 25, 30)
            tab.Button.TextColor3 = Color3.fromRGB(180, 170, 175)
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(55, 35, 40)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        currentTab = tabName
    end)
    
    table.insert(tabs, {Button = TabBtn, Page = Page})
    return Page
end

-- UI Helpers
local function AddSection(parent, title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(0, 460, 0, 32)
    Section.BackgroundColor3 = Color3.fromRGB(35, 25, 30)
    Section.BorderSizePixel = 0
    Section.ClipsDescendants = true
    Section.Parent = parent
    Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 4)
    
    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, 0, 1, 0)
    Header.BackgroundTransparency = 1
    Header.Text = "  " .. title
    Header.TextColor3 = Color3.fromRGB(230, 220, 225)
    Header.Font = Enum.Font.SourceSansBold
    Header.TextSize = 12
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Section
    
    return Section
end

local function AddToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 460, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 20, 24)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 3)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 340, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 200, 205)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 50, 0, 20)
    Btn.Position = UDim2.new(1, -58, 0.5, -10)
    Btn.BackgroundColor3 = default and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 45, 50)
    Btn.Text = default and "ON" or "OFF"
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.SourceSansBold
    Btn.TextSize = 10
    Btn.Parent = Frame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 3)
    
    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Btn.BackgroundColor3 = state and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(60, 45, 50)
        Btn.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end)
end

local function AddInput(parent, text, placeholder, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 460, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 20, 24)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 3)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 120, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 200, 205)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0, 120, 0, 22)
    Box.Position = UDim2.new(1, -128, 0.5, -11)
    Box.BackgroundColor3 = Color3.fromRGB(45, 35, 40)
    Box.PlaceholderText = placeholder
    Box.Text = ""
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.SourceSans
    Box.TextSize = 12
    Box.Parent = Frame
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 3)
    
    Box.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            callback(tonumber(Box.Text) or 0)
        end
    end)
end

local function AddDropdown(parent, text, options, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 460, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 20, 24)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 3)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 140, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 200, 205)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0, 180, 0, 22)
    DropBtn.Position = UDim2.new(1, -188, 0.5, -11)
    DropBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 40)
    DropBtn.Text = options[1] or "Select"
    DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropBtn.Font = Enum.Font.SourceSans
    DropBtn.TextSize = 11
    DropBtn.Parent = Frame
    Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 3)
    
    local isOpen = false
    local List = Instance.new("ScrollingFrame")
    List.Size = UDim2.new(0, 440, 0, 80)
    List.Position = UDim2.new(0, 8, 0, 30)
    List.BackgroundColor3 = Color3.fromRGB(35, 25, 30)
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
        Frame.Size = isOpen and UDim2.new(0, 460, 0, 115) or UDim2.new(0, 460, 0, 30)
    end)
    
    for _, opt in pairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, 0, 0, 20)
        OptBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 36)
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
            Frame.Size = UDim2.new(0, 460, 0, 30)
            if callback then callback(opt) end
        end)
    end
end

-- =============================================================================
-- 7. BUILD UI TABS
-- =============================================================================

-- TAB 1: COLLECT
local collectPage = CreateTab("Collect")

local collectSettingSection = AddSection(collectPage, "🍓 Auto Collect Settings")
AddToggle(collectSettingSection, "Auto Collect Filter Fruit", false, function(v) _G.AutoCollectFruit = v end)
AddToggle(collectSettingSection, "Auto Collect ALL Fruit", false, function(v) _G.AutoCollectAllFruit = v end)

local listFilter = {"All"}
for _, f in pairs(FruitsList) do 
    table.insert(listFilter, f) 
end
AddDropdown(collectSettingSection, "Select Fruit Filter", listFilter, function(v) _G.CollectSelectedFruit = v end)

local weightSection = AddSection(collectPage, "⚖️ Weight Filter (KG)")
AddInput(weightSection, "Min Weight (KG)", "0", function(v) _G.CollectMinWeight = v end)
AddInput(weightSection, "Max Weight (KG)", "80", function(v) _G.CollectMaxWeight = v end)

-- TAB 2: SELL
local sellPage = CreateTab("Sell")

local sellSettingSection = AddSection(sellPage, "💰 Auto Sell Settings")
AddToggle(sellSettingSection, "Auto Sell All", false, function(v) _G.AutoSellAll = v end)
AddToggle(sellSettingSection, "Auto Sell Filter Fruit", false, function(v) _G.AutoSellFruit = v end)
AddDropdown(sellSettingSection, "Select Fruit to Sell", listFilter, function(v) _G.SellSelectedFruit = v end)

local rarityFilter = {"All", "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"}
AddDropdown(sellSettingSection, "Rarity Filter", rarityFilter, function(v) _G.AutoSellFilter = v end)

-- TAB 3: BUY
local buyPage = CreateTab("Buy")

local buySeedSection = AddSection(buyPage, "🌱 Auto Buy Seed")
AddToggle(buySeedSection, "Auto Buy Seed", false, function(v) _G.AutoBuySeed = v end)
AddDropdown(buySeedSection, "Select Seed", FruitsList, function(v) _G.SelectedSeed = v end)

local buyGearSection = AddSection(buyPage, "🔧 Auto Buy Gear")
AddToggle(buyGearSection, "Auto Buy Gear", false, function(v) _G.AutoBuyGear = v end)
AddDropdown(buyGearSection, "Select Gear", GearsList, function(v) _G.SelectedGear = v end)

local buyPetSection = AddSection(buyPage, "🐣 Auto Buy Pet")
AddToggle(buyPetSection, "Auto Buy Pet", false, function(v) _G.AutoBuyPet = v end)
AddDropdown(buyPetSection, "Select Pet", PetsList, function(v) _G.BuySelectedPet = v end)

-- TAB 4: SETTINGS
local settingsPage = CreateTab("Settings")

local playerSection = AddSection(settingsPage, "⚙️ Player Settings")
AddToggle(playerSection, "Walkspeed Boost", false, function(v) _G.WalkspeedToggle = v end)
AddToggle(playerSection, "No Clip", false, function(v) _G.NoClipToggle = v end)
AddToggle(playerSection, "Silent Mode", true, function(v) _G.SilentModeGlobal = v end)

-- Select first tab
if #tabs > 0 then
    tabs[1].Button:MouseButton1Click()
end

-- Update Canvas Size
task.spawn(function()
    while task.wait(1) do
        for _, tab in pairs(tabs) do
            local page = tab.Page
            local layout = page:FindFirstChildOfClass("UIListLayout")
            if layout then
                page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
            end
        end
    end
end)

print("✅ Speed Hub X v7.0 LOADED!")
print("📌 Fitur: Auto Collect (dengan filter berat KG), Auto Sell (dengan filter rarity), Auto Buy Seed, Auto Buy Gear, Auto Buy Pet")
