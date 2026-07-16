-- ==========================================
-- 1. SETUP & KONFIGURASI
-- ==========================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- Hapus UI lama jika script dijalankan ulang agar tidak menumpuk
if CoreGui:FindFirstChild("GAG2_AdvancedFarm") then
    CoreGui:FindFirstChild("GAG2_AdvancedFarm"):Destroy()
end

-- Status Fitur (Default: MATI)
_G.AutoHarvest = false
_G.AutoWater = false
_G.AutoBuySeed = false
_G.AutoBuyGear = false
_G.ScriptRunning = true -- Menandakan script utama sedang berjalan

-- Batasan Kondisi
local LIMIT_FRUIT_WEIGHT = 80 -- Panen hanya jika berat buah di bawah 80 Kg
local LIMIT_MONEY_BUY = 80000000 -- Beli hanya jika uang di atas 80M (80.000.000)

-- ==========================================
-- 2. MEMBUAT UI PANEL UTAMA (DRAGGABLE)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GAG2_AdvancedFarm"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Main Frame (Panel Menu Utama)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 240, 0, 360)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Judul Menu
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.Size = UDim2.new(1, -60, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "GAG 2 ADVANCED"
Title.TextColor3 = Color3.fromRGB(255, 215, 0) -- Warna Emas
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- ------------------------------------------
-- FITUR TOMBOL CLOSE & MINIMIZE (Kanan Atas)
-- ------------------------------------------
-- Tombol Close (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = MainFrame
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.SourceSansBold

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(1, 0) -- Lingkaran sempurna
CloseCorner.Parent = CloseBtn

-- Tombol Minimize (-)
local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Parent = MainFrame
MinBtn.Size = UDim2.new(0, 25, 0, 25)
MinBtn.Position = UDim2.new(1, -60, 0, 8)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.SourceSansBold

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(1, 0)
MinCorner.Parent = MinBtn

-- ------------------------------------------
-- TOMBOL EXPAND (Hanya Muncul Saat di-Minimize)
-- ------------------------------------------
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Parent = ScreenGui
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
OpenBtn.Text = "OPEN"
OpenBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
OpenBtn.TextSize = 12
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.Visible = false -- Sembunyikan secara default
OpenBtn.Active = true
OpenBtn.Draggable = true

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0) -- Bentuk lingkaran
OpenCorner.Parent = OpenBtn

-- ==========================================
-- 3. TOMBOL FITUR AUTO FARM
-- ==========================================
local function createToggleButton(name, text, positionY)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Parent = MainFrame
    Button.Size = UDim2.new(0, 200, 0, 40)
    Button.Position = UDim2.new(0.5, -100, 0, positionY)
    Button.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Default Merah
    Button.Text = text .. ": OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.SourceSansBold
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Button
    
    return Button
end

local btnHarvest = createToggleButton("BtnHarvest", "Auto Harvest (<80kg)", 50)
local btnWater = createToggleButton("BtnWater", "Auto Water", 110)
local btnBuySeed = createToggleButton("BtnBuySeed", "Auto Buy Seed (>80M)", 170)
local btnBuyGear = createToggleButton("BtnBuyGear", "Auto Buy Gear", 230)

-- Text Info Kondisi Aktif di bagian bawah UI
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = MainFrame
InfoLabel.Size = UDim2.new(1, 0, 0, 60)
InfoLabel.Position = UDim2.new(0, 0, 0, 290)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Limit Panen: < 80 Kg\nLimit Beli: > 80M Sheckles"
InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.SourceSansItalic

-- ==========================================
-- 4. KONTROL TOMBOL CLOSE & MINIMIZE (LOGIKA)
-- ==========================================
-- Logika Menutup UI (Close)
CloseBtn.MouseButton1Click:Connect(function()
    _G.AutoHarvest = false
    _G.AutoWater = false
    _G.AutoBuySeed = false
    _G.AutoBuyGear = false
    _G.ScriptRunning = false -- Hentikan semua looping
    ScreenGui:Destroy() -- Hapus UI dari game
end)

-- Logika Mengecilkan UI (Minimize)
MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Position = MainFrame.Position -- Samakan posisi tombol Open dengan panel terakhir
    OpenBtn.Visible = true
end)

-- Logika Membuka Kembali UI (Maximize)
OpenBtn.MouseButton1Click:Connect(function()
    OpenBtn.Visible = false
    MainFrame.Position = OpenBtn.Position -- Samakan posisi panel dengan tombol Open terakhir
    MainFrame.Visible = true
end)

