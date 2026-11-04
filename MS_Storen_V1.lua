-- MS STOREN V1 | ONE LOCAL SCRIPT
-- Features: Zombie ESP, NPC Hitbox, Auto Repair, Auto Speed,
-- Backpack GUI toggle, Callout panel, draggable mobile GUI.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ASSET = {
    Background = "rbxassetid://105232558442634",
    Home = "rbxassetid://121041620577917",
    Section = "rbxassetid://72053556177166",
    Intro = "rbxassetid://120820682509222",
    Sound = "rbxassetid://99936497230394"
}

local RED = Color3.fromRGB(225, 25, 35)
local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.fromRGB(12, 12, 15)
local DARK = Color3.fromRGB(25, 25, 29)

local HITBOX_SIZE = Vector3.new(30, 30, 30)
local HITBOX_NAME = "Hitbox expender by epiclnfantry"
local REPAIR_RANGE = 14
local REPAIR_INTERVAL = 0.25
local DEFAULT_SPEED = 19
local BONUS_SPEED = 5

local State = {
    Runner = false, Bomber = false, Cuirassier = false, Zapper = false,
    Hitbox = false, Repair = false, Speed = false, Backpack = false,
    Callout = false
}

for _, name in ipairs({"MS_Storen_Menu", "MS_Storen_Intro"}) do
    local old = PlayerGui:FindFirstChild(name)
    if old then old:Destroy() end
end

-- INTRO: show for 0.5s, fade for 0.7s, then destroy.
local intro = Instance.new("ScreenGui")
intro.Name = "MS_Storen_Intro"
intro.IgnoreGuiInset = true
intro.ResetOnSpawn = false
intro.DisplayOrder = 999
intro.Parent = PlayerGui

local introImage = Instance.new("ImageLabel")
introImage.Size = UDim2.fromScale(1, 1)
introImage.BackgroundColor3 = BLACK
introImage.BackgroundTransparency = 1
introImage.Image = ASSET.Intro
introImage.ScaleType = Enum.ScaleType.Stretch
introImage.Parent = intro

local sound = Instance.new("Sound")
sound.SoundId = ASSET.Sound
sound.Volume = 3
sound.Parent = intro
sound:Play()

task.spawn(function()
    task.wait(0.5)
    if not intro.Parent then return end
    local fade = TweenService:Create(
        introImage,
        TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {ImageTransparency = 1, BackgroundTransparency = 1}
    )
    fade:Play()
    fade.Completed:Wait()
    if intro.Parent then intro:Destroy() end
end)

-- GUI helpers
local gui = Instance.new("ScreenGui")
gui.Name = "MS_Storen_Menu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

local function round(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end

local function image(parent, asset, transparency)
    local img = Instance.new("ImageLabel")
    img.BackgroundTransparency = 1
    img.Size = UDim2.fromScale(1, 1)
    img.Image = asset
    img.ImageTransparency = transparency or 0
    img.ScaleType = Enum.ScaleType.Stretch
    img.Parent = parent
    return img
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(250, 440)
main.Position = UDim2.new(0.5, -125, 0.5, -220)
main.BackgroundColor3 = BLACK
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui
round(main, 12)
image(main, ASSET.Background, 0.15)

local title = Instance.new("Frame")
title.Size = UDim2.new(1, 0, 0, 48)
title.BackgroundColor3 = BLACK
title.BackgroundTransparency = 0.15
title.BorderSizePixel = 0
title.Parent = main

local home = Instance.new("ImageLabel")
home.Size = UDim2.fromOffset(28, 28)
home.Position = UDim2.fromOffset(10, 10)
home.BackgroundTransparency = 1
home.Image = ASSET.Home
home.ImageColor3 = WHITE
home.Parent = title

local titleText = Instance.new("TextLabel")
titleText.Position = UDim2.fromOffset(44, 0)
titleText.Size = UDim2.new(1, -48, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "menu gui by ms storen V 1"
titleText.TextColor3 = WHITE
titleText.TextSize = 14
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = title

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Functions"
scroll.Position = UDim2.fromOffset(7, 54)
scroll.Size = UDim2.new(1, -14, 1, -61)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = RED
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 4)
padding.PaddingBottom = UDim.new(0, 8)
padding.Parent = scroll

local order = 0

local function section(name)
    order += 1
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -4, 0, 28)
    frame.BackgroundColor3 = DARK
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.ClipsDescendants = true
    frame.Parent = scroll
    round(frame, 6)
    image(frame, ASSET.Section, 0.15)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.fromOffset(6, 0)
    label.BackgroundTransparency = 1
    label.Text = "── " .. name .. " ──"
    label.TextColor3 = RED
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = frame
end

