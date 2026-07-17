-- =============================================================================
-- SPEED HUB X v10.3 - GAG2 (FULL UI + IN-GAME LOG / NO F9 NEEDED)
-- =============================================================================

local Player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- =============================================================================
-- 1. KONFIGURASI
-- =============================================================================
_G.AutoCollect = false
_G.AutoPlant = false
_G.AutoHarvest = false
_G.AutoSell = false
_G.AutoBuySeed = false
_G.AutoBuyGear = false
_G.SelectedSeeds = {"Wortel", "Carrot"}
_G.BuyAllSeeds = false
_G.SelectedGear = "Sekop"

-- =============================================================================
-- 2. VARIABEL GLOBAL UNTUK LOG
-- =============================================================================
local LogMessages = {}
local MaxLogs = 30

local function addLog(msg)
    table.insert(LogMessages, msg)
    if #LogMessages > MaxLogs then table.remove(LogMessages, 1) end
    pcall(function()
        if LogLabel then
            LogLabel.Text = table.concat(LogMessages, "\n")
            LogScroll.CanvasSize = UDim2.new(0, 0, 0, LogLabel.TextBounds.Y + 10)
            LogScroll.ScrollPosition = LogScroll.CanvasSize.Y.Offset
        end
    end)
    print("[GAG2] " .. msg)
end

-- =============================================================================
-- 3. CORE DETECTION
-- =============================================================================

-- Scan semua ProximityPrompt
local function scanPrompts()
    local prompts = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            table.insert(prompts, {
                Parent = obj.Parent and obj.Parent.Name or "nil",
                Action = obj.ActionText or "",
                Object = obj.ObjectText or ""
            })
        end
    end
    return prompts
end

-- Scan RemoteEvent
local function scanRemotes()
    local remotes = {}
    for _, child in pairs(ReplicatedStorage:GetChildren()) do
        if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
            table.insert(remotes, child.Name)
        end
    end
    return remotes
end

-- Cari objek buah
local function getFruits()
    local items = {}
    local names = {"carrot","strawberry","blueberry","tulip","tomato","bamboo",
        "corn","apple","mango","mushroom","banana","grape","acorn",
        "rocket","pineapple","cactus","dragon","cherry","coconut",
        "sunflower","pomegranate","star","wortel","stroberi","jagung",
        "apel","mangga","pisang","anggur","nanas","kelapa"}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent then
            local name = string.lower(obj.Name)
            local pname = string.lower(obj.Parent.Name or "")
            for _, n in pairs(names) do
                if string.find(name, n) or string.find(pname, n) then
                    table.insert(items, obj)
                    break
                end
            end
        end
    end
    return items
end

-- Cari garden
local function findGarden()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local a = string.lower(obj.ActionText or "")
            if string.find(a, "tanam") or string.find(a, "plant") then
                local p = obj.Parent
                while p and not p:IsA("Model") do p = p.Parent end
                if p then return p end
            end
        end
    end
    return nil
end

-- Klik tombol
local function clickBtn(btn)
    if not btn then return false end
    pcall(function()
        btn:Activate()
        btn:Click()
        firesignal(btn.MouseButton1Click)
        for _, c in pairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
    end)
    return true
end

-- Trigger Prompt
local function triggerPrompt(prompt)
    if not prompt then return false end
    pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 999999
        prompt.HoldDuration = 0
        fireproximityprompt(prompt)
        prompt:InputHoldBegin()
        task.wait(0.05)
        prompt:InputHoldEnd()
    end)
    return true
end

-- =============================================================================
-- 4. AUTO LOOP
-- =============================================================================

-- Auto Collect
task.spawn(function()
    while task.wait(0.2) do
        if not _G.AutoCollect then continue end
        local char = Player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local fruits = getFruits()
        for _, f in pairs(fruits) do
            pcall(function()
                if (f.Position - hrp.Position).Magnitude < 40 then
                    firetouchinterest(hrp, f, 0)
                    task.wait(0.01)
                    firetouchinterest(hrp, f, 1)
                    addLog("Collect: " .. f.Name)
                end
            end)
        end
    end
end)

