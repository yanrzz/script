-- =============================================================================
-- SPEED HUB X v6.2 - UI PRESISI (SESUAI GAMBAR)
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
-- 6. UI GENERATOR - PRESISI SESUAI GAMBAR
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedHubX_V6"
ScreenGui.ResetOnSpawn = false

local guiParent = game:GetService("CoreGui") or Player:WaitForChild("PlayerGui")
pcall(function() ScreenGui.Parent = guiParent end)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 450)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 18)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(60, 40, 45)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

-- Top Bar (Header)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 20, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Speed Hub X | Version 6.2 | discord.gg/speedhubx"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.TextSize = 12
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
CloseBtn.MouseButton1Click:Connect(function() 
    ScreenGui:Destroy() 
end)

-- SIDEBAR (KIRI)
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 160, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 18, 22)
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 400)
Sidebar.ScrollBarThickness = 0
Sidebar.Parent = MainFrame

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 2)
SidebarLayout.Parent = Sidebar

-- Search Box
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -10, 0, 28)
SearchBox.Position = UDim2.new(0, 5, 0, 5)
SearchBox.BackgroundColor3 = Color3.fromRGB(40, 28, 35)
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "🔍 Search"
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 12
SearchBox.Parent = Sidebar
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

-- Page Container (KANAN)
local PageContainer = Instance.new("Frame")
PageContainer.Size = UDim2.new(1, -160, 1, -35)
PageContainer.Position = UDim2.new(0, 160, 0, 35)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

-- Tab System
local tabs = {}
local currentTab = nil

local function CreateTab(tabName, icon)
    -- Sidebar Button
    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(1, -10, 0, 32)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = "   " .. tabName
    TabBtn.TextColor3 = Color3.fromRGB(180, 170, 175)
    TabBtn.Font = Enum.Font.SourceSans
    TabBtn.TextSize = 13
    TabBtn.TextXAlignment = Enum.TextXAlignment.Left
    TabBtn.Parent = Sidebar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)
    
    -- Icon indicator
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 20, 1, 0)
    Icon.Position = UDim2.new(0, 5, 0, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = "•"
    Icon.TextColor3 = Color3.fromRGB(255, 80, 80)
    Icon.TextSize = 16
    Icon.Visible = false
    Icon.Parent = TabBtn
    
    -- Content Page
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -10, 1, -10)
    Page.Position = UDim2.new(0, 5, 0, 5)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = Color3.fromRGB(70, 50, 55)
    Page.Parent = PageContainer
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 5)
    PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    PageLayout.Parent = Page
    
    -- Click handler
    TabBtn.MouseButton1Click:Connect(function()
        for _, tab in pairs(tabs) do
            tab.Page.Visible = false
            tab.Button.BackgroundTransparency = 1
            tab.Button.TextColor3 = Color3.fromRGB(180, 170, 175)
            local icon = tab.Button:FindFirstChild("TextLabel")
            if icon then icon.Visible = false end
        end
        
        Page.Visible = true
        TabBtn.BackgroundTransparency = 0
        TabBtn.BackgroundColor3 = Color3.fromRGB(45, 30, 38)
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Icon.Visible = true
        currentTab = tabName
    end)
    
    table.insert(tabs, {Button = TabBtn, Page = Page, Layout = PageLayout, Name = tabName})
    return Page
end