local function toggle(name, callback)
    order += 1
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -4, 0, 36)
    button.BackgroundColor3 = BLACK
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.LayoutOrder = order
    button.ClipsDescendants = true
    button.Parent = scroll
    round(button, 6)
    image(button, ASSET.Section, 0.35)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -65, 1, 0)
    label.Position = UDim2.fromOffset(9, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = RED
    label.TextSize = 12
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button

    local switch = Instance.new("Frame")
    switch.Size = UDim2.fromOffset(42, 21)
    switch.Position = UDim2.new(1, -51, 0.5, -10)
    switch.BackgroundColor3 = Color3.fromRGB(35, 35, 39)
    switch.BorderSizePixel = 0
    switch.Parent = button
    round(switch, 6)

    local switchText = Instance.new("TextLabel")
    switchText.Size = UDim2.fromScale(1, 1)
    switchText.BackgroundTransparency = 1
    switchText.Text = "OFF"
    switchText.TextColor3 = WHITE
    switchText.Font = Enum.Font.GothamBold
    switchText.TextSize = 10
    switchText.Parent = switch

    local enabled = false
    button.Activated:Connect(function()
        enabled = not enabled
        label.TextColor3 = enabled and WHITE or RED
        switch.BackgroundColor3 = enabled and RED or Color3.fromRGB(35, 35, 39)
        switchText.Text = enabled and "ON" or "OFF"
        callback(enabled)
    end)
    return button
end

-- Character references
local Character, Humanoid, RootPart
local function updateCharacter(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid", 10)
    RootPart = character:WaitForChild("HumanoidRootPart", 10)
end
if Player.Character then task.spawn(updateCharacter, Player.Character) end
Player.CharacterAdded:Connect(function(character)
    task.spawn(updateCharacter, character)
end)

-- Zombie ESP
local zombieHighlights = {}

local function removeZombieESP(obj)
    local h = zombieHighlights[obj]
    if h then
        h:Destroy()
        zombieHighlights[obj] = nil
    end
end

local function scanZombieESP()
    local camera = Workspace:FindFirstChild("Camera") or Workspace.CurrentCamera
    if not camera then return end

    for _, child in ipairs(camera:GetChildren()) do
        if child.Name ~= "m_Zombie" then continue end
        local origin = child:FindFirstChild("Orig")
        local zombie = origin and origin.Value
        local color

        if zombie then
            local zombieHumanoid = zombie:FindFirstChild("Zombie")
            if State.Runner and zombieHumanoid and zombieHumanoid.WalkSpeed > 20 then
                color = Color3.fromRGB(255, 35, 35)
            elseif State.Bomber and child:FindFirstChild("Barrel") then
                color = Color3.fromRGB(65, 105, 225)
            elseif State.Cuirassier and child:FindFirstChild("Sword") then
                color = Color3.fromRGB(65, 105, 225)
            elseif State.Zapper and child:FindFirstChild("Axe") then
                color = Color3.fromRGB(255, 0, 255)
            end
        end

        if color then
            local h = zombieHighlights[child]
            if not h or not h.Parent then
                h = Instance.new("Highlight")
                h.Name = "ESP_Highlight"
                h.Adornee = child
                h.Parent = child
                zombieHighlights[child] = h
            end
            h.FillColor = color
            h.OutlineColor = color
        else
            removeZombieESP(child)
        end
    end

    for obj in pairs(zombieHighlights) do
        if not obj.Parent then removeZombieESP(obj) end
    end
end

section("ZOMBIE ESP")
toggle("Runner ESP", function(v) State.Runner = v end)
toggle("Bomber ESP", function(v) State.Bomber = v end)
toggle("Cuirassier ESP", function(v) State.Cuirassier = v end)
toggle("Zapper ESP", function(v) State.Zapper = v end)

-- NPC hitbox
local trackedNPCs = {}

local function removeHitboxes()
    for npc, hitbox in pairs(trackedNPCs) do
        if hitbox and hitbox.Parent then hitbox:Destroy() end
        trackedNPCs[npc] = nil
    end
end

local function setupNPC(npc)
    if not State.Hitbox or not npc:IsA("Model") or trackedNPCs[npc] then return end
    if Players:GetPlayerFromCharacter(npc) then return end
    local head = npc:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") or npc:FindFirstChild(HITBOX_NAME) then return end

    local hitbox = Instance.new("Part")
    hitbox.Name = HITBOX_NAME
    hitbox.Size = HITBOX_SIZE
    hitbox.Transparency = 1
    hitbox.CanCollide = false
    hitbox.CanTouch = false
    hitbox.CanQuery = true
    hitbox.Massless = true
    hitbox.CFrame = head.CFrame
    hitbox.Parent = npc

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = head
    weld.Part1 = hitbox
    weld.Parent = hitbox
    trackedNPCs[npc] = hitbox
end

section("HITBOX EXPANDER")
toggle("Hitbox Expander", function(v)
    State.Hitbox = v
    if v then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then setupNPC(obj) end
        end
    else
        removeHitboxes()
    end
end)

Workspace.DescendantAdded:Connect(function(obj)
    if not State.Hitbox then return end
    if obj:IsA("Model") then
        task.defer(setupNPC, obj)
    elseif obj.Name == "Head" then
        local model = obj:FindFirstAncestorOfClass("Model")
        if model then task.defer(setupNPC, model) end
    end
end)

-- Auto repair all building owner folders
local function getHammer()
    local character = Player.Character
    local hammer = character and character:FindFirstChild("Hammer")
    if not hammer then
        local backpack = Player:FindFirstChild("Backpack")
        hammer = backpack and backpack:FindFirstChild("Hammer")
    end
    return hammer
end

local function buildingPosition(building)
    if building:IsA("BasePart") then return building.Position end
    if building:IsA("Model") then
        local ok, pivot = pcall(function() return building:GetPivot() end)
        if ok then return pivot.Position end
    end
    local part = building:FindFirstChildWhichIsA("BasePart", true)
    return part and part.Position
end

local function repairNearby()
    if not State.Repair then return end
    local character = Player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local hammer = getHammer()
    local remote = hammer and hammer:FindFirstChild("RemoteEvent")
    local folder = Workspace:FindFirstChild("Buildings")
    if not root or not remote or not remote:IsA("RemoteEvent") or not folder then return end

    local checked = {}
    local function check(building)
        if checked[building] then return false end
        checked[building] = true
        local health = building:FindFirstChild("BuildingHealth")
        if not health or not health:IsA("NumberValue") then return false end
        local maxHealth = health:GetAttribute("MaxHealth")
        if not maxHealth or health.Value >= maxHealth then return false end
        local pos = buildingPosition(building)
        if not pos or (root.Position - pos).Magnitude > REPAIR_RANGE then return false end
        remote:FireServer("Repair", health)
        return true
    end

    for _, item in ipairs(folder:GetChildren()) do
        if check(item) then return end
    end
    for _, ownerFolder in ipairs(folder:GetChildren()) do
        if ownerFolder:IsA("Folder") then
            for _, building in ipairs(ownerFolder:GetChildren()) do
                if check(building) then return end
            end
        end
    end
end

section("BUILDING")
toggle("Auto Repair", function(v) State.Repair = v end)

task.spawn(function()
    while gui.Parent do
        if State.Repair then pcall(repairNearby) end
        task.wait(REPAIR_INTERVAL)
    end
end)

-- Auto speed
local speedConnection
local speedHumanoid
local lastSpeed = DEFAULT_SPEED
local changingSpeed = false

local function setupSpeed(character)
    if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
    speedHumanoid = nil
    if not State.Speed then return end

    local hum = character:WaitForChild("Humanoid", 5)
    if not hum or not State.Speed then return end
    speedHumanoid = hum
    lastSpeed = hum.WalkSpeed

    local function setSpeed(value)
        changingSpeed = true
        hum.WalkSpeed = value
        lastSpeed = value
        changingSpeed = false
    end

    if hum.WalkSpeed < DEFAULT_SPEED then setSpeed(DEFAULT_SPEED) end
    speedConnection = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if changingSpeed or not State.Speed then return end
        local current = hum.WalkSpeed
        if current < DEFAULT_SPEED then
            setSpeed(DEFAULT_SPEED)
        elseif current > lastSpeed then
            setSpeed(current + BONUS_SPEED)
        else
            lastSpeed = current
        end
    end)
end

section("PLAYER")
toggle("Auto Speed", function(v)
    State.Speed = v
    if v and Player.Character then
        task.spawn(setupSpeed, Player.Character)
    elseif speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
        speedHumanoid = nil
    end
end)

Player.CharacterAdded:Connect(function(character)
    if State.Speed then task.spawn(setupSpeed, character) end
end)

-- Backpack GUI: reveal the existing game GUI only
local backpackGui
local originalBackpackState

local function setBackpack(enabled)
    local found = PlayerGui:FindFirstChild("BackpackGui")
    if not found or not found:IsA("ScreenGui") then return end

    if enabled then
        if backpackGui ~= found then
            backpackGui = found
            originalBackpackState = found.Enabled
        end
        found.Enabled = true
    else
        if backpackGui and backpackGui.Parent and originalBackpackState ~= nil then
            backpackGui.Enabled = originalBackpackState
        end
        backpackGui = nil
        originalBackpackState = nil
    end
end

section("BACKPACK")
toggle("Backpack GUI", function(v)
    State.Backpack = v
    setBackpack(v)
end)

PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "BackpackGui" and child:IsA("ScreenGui") and State.Backpack then
        backpackGui = child
        originalBackpackState = child.Enabled
        child.Enabled = true
    end
end)

