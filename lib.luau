local Millionware
local success, res = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Mrsims0/Ui/refs/heads/main/lib.luau"))()
end)

if success and res then
    Millionware = res
elseif script and script.Parent and script.Parent:FindFirstChild("library") then
    Millionware = require(script.Parent.library)
end

local Window = Millionware:CreateWindow({
    Title = "millionware",
    Size = Vector2.new(740, 532),
    SidebarWidth = 140,
    MainAreaOffset = Vector2.new(143, 0),
    SubtabsHeight = 22,
    SubtabsOffset = Vector2.new(0, 0),
    LogoId = "millionware.png",
    LogoPosition = UDim2.new(0, 18, 0, 8),
    LogoRotation = 0,
    LogoSize = UDim2.new(0, 104, 0, 48),
})

local AimbotTab = Window:Tab("Aimbot")
local VisualsTab = Window:Tab("Visuals")
local MiscTab = Window:Tab("Misc")
local SkinsTab = Window:Tab("Skins")
local SettingsTab = Window:Tab("Settings")

local EntitiesSubtab = AimbotTab:Subtab("Entities")
local WorldSubtab = AimbotTab:Subtab("World")
local ViewSubtab = AimbotTab:Subtab("View")

local General = EntitiesSubtab:Section({
    Title = "General",
    Side = "Left"
})

local PerWeapon = General:Checkbox({
    Name = "Per weapon settings",
    Default = true,
    Callback = function(val)
        print("Per weapon settings:", val)
    end
})
PerWeapon:Colorpicker({
    Default = Color3.fromRGB(130, 40, 240),
    Callback = function(col)
        print("Color changed:", col)
    end
})

local Enabled = General:Checkbox({
    Name = "Enabled",
    Default = true,
    Callback = function(val)
        print("Enabled:", val)
    end
})
Enabled:Keybind({
    Default = Enum.UserInputType.MouseButton2,
    Callback = function(key)
        print("Enabled keybind set to:", key)
    end
})

General:Dropdown({
    Name = "Flick bot",
    Items = { "Disabled", "Enabled" },
    Default = "Enabled",
    Callback = function(selected)
        print("Flick bot:", selected)
    end
})

General:Checkbox({
    Name = "Console aim assist",
    Default = true,
    Callback = function(val)
        print("Console aim assist:", val)
    end
})

General:Checkbox({
    Name = "Backtrack",
    Default = true,
    Callback = function(val)
        print("Backtrack:", val)
    end
})

local Filters = EntitiesSubtab:Section({
    Title = "Filters",
    Side = "Left"
})

Filters:Checkbox({
    Name = "Auto wall",
    Default = true,
    Callback = function(val)
        print("Auto wall:", val)
    end
})

Filters:Checkbox({
    Name = "Target teammates",
    Default = true,
    Callback = function(val)
        print("Target teammates:", val)
    end
})

Filters:Checkbox({
    Name = "Smoke check",
    Default = true,
    Callback = function(val)
        print("Smoke check:", val)
    end
})

Filters:Checkbox({
    Name = "Flash check",
    Default = false,
    Callback = function(val)
        print("Flash check:", val)
    end
})

local StandaloneRCS = EntitiesSubtab:Section({
    Title = "Standalone RCS",
    Side = "Left"
})

StandaloneRCS:Checkbox({
    Name = "Enabled",
    Default = false,
    Callback = function(val)
        print("Standalone RCS Enabled:", val)
    end
})

local AimOptions = EntitiesSubtab:Section({
    Title = "Aim options",
    Side = "Right"
})

AimOptions:Slider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 35,
    Callback = function(val)
        print("Speed:", val)
    end
})

AimOptions:Slider({
    Name = "Speed exponent",
    Min = 1,
    Max = 10,
    Default = 7.3,
    Float = true,
    Callback = function(val)
        print("Speed exponent:", val)
    end
})

AimOptions:Slider({
    Name = "RCS X",
    Min = 0,
    Max = 100,
    Default = 90,
    Suffix = "%",
    Callback = function(val)
        print("RCS X:", val)
    end
})

AimOptions:Slider({
    Name = "RCS Y",
    Min = 0,
    Max = 100,
    Default = 39,
    Suffix = "%",
    Callback = function(val)
        print("RCS Y:", val)
    end
})

AimOptions:Checkbox({
    Name = "Adaptive",
    Default = true,
    Callback = function(val)
        print("Adaptive:", val)
    end
})