-- Auto Plant & Harvest
task.spawn(function()
    while task.wait(0.3) do
        if not _G.AutoPlant and not _G.AutoHarvest then continue end
        local garden = findGarden()
        if not garden then 
            addLog("Garden not found")
            continue 
        end
        for _, p in pairs(garden:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                local a = string.lower(p.ActionText or "")
                if _G.AutoHarvest and (string.find(a, "panen") or string.find(a, "harvest") or string.find(a, "ambil")) then
                    triggerPrompt(p)
                    addLog("Harvest triggered")
                end
                if _G.AutoPlant and (string.find(a, "tanam") or string.find(a, "plant") or string.find(a, "biji")) then
                    triggerPrompt(p)
                    addLog("Plant triggered")
                end
            end
        end
    end
end)

-- Auto Sell
task.spawn(function()
    while task.wait(0.5) do
        if not _G.AutoSell then continue end
        local done = false
        
        -- Cari GUI
        for _, v in pairs(Player.PlayerGui:GetDescendants()) do
            if v:IsA("TextButton") and v:IsVisible() then
                local t = string.lower(v.Text or "")
                if string.find(t, "jual") or string.find(t, "sell") then
                    if clickBtn(v) then addLog("Sell via GUI: " .. v.Text); done = true; break end
                end
            end
        end
        
        -- Cari Prompt
        if not done then
            for _, p in pairs(Workspace:GetDescendants()) do
                if p:IsA("ProximityPrompt") then
                    local a = string.lower(p.ActionText or "")
                    if string.find(a, "jual") or string.find(a, "sell") then
                        triggerPrompt(p)
                        addLog("Sell via Prompt")
                        done = true
                        break
                    end
                end
            end
        end
        
        -- Cari Remote
        if not done then
            for _, r in pairs(ReplicatedStorage:GetChildren()) do
                if r:IsA("RemoteEvent") then
                    local n = string.lower(r.Name)
                    if string.find(n, "sell") or string.find(n, "jual") then
                        pcall(function() r:FireServer() end)
                        addLog("Sell via Remote: " .. r.Name)
                        done = true
                        break
                    end
                end
            end
        end
        if not done then addLog("Sell: No method found!") end
        task.wait(0.3)
    end
end)

-- Auto Buy Seed (Multi)
task.spawn(function()
    while task.wait(0.5) do
        if not _G.AutoBuySeed then continue end
        local targets = {}
        if _G.BuyAllSeeds then
            for _, g in pairs(Player.PlayerGui:GetDescendants()) do
                if g:IsA("TextLabel") then
                    for _, s in pairs(_G.SelectedSeeds) do
                        if string.find(string.lower(g.Text), string.lower(s)) and not table.find(targets, s) then
                            table.insert(targets, s)
                        end
                    end
                end
            end
        else
            targets = _G.SelectedSeeds
        end
        
        for _, seed in pairs(targets) do
            local row = nil
            for _, g in pairs(Player.PlayerGui:GetDescendants()) do
                if g:IsA("TextLabel") and string.find(string.lower(g.Text), string.lower(seed)) then
                    row = g.Parent
                    break
                end
            end
            if row then
                local rarity = nil
                for _, child in pairs(row:GetDescendants()) do
                    if child:IsA("TextButton") then
                        local t = string.lower(child.Text or "")
                        if string.find(t, "umum") or string.find(t, "langka") or string.find(t, "common") or string.find(t, "rare") then
                            rarity = child; break
                        end
                    end
                end
                if rarity then
                    clickBtn(rarity)
                    task.wait(0.15)
                    for _, v in pairs(Player.PlayerGui:GetDescendants()) do
                        if v:IsA("TextButton") and v:IsVisible() then
                            local bg = v.BackgroundColor3
                            if bg.G > bg.R and bg.G > bg.B and bg.G > 0.3 then
                                local t = string.lower(v.Text or "")
                                if string.find(t, "beli") or string.find(t, "buy") or string.find(t, "¢") then
                                    clickBtn(v)
                                    addLog("Buy Seed: " .. seed)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Buy Gear
task.spawn(function()
    while task.wait(0.5) do
        if not _G.AutoBuyGear or not _G.SelectedGear then continue end
        local done = false
        for _, p in pairs(Workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                local parent = string.lower(p.Parent.Name or "")
                if string.find(parent, string.lower(_G.SelectedGear)) then
                    triggerPrompt(p)
                    addLog("Buy Gear: " .. _G.SelectedGear)
                    done = true
                    break
                end
            end
        end
        if not done then addLog("Gear not found: " .. _G.SelectedGear) end
        task.wait(0.3)
    end
end)

-- =============================================================================
-- 5. UI DENGAN LOG (TANPA PERLU F9)
-- =============================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GAG2Hub"
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 400)
Frame.Position = UDim2.new(0.5, -160, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(18, 15, 18)
Frame.BackgroundTransparency = 0.05
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 25, 30)
TitleBar.BackgroundTransparency = 0.2
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Text = "🌱 GAG2 Auto (Log)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 25, 1, 0)
MinBtn.Position = UDim2.new(0.88, 0, 0, 0)
MinBtn.Text = "−"
MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
MinBtn.BackgroundTransparency = 1
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 16
MinBtn.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 1, 0)
CloseBtn.Position = UDim2.new(0.95, 0, 0, 0)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255,80,80)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar

local isMin = false
MinBtn.MouseButton1Click:Connect(function()
    isMin = not isMin
    Frame.Size = isMin and UDim2.new(0, 320, 0, 30) or UDim2.new(0, 320, 0, 400)
    Content.Visible = not isMin
end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Content
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -10, 1, -40)
Content.Position = UDim2.new(0, 5, 0, 34)
Content.BackgroundTransparency = 1
Content.Parent = Frame