task.spawn(function()
    while gui.Parent do
        if State.Backpack then setBackpack(true) end
        task.wait(0.5)
    end
end)

-- Callout panel
section("CALLOUT")

local callout = Instance.new("Frame")
callout.Name = "CalloutFrame"
callout.Size = UDim2.fromOffset(185, 275)
callout.Position = UDim2.new(0.5, 135, 0.35, 0)
callout.BackgroundColor3 = BLACK
callout.BorderSizePixel = 0
callout.Visible = false
callout.Parent = gui
round(callout, 10)
image(callout, ASSET.Background, 0.2)

local calloutTitle = Instance.new("TextLabel")
calloutTitle.Size = UDim2.new(1, 0, 0, 38)
calloutTitle.BackgroundColor3 = RED
calloutTitle.Text = "CALLOUT"
calloutTitle.TextColor3 = WHITE
calloutTitle.Font = Enum.Font.GothamBold
calloutTitle.TextSize = 15
calloutTitle.Parent = callout
round(calloutTitle, 8)

local calloutList = Instance.new("Frame")
calloutList.Position = UDim2.fromOffset(6, 44)
calloutList.Size = UDim2.new(1, -12, 1, -50)
calloutList.BackgroundTransparency = 1
calloutList.Parent = callout

local calloutLayout = Instance.new("UIListLayout")
calloutLayout.Padding = UDim.new(0, 5)
calloutLayout.Parent = calloutList