local Prerequisites = EntitiesSubtab:Section({
    Title = "Prerequisites",
    Side = "Right"
})

Prerequisites:Slider({
    Name = "FOV",
    Min = 0,
    Max = 180,
    Default = 40,
    Callback = function(val)
        print("FOV:", val)
    end
})

Prerequisites:Slider({
    Name = "Start bullets",
    Min = 1,
    Max = 4,
    Default = 4,
    Callback = function(val)
        print("Start bullets:", val)
    end
})

Prerequisites:Dropdown({
    Name = "Hitbox method",
    Items = { "Head", "Body", "Chest", "Arms", "Legs", "Nearest" },
    Default = "Body",
    Callback = function(selected)
        print("Hitbox method:", selected)
    end
})

Prerequisites:Checkbox({
    Name = "Target backtrack",
    Default = true,
    Callback = function(val)
        print("Target backtrack:", val)
    end
})

local Triggerbot = EntitiesSubtab:Section({
    Title = "Triggerbot",
    Side = "Right"
})

Triggerbot:Checkbox({
    Name = "Enabled",
    Default = true,
    Callback = function(val)
        print("Triggerbot Enabled:", val)
    end
})

local Preview = Window:CreatePreview({
    Title = "ESP Preview",
    Size = Vector2.new(220, 340),
    Offset = Vector2.new(12, 0),
    Visible = true
})

local PlayersSubtab = VisualsTab:Subtab("Players")
local WorldVisualsSubtab = VisualsTab:Subtab("World")

local ESPSection = PlayersSubtab:Section({
    Title = "ESP",
    Side = "Left"
})

local espSettings = {
    Enabled = true,
    Box = true,
    BoxColor = Color3.fromRGB(255, 255, 255),
    Skeleton = true,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    Name = true,
    NameColor = Color3.fromRGB(240, 240, 240),
    Health = true,
    HealthValue = 100,
    Chams = true,
    ChamsColor = Color3.fromRGB(150, 100, 220),
    ChamsMaterial = Enum.Material.ForceField,
}

local PlayersService = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = PlayersService.LocalPlayer
local Camera = workspace.CurrentCamera

local espDrawings = {}

local function createPlayerESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Filled = false
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Visible = false

    local boxOutline = Drawing.new("Square")
    boxOutline.Thickness = 3
    boxOutline.Filled = false
    boxOutline.Color = Color3.fromRGB(0, 0, 0)
    boxOutline.Visible = false

    local name = Drawing.new("Text")
    name.Size = 13
    name.Center = true
    name.Outline = true
    name.Visible = false

    local healthBg = Drawing.new("Square")
    healthBg.Filled = true
    healthBg.Color = Color3.fromRGB(0, 0, 0)
    healthBg.Visible = false

    local healthFill = Drawing.new("Square")
    healthFill.Filled = true
    healthFill.Color = Color3.fromRGB(80, 220, 80)
    healthFill.Visible = false

    local bones = {}
    for i = 1, 14 do
        local line = Drawing.new("Line")
        line.Thickness = 1.2
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Visible = false
        bones[i] = line
    end

    espDrawings[player] = {
        Box = box,
        BoxOutline = boxOutline,
        Name = name,
        HealthBg = healthBg,
        HealthFill = healthFill,
        Highlight = nil,
        Bones = bones,
    }
end

local function removePlayerESP(player)
    local data = espDrawings[player]
    if data then
        if data.Box then data.Box:Remove() end
        if data.BoxOutline then data.BoxOutline:Remove() end
        if data.Name then data.Name:Remove() end
        if data.HealthBg then data.HealthBg:Remove() end
        if data.HealthFill then data.HealthFill:Remove() end
        if data.Highlight then data.Highlight:Destroy() end
        if data.Bones then
            for _, b in ipairs(data.Bones) do
                b:Remove()
            end
        end
        espDrawings[player] = nil
    end
end

for _, p in ipairs(PlayersService:GetPlayers()) do
    createPlayerESP(p)
end
PlayersService.PlayerAdded:Connect(createPlayerESP)
PlayersService.PlayerRemoving:Connect(removePlayerESP)