-- Toggle Helper
local function addToggle(parent, y, text, cb)
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 0, 24)
    c.Position = UDim2.new(0, 0, 0, y)
    c.BackgroundTransparency = 1
    c.Parent = parent
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.6, 0, 1, 0)
    l.Text = text
    l.TextColor3 = Color3.fromRGB(255,255,255)
    l.BackgroundTransparency = 1
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.Parent = c
    
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 40, 0, 18)
    b.Position = UDim2.new(0.8, 0, 0.5, -9)
    b.BackgroundColor3 = Color3.fromRGB(255,50,50)
    b.Text = "OFF"
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.BorderSizePixel = 0
    b.Parent = c
    
    local state = false
    b.MouseButton1Click:Connect(function()
        state = not state
        b.BackgroundColor3 = state and Color3.fromRGB(0,200,50) or Color3.fromRGB(255,50,50)
        b.Text = state and "ON" or "OFF"
        cb(state)
    end)
end

-- Build Toggles
local yy = 2
addToggle(Content, yy, "Auto Collect", function(v) _G.AutoCollect = v end)
yy = yy + 27
addToggle(Content, yy, "Auto Plant", function(v) _G.AutoPlant = v end)
yy = yy + 27
addToggle(Content, yy, "Auto Harvest", function(v) _G.AutoHarvest = v end)
yy = yy + 27
addToggle(Content, yy, "Auto Sell", function(v) _G.AutoSell = v end)
yy = yy + 27
addToggle(Content, yy, "Auto Buy Seed", function(v) _G.AutoBuySeed = v end)
yy = yy + 27
addToggle(Content, yy, "Auto Buy Gear", function(v) _G.AutoBuyGear = v end)
yy = yy + 32

-- === LOG AREA (IN-GAME CONSOLE) ===
local LogFrame = Instance.new("Frame")
LogFrame.Size = UDim2.new(1, 0, 0, 90)
LogFrame.Position = UDim2.new(0, 0, 0, yy)
LogFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
LogFrame.BackgroundTransparency = 0.6
LogFrame.BorderSizePixel = 1
LogFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
LogFrame.Parent = Content
Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 4)

local LogScroll = Instance.new("ScrollingFrame")
LogScroll.Size = UDim2.new(1, -4, 1, -4)
LogScroll.Position = UDim2.new(0, 2, 0, 2)
LogScroll.BackgroundTransparency = 1
LogScroll.BorderSizePixel = 0
LogScroll.CanvasSize = UDim2.new(0, 0, 0, 20)
LogScroll.ScrollBarThickness = 2
LogScroll.Parent = LogFrame

local LogLabel = Instance.new("TextLabel")
LogLabel.Size = UDim2.new(1, 0, 1, 0)
LogLabel.BackgroundTransparency = 1
LogLabel.Text = "=== LOG START ==="
LogLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
LogLabel.Font = Enum.Font.Gotham
LogLabel.TextSize = 10
LogLabel.TextXAlignment = Enum.TextXAlignment.Left
LogLabel.TextYAlignment = Enum.TextYAlignment.Top
LogLabel.TextWrapped = true
LogLabel.Parent = LogScroll
-- NOTE: LogLabel.TextBounds only works if Size is not 1,1. Let's adjust.
LogLabel.Size = UDim2.new(1, 0, 0, 20) -- will be updated by addLog
LogLabel.AutomaticSize = Enum.AutomaticSize.Y

addLog("=== GAG2 SCRIPT LOADED ===")
addLog("Scanning game elements...")

-- Auto scan and show in log
task.wait(0.5)
local prompts = scanPrompts()
if #prompts > 0 then
    addLog("Found " .. #prompts .. " ProximityPrompts")
    for i, p in pairs(prompts) do
        if i <= 5 then addLog("  - " .. p.Parent .. " | " .. p.Action) end
    end
    if #prompts > 5 then addLog("  ... and " .. (#prompts-5) .. " more") end
else
    addLog("⚠️ No ProximityPrompts found!")
end

local remotes = scanRemotes()
if #remotes > 0 then
    addLog("Found " .. #remotes .. " RemoteEvents")
    for i, r in pairs(remotes) do
        if i <= 5 then addLog("  - " .. r) end
    end
    if #remotes > 5 then addLog("  ... and " .. (#remotes-5) .. " more") end
else
    addLog("⚠️ No RemoteEvents found!")
end

addLog("✅ Toggle ON to start farming!")

-- Anti-AFK
Player.Idled:Connect(function()
    VirtualUser:ClickButton2(Vector2.new())
end)

print("✅ GAG2 Auto Farm Loaded with In-Game Log!")
print("📌 Lihat log di bagian bawah UI.")