-- UI Helper Functions
local function AddSection(parent, title)
    local Section = Instance.new("Frame")
    Section.Size = UDim2.new(0, 410, 0, 0)
    Section.BackgroundColor3 = Color3.fromRGB(30, 22, 27)
    Section.BorderSizePixel = 0
    Section.ClipsDescendants = true
    Section.Parent = parent
    Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 4)
    
    local Header = Instance.new("TextButton")
    Header.Size = UDim2.new(1, 0, 0, 32)
    Header.BackgroundColor3 = Color3.fromRGB(38, 28, 34)
    Header.BorderSizePixel = 0
    Header.Text = "  " .. title
    Header.TextColor3 = Color3.fromRGB(230, 220, 225)
    Header.Font = Enum.Font.SourceSansBold
    Header.TextSize = 12
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Section
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 4)
    
    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 30, 1, 0)
    Arrow.Position = UDim2.new(1, -35, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = Color3.fromRGB(180, 170, 175)
    Arrow.Font = Enum.Font.SourceSansBold
    Arrow.TextSize = 12
    Arrow.Parent = Header
    
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 0, 0)
    Content.BackgroundTransparency = 1
    Content.Parent = Section
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 3)
    ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ContentLayout.Parent = Content
    Instance.new("UIPadding", Content).PaddingTop = UDim.new(0, 3)
    
    local isOpen = true
    
    local function UpdateSize()
        if isOpen then
            Section.Size = UDim2.new(0, 410, 0, 32 + ContentLayout.AbsoluteContentSize.Y + 5)
        else
            Section.Size = UDim2.new(0, 410, 0, 32)
        end
        
        local pLayout = parent:FindFirstChildOfClass("UIListLayout")
        if pLayout then
            parent.CanvasSize = UDim2.new(0, 0, 0, pLayout.AbsoluteContentSize.Y + 10)
        end
    end
    
    Header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        Arrow.Text = isOpen and "▼" or "▶"
        UpdateSize()
    end)
    
    task.wait(0.05)
    UpdateSize()
    
    return Content
end

local function AddToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 395, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 30, 36)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 3)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 280, 1, 0)
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

local function AddDropdown(parent, text, options, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 395, 0, 30)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 30, 36)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 3)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 160, 1, 0)
    Label.Position = UDim2.new(0, 8, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(210, 200, 205)
    Label.Font = Enum.Font.SourceSans
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame
    
    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(0, 160, 0, 22)
    DropBtn.Position = UDim2.new(1, -168, 0.5, -11)
    DropBtn.BackgroundColor3 = Color3.fromRGB(50, 38, 45)
    DropBtn.Text = options[1] or "Select"
    DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropBtn.Font = Enum.Font.SourceSans
    DropBtn.TextSize = 11
    DropBtn.Parent = Frame
    Instance.new("UICorner", DropBtn).CornerRadius = UDim.new(0, 3)
    
    local isOpen = false
    local List = Instance.new("ScrollingFrame")
    List.Size = UDim2.new(0, 378, 0, 80)
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
        Frame.Size = isOpen and UDim2.new(0, 395, 0, 115) or UDim2.new(0, 395, 0, 30)
        
        local layout = parent:FindFirstChildOfClass("UIListLayout")
        if layout then
            parent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
        end
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
            Frame.Size = UDim2.new(0, 395, 0, 30)
            if callback then callback(opt) end
            
            local layout = parent:FindFirstChildOfClass("UIListLayout")
            if layout then
                parent.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
            end
        end)
    end
end

-- =============================================================================
-- 7. BUILD TABS - SESUAI GAMBAR
-- =============================================================================

-- TAB 1: HOME
local homePage = CreateTab("Home")
local homeSection = AddSection(homePage, "⚙️ Player Settings")
AddToggle(homeSection, "Walkspeed Boost", false, function(v) _G.WalkspeedToggle = v end)
AddToggle(homeSection, "No Clip", false, function(v) _G.NoClipToggle = v end)
AddToggle(homeSection, "Silent Mode", true, function(v) _G.SilentModeGlobal = v end)

-- TAB 2: MAIN
local mainPage = CreateTab("Main")
local mainSection = AddSection(mainPage, "⚙️ Automation Main")

-- Teleport Manager
local teleportSection = AddSection(mainPage, "📌 Teleport Manager")
AddToggle(teleportSection, "Auto Teleport to Fruit", false, function(v) end)

-- Stack Farm Manager
local stackSection = AddSection(mainPage, "📦 Stack Farm Manager")
AddToggle(stackSection, "Stack Farm Mode", false, function(v) end)

-- Automation Plants
local plantSection = AddSection(mainPage, "🌱 Automation Plants")
local listFilter = {"All"}
for _, f in pairs(FruitsList) do 
    table.insert(listFilter, f) 