RunService.RenderStepped:Connect(function()
    for player, data in pairs(espDrawings) do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if espSettings.Enabled and char and hum and hrp and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local head = char:FindFirstChild("Head")
                local topY = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0)).Y or (pos.Y - 20)
                local bottomY = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0)).Y
                local height = math.abs(bottomY - topY)
                local width = height * 0.48
                local x = pos.X - width / 2
                local y = topY

                if espSettings.Box then
                    data.BoxOutline.Size = Vector2.new(width, height)
                    data.BoxOutline.Position = Vector2.new(x, y)
                    data.BoxOutline.Visible = true

                    data.Box.Size = Vector2.new(width, height)
                    data.Box.Position = Vector2.new(x, y)
                    data.Box.Color = espSettings.BoxColor
                    data.Box.Visible = true
                else
                    data.Box.Visible = false
                    data.BoxOutline.Visible = false
                end

                if espSettings.Name then
                    data.Name.Text = player.DisplayName
                    data.Name.Position = Vector2.new(pos.X, y - 16)
                    data.Name.Color = espSettings.NameColor
                    data.Name.Visible = true
                else
                    data.Name.Visible = false
                end

                if espSettings.Health then
                    local hpPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    data.HealthBg.Size = Vector2.new(2, height)
                    data.HealthBg.Position = Vector2.new(x - 5, y)
                    data.HealthBg.Visible = true

                    local fillH = height * hpPct
                    data.HealthFill.Size = Vector2.new(2, fillH)
                    data.HealthFill.Position = Vector2.new(x - 5, y + (height - fillH))
                    data.HealthFill.Visible = true
                else
                    data.HealthBg.Visible = false
                    data.HealthFill.Visible = false
                end

                if espSettings.Skeleton and data.Bones then
                    local bonePairs = {}
                    if char:FindFirstChild("UpperTorso") then
                        bonePairs = {
                            { "Head", "UpperTorso" },
                            { "UpperTorso", "LowerTorso" },
                            { "UpperTorso", "LeftUpperArm" },
                            { "LeftUpperArm", "LeftLowerArm" },
                            { "LeftLowerArm", "LeftHand" },
                            { "UpperTorso", "RightUpperArm" },
                            { "RightUpperArm", "RightLowerArm" },
                            { "RightLowerArm", "RightHand" },
                            { "LowerTorso", "LeftUpperLeg" },
                            { "LeftUpperLeg", "LeftLowerLeg" },
                            { "LeftLowerLeg", "LeftFoot" },
                            { "LowerTorso", "RightUpperLeg" },
                            { "RightUpperLeg", "RightLowerLeg" },
                            { "RightLowerLeg", "RightFoot" },
                        }
                    elseif char:FindFirstChild("Torso") then
                        bonePairs = {
                            { "Head", "Torso" },
                            { "Torso", "Left Arm" },
                            { "Torso", "Right Arm" },
                            { "Torso", "Left Leg" },
                            { "Torso", "Right Leg" },
                        }
                    end

                    for idx, line in ipairs(data.Bones) do
                        local pair = bonePairs[idx]
                        if pair then
                            local p1Part = char:FindFirstChild(pair[1], true)
                            local p2Part = char:FindFirstChild(pair[2], true)
                            if p1Part and p2Part then
                                local p1, s1 = Camera:WorldToViewportPoint(p1Part.Position)
                                local p2, s2 = Camera:WorldToViewportPoint(p2Part.Position)
                                if s1 and s2 then
                                    line.From = Vector2.new(p1.X, p1.Y)
                                    line.To = Vector2.new(p2.X, p2.Y)
                                    line.Color = espSettings.SkeletonColor
                                    line.Visible = true
                                else
                                    line.Visible = false
                                end
                            else
                                line.Visible = false
                            end
                        else
                            line.Visible = false
                        end
                    end
                else
                    if data.Bones then
                        for _, line in ipairs(data.Bones) do
                            line.Visible = false
                        end
                    end
                end

                if espSettings.Chams then
                    if not data.Highlight then
                        local hl = Instance.new("Highlight")
                        hl.Name = "MW_Chams"
                        hl.FillTransparency = 0.4
                        hl.OutlineTransparency = 0
                        hl.Parent = char
                        data.Highlight = hl
                    end
                    data.Highlight.FillColor = espSettings.ChamsColor
                    data.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    data.Highlight.Enabled = true
                else
                    if data.Highlight then
                        data.Highlight.Enabled = false
                    end
                end
            else
                data.Box.Visible = false
                data.BoxOutline.Visible = false
                data.Name.Visible = false
                data.HealthBg.Visible = false
                data.HealthFill.Visible = false
                if data.Bones then
                    for _, line in ipairs(data.Bones) do line.Visible = false end
                end
                if data.Highlight then data.Highlight.Enabled = false end
            end
        else
            data.Box.Visible = false
            data.BoxOutline.Visible = false
            data.Name.Visible = false
            data.HealthBg.Visible = false
            data.HealthFill.Visible = false
            if data.Bones then
                for _, line in ipairs(data.Bones) do line.Visible = false end
            end
            if data.Highlight then data.Highlight.Enabled = false end
        end
    end