for _, name in ipairs({"Cuirassier", "Runner", "Shambler", "Zapper", "Bomber", "Igniter"}) do
    local b = Instance.new("TextButton")
    b.Name = "Call_" .. name
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = BLACK
    b.BorderSizePixel = 0
    b.Text = name
    b.TextColor3 = RED
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.Parent = calloutList
    round(b, 6)

    b.Activated:Connect(function()
        local character = Player.Character
        local remote = character and character:FindFirstChild("TriggerVoice")
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer("CalloutZombie", name)
        end
    end)
end

toggle("Callout GUI", function(v)
    State.Callout = v
    callout.Visible = v
end)

-- Hide/show button
local hide = Instance.new("TextButton")
hide.Name = "HideButton"
hide.Size = UDim2.fromOffset(105, 36)
hide.Position = UDim2.new(0, 12, 0.5, 0)
hide.BackgroundColor3 = RED
hide.BorderSizePixel = 0
hide.Text = "ẨN GUI"
hide.TextColor3 = WHITE
hide.TextSize = 13
hide.Font = Enum.Font.GothamBold
hide.Parent = gui
round(hide, 7)

hide.Activated:Connect(function()
    main.Visible = not main.Visible
    hide.Text = main.Visible and "ẨN GUI" or "HIỆN GUI"
end)

-- Drag support for mouse and touch
local function makeDraggable(handle, target)
    local dragging = false
    local startInput, startPosition, activeTouch

    handle.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
            and input.UserInputType ~= Enum.UserInputType.Touch then return end

        dragging = true
        startInput = input.Position
        startPosition = target.Position
        activeTouch = input.UserInputType == Enum.UserInputType.Touch and input or nil

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                activeTouch = nil
            end
        end)
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if activeTouch and input.UserInputType == Enum.UserInputType.Touch
            and input ~= activeTouch then return end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - startInput
            target.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(title, main)
makeDraggable(hide, hide)
makeDraggable(calloutTitle, callout)

-- Periodic ESP and cleanup
local espTimer = 0
RunService.Heartbeat:Connect(function(dt)
    espTimer += dt
    if espTimer >= 0.5 then
        espTimer = 0
        scanZombieESP()
    end
end)

-- Cleanup if features are switched off
task.spawn(function()
    while gui.Parent do
        if not State.Hitbox then removeHitboxes() end
        if not State.Speed and speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
            speedHumanoid = nil
        end
        task.wait(1)
    end
end)

print("MS STOREN V1 LOADED")