end
AddDropdown(plantSection, "Select Seeds", FruitsList, function(v) _G.SelectedSeed = v end)
AddToggle(plantSection, "Auto Plants Selected Seed", false, function(v) _G.AutoPlantsSeed = v end)
AddToggle(plantSection, "Auto Plants All Seeds", false, function(v) _G.AutoPlantsAllSeeds = v end)

-- Automation Collection
local collectSection = AddSection(mainPage, "🍓 Automation Collection")
AddDropdown(collectSection, "Select Fruit Filter", listFilter, function(v) _G.CollectSelectedFruit = v end)
AddToggle(collectSection, "Auto Collect Filter Fruit", false, function(v) _G.AutoCollectFruit = v end)
AddToggle(collectSection, "Auto Collect All Fruit", false, function(v) _G.AutoCollectAllFruit = v end)

-- Automation Steal
local stealSection = AddSection(mainPage, "🎯 Automation Steal")
AddToggle(stealSection, "Auto Steal Mode", false, function(v) end)

-- Automation Sell
local sellSection = AddSection(mainPage, "💰 Automation Sell")
AddDropdown(sellSection, "Select Fruit to Sell", listFilter, function(v) _G.SellSelectedFruit = v end)
AddToggle(sellSection, "Auto Sell All", false, function(v) _G.AutoSellAll = v end)
AddToggle(sellSection, "Auto Sell Filter Fruit", false, function(v) _G.AutoSellFruit = v end)

-- Automation Pets
local petSection = AddSection(mainPage, "🐣 Automation Pets")
AddDropdown(petSection, "Select Pet Egg Type", PetsList, function(v) _G.BuySelectedPet = v end)
AddToggle(petSection, "Auto Buy Pet", false, function(v) _G.AutoBuyPet = v end)

-- TAB 3: AUTOMATICALLY
local autoPage = CreateTab("Automatically")
local autoMainSection = AddSection(autoPage, "⚙️ Auto Settings")
AddToggle(autoMainSection, "Auto Collect All", false, function(v) _G.AutoCollectAllFruit = v end)
AddToggle(autoMainSection, "Auto Sell All", false, function(v) _G.AutoSellAll = v end)
AddToggle(autoMainSection, "Auto Plant All", false, function(v) _G.AutoPlantsAllSeeds = v end)

-- TAB 4: INVENTORY
local invPage = CreateTab("Inventory")
local invSection = AddSection(invPage, "📦 Inventory Manager")
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0, 380, 0, 60)
InfoLabel.Position = UDim2.new(0, 10, 0, 5)
InfoLabel.BackgroundColor3 = Color3.fromRGB(40, 30, 36)
InfoLabel.Text = "Inventory Features\nComing Soon!"
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextYAlignment = Enum.TextYAlignment.Center
InfoLabel.Parent = invSection
Instance.new("UICorner", InfoLabel).CornerRadius = UDim.new(0, 4)

-- TAB 5: SHOP
local shopPage = CreateTab("Shop")
local shopSection = AddSection(shopPage, "🏪 Shop Automation")
AddDropdown(shopSection, "Select Pet Egg Type", PetsList, function(v) _G.BuySelectedPet = v end)
AddToggle(shopSection, "Auto Buy Pet", false, function(v) _G.AutoBuyPet = v end)

-- TAB 6: WEBHOOK
local webhookPage = CreateTab("Webhook")
local webhookSection = AddSection(webhookPage, "🔗 Discord Webhook")
local WebhookInput = Instance.new("TextBox")
WebhookInput.Size = UDim2.new(0, 380, 0, 30)
WebhookInput.Position = UDim2.new(0, 10, 0, 5)
WebhookInput.BackgroundColor3 = Color3.fromRGB(40, 30, 36)
WebhookInput.PlaceholderText = "https://discord.com/api/webhooks/..."
WebhookInput.Text = ""
WebhookInput.TextColor3 = Color3.fromRGB(200, 200, 200)
WebhookInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
WebhookInput.Font = Enum.Font.SourceSans
WebhookInput.TextSize = 12
WebhookInput.Parent = webhookSection
Instance.new("UICorner", WebhookInput).CornerRadius = UDim.new(0, 4)
AddToggle(webhookSection
