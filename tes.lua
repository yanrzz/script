-- ============================================================ --
-- Grow a Garden 2 (GAG2) Auto Farm Script (GUI Click)        --
-- ============================================================ --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- ================= SETTINGS ================= --
local Settings = {
    AutoCollect = false,
    AutoSell = false,
    AutoBuy = false,
    CollectRadius = 40,
    SellCooldown = 2,
    BuyItem = "Blueberry",
}

-- ================= GUI ================= --
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GAG2AutoFarm"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 200)
Frame.Position = UDim2.new(0.5, -140, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Frame

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.75, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Text = "🌱 GAG2 Auto"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 1, 0)
MinBtn.Position = UDim2.new(0.88, 0, 0, 0)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundTransparency = 1
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 1, 0)
CloseBtn.Position = UDim2.new(0.95, 0, 0, 0)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar

local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Frame.Size = isMinimized and UDim2.new(0, 280, 0, 28) or UDim2.new(0, 280, 0, 200)
    Content.Visible = not isMinimized
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -10, 1, -38)
Content.Position = UDim2.new(0, 5, 0, 32)
Content.BackgroundTransparency = 1
Content.Parent = Frame

local function createToggle(parent, y, text, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 26)
    container.Position = UDim2.new(0, 0, 0, y)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = container

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(0.8, 0, 0.5, -10)
    toggle.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 11
    toggle.BorderSizePixel = 0
    toggle.Parent = container

    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 200, 50) or Color3.fromRGB(255, 50, 50)
        toggle.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return toggle
end

local y = 2
createToggle(Content, y, "Auto Collect", function(v) Settings.AutoCollect = v end)
y = y + 30
createToggle(Content, y, "Auto Sell", function(v) Settings.AutoSell = v end)
y = y + 30
createToggle(Content, y, "Auto Buy", function(v) Settings.AutoBuy = v end)
y = y + 36

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, y)
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.Parent = Content

-- ================= FUNGSI UTILITY ================= --

-- Cari objek collectible (buah/tanaman)
local function getCollectibles()
    local objects = {}
    local fruitKeywords = {
        "carrot","strawberry","blueberry","tulip","tomato","bamboo",
        "corn","apple","mango","mushroom","banana","grape","acorn",
        "rocket pop","pineapple","cactus","dragon fruit","cherry",
        "fire fern","green bean","coconut","sunflower","venus fly trap",
        "poison apple","pomegranate","venom spritter","sun bloom",
        "moon bloom","dragon's breath","star fruit"
    }
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent then
            local name = obj.Name:lower()
            local match = false
            if obj:GetAttribute("Fruit") or obj:GetAttribute("Plant") or obj:GetAttribute("Harvestable") then
                match = true
            end
            if not match then
                for _, kw in ipairs(fruitKeywords) do
                    if name:find(kw) then
                        match = true
                        break
                    end
                end
            end
            if not match and obj.Parent then
                local pname = obj.Parent.Name:lower()
                for _, kw in ipairs(fruitKeywords) do
                    if pname:find(kw) then
                        match = true
                        break
                    end
                end
            end
            if match then
                table.insert(objects, obj)
            end
        end
    end
    return objects
end

local function teleportTo(pos)
    if not RootPart then return end
    RootPart.CFrame = CFrame.new(pos)
    task.wait(0.12)
end

local function interactWith(obj)
    if not obj then return false end
    VirtualUser:ClickButton2(Vector2.new(0,0))
    local remoteNames = {"CollectFruit", "Harvest", "Gather", "Pickup", "Collect"}
    for _, name in ipairs(remoteNames) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote then
            remote:FireServer(obj)
            return true
        end
    end
    return true
end

-- Cari dan klik tombol GUI berdasarkan teks
local function clickGUIButton(buttonText)
    local gui = Player.PlayerGui
    for _, child in ipairs(gui:GetDescendants()) do
        if child:IsA("TextButton") and child:IsVisible() then
            local text = child.Text and child.Text:lower() or ""
            local name = child.Name and child.Name:lower() or ""
            if text:find(buttonText:lower()) or name:find(buttonText:lower()) then
                child:Click()
                return true
            end
        end
    end
    return false
end

-- Jual inventaris (cari "Jual Inventaris" atau "Jual")
local function sellAll()
    if clickGUIButton("jual inventaris") or clickGUIButton("jual") then
        return true
    end
    local remoteNames = {"SellAll", "SellFruit", "Sell", "SellCrops"}
    for _, name in ipairs(remoteNames) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote then
            remote:FireServer()
            return true
        end
    end
    return false
end

-- Beli item (buka Peralatan lalu cari item)
local function buyItem(itemName)
    if not itemName or itemName == "" then return false end
    if clickGUIButton("peralatan") or clickGUIButton("shop") then
        task.wait(0.5)
        local gui = Player.PlayerGui
        for _, child in ipairs(gui:GetDescendants()) do
            if child:IsA("TextButton") and child:IsVisible() then
                local text = child.Text and child.Text:lower() or ""
                if text:find(itemName:lower()) then
                    child:Click()
                    return true
                end
            end
        end
    end
    return false
end

-- ================= MAIN LOOP ================= --
local lastSellTime = 0
local lastActionTime = 0

RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastActionTime < 0.3 then return end
    local status = "Idle"

    if Settings.AutoCollect then
        status = "Collecting..."
        local collectibles = getCollectibles()
        for _, obj in ipairs(collectibles) do
            local dist = (obj.Position - RootPart.Position).Magnitude
            if dist < Settings.CollectRadius then
                teleportTo(obj.Position)
                interactWith(obj)
                lastActionTime = now
                task.wait(0.08)
            end
        end
    end

    if Settings.AutoSell then
        if now - lastSellTime > Settings.SellCooldown then
            status = "Selling..."
            sellAll()
            lastSellTime = now
            lastActionTime = now
            task.wait(0.5)
        end
    end

    if Settings.AutoBuy then
        status = "Buying..."
        buyItem(Settings.BuyItem)
        lastActionTime = now
        task.wait(1)
    end

    statusLabel.Text = "Status: " .. status
end)

-- Anti-AFK
Player.Idled:Connect(function()
    VirtualUser:ClickButton2(Vector2.new())
end)

print("🌱 GAG2 Auto Farm Loaded!")
print("📌 Klik toggle untuk mengaktifkan fitur.")