-- ==========================================
-- 5. FUNGSI UNTUK MENDAPATKAN DATA PEMAIN
-- ==========================================
local function getPlayerStats()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local s_money = 0
    local s_fruit = 0
    
    if leaderstats then
        local moneyObj = leaderstats:FindFirstChild("Sheckles") or leaderstats:FindFirstChild("Money") or leaderstats:FindFirstChild("Cash")
        if moneyObj then
            s_money = moneyObj.Value
        end
        
        local fruitObj = leaderstats:FindFirstChild("Fruits") or leaderstats:FindFirstChild("Weight") or leaderstats:FindFirstChild("Fruit")
        if fruitObj then
            s_fruit = fruitObj.Value
        end
    end
    return s_money, s_fruit
end

local function firePrompt(prompt)
    if prompt and prompt:IsA("ProximityPrompt") then
        fireproximityprompt(prompt, 1)
    end
end

-- ==========================================
-- 6. LOGIKA UTAMA (LOOP DETEKSI)
-- ==========================================
task.spawn(function()
    while _G.ScriptRunning do
        task.wait(0.3)
        local money, fruitWeight = getPlayerStats()

        -- LOOP UNTUK HARVEST & WATER
        if _G.AutoHarvest or _G.AutoWater then
            for _, obj in pairs(workspace:GetDescendants()) do
                if not _G.ScriptRunning then break end
                if obj:IsA("ProximityPrompt") then
                    
                    -- Aksi 1: AUTO HARVEST (Hanya jika berat buah DI BAWAH 80 Kg)
                    if _G.AutoHarvest and fruitWeight < LIMIT_FRUIT_WEIGHT then
                        if obj.ActionText == "Harvest" or obj.ObjectText == "Harvest" then
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = obj.Parent.CFrame + Vector3.new(0, 2, 0)
                                task.wait(0.1)
                                firePrompt(obj)
                                task.wait(0.2)
                            end
                        end
                    end

                    -- Aksi 2: AUTO WATER
                    if _G.AutoWater then
                        if obj.ActionText == "Water" or obj.ObjectText == "Water" then
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = obj.Parent.CFrame + Vector3.new(0, 2, 0)
                                task.wait(0.1)
                                firePrompt(obj)
                                task.wait(0.2)
                            end
                        end
                    end

                end
            end
        end

        -- LOOP UNTUK AUTO BUY (Hanya jika uang DI ATAS 80M)
        if (_G.AutoBuySeed or _G.AutoBuyGear) and money > LIMIT_MONEY_BUY then
            for _, obj in pairs(workspace:GetDescendants()) do
                if not _G.ScriptRunning then break end
                if obj:IsA("ProximityPrompt") then
                    
                    -- Aksi 3: AUTO BUY SEED
                    if _G.AutoBuySeed and (obj.ActionText == "Buy Seed" or obj.ObjectText == "Seed Shop") then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.Parent.CFrame + Vector3.new(0, 2, 0)
                            task.wait(0.1)
                            firePrompt(obj)
                            task.wait(0.3)
                        end
                    end

                    -- Aksi 4: AUTO BUY GEAR
                    if _G.AutoBuyGear and (obj.ActionText == "Buy Gear" or obj.ObjectText == "Gear Shop") then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = obj.Parent.CFrame + Vector3.new(0, 2, 0)
                            task.wait(0.1)
                            firePrompt(obj)
                            task.wait(0.3)
                        end
                    end

                end
            end
        end

    end
end)

-- ==========================================
-- 7. KONTROL INTERAKSI TOMBOL (TOGGLE)
-- ==========================================
btnHarvest.MouseButton1Click:Connect(function()
    _G.AutoHarvest = not _G.AutoHarvest
    if _G.AutoHarvest then
        btnHarvest.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        btnHarvest.Text = "Auto Harvest: ON"
    else
        btnHarvest.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        btnHarvest.Text = "Auto Harvest: OFF"
    end
end)

btnWater.MouseButton1Click:Connect(function()
    _G.AutoWater = not _G.AutoWater
    if _G.AutoWater then
        btnWater.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        btnWater.Text = "Auto Water: ON"
    else
        btnWater.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        btnWater.Text = "Auto Water: OFF"
    end
end)

btnBuySeed.MouseButton1Click:Connect(function()
    _G.AutoBuySeed = not _G.AutoBuySeed
    if _G.AutoBuySeed then
        btnBuySeed.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        btnBuySeed.Text = "Auto Buy Seed: ON"
    else
        btnBuySeed.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        btnBuySeed.Text = "Auto Buy Seed: OFF"
    end
end)

btnBuyGear.MouseButton1Click:Connect(function()
    _G.AutoBuyGear = not _G.AutoBuyGear
    if _G.AutoBuyGear then
        btnBuyGear.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        btnBuyGear.Text = "Auto Buy Gear: ON"
    else
        btnBuyGear.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        btnBuyGear.Text = "Auto Buy Gear: OFF"
    end
end)
