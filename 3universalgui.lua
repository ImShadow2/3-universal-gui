-- Combined GUI for Fullbright, Speed, Instant Interaction, and ESP Teleport

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- CLEANUP
if game.CoreGui:FindFirstChild("UtilityGUI") then
    game.CoreGui.UtilityGUI:Destroy()
end

-- UI SETUP
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "UtilityGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 210)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local function createToggle(text, position, default, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, position)
    btn.Text = text .. (default and " [ON]" or " [OFF]")
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Arial
    btn.TextScaled = true
    local state = default

    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and " [ON]" or " [OFF]")
        callback(state)
    end)
end

-- FULLBRIGHT
local fullbrightConn, lightConn, playerLight
local function setFullbright(state)
    if state then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 1
        Lighting.FogEnd = 1e10
        for _, v in pairs(Lighting:GetDescendants()) do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = false
            end
        end
        fullbrightConn = Lighting.Changed:Connect(function()
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.Brightness = 1
            Lighting.FogEnd = 1e10
        end)
        lightConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and not char.HumanoidRootPart:FindFirstChild("FullbrightLight") then
                local pl = Instance.new("PointLight")
                pl.Name = "FullbrightLight"
                pl.Brightness = 1
                pl.Range = 60
                pl.Parent = char.HumanoidRootPart
                playerLight = pl
            end
        end)
    else
        if fullbrightConn then fullbrightConn:Disconnect() end
        if lightConn then lightConn:Disconnect() end
        if playerLight then playerLight:Destroy() end
        Lighting.Ambient = Color3.new(0, 0, 0)
        Lighting.Brightness = 1
        Lighting.FogEnd = 1000
    end
end

-- SPEED HACK
local customSpeed = 80
local defaultSpeed
local speedLoop
local function setSpeed(state)
    if state then
        local function getHumanoid()
            return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        end
        LocalPlayer.CharacterAdded:Connect(function(char)
            local humanoid = char:WaitForChild("Humanoid")
            defaultSpeed = humanoid.WalkSpeed
            humanoid.WalkSpeed = customSpeed
        end)
        local hum = getHumanoid()
        if hum then
            defaultSpeed = hum.WalkSpeed
            hum.WalkSpeed = customSpeed
        end
        speedLoop = RunService.Stepped:Connect(function()
            local h = getHumanoid()
            if h and h.WalkSpeed == defaultSpeed then
                h.WalkSpeed = customSpeed
            end
        end)
    else
        if speedLoop then speedLoop:Disconnect() end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.WalkSpeed = defaultSpeed or 16 end
    end
end

-- SPEED INPUT
local speedInput = Instance.new("TextBox", frame)
speedInput.PlaceholderText = "Speed (e.g. 80)"
speedInput.Size = UDim2.new(1, -20, 0, 25)
speedInput.Position = UDim2.new(0, 10, 0, 80)
speedInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedInput.TextColor3 = Color3.new(1, 1, 1)
speedInput.Text = tostring(customSpeed)
speedInput.Font = Enum.Font.Arial
speedInput.TextScaled = true
speedInput.BorderSizePixel = 0

speedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local value = tonumber(speedInput.Text)
        if value and value > 0 then
            customSpeed = value
        end
    end
end)

-- INSTANT INTERACTION
local instantConn
local function setInstantPrompt(state)
    if state then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") then
                v.HoldDuration = 0.0001
            end
        end
        instantConn = Workspace.DescendantAdded:Connect(function(desc)
            if desc:IsA("ProximityPrompt") then
                desc.HoldDuration = 0.0001
            end
        end)
    else
        if instantConn then instantConn:Disconnect() end
    end
end

-- ESP TELEPORT TOOL
local espButtons = {}
local function clearESP()
    for _, item in ipairs(espButtons) do
        if item.btn then item.btn:Destroy() end
    end
    espButtons = {}
end

local function scanESP(name)
    clearESP()
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Parent and string.lower(part.Parent.Name):find(string.lower(name)) then
            local parentName = part.Parent.Name
            local btn = Instance.new("TextButton", gui)
            btn.Text = parentName
            btn.Size = UDim2.new(0, 80, 0, 18)
            btn.BackgroundTransparency = 1
            btn.TextColor3 = Color3.fromRGB(255, 255, 0)
            btn.TextScaled = true
            btn.Font = Enum.Font.Arial
            btn.MouseButton1Click:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char:MoveTo(part.Position + Vector3.new(0, -1, 0))
                end
            end)
            table.insert(espButtons, {btn = btn, part = part})
        end
    end
end

RunService.RenderStepped:Connect(function()
    for i = #espButtons, 1, -1 do
        local item = espButtons[i]
        if not item.part or not item.part:IsDescendantOf(Workspace) then
            item.btn:Destroy()
            table.remove(espButtons, i)
        else
            local screenPos, onScreen = Camera:WorldToViewportPoint(item.part.Position)
            item.btn.Visible = onScreen
            if onScreen then
				item.btn.AnchorPoint = Vector2.new(0.5, 0.5)
                item.btn.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
            end
        end
    end
end)

-- GUI BUTTONS
createToggle("Fullbright", 10, false, setFullbright)
createToggle("Speed Hack", 45, false, setSpeed)
createToggle("Instant Interact", 115, false, setInstantPrompt)

-- TEXTBOX + SCAN BUTTON
local input = Instance.new("TextBox", frame)
input.PlaceholderText = "Type name (e.g. coin)"
input.Size = UDim2.new(1, -20, 0, 25)
input.Position = UDim2.new(0, 10, 0, 150)
input.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.Text = ""
input.Font = Enum.Font.Arial
input.TextScaled = true
input.BorderSizePixel = 0

local scanBtn = Instance.new("TextButton", frame)
scanBtn.Text = "Scan ESP"
scanBtn.Size = UDim2.new(1, -20, 0, 25)
scanBtn.Position = UDim2.new(0, 10, 0, 180)
scanBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
scanBtn.TextColor3 = Color3.new(1, 1, 1)
scanBtn.Font = Enum.Font.Arial
scanBtn.TextScaled = true
scanBtn.BorderSizePixel = 0

scanBtn.MouseButton1Click:Connect(function()
    if input.Text ~= "" then
        scanESP(input.Text)
    end
end)
