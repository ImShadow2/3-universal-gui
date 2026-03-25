-- Player aimbot
-- Reset everything on re-execution
if getgenv().inputConnection then getgenv().inputConnection:Disconnect() end
if getgenv().ESPloop then getgenv().ESPloop:Disconnect() end
if getgenv().FOVring then getgenv().FOVring:Remove() end
for _,v in pairs(game:GetService("Players"):GetPlayers()) do
    if v.Character then
        local esp = v.Character:FindFirstChild("AimbotESP")
        if esp then esp:Destroy() end
    end
end


-- F4 to ESP


-- SETTINGS
getgenv().teamCheck = false
getgenv().fov = 120
getgenv().smoothing = 1
getgenv().predictionFactor = 0
getgenv().highlightEnabled = true
getgenv().Toggle = false -- false = hold right-click, true = toggle with key
getgenv().ToggleKey = Enum.KeyCode.E
getgenv().lockPartName = "Head" -- 🟢 You can change this to "Head", "UpperTorso", etc. anytime


-- ESP SETTINGS
getgenv().ESPenabled = true
getgenv().ESPtoggleKey = Enum.KeyCode.F4
getgenv().ESPcolor = Color3.fromRGB(255, 0, 0)


-- Variables
getgenv().currentTarget = nil
getgenv().aimbotEnabled = true
getgenv().toggleState = false
getgenv().debounce = false


-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local StarterGui = game:GetService("StarterGui")
-- DEBUG: Print ALL DISTINCT character body parts (global)
local printedOnce = false

local function printAllDistinctParts()
    if printedOnce then return end
    printedOnce = true

    local partSet = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            for _, obj in ipairs(player.Character:GetDescendants()) do
                if obj:IsA("BasePart") then
                    partSet[obj.Name] = true
                end
            end
        end
    end

    print("========== ALL DISTINCT PLAYER BODY PARTS ==========")
    for partName, _ in pairs(partSet) do
        print(partName)
    end
    print("===================================================")
end

-- Run once after characters load
task.delay(2, printAllDistinctParts)



local function notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 3
    })
end


notify("Universal Aimbot + ESP", "Loaded successfully.", 4)


-- FOV Circle
getgenv().FOVring = Drawing.new("Circle")
getgenv().FOVring.Visible = true
getgenv().FOVring.Thickness = 1.5
getgenv().FOVring.Radius = getgenv().fov
getgenv().FOVring.Transparency = 0.6
getgenv().FOVring.Color = Color3.fromRGB(255, 128, 128)
getgenv().FOVring.Position = Camera.ViewportSize / 2


-- Functions
local function getClosestTarget()
    local closest, shortestDistance = nil, math.huge
    local screenCenter = Camera.ViewportSize / 2


    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild(getgenv().lockPartName) and player.Character:FindFirstChild("Humanoid") then
            if not getgenv().teamCheck or player.Team ~= Players.LocalPlayer.Team then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character[getgenv().lockPartName].Position)
                local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                if onScreen and dist < shortestDistance and dist <= getgenv().fov then
                    closest = player
                    shortestDistance = dist
                end
            end
        end
    end
    return closest
end




local function predictPosition(target)
    local root = target and target.Character and target.Character:FindFirstChild(getgenv().lockPartName)
    if root and root:IsA("BasePart") then
        return root.Position + (root.Velocity * getgenv().predictionFactor)
    end
end


local function updateFOVRing()
    getgenv().FOVring.Position = Camera.ViewportSize / 2
end


local function highlightTarget(target)
    if getgenv().highlightEnabled and target and target.Character then
        local oldHighlight = target.Character:FindFirstChild("AimbotHighlight")
        if oldHighlight then oldHighlight:Destroy() end
        local highlight = Instance.new("Highlight")
        highlight.Name = "AimbotHighlight"
        highlight.Adornee = target.Character
        highlight.FillColor = Color3.fromRGB(255, 128, 128)
        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
        highlight.Parent = target.Character
    end
end


local function removeHighlight(target)
    if target and target.Character then
        local highlight = target.Character:FindFirstChild("AimbotHighlight")
        if highlight then highlight:Destroy() end
    end
end


local function toggleESP()
    getgenv().ESPenabled = not getgenv().ESPenabled
    if not getgenv().ESPenabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character then
                local esp = v.Character:FindFirstChild("AimbotESP")
                if esp then esp:Destroy() end
            end
        end
    end
    notify("ESP Toggle", getgenv().ESPenabled and "Enabled" or "Disabled")
end


local function handleToggle()
    if getgenv().debounce then return end
    getgenv().debounce = true
    getgenv().toggleState = not getgenv().toggleState
    notify("Aimbot Toggle", getgenv().toggleState and "ON" or "OFF")
    task.wait(0.3)
    getgenv().debounce = false
end


getgenv().inputConnection = UIS.InputBegan:Connect(function(input, gpe)
    if not gpe then
        if input.KeyCode == getgenv().ToggleKey and getgenv().Toggle then
            handleToggle()
        elseif input.KeyCode == getgenv().ESPtoggleKey then
            toggleESP()
        elseif input.KeyCode == Enum.KeyCode.End then
            getgenv().aimbotEnabled = not getgenv().aimbotEnabled
            notify("Aimbot System", getgenv().aimbotEnabled and "Aimbot Enabled" or "Aimbot Disabled")
        end
    end
end)


-- ESP Loop
getgenv().ESPloop = RunService.RenderStepped:Connect(function()
    if getgenv().ESPenabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild(getgenv().lockPartName) then
                local existing = player.Character:FindFirstChild("AimbotESP")
                if not existing then
                    local esp = Instance.new("Highlight")
                    esp.Name = "AimbotESP"
                    esp.FillColor = Color3.fromRGB(0, 0, 0)
                    esp.FillTransparency = 1
                    esp.OutlineColor = getgenv().ESPcolor
                    esp.OutlineTransparency = 0
                    esp.Adornee = player.Character
                    esp.Parent = player.Character
                end
            end
        end
    end
end)


-- Aimbot Loop
getgenv().aimbotLoop = RunService.RenderStepped:Connect(function()
    if getgenv().aimbotEnabled then
        updateFOVRing()


        if not getgenv().Toggle then
            getgenv().toggleState = UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        end


        if getgenv().toggleState then
            if not getgenv().currentTarget or not getgenv().currentTarget.Character or not getgenv().currentTarget.Character:FindFirstChild(getgenv().lockPartName) then
                getgenv().currentTarget = getClosestTarget()
                highlightTarget(getgenv().currentTarget)
            end


            if getgenv().currentTarget then
                local predicted = predictPosition(getgenv().currentTarget)
                if predicted then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, predicted), getgenv().smoothing)
                end
                getgenv().FOVring.Color = Color3.fromRGB(0, 255, 0)
            else
                getgenv().FOVring.Color = Color3.fromRGB(255, 128, 128)
            end
        else
            removeHighlight(getgenv().currentTarget)
            getgenv().currentTarget = nil
            getgenv().FOVring.Color = Color3.fromRGB(255, 128, 128)
        end
    end
end)