end)

ESPSection:Checkbox({
    Name = "Master enabled",
    Default = espSettings.Enabled,
    Callback = function(val)
        espSettings.Enabled = val
    end
})

ESPSection:Checkbox({
    Name = "Bounding box",
    Default = espSettings.Box,
    Color = espSettings.BoxColor,
    Callback = function(val)
        espSettings.Box = val
        Preview:SetBox(espSettings.Box, espSettings.BoxColor)
    end,
    ColorCallback = function(col)
        espSettings.BoxColor = col
        Preview:SetBox(espSettings.Box, espSettings.BoxColor)
    end
})

ESPSection:Checkbox({
    Name = "Skeleton",
    Default = espSettings.Skeleton,
    Color = espSettings.SkeletonColor,
    Callback = function(val)
        espSettings.Skeleton = val
        Preview:SetSkeleton(espSettings.Skeleton, espSettings.SkeletonColor)
    end,
    ColorCallback = function(col)
        espSettings.SkeletonColor = col
        Preview:SetSkeleton(espSettings.Skeleton, espSettings.SkeletonColor)
    end
})

ESPSection:Checkbox({
    Name = "Name tag",
    Default = espSettings.Name,
    Color = espSettings.NameColor,
    Callback = function(val)
        espSettings.Name = val
        Preview:SetName(espSettings.Name, (LocalPlayer and LocalPlayer.DisplayName or "LocalPlayer") .. " [0m]", espSettings.NameColor)
    end,
    ColorCallback = function(col)
        espSettings.NameColor = col
        Preview:SetName(espSettings.Name, (LocalPlayer and LocalPlayer.DisplayName or "LocalPlayer") .. " [0m]", espSettings.NameColor)
    end
})

ESPSection:Checkbox({
    Name = "Health bar",
    Default = espSettings.Health,
    Callback = function(val)
        espSettings.Health = val
        Preview:SetHealth(espSettings.Health, espSettings.HealthValue / 100)
    end
})

ESPSection:SliderInt({
    Name = "Preview health",
    Min = 0,
    Max = 100,
    Default = 100,
    Suffix = "%",
    Callback = function(val)
        espSettings.HealthValue = val
        Preview:SetHealth(espSettings.Health, val / 100)
    end
})

local ChamsSection = PlayersSubtab:Section({
    Title = "Chams & Models",
    Side = "Right"
})

ChamsSection:Checkbox({
    Name = "Player chams",
    Default = espSettings.Chams,
    Color = espSettings.ChamsColor,
    Callback = function(val)
        espSettings.Chams = val
        Preview:SetChams(espSettings.Chams, espSettings.ChamsColor, espSettings.ChamsMaterial)
    end,
    ColorCallback = function(col)
        espSettings.ChamsColor = col
        Preview:SetChams(espSettings.Chams, espSettings.ChamsColor, espSettings.ChamsMaterial)
    end
})

ChamsSection:Dropdown({
    Name = "Material",
    Items = { "ForceField", "Neon", "SmoothPlastic", "Glass" },
    Default = "ForceField",
    Callback = function(matName)
        local mat = Enum.Material[matName] or Enum.Material.SmoothPlastic
        espSettings.ChamsMaterial = mat
        Preview:SetChams(espSettings.Chams, espSettings.ChamsColor, mat)
    end
})

ChamsSection:Checkbox({
    Name = "Show preview window",
    Default = true,
    Callback = function(val)
        Preview:SetVisible(val)
    end
})

Preview:SetBox(espSettings.Box, espSettings.BoxColor)
Preview:SetSkeleton(espSettings.Skeleton, espSettings.SkeletonColor)
Preview:SetName(espSettings.Name, (LocalPlayer and LocalPlayer.DisplayName or "LocalPlayer") .. " [0m]", espSettings.NameColor)
Preview:SetHealth(espSettings.Health, espSettings.HealthValue / 100)
Preview:SetChams(espSettings.Chams, espSettings.ChamsColor, espSettings.ChamsMaterial)
