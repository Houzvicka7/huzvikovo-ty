-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local localPlayer = Players.LocalPlayer
local aimbotEnabled = false
local highlightEnabled = false
local noclipEnabled = false
local aimSmoothness = 0 -- Default to 0 for instant lock-on
local speed = 20 -- Default walking speed
local aimbotTarget = nil

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomGui"
screenGui.Parent = localPlayer.PlayerGui

-- Create Frame for the GUI
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 400)
frame.Position = UDim2.new(0.5, -100, 0.5, -200)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true -- Makes the frame draggable

-- Create Highlight Button
local highlightButton = Instance.new("TextButton")
highlightButton.Size = UDim2.new(0, 180, 0, 50)
highlightButton.Position = UDim2.new(0, 10, 0, 10)
highlightButton.Text = "Enable Highlight"
highlightButton.Parent = frame

-- Create Aimbot Button
local aimbotButton = Instance.new("TextButton")
aimbotButton.Size = UDim2.new(0, 180, 0, 50)
aimbotButton.Position = UDim2.new(0, 10, 0, 70)
aimbotButton.Text = "Enable Aimbot"
aimbotButton.Parent = frame

-- Create Aimbot Smoothness Slider
local smoothnessLabel = Instance.new("TextLabel")
smoothnessLabel.Size = UDim2.new(0, 180, 0, 20)
smoothnessLabel.Position = UDim2.new(0, 10, 0, 130)
smoothnessLabel.Text = "Aimbot Smoothness: 0"
smoothnessLabel.Parent = frame

local smoothnessSlider = Instance.new("TextButton")
smoothnessSlider.Size = UDim2.new(0, 180, 0, 20)
smoothnessSlider.Position = UDim2.new(0, 10, 0, 150)
smoothnessSlider.Text = "Adjust Smoothness"
smoothnessSlider.Parent = frame

-- Create Speed Slider
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 180, 0, 20)
speedLabel.Position = UDim2.new(0, 10, 0, 180)
speedLabel.Text = "Speed: 20"
speedLabel.Parent = frame

local speedSlider = Instance.new("TextButton")
speedSlider.Size = UDim2.new(0, 180, 0, 20)
speedSlider.Position = UDim2.new(0, 10, 0, 200)
speedSlider.Text = "Adjust Speed"
speedSlider.Parent = frame

-- Create Noclip Button
local noclipButton = Instance.new("TextButton")
noclipButton.Size = UDim2.new(0, 180, 0, 50)
noclipButton.Position = UDim2.new(0, 10, 0, 230)
noclipButton.Text = "Enable Noclip"
noclipButton.Parent = frame

-- Highlight Functionality
local function highlightPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local highlight = player.Character:FindFirstChild("Highlight") or Instance.new("Highlight")
            highlight.Parent = player.Character
            highlight.FillColor = Color3.new(1, 0, 0)
            highlight.Enabled = highlightEnabled
        end
    end
end

RunService.Heartbeat:Connect(function()
    if highlightEnabled then
        highlightPlayers()
    end
end)

highlightButton.MouseButton1Click:Connect(function()
    highlightEnabled = not highlightEnabled
    highlightButton.Text = highlightEnabled and "Disable Highlight" or "Enable Highlight"
    highlightPlayers()
end)

-- Aimbot Functionality
local function getClosestPlayer()
    local closestDistance = math.huge
    local closestPlayer = nil

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (localPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

UserInputService.InputBegan:Connect(function(input)
    if aimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 then
        aimbotTarget = getClosestPlayer()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        aimbotTarget = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and aimbotTarget and aimbotTarget.Character and aimbotTarget.Character:FindFirstChild("Head") then
        local headPosition = aimbotTarget.Character.Head.Position
        local currentCamera = workspace.CurrentCamera
        local direction = (headPosition - currentCamera.CFrame.Position).unit

        local targetCFrame = CFrame.new(currentCamera.CFrame.Position, currentCamera.CFrame.Position + direction)
        currentCamera.CFrame = currentCamera.CFrame:Lerp(targetCFrame, 1 - aimSmoothness)
    end
end)

aimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimbotButton.Text = aimbotEnabled and "Disable Aimbot" or "Enable Aimbot"
end)

smoothnessSlider.MouseButton1Click:Connect(function()
    aimSmoothness = aimSmoothness + 0.1
    if aimSmoothness > 1 then aimSmoothness = 0 end
    smoothnessLabel.Text = "Aimbot Smoothness: " .. math.floor(aimSmoothness * 100)
end)

-- Speed Slider Functionality
local function setWalkSpeed(newSpeed)
    speed = newSpeed
    if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
        localPlayer.Character.Humanoid.WalkSpeed = speed
    end
end

speedSlider.MouseButton1Click:Connect(function()
    speed = speed + 10
    if speed > 500 then speed = 20 end
    speedLabel.Text = "Speed: " .. speed
    setWalkSpeed(speed) -- Set the walk speed immediately
end)

-- Noclip Functionality
RunService.Stepped:Connect(function()
    if noclipEnabled then
        local character = localPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

noclipButton.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipButton.Text = noclipEnabled and "Disable Noclip" or "Enable Noclip"
end)

-- Keep GUI visible when respawning
localPlayer.CharacterAdded:Connect(function()
    frame.Visible = true
end)

-- Ensure GUI is visible initially
frame.Visible = true

-- Highlight all players at start
highlightPlayers()
