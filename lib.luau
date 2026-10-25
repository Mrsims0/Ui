--[[
    Millionware UI Library for Roblox (Luau)
    1:1 Port from C++ ImGui / Slate Implementation
    Supports Roblox GUI + Drawing API environment
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local function getGuiParent()
    local success, core = pcall(function()
        return CoreGui
    end)
    if success and core then
        return core
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local Library = {
    Font = Enum.Font.SourceSans,
    FontBold = Enum.Font.SourceSansBold,
    Themes = {
        Default = {
            Scheme = Color3.fromRGB(202, 115, 132), -- #CA7384 Rose pink
            Text = Color3.fromRGB(234, 234, 234),
            TextDim = Color3.fromRGB(160, 160, 160),
            TextDisabled = Color3.fromRGB(100, 100, 100),
            MainBg = Color3.fromRGB(14, 14, 14),
            ChildBg = Color3.fromRGB(17, 17, 17),
            TabBg = Color3.fromRGB(22, 22, 22),
            TabHover = Color3.fromRGB(30, 27, 29),
            WidgetBg = Color3.fromRGB(18, 18, 18),
            WidgetHover = Color3.fromRGB(27, 27, 27),
            Border = Color3.fromRGB(0, 0, 0),
            SubBorder = Color3.fromRGB(30, 30, 30),
            Separator = Color3.fromRGB(255, 255, 255),
            SeparatorTransparency = 0.96,
        }
    },
    CurrentTheme = nil,
    ScreenGui = nil,
    Popups = nil,
}
Library.CurrentTheme = Library.Themes.Default

function Library:SetFont(regular, bold)
    Library.Font = regular or Library.Font
    Library.FontBold = bold or Library.FontBold
    if Library.ScreenGui then
        for _, desc in ipairs(Library.ScreenGui:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                if desc.Font == Enum.Font.SourceSansBold or desc.Font == Library.FontBold then
                    desc.Font = Library.FontBold
                else
                    desc.Font = Library.Font
                end
            end
        end
    end
end

local KeyNames = {
    [Enum.UserInputType.MouseButton1] = "M1",
    [Enum.UserInputType.MouseButton2] = "M2",
    [Enum.UserInputType.MouseButton3] = "M3",
    [Enum.KeyCode.LeftShift] = "SHIFT",
    [Enum.KeyCode.RightShift] = "SHIFT",
    [Enum.KeyCode.LeftControl] = "CTRL",
    [Enum.KeyCode.RightControl] = "CTRL",
    [Enum.KeyCode.LeftAlt] = "ALT",
    [Enum.KeyCode.RightAlt] = "ALT",
    [Enum.KeyCode.CapsLock] = "CAPS",
    [Enum.KeyCode.Return] = "ENT",
    [Enum.KeyCode.Backspace] = "BACK",
    [Enum.KeyCode.Space] = "SPACE",
    [Enum.KeyCode.Tab] = "TAB",
}

local function formatKey(input)
    if not input then return "NONE" end
    if typeof(input) == "EnumItem" then
        if KeyNames[input] then return KeyNames[input] end
        local name = input.Name
        if #name > 5 then
            return string.sub(name, 1, 5):upper()
        end
        return name:upper()
    end
    return tostring(input):upper()
end

local function tween(object, info, properties)
    local tw = TweenService:Create(object, info, properties)
    tw:Play()
    return tw
end

-- Custom Draggable
local function makeDraggable(topbar, main)
    local dragging = false
    local dragInput, dragStart, startPos

    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Library:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "millionware"
    local Logo = config.Logo or config.LogoId or ""
    local Size = config.Size or Vector2.new(740, 532)

    -- Cleanup existing if any
    if Library.ScreenGui then
        Library.ScreenGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Millionware_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = getGuiParent()
    Library.ScreenGui = ScreenGui

    -- Popups holder for dropdowns and colorpickers (Top ZIndex)
    local Popups = Instance.new("Frame")
    Popups.Name = "Popups"
    Popups.BackgroundTransparency = 1
    Popups.Size = UDim2.new(1, 0, 1, 0)
    Popups.ZIndex = 100
    Popups.Parent = ScreenGui
    Library.Popups = Popups

    -- Main Container Window (740x532 exact)
    local Main = Instance.new("Frame")
    Main.Name = "MainWindow"
    Main.Size = UDim2.new(0, Size.X, 0, Size.Y)
    Main.Position = UDim2.new(0.5, -Size.X / 2, 0.5, -Size.Y / 2)
    Main.BackgroundColor3 = Library.CurrentTheme.MainBg
    Main.BorderSizePixel = 1
    Main.BorderColor3 = Library.CurrentTheme.Border
    Main.Active = true
    Main.ClipsDescendants = false
    Main.Parent = ScreenGui

    -- Top 31px gradient shine (1:1 from C++)
    local WindowGradient = Instance.new("Frame")
    WindowGradient.Name = "TopShine"
    WindowGradient.Size = UDim2.new(1, 0, 0, 31)
    WindowGradient.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    WindowGradient.BorderSizePixel = 0
    WindowGradient.ZIndex = 2
    WindowGradient.Parent = Main

    local UIGrad = Instance.new("UIGradient")
    UIGrad.Rotation = 90
    UIGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.97),
        NumberSequenceKeypoint.new(1, 1)
    })
    UIGrad.Parent = WindowGradient

    -- Drag Handle on topbar
    local DragBar = Instance.new("Frame")
    DragBar.Name = "DragBar"
    DragBar.Size = UDim2.new(1, 0, 0, 31)
    DragBar.BackgroundTransparency = 1
    DragBar.ZIndex = 5
    DragBar.Parent = Main
    makeDraggable(DragBar, Main)

    -- Topbar Search Input
    local SearchContainer = Instance.new("Frame")
    SearchContainer.Name = "SearchContainer"
    SearchContainer.Size = UDim2.new(0, 160, 0, 20)
    SearchContainer.Position = UDim2.new(1, -170, 0, 5)
    SearchContainer.BackgroundColor3 = Library.CurrentTheme.WidgetBg
    SearchContainer.BorderSizePixel = 1
    SearchContainer.BorderColor3 = Library.CurrentTheme.Border
    SearchContainer.ZIndex = 6
    SearchContainer.Parent = Main

    local SearchBox = Instance.new("TextBox")
    SearchBox.Name = "SearchBox"
    SearchBox.Size = UDim2.new(1, -12, 1, 0)
    SearchBox.Position = UDim2.new(0, 6, 0, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.PlaceholderText = "Search features..."
    SearchBox.PlaceholderColor3 = Library.CurrentTheme.TextDisabled
    SearchBox.Text = ""
    SearchBox.TextColor3 = Library.CurrentTheme.Text
    SearchBox.Font = Library.Font
    SearchBox.TextSize = 12
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = 7
    SearchBox.Parent = SearchContainer

    local allRegisteredWidgets = {}
    local function performSearch(query)
        query = string.lower(string.gsub(query or "", "^%s*(.-)%s*$", "%1"))
        for _, w in ipairs(allRegisteredWidgets) do
            if w.Frame and w.Name then
                if query == "" then
                    w.Frame.Visible = true
                else
                    local wName = string.lower(w.Name)
                    -- Matches items that start with the query, or any word within the title starting with query
                    local startsWith = string.sub(wName, 1, #query) == query
                    if not startsWith then
                        -- Check each word start (e.g. "per weapon settings" matching "weapon")
                        for word in string.gmatch(wName, "%S+") do
                            if string.sub(word, 1, #query) == query then
                                startsWith = true
                                break
                            end
                        end
                    end
                    w.Frame.Visible = startsWith
                end
            end
        end
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        performSearch(SearchBox.Text)
    end)

    -- Inner Container: 720 x 491 at (10, 31)
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Size = UDim2.new(0, Size.X - 20, 0, Size.Y - 41)
    ContentHolder.Position = UDim2.new(0, 10, 0, 31)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = Main

    local SidebarWidth = config.SidebarWidth or 140
    local SubtabsHeight = config.SubtabsHeight or 22
    local SubtabsOffset = config.SubtabsOffset or Vector2.new(0, 0)
    local MainAreaOffset = config.MainAreaOffset or Vector2.new(143, 0)
    local LogoPosition = config.LogoPosition or UDim2.new(0, 18, 0, 8)
    local LogoRotation = config.LogoRotation or 0

    -- Left Sidebar (width 140 or configured)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, SidebarWidth, 1, 0)
    Sidebar.BackgroundColor3 = Library.CurrentTheme.MainBg
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = ContentHolder

    -- Logo Area
    local LogoHolder = Instance.new("Frame")
    LogoHolder.Name = "LogoHolder"
    LogoHolder.Size = UDim2.new(1, 0, 0, 68)
    LogoHolder.BackgroundTransparency = 1
    LogoHolder.Parent = Sidebar

    local LogoImage = Instance.new("ImageLabel")
    LogoImage.Name = "Logo"
    LogoImage.Size = config.LogoSize or UDim2.new(0, 104, 0, 48)
    LogoImage.Position = LogoPosition
    LogoImage.Rotation = LogoRotation
    LogoImage.BackgroundTransparency = 1
    LogoImage.ScaleType = Enum.ScaleType.Fit

    if Logo and Logo ~= "" then
        local logoStr = tostring(Logo)
        -- Support executor filesystem workspace PNG/images (e.g. "millionware.png" or "workspace/millionware.png")
        if typeof(getcustomasset) == "function" and (string.find(logoStr:lower(), "%.png$") or string.find(logoStr:lower(), "%.jpg$") or string.find(logoStr:lower(), "%.jpeg$")) then
            local customAsset
            pcall(function()
                customAsset = getcustomasset(logoStr)
            end)
            if customAsset then
                LogoImage.Image = customAsset
            else
                LogoImage.Image = logoStr
            end
        elseif string.find(logoStr, "rbxasset") or string.find(logoStr, "%d+") or string.find(logoStr, "http") then
            LogoImage.Image = logoStr
        else
            local LogoText = Instance.new("TextLabel")
            LogoText.Text = logoStr
            LogoText.Font = Enum.Font.SourceSansBold
            LogoText.TextSize = 22
            LogoText.TextColor3 = Color3.fromRGB(240, 240, 240)
            LogoText.Size = UDim2.new(1, 0, 1, 0)
            LogoText.BackgroundTransparency = 1
            LogoText.TextXAlignment = Enum.TextXAlignment.Left
            LogoText.TextTruncate = Enum.TextTruncate.AtEnd
            LogoText.Parent = LogoImage
        end
    else
        -- 1-1 MW$ vector-style typography
        local MWText = Instance.new("TextLabel")
        MWText.Text = "MW"
        MWText.Font = Enum.Font.SourceSansBold
        MWText.TextSize = 34
        MWText.TextColor3 = Color3.fromRGB(240, 240, 240)
        MWText.Position = UDim2.new(0, 4, 0, 4)
        MWText.Size = UDim2.new(0, 60, 0, 36)
        MWText.BackgroundTransparency = 1
        MWText.TextXAlignment = Enum.TextXAlignment.Left
        MWText.Parent = LogoImage

        local Dollar = Instance.new("TextLabel")
        Dollar.Text = "$"
        Dollar.Font = Enum.Font.SourceSansBold
        Dollar.TextSize = 19
        Dollar.TextColor3 = Library.CurrentTheme.Scheme
        Dollar.Position = UDim2.new(0, 62, 0, 2)
        Dollar.Size = UDim2.new(0, 16, 0, 18)
        Dollar.BackgroundTransparency = 1
        Dollar.Parent = LogoImage
    end
    LogoImage.Parent = LogoHolder

    -- Sidebar Tabs list
    local TabList = Instance.new("Frame")
    TabList.Name = "TabList"
    TabList.Size = UDim2.new(0, SidebarWidth - 6, 1, -74)
    TabList.Position = UDim2.new(0, 3, 0, 74)
    TabList.BackgroundTransparency = 1
    TabList.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 3)
    TabListLayout.Parent = TabList

    -- Right Main Area (width: Size.X - SidebarWidth - 26, height: ContentHolder height)
    local MainArea = Instance.new("Frame")
    MainArea.Name = "MainArea"
    MainArea.Size = UDim2.new(1, -SidebarWidth - 3, 1, 0)
    MainArea.Position = UDim2.new(0, MainAreaOffset.X, 0, MainAreaOffset.Y)
    MainArea.BackgroundTransparency = 1
    MainArea.ClipsDescendants = false
    MainArea.Parent = ContentHolder

    local WindowObj = {
        Tabs = {},
        CurrentTab = nil,
        Main = Main,
        ContentHolder = ContentHolder,
        Sidebar = Sidebar,
        MainArea = MainArea,
        Logo = LogoImage,
        Config = config,
        SubtabsOffset = SubtabsOffset,
        SubtabsHeight = SubtabsHeight,
    }

    function WindowObj:SetSize(newSize)
        Main.Size = UDim2.new(0, newSize.X, 0, newSize.Y)
        ContentHolder.Size = UDim2.new(0, newSize.X - 20, 0, newSize.Y - 41)
    end

    function WindowObj:SetPosition(newPos)
        Main.Position = newPos
    end

    function WindowObj:SetLogoPosition(newPos, newRotation)
        LogoImage.Position = newPos
        if newRotation then LogoImage.Rotation = newRotation end
    end

    -- Visuals ESP / Character Preview System (1-1 Slate / Millionware style)
    function WindowObj:CreatePreview(previewConfig)
        previewConfig = previewConfig or {}
        local PreviewSize = previewConfig.Size or Vector2.new(240, 360)
        local PreviewOffset = previewConfig.Offset or Vector2.new(16, 0)

        local PreviewFrame = Instance.new("Frame")
        PreviewFrame.Name = "VisualPreviewWindow"
        PreviewFrame.Size = UDim2.new(0, PreviewSize.X, 0, PreviewSize.Y)
        PreviewFrame.Position = UDim2.new(0, Main.AbsolutePosition.X + Main.AbsoluteSize.X + PreviewOffset.X, 0, Main.AbsolutePosition.Y + PreviewOffset.Y)
        PreviewFrame.BackgroundColor3 = Library.CurrentTheme.MainBg
        PreviewFrame.BorderSizePixel = 1
        PreviewFrame.BorderColor3 = Library.CurrentTheme.Border
        PreviewFrame.Active = true
        PreviewFrame.ClipsDescendants = false
        PreviewFrame.Visible = previewConfig.Visible ~= false
        PreviewFrame.Parent = ScreenGui

        -- Top gradient shine
        local PrevShine = Instance.new("Frame")
        PrevShine.Name = "TopShine"
        PrevShine.Size = UDim2.new(1, 0, 0, 24)
        PrevShine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        PrevShine.BorderSizePixel = 0
        PrevShine.ZIndex = 2
        PrevShine.Parent = PreviewFrame

        local PrevGrad = Instance.new("UIGradient")
        PrevGrad.Rotation = 90
        PrevGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.97),
            NumberSequenceKeypoint.new(1, 1)
        })
        PrevGrad.Parent = PrevShine

        -- Title
        local PrevTitle = Instance.new("TextLabel")
        PrevTitle.Name = "Title"
        PrevTitle.Size = UDim2.new(1, -16, 0, 24)
        PrevTitle.Position = UDim2.new(0, 8, 0, 0)
        PrevTitle.BackgroundTransparency = 1
        PrevTitle.Text = previewConfig.Title or "ESP Preview"
        PrevTitle.Font = Enum.Font.SourceSansBold
        PrevTitle.TextSize = 13
        PrevTitle.TextColor3 = Library.CurrentTheme.TextDim
        PrevTitle.TextXAlignment = Enum.TextXAlignment.Left
        PrevTitle.ZIndex = 3
        PrevTitle.Parent = PreviewFrame

        -- Viewport container
        local Viewport = Instance.new("ViewportFrame")
        Viewport.Name = "CharacterViewport"
        Viewport.Size = UDim2.new(1, -16, 1, -34)
        Viewport.Position = UDim2.new(0, 8, 0, 26)
        Viewport.BackgroundColor3 = Library.CurrentTheme.ChildBg
        Viewport.BorderSizePixel = 1
        Viewport.BorderColor3 = Library.CurrentTheme.Border
        Viewport.Ambient = Color3.fromRGB(180, 180, 180)
        Viewport.LightColor = Color3.fromRGB(255, 255, 255)
        Viewport.LightDirection = Vector3.new(-1, -1, -1)
        Viewport.Parent = PreviewFrame

        local ViewportCamera = Instance.new("Camera")
        Viewport.CurrentCamera = ViewportCamera
        ViewportCamera.Parent = Viewport

        local Rig = nil
        local skeletonVisible = false
        local skeletonColor = Color3.fromRGB(255, 255, 255)
        local boneFrames = {}

        local SkeletonFolder = Instance.new("Folder")
        SkeletonFolder.Name = "SkeletonLines"
        SkeletonFolder.Parent = Viewport

        local function getOrCreateBoneFrame(i)
            if not boneFrames[i] then
                local b = Instance.new("Frame")
                b.BackgroundColor3 = skeletonColor
                b.BorderSizePixel = 0
                b.ZIndex = 6
                b.Visible = false
                b.Parent = SkeletonFolder
                boneFrames[i] = b
            end
            return boneFrames[i]
        end

        local function projectPoint(worldPos)
            local camCFrame = ViewportCamera.CFrame
            local pointInCam = camCFrame:PointToObjectSpace(worldPos)
            if pointInCam.Z >= 0 then return nil end

            local fovRad = math.rad(ViewportCamera.FieldOfView)
            local h = Viewport.AbsoluteSize.Y
            local w = Viewport.AbsoluteSize.X
            if h <= 0 or w <= 0 then return nil end

            local scaleY = (h / 2) / math.tan(fovRad / 2)
            local scaleX = scaleY

            local x = (w / 2) + (pointInCam.X / -pointInCam.Z) * scaleX
            local y = (h / 2) - (pointInCam.Y / -pointInCam.Z) * scaleY
            return Vector2.new(x, y)
        end

        local BoxOutline = Instance.new("Frame")
        BoxOutline.Name = "BoxOutline"
        BoxOutline.BackgroundTransparency = 1
        BoxOutline.BorderSizePixel = 1
        BoxOutline.BorderColor3 = Color3.fromRGB(0, 0, 0)
        BoxOutline.ZIndex = 5
        BoxOutline.Visible = false
        BoxOutline.Parent = Viewport

        local BoxMain = Instance.new("Frame")
        BoxMain.Name = "Box"
        BoxMain.Size = UDim2.new(1, -2, 1, -2)
        BoxMain.Position = UDim2.new(0, 1, 0, 1)
        BoxMain.BackgroundTransparency = 1
        BoxMain.BorderSizePixel = 1
        BoxMain.BorderColor3 = Color3.fromRGB(255, 255, 255)
        BoxMain.ZIndex = 6
        BoxMain.Parent = BoxOutline

        local NameTag = Instance.new("TextLabel")
        NameTag.Name = "NameTag"
        NameTag.Size = UDim2.new(1, 0, 0, 14)
        NameTag.Position = UDim2.new(0, 0, 0, -15)
        NameTag.BackgroundTransparency = 1
        NameTag.Text = (Players.LocalPlayer and Players.LocalPlayer.DisplayName or "LocalPlayer") .. " [0m]"
        NameTag.Font = Enum.Font.SourceSansBold
        NameTag.TextSize = 12
        NameTag.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameTag.TextStrokeTransparency = 0.3
        NameTag.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        NameTag.ZIndex = 7
        NameTag.Visible = false
        NameTag.Parent = BoxOutline

        local HealthBarBg = Instance.new("Frame")
        HealthBarBg.Name = "HealthBarBg"
        HealthBarBg.Size = UDim2.new(0, 2, 1, 0)
        HealthBarBg.Position = UDim2.new(0, -5, 0, 0)
        HealthBarBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        HealthBarBg.BorderSizePixel = 1
        HealthBarBg.BorderColor3 = Color3.fromRGB(0, 0, 0)
        HealthBarBg.ZIndex = 6
        HealthBarBg.Visible = false
        HealthBarBg.Parent = BoxOutline

        local HealthBarFill = Instance.new("Frame")
        HealthBarFill.Name = "Fill"
        HealthBarFill.Size = UDim2.new(1, 0, 1, 0)
        HealthBarFill.Position = UDim2.new(0, 0, 0, 0)
        HealthBarFill.BackgroundColor3 = Color3.fromRGB(80, 220, 80)
        HealthBarFill.BorderSizePixel = 0
        HealthBarFill.ZIndex = 7
        HealthBarFill.Parent = HealthBarBg

        local function updateSkeletonAndBox()
            if not Rig then return end
            local w = Viewport.AbsoluteSize.X
            local h = Viewport.AbsoluteSize.Y
            if w <= 0 or h <= 0 then return end

            local minX, minY = math.huge, math.huge
            local maxX, maxY = -math.huge, -math.huge
            local hasPoints = false

            for _, part in ipairs(Rig:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Transparency < 1 then
                    local p = projectPoint(part.Position)
                    if p then
                        hasPoints = true
                        minX = math.min(minX, p.X)
                        minY = math.min(minY, p.Y)
                        maxX = math.max(maxX, p.X)
                        maxY = math.max(maxY, p.Y)
                    end
                end
            end

            if hasPoints then
                local padX = 6
                local padY = 5
                local bX = math.clamp(minX - padX, 2, w - 10)
                local bY = math.clamp(minY - padY, 2, h - 10)
                local bW = math.clamp(maxX - minX + padX * 2, 20, w - bX - 2)
                local bH = math.clamp(maxY - minY + padY * 2, 30, h - bY - 2)

                BoxOutline.Position = UDim2.new(0, bX, 0, bY)
                BoxOutline.Size = UDim2.new(0, bW, 0, bH)
            end

            for _, b in ipairs(boneFrames) do
                b.Visible = false
            end

            if not skeletonVisible then return end

            local boneConnections = {}
            if Rig:FindFirstChild("UpperTorso") then
                boneConnections = {
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
            elseif Rig:FindFirstChild("Torso") then
                boneConnections = {
                    { "Head", "Torso" },
                    { "Torso", "Left Arm" },
                    { "Torso", "Right Arm" },
                    { "Torso", "Left Leg" },
                    { "Torso", "Right Leg" },
                }
            end

            local function findBone(name)
                return Rig:FindFirstChild(name, true)
            end

            local boneIdx = 1
            for _, pair in ipairs(boneConnections) do
                local p1Part = findBone(pair[1])
                local p2Part = findBone(pair[2])
                if p1Part and p2Part then
                    local s1 = projectPoint(p1Part.Position)
                    local s2 = projectPoint(p2Part.Position)
                    if s1 and s2 then
                        local dist = (s2 - s1).Magnitude
                        local center = (s1 + s2) / 2
                        local angle = math.deg(math.atan2(s2.Y - s1.Y, s2.X - s1.X))
                        local bf = getOrCreateBoneFrame(boneIdx)
                        bf.Size = UDim2.new(0, dist, 0, 1.2)
                        bf.Position = UDim2.new(0, center.X - dist / 2, 0, center.Y)
                        bf.Rotation = angle
                        bf.BackgroundColor3 = skeletonColor
                        bf.Visible = true
                        boneIdx = boneIdx + 1
                    end
                end
            end
        end

        local originalVisuals = {}
        local function setupRig()
            if Rig then Rig:Destroy() end
            table.clear(originalVisuals)
            local localChar = Players.LocalPlayer and Players.LocalPlayer.Character
            if localChar and (localChar:FindFirstChild("HumanoidRootPart") or localChar:FindFirstChild("Head")) then
                local backupArch = localChar.Archivable
                localChar.Archivable = true
                local clone = localChar:Clone()
                localChar.Archivable = backupArch
                for _, desc in ipairs(clone:GetDescendants()) do
                    if desc:IsA("Script") or desc:IsA("LocalScript") or desc:IsA("Sound") or desc:IsA("BillboardGui") or desc:IsA("ParticleEmitter") then
                        desc:Destroy()
                    elseif desc:IsA("BasePart") then
                        desc.Anchored = true
                        desc.CanCollide = false
                        originalVisuals[desc] = { Color = desc.Color, Material = desc.Material, Transparency = desc.Transparency }
                    end
                end
                clone.Parent = Viewport
                local hrp = clone:FindFirstChild("HumanoidRootPart") or clone:FindFirstChild("Torso") or clone:FindFirstChild("UpperTorso")
                if hrp then
                    local offset = hrp.Position
                    for _, p in ipairs(clone:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CFrame = CFrame.new(p.Position - offset)
                        end
                    end
                end
                Rig = clone
            else
                Rig = Instance.new("Model")
                Rig.Name = "DummyRig"
                Rig.Parent = Viewport

                local function makeLimb(name, size, cframe)
                    local part = Instance.new("Part")
                    part.Name = name
                    part.Size = size
                    part.CFrame = cframe
                    part.Anchored = true
                    part.CanCollide = false
                    part.Material = Enum.Material.SmoothPlastic
                    part.Color = Color3.fromRGB(150, 150, 155)
                    part.TopSurface = Enum.SurfaceType.Smooth
                    part.BottomSurface = Enum.SurfaceType.Smooth
                    part.Parent = Rig
                    originalVisuals[part] = { Color = part.Color, Material = part.Material, Transparency = part.Transparency }
                    return part
                end

                local root = makeLimb("HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(0, 0, 0))
                root.Transparency = 1
                makeLimb("Head", Vector3.new(1.2, 1.2, 1.2), CFrame.new(0, 1.6, 0))
                makeLimb("UpperTorso", Vector3.new(2, 1.6, 1), CFrame.new(0, 0.2, 0))
                makeLimb("LowerTorso", Vector3.new(1.9, 0.8, 1), CFrame.new(0, -1.0, 0))
                makeLimb("LeftUpperArm", Vector3.new(0.9, 1.2, 0.9), CFrame.new(-1.45, 0.4, 0))
                makeLimb("LeftLowerArm", Vector3.new(0.8, 1.1, 0.8), CFrame.new(-1.45, -0.7, 0))
                makeLimb("RightUpperArm", Vector3.new(0.9, 1.2, 0.9), CFrame.new(1.45, 0.4, 0))
                makeLimb("RightLowerArm", Vector3.new(0.8, 1.1, 0.8), CFrame.new(1.45, -0.7, 0))
                makeLimb("LeftUpperLeg", Vector3.new(0.9, 1.3, 0.9), CFrame.new(-0.55, -2.0, 0))
                makeLimb("LeftLowerLeg", Vector3.new(0.8, 1.2, 0.8), CFrame.new(-0.55, -3.2, 0))
                makeLimb("RightUpperLeg", Vector3.new(0.9, 1.3, 0.9), CFrame.new(0.55, -2.0, 0))
                makeLimb("RightLowerLeg", Vector3.new(0.8, 1.2, 0.8), CFrame.new(0.55, -3.2, 0))
            end

            local cf, sz = Rig:GetBoundingBox()
            local maxDim = math.max(sz.X, sz.Y, sz.Z)
            local dist = maxDim * 1.55
            ViewportCamera.FieldOfView = 48
            ViewportCamera.CFrame = CFrame.new(cf.Position + Vector3.new(0, 0, dist), cf.Position)
            task.defer(updateSkeletonAndBox)
        end

        setupRig()
        if Players.LocalPlayer then
            Players.LocalPlayer.CharacterAdded:Connect(function()
                task.wait(0.5)
                setupRig()
            end)
        end

        Viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSkeletonAndBox)
        task.delay(0.1, updateSkeletonAndBox)

        local function syncPreviewPosition()
            PreviewFrame.Position = UDim2.new(
                Main.Position.X.Scale,
                Main.Position.X.Offset + Main.AbsoluteSize.X + PreviewOffset.X,
                Main.Position.Y.Scale,
                Main.Position.Y.Offset + PreviewOffset.Y
            )
        end
        Main:GetPropertyChangedSignal("Position"):Connect(syncPreviewPosition)
        makeDraggable(PrevTitle, PreviewFrame)

        local PreviewObj = {
            Frame = PreviewFrame,
            Viewport = Viewport,
            Rig = Rig,
            Box = BoxOutline,
            BoxColor = BoxMain,
            NameTag = NameTag,
            HealthBar = HealthBarBg,
            HealthFill = HealthBarFill,
            Skeleton = SkeletonFolder,
        }

        function PreviewObj:SetVisible(visible)
            PreviewFrame.Visible = visible
        end

        function PreviewObj:SetBox(enabled, color)
            BoxOutline.Visible = enabled
            if color then
                BoxMain.BorderColor3 = color
            else
                BoxMain.BorderColor3 = Color3.fromRGB(255, 255, 255)
            end
            updateSkeletonAndBox()
        end

        function PreviewObj:SetName(enabled, text, color)
            NameTag.Visible = enabled
            if text then NameTag.Text = text end
            if color then NameTag.TextColor3 = color end
        end

        function PreviewObj:SetHealth(enabled, percent, color)
            HealthBarBg.Visible = enabled
            percent = math.clamp(percent or 1, 0, 1)
            HealthBarFill.Size = UDim2.new(1, 0, percent, 0)
            HealthBarFill.Position = UDim2.new(0, 0, 1 - percent, 0)
            if color then
                HealthBarFill.BackgroundColor3 = color
            end
        end

        function PreviewObj:SetSkeleton(enabled, color)
            skeletonVisible = enabled
            if color then skeletonColor = color end
            updateSkeletonAndBox()
        end

        function PreviewObj:SetChams(enabled, color, material)
            if not Rig then return end
            for _, part in ipairs(Rig:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    if enabled then
                        part.Color = color or Color3.fromRGB(150, 150, 155)
                        part.Material = material or Enum.Material.ForceField
                    else
                        local orig = originalVisuals[part]
                        if orig then
                            part.Color = orig.Color
                            part.Material = orig.Material
                            part.Transparency = orig.Transparency
                        else
                            part.Color = Color3.fromRGB(150, 150, 155)
                            part.Material = Enum.Material.SmoothPlastic
                        end
                    end
                end
            end
        end

        WindowObj.Preview = PreviewObj
        return PreviewObj
    end

    function WindowObj:Tab(tabName)
        local TabObj = {
            Name = tabName,
            Subtabs = {},
            CurrentSubtab = nil,
            Button = nil,
            Indicator = nil,
        }

        -- Sidebar Tab Button (134 x 32)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName .. "_Tab"
        TabBtn.Size = UDim2.new(0, 134, 0, 32)
        TabBtn.BackgroundColor3 = Library.CurrentTheme.TabBg
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 1
        TabBtn.BorderColor3 = Library.CurrentTheme.Border
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabList
        TabObj.Button = TabBtn

        local TabIndicator = Instance.new("Frame")
        TabIndicator.Name = "ActiveIndicator"
        TabIndicator.Size = UDim2.new(0, 3, 1, 0)
        TabIndicator.Position = UDim2.new(0, 0, 0, 0)
        TabIndicator.BackgroundColor3 = Library.CurrentTheme.Scheme
        TabIndicator.BorderSizePixel = 0
        TabIndicator.Visible = false
        TabIndicator.Parent = TabBtn
        TabObj.Indicator = TabIndicator

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Name = "Label"
        TabLabel.Size = UDim2.new(1, -16, 1, 0)
        TabLabel.Position = UDim2.new(0, 10, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = tabName
        TabLabel.Font = Enum.Font.SourceSans
        TabLabel.TextSize = 14
        TabLabel.TextColor3 = Library.CurrentTheme.TextDim
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabBtn

        TabBtn.MouseEnter:Connect(function()
            if WindowObj.CurrentTab ~= TabObj then
                tween(TabBtn, TweenInfo.new(0.15), { BackgroundTransparency = 0.5, BackgroundColor3 = Library.CurrentTheme.TabHover })
                tween(TabLabel, TweenInfo.new(0.15), { TextColor3 = Library.CurrentTheme.Text })
            end
        end)

        TabBtn.MouseLeave:Connect(function()
            if WindowObj.CurrentTab ~= TabObj then
                tween(TabBtn, TweenInfo.new(0.15), { BackgroundTransparency = 1 })
                tween(TabLabel, TweenInfo.new(0.15), { TextColor3 = Library.CurrentTheme.TextDim })
            end
        end)

        -- Each Tab gets its own dedicated SubtabsBar and PageContainer inside MainArea
        local SubtabsBar = Instance.new("Frame")
        SubtabsBar.Name = tabName .. "_SubtabsBar"
        SubtabsBar.Size = UDim2.new(1, 0, 0, SubtabsHeight)
        SubtabsBar.Position = UDim2.new(0, SubtabsOffset.X, 0, SubtabsOffset.Y)
        SubtabsBar.BackgroundColor3 = Library.CurrentTheme.ChildBg
        SubtabsBar.BorderSizePixel = 0
        SubtabsBar.ZIndex = 3
        SubtabsBar.Visible = false
        SubtabsBar.Parent = MainArea
        TabObj.SubtabsBar = SubtabsBar

        local SubtabsLine = Instance.new("Frame")
        SubtabsLine.Name = tabName .. "_BottomLine"
        SubtabsLine.Size = UDim2.new(1, 0, 0, 1)
        SubtabsLine.Position = UDim2.new(0, SubtabsOffset.X, 0, SubtabsOffset.Y + SubtabsHeight - 1)
        SubtabsLine.BackgroundColor3 = Library.CurrentTheme.Border
        SubtabsLine.BorderSizePixel = 0
        SubtabsLine.ZIndex = 4
        SubtabsLine.Visible = false
        SubtabsLine.Parent = MainArea
        TabObj.SubtabsLine = SubtabsLine

        local SubtabsLayout = Instance.new("UIListLayout")
        SubtabsLayout.FillDirection = Enum.FillDirection.Horizontal
        SubtabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SubtabsLayout.Parent = SubtabsBar

        local PageContainer = Instance.new("Frame")
        PageContainer.Name = tabName .. "_PageContainer"
        PageContainer.Size = UDim2.new(1, 0, 1, 0)
        PageContainer.Position = UDim2.new(0, 0, 0, 0)
        PageContainer.BackgroundTransparency = 1
        PageContainer.Visible = false
        PageContainer.Parent = MainArea
        TabObj.PageContainer = PageContainer

        function TabObj:Activate()
            for _, otherTab in ipairs(WindowObj.Tabs) do
                otherTab.Button.BackgroundTransparency = 1
                otherTab.Button.BackgroundColor3 = Library.CurrentTheme.TabBg
                otherTab.Indicator.Visible = false
                otherTab.Button.Label.Font = Enum.Font.SourceSans
                otherTab.Button.Label.TextColor3 = Library.CurrentTheme.TextDim
                otherTab.SubtabsBar.Visible = false
                if otherTab.SubtabsLine then otherTab.SubtabsLine.Visible = false end
                otherTab.PageContainer.Visible = false
            end

            WindowObj.CurrentTab = TabObj
            TabBtn.BackgroundTransparency = 0
            TabBtn.BackgroundColor3 = Library.CurrentTheme.TabBg
            TabIndicator.Visible = true
            TabLabel.Font = Enum.Font.SourceSansBold
            TabLabel.TextColor3 = Library.CurrentTheme.Text

            TabObj.PageContainer.Visible = true

            local subCount = #TabObj.Subtabs
            if subCount > 0 then
                SubtabsBar.Visible = true
                if TabObj.SubtabsLine then TabObj.SubtabsLine.Visible = true end
                local topOffset = SubtabsHeight + 6
                PageContainer.Size = UDim2.new(1, 0, 1, -topOffset)
                PageContainer.Position = UDim2.new(0, 0, 0, topOffset)

                for _, sub in ipairs(TabObj.Subtabs) do
                    sub.Button.Size = UDim2.new(1 / subCount, 0, 1, 0)
                    sub.Button.Visible = true
                end

                if TabObj.CurrentSubtab then
                    TabObj.CurrentSubtab:Activate()
                else
                    TabObj.Subtabs[1]:Activate()
                end
            else
                SubtabsBar.Visible = false
                if TabObj.SubtabsLine then TabObj.SubtabsLine.Visible = false end
                PageContainer.Size = UDim2.new(1, 0, 1, 0)
                PageContainer.Position = UDim2.new(0, 0, 0, 0)
            end
        end

        TabBtn.MouseButton1Click:Connect(function()
            TabObj:Activate()
        end)

        function TabObj:Subtab(subtabName)
            local SubtabObj = {
                Name = subtabName,
                Button = nil,
                Indicator = nil,
                PageFrame = nil,
                LeftColumn = nil,
                RightColumn = nil,
            }

            local SubBtn = Instance.new("TextButton")
            SubBtn.Name = subtabName .. "_Subtab"
            SubBtn.Size = UDim2.new(1, 0, 1, 0)
            SubBtn.BackgroundTransparency = 1
            SubBtn.BorderSizePixel = 0
            SubBtn.Text = ""
            SubBtn.AutoButtonColor = false
            SubBtn.Visible = false
            SubBtn.Parent = SubtabsBar
            SubtabObj.Button = SubBtn

            local SubGlow = Instance.new("Frame")
            SubGlow.Name = "GradientShine"
            SubGlow.Size = UDim2.new(1, 0, 1, -2)
            SubGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SubGlow.BorderSizePixel = 0
            SubGlow.ZIndex = 1
            SubGlow.Parent = SubBtn

            local SubUIGrad = Instance.new("UIGradient")
            SubUIGrad.Rotation = 90
            SubUIGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.96),
                NumberSequenceKeypoint.new(1, 1)
            })
            SubUIGrad.Parent = SubGlow

            local SubLabel = Instance.new("TextLabel")
            SubLabel.Name = "Label"
            SubLabel.Size = UDim2.new(1, 0, 1, -2)
            SubLabel.BackgroundTransparency = 1
            SubLabel.Text = subtabName
            SubLabel.Font = Enum.Font.SourceSans
            SubLabel.TextSize = 13
            SubLabel.TextColor3 = Library.CurrentTheme.TextDim
            SubLabel.ZIndex = 2
            SubLabel.Parent = SubBtn

            local SubIndicator = Instance.new("Frame")
            SubIndicator.Name = "Underline"
            SubIndicator.Size = UDim2.new(1, 0, 0, 2)
            SubIndicator.Position = UDim2.new(0, 0, 1, -2)
            SubIndicator.BackgroundColor3 = Library.CurrentTheme.Scheme
            SubIndicator.BorderSizePixel = 0
            SubIndicator.Visible = false
            SubIndicator.ZIndex = 5
            SubIndicator.Parent = SubBtn
            SubtabObj.Indicator = SubIndicator

            -- Page Frame containing 2 columns (Left & Right)
            local Page = Instance.new("Frame")
            Page.Name = subtabName .. "_Page"
            Page.Size = UDim2.new(1, 0, 1, 0)
            Page.BackgroundTransparency = 1
            Page.Visible = false
            Page.Parent = PageContainer
            SubtabObj.PageFrame = Page

            -- Left Column
            local Left = Instance.new("ScrollingFrame")
            Left.Name = "LeftColumn"
            Left.Size = UDim2.new(0.5, -5, 1, -5)
            Left.Position = UDim2.new(0, 0, 0, 5)
            Left.BackgroundTransparency = 1
            Left.BorderSizePixel = 0
            Left.ScrollBarThickness = 3
            Left.ScrollBarImageColor3 = Library.CurrentTheme.WidgetHover
            Left.CanvasSize = UDim2.new(0, 0, 0, 0)
            Left.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Left.Parent = Page
            SubtabObj.LeftColumn = Left

            local LeftLayout = Instance.new("UIListLayout")
            LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
            LeftLayout.Padding = UDim.new(0, 10)
            LeftLayout.Parent = Left

            -- Right Column
            local Right = Instance.new("ScrollingFrame")
            Right.Name = "RightColumn"
            Right.Size = UDim2.new(0.5, -5, 1, -5)
            Right.Position = UDim2.new(0.5, 5, 0, 5)
            Right.BackgroundTransparency = 1
            Right.BorderSizePixel = 0
            Right.ScrollBarThickness = 3
            Right.ScrollBarImageColor3 = Library.CurrentTheme.WidgetHover
            Right.CanvasSize = UDim2.new(0, 0, 0, 0)
            Right.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Right.Parent = Page
            SubtabObj.RightColumn = Right

            local RightLayout = Instance.new("UIListLayout")
            RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
            RightLayout.Padding = UDim.new(0, 10)
            RightLayout.Parent = Right

            function SubtabObj:Activate()
                for _, s in ipairs(TabObj.Subtabs) do
                    s.Indicator.Visible = false
                    s.Button.Label.Font = Enum.Font.SourceSans
                    s.Button.Label.TextColor3 = Library.CurrentTheme.TextDim
                    s.PageFrame.Visible = false
                end
                TabObj.CurrentSubtab = SubtabObj
                SubtabObj.Indicator.Visible = true
                SubtabObj.Button.Label.Font = Enum.Font.SourceSansBold
                SubtabObj.Button.Label.TextColor3 = Library.CurrentTheme.Text
                SubtabObj.PageFrame.Visible = true
            end

            SubBtn.MouseButton1Click:Connect(function()
                SubtabObj:Activate()
            end)

            table.insert(TabObj.Subtabs, SubtabObj)

            -- Re-proportionalize subtabs width
            local count = #TabObj.Subtabs
            for _, s in ipairs(TabObj.Subtabs) do
                s.Button.Size = UDim2.new(1 / count, 0, 1, 0)
                if WindowObj.CurrentTab == TabObj then
                    s.Button.Visible = true
                end
            end

            if WindowObj.CurrentTab == TabObj then
                SubtabsBar.Visible = true
                if TabObj.SubtabsLine then TabObj.SubtabsLine.Visible = true end
                local topOffset = SubtabsHeight + 6
                PageContainer.Size = UDim2.new(1, 0, 1, -topOffset)
                PageContainer.Position = UDim2.new(0, 0, 0, topOffset)
                if #TabObj.Subtabs == 1 or TabObj.CurrentSubtab == nil then
                    SubtabObj:Activate()
                end
            end

            SubBtn.MouseEnter:Connect(function()
                if TabObj.CurrentSubtab ~= SubtabObj then
                    tween(SubLabel, TweenInfo.new(0.15), { TextColor3 = Library.CurrentTheme.Text })
                end
            end)
            SubBtn.MouseLeave:Connect(function()
                if TabObj.CurrentSubtab ~= SubtabObj then
                    tween(SubLabel, TweenInfo.new(0.15), { TextColor3 = Library.CurrentTheme.TextDim })
                end
            end)

            -- Section / Groupbox builder
            function SubtabObj:Section(options)
                options = options or {}
                local title = options.Title or options.Name or "Section"
                local side = string.lower(options.Side or "left")
                local parentCol = side == "right" and Right or Left

                local SectionFrame = Instance.new("Frame")
                SectionFrame.Name = title .. "_Section"
                SectionFrame.Size = UDim2.new(1, -4, 0, 0)
                SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
                SectionFrame.BackgroundColor3 = Library.CurrentTheme.ChildBg
                SectionFrame.BorderSizePixel = 1
                SectionFrame.BorderColor3 = Library.CurrentTheme.Border
                SectionFrame.Parent = parentCol

                local TitleHolder = Instance.new("Frame")
                TitleHolder.Name = "TitleHolder"
                TitleHolder.Size = UDim2.new(1, 0, 0, 24)
                TitleHolder.BackgroundTransparency = 1
                TitleHolder.Parent = SectionFrame

                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Name = "Title"
                TitleLabel.Size = UDim2.new(1, -22, 1, 0)
                TitleLabel.Position = UDim2.new(0, 11, 0, 4)
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.Text = title
                TitleLabel.Font = Enum.Font.SourceSansBold
                TitleLabel.TextSize = 13
                TitleLabel.TextColor3 = Library.CurrentTheme.Text
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                TitleLabel.Parent = TitleHolder

                local Content = Instance.new("Frame")
                Content.Name = "Elements"
                Content.Size = UDim2.new(1, 0, 0, 0)
                Content.Position = UDim2.new(0, 0, 0, 24)
                Content.AutomaticSize = Enum.AutomaticSize.Y
                Content.BackgroundTransparency = 1
                Content.Parent = SectionFrame

                local ContentPadding = Instance.new("UIPadding")
                ContentPadding.PaddingLeft = UDim.new(0, 11)
                ContentPadding.PaddingRight = UDim.new(0, 11)
                ContentPadding.PaddingTop = UDim.new(0, 4)
                ContentPadding.PaddingBottom = UDim.new(0, 11)
                ContentPadding.Parent = Content

                local ContentLayout = Instance.new("UIListLayout")
                ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ContentLayout.Padding = UDim.new(0, 6)
                ContentLayout.Parent = Content

                local SectionObj = {}

                -- Checkbox widget
                function SectionObj:Checkbox(cfg)
                    cfg = cfg or {}
                    local text = cfg.Name or "Checkbox"
                    local default = cfg.Default or false
                    local callback = cfg.Callback or function() end

                    local state = default

                    local CheckboxFrame = Instance.new("Frame")
                    CheckboxFrame.Name = text .. "_Toggle"
                    CheckboxFrame.Size = UDim2.new(1, 0, 0, 18)
                    CheckboxFrame.BackgroundTransparency = 1
                    CheckboxFrame.Parent = Content
                    table.insert(allRegisteredWidgets, { Name = text, Frame = CheckboxFrame })

                    local Box = Instance.new("TextButton")
                    Box.Name = "Box"
                    Box.Size = UDim2.new(0, 10, 0, 10)
                    Box.Position = UDim2.new(0, 0, 0.5, -5)
                    Box.BackgroundColor3 = state and Library.CurrentTheme.Scheme or Library.CurrentTheme.WidgetBg
                    Box.BorderSizePixel = 1
                    Box.BorderColor3 = Library.CurrentTheme.Border
                    Box.Text = ""
                    Box.AutoButtonColor = false
                    Box.Parent = CheckboxFrame

                    local Label = Instance.new("TextButton")
                    Label.Name = "Label"
                    Label.Size = UDim2.new(1, -20, 1, 0)
                    Label.Position = UDim2.new(0, 18, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Text = text
                    Label.Font = state and Enum.Font.SourceSansBold or Enum.Font.SourceSans
                    Label.TextSize = 13
                    Label.TextColor3 = state and Library.CurrentTheme.Text or Library.CurrentTheme.TextDim
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.AutoButtonColor = false
                    Label.Parent = CheckboxFrame

                    local Extras = Instance.new("Frame")
                    Extras.Name = "Extras"
                    Extras.Size = UDim2.new(0, 0, 1, 0)
                    Extras.Position = UDim2.new(1, 0, 0, 0)
                    Extras.AnchorPoint = Vector2.new(1, 0)
                    Extras.BackgroundTransparency = 1
                    Extras.AutomaticSize = Enum.AutomaticSize.X
                    Extras.Parent = CheckboxFrame

                    local ExtrasLayout = Instance.new("UIListLayout")
                    ExtrasLayout.FillDirection = Enum.FillDirection.Horizontal
                    ExtrasLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                    ExtrasLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                    ExtrasLayout.Padding = UDim.new(0, 6)
                    ExtrasLayout.Parent = Extras

                    local function update(val)
                        state = val
                        tween(Box, TweenInfo.new(0.12), {
                            BackgroundColor3 = state and Library.CurrentTheme.Scheme or Library.CurrentTheme.WidgetBg
                        })
                        tween(Label, TweenInfo.new(0.12), {
                            TextColor3 = state and Library.CurrentTheme.Text or Library.CurrentTheme.TextDim
                        })
                        Label.Font = state and Enum.Font.SourceSansBold or Enum.Font.SourceSans
                        callback(state)
                    end

                    local function toggle()
                        update(not state)
                    end

                    Box.MouseButton1Click:Connect(toggle)
                    Label.MouseButton1Click:Connect(toggle)

                    local CheckboxAPI = {
                        Set = function(_, v) update(v) end,
                        Get = function(_) return state end,
                    }

                    function CheckboxAPI:Keybind(keyCfg)
                        keyCfg = keyCfg or {}
                        local currentKey = keyCfg.Default or Enum.KeyCode.Unknown
                        local onKeyChanged = keyCfg.Callback or function() end
                        local listening = false

                        local KeyBtn = Instance.new("TextButton")
                        KeyBtn.Name = "Keybind"
                        KeyBtn.Size = UDim2.new(0, 24, 0, 14)
                        KeyBtn.AutomaticSize = Enum.AutomaticSize.X
                        KeyBtn.BackgroundColor3 = Library.CurrentTheme.WidgetBg
                        KeyBtn.BorderSizePixel = 1
                        KeyBtn.BorderColor3 = Library.CurrentTheme.Border
                        KeyBtn.Text = " " .. formatKey(currentKey) .. " "
                        KeyBtn.Font = Enum.Font.SourceSans
                        KeyBtn.TextSize = 11
                        KeyBtn.TextColor3 = Library.CurrentTheme.TextDim
                        KeyBtn.AutoButtonColor = false
                        KeyBtn.Parent = Extras

                        local KeyPadding = Instance.new("UIPadding")
                        KeyPadding.PaddingLeft = UDim.new(0, 4)
                        KeyPadding.PaddingRight = UDim.new(0, 4)
                        KeyPadding.Parent = KeyBtn

                        KeyBtn.MouseButton1Click:Connect(function()
                            if listening then return end
                            listening = true
                            KeyBtn.Text = " ... "
                            KeyBtn.TextColor3 = Library.CurrentTheme.Scheme

                            local conn
                            conn = UserInputService.InputBegan:Connect(function(input, gpe)
                                if input.UserInputType == Enum.UserInputType.Keyboard or
                                   input.UserInputType == Enum.UserInputType.MouseButton1 or
                                   input.UserInputType == Enum.UserInputType.MouseButton2 or
                                   input.UserInputType == Enum.UserInputType.MouseButton3 then

                                    conn:Disconnect()
                                    listening = false

                                    if input.KeyCode == Enum.KeyCode.Escape then
                                        currentKey = nil
                                        KeyBtn.Text = " NONE "
                                    else
                                        currentKey = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
                                        KeyBtn.Text = " " .. formatKey(currentKey) .. " "
                                    end

                                    KeyBtn.TextColor3 = Library.CurrentTheme.TextDim
                                    onKeyChanged(currentKey)
                                end
                            end)
                        end)

                        return {
                            SetKey = function(_, k)
                                currentKey = k
                                KeyBtn.Text = " " .. formatKey(currentKey) .. " "
                                onKeyChanged(currentKey)
                            end,
                            GetKey = function(_) return currentKey end
                        }
                    end

                    function CheckboxAPI:Colorpicker(cpCfg)
                        cpCfg = cpCfg or {}
                        local curCol = cpCfg.Default or Color3.fromRGB(173, 104, 219)
                        local onColChanged = cpCfg.Callback or function() end

                        local CPBtn = Instance.new("TextButton")
                        CPBtn.Name = "ColorButton"
                        CPBtn.Size = UDim2.new(0, 20, 0, 10)
                        CPBtn.BackgroundColor3 = curCol
                        CPBtn.BorderSizePixel = 1
                        CPBtn.BorderColor3 = Library.CurrentTheme.Border
                        CPBtn.Text = ""
                        CPBtn.AutoButtonColor = false
                        CPBtn.Parent = Extras

                        local open = false
                        local CPPopup = Instance.new("Frame")
                        CPPopup.Name = "CPPopup"
                        CPPopup.Size = UDim2.new(0, 215, 0, 175)
                        CPPopup.BackgroundColor3 = Library.CurrentTheme.WidgetBg
                        CPPopup.BorderSizePixel = 1
                        CPPopup.BorderColor3 = Library.CurrentTheme.Border
                        CPPopup.Visible = false
                        CPPopup.ZIndex = 110
                        CPPopup.Parent = Library.Popups

                        local CPInnerPad = Instance.new("UIPadding")
                        CPInnerPad.PaddingLeft = UDim.new(0, 8)
                        CPInnerPad.PaddingRight = UDim.new(0, 8)
                        CPInnerPad.PaddingTop = UDim.new(0, 8)
                        CPInnerPad.PaddingBottom = UDim.new(0, 8)
                        CPInnerPad.Parent = CPPopup

                        local SVMap = Instance.new("ImageButton")
                        SVMap.Name = "SVMap"
                        SVMap.Size = UDim2.new(0, 193, 0, 110)
                        SVMap.Image = "rbxassetid://4155801252"
                        SVMap.BackgroundColor3 = curCol
                        SVMap.BorderSizePixel = 1
                        SVMap.BorderColor3 = Library.CurrentTheme.Border
                        SVMap.AutoButtonColor = false
                        SVMap.ZIndex = 111
                        SVMap.Parent = CPPopup

                        local PickerCircle = Instance.new("Frame")
                        PickerCircle.Name = "Circle"
                        PickerCircle.Size = UDim2.new(0, 6, 0, 6)
                        PickerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
                        PickerCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        PickerCircle.BorderSizePixel = 1
                        PickerCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        PickerCircle.ZIndex = 112
                        PickerCircle.Parent = SVMap

                        local HueBar = Instance.new("ImageButton")
                        HueBar.Name = "HueBar"
                        HueBar.Size = UDim2.new(0, 193, 0, 10)
                        HueBar.Position = UDim2.new(0, 0, 0, 116)
                        HueBar.Image = "rbxassetid://3641079629"
                        HueBar.BorderSizePixel = 1
                        HueBar.BorderColor3 = Library.CurrentTheme.Border
                        HueBar.AutoButtonColor = false
                        HueBar.ZIndex = 111
                        HueBar.Parent = CPPopup

                        local HuePicker = Instance.new("Frame")
                        HuePicker.Name = "HuePicker"
                        HuePicker.Size = UDim2.new(0, 3, 1, 2)
                        HuePicker.Position = UDim2.new(0, 0, 0, -1)
                        HuePicker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        HuePicker.BorderSizePixel = 1
                        HuePicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        HuePicker.ZIndex = 112
                        HuePicker.Parent = HueBar

                        local HexLabel = Instance.new("TextLabel")
                        HexLabel.Name = "HexLabel"
                        HexLabel.Size = UDim2.new(1, 0, 0, 20)
                        HexLabel.Position = UDim2.new(0, 0, 0, 132)
                        HexLabel.BackgroundTransparency = 1
                        HexLabel.Font = Enum.Font.Code
                        HexLabel.TextSize = 12
                        HexLabel.TextColor3 = Library.CurrentTheme.TextDim
                        HexLabel.Text = "#" .. curCol:ToHex():upper()
                        HexLabel.ZIndex = 111
                        HexLabel.Parent = CPPopup

                        local curH, curS, curV = curCol:ToHSV()

                        local function updateColor()
                            local finalCol = Color3.fromHSV(curH, curS, curV)
                            CPBtn.BackgroundColor3 = finalCol
                            SVMap.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
                            HexLabel.Text = "#" .. finalCol:ToHex():upper()
                            onColChanged(finalCol)
                        end

                        local svDown = false
                        SVMap.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                svDown = true
                                local relX = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                                local relY = math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                                curS = relX
                                curV = 1 - relY
                                PickerCircle.Position = UDim2.new(curS, 0, 1 - curV, 0)
                                updateColor()
                            end
                        end)

                        local hueDown = false
                        HueBar.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                hueDown = true
                                local relX = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                                curH = relX
                                HuePicker.Position = UDim2.new(curH, -1, 0, -1)
                                updateColor()
                            end
                        end)

                        UserInputService.InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement then
                                if svDown then
                                    local relX = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                                    local relY = math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                                    curS = relX
                                    curV = 1 - relY
                                    PickerCircle.Position = UDim2.new(curS, 0, 1 - curV, 0)
                                    updateColor()
                                elseif hueDown then
                                    local relX = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                                    curH = relX
                                    HuePicker.Position = UDim2.new(curH, -1, 0, -1)
                                    updateColor()
                                end
                            end
                        end)

                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                svDown = false
                                hueDown = false
                            end
                        end)

                        CPBtn.MouseButton1Click:Connect(function()
                            open = not open
                            if open then
                                local btnPos = CPBtn.AbsolutePosition
                                CPPopup.Position = UDim2.new(0, btnPos.X - 195, 0, btnPos.Y + 16)
                                CPPopup.Visible = true
                            else
                                CPPopup.Visible = false
                            end
                        end)

                        return {
                            Set = function(_, col)
                                curCol = col
                                curH, curS, curV = col:ToHSV()
                                PickerCircle.Position = UDim2.new(curS, 0, 1 - curV, 0)
                                HuePicker.Position = UDim2.new(curH, -1, 0, -1)
                                updateColor()
                            end
                        }
                    end

                    return CheckboxAPI
                end

                -- Slider Widget (Exact replication: Label on top left, value on top right, 6px track below with scheme fill)
                function SectionObj:Slider(cfg)
                    cfg = cfg or {}
                    local text = cfg.Name or "Slider"
                    local min = cfg.Min or 0
                    local max = cfg.Max or 100
                    local default = cfg.Default or min
                    local suffix = cfg.Suffix or ""
                    local isFloat = cfg.Float or false
                    local callback = cfg.Callback or function() end

                    local value = math.clamp(default, min, max)

                    local SliderFrame = Instance.new("Frame")
                    SliderFrame.Name = text .. "_Slider"
                    SliderFrame.Size = UDim2.new(1, 0, 0, 24)
                    SliderFrame.BackgroundTransparency = 1
                    SliderFrame.Parent = Content
                    table.insert(allRegisteredWidgets, { Name = text, Frame = SliderFrame })

                    local Label = Instance.new("TextLabel")
                    Label.Name = "Label"
                    Label.Size = UDim2.new(0.7, 0, 0, 14)
                    Label.BackgroundTransparency = 1
                    Label.Text = text
                    Label.Font = Enum.Font.SourceSans
                    Label.TextSize = 13
                    Label.TextColor3 = Library.CurrentTheme.Text
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = SliderFrame

                    local ValueLabel = Instance.new("TextLabel")
                    ValueLabel.Name = "Value"
                    ValueLabel.Size = UDim2.new(0.3, 0, 0, 14)
                    ValueLabel.Position = UDim2.new(0.7, 0, 0, 0)
                    ValueLabel.BackgroundTransparency = 1
                    ValueLabel.Font = Enum.Font.SourceSans
                    ValueLabel.TextSize = 13
                    ValueLabel.TextColor3 = Library.CurrentTheme.TextDim
                    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                    ValueLabel.Parent = SliderFrame

                    local Track = Instance.new("TextButton")
                    Track.Name = "Track"
                    Track.Size = UDim2.new(1, 0, 0, 6)
                    Track.Position = UDim2.new(0, 0, 0, 16)
                    Track.BackgroundColor3 = Library.CurrentTheme.WidgetBg
                    Track.BorderSizePixel = 1
                    Track.BorderColor3 = Library.CurrentTheme.Border
                    Track.Text = ""
                    Track.AutoButtonColor = false
                    Track.Parent = SliderFrame

                    local Fill = Instance.new("Frame")
                    Fill.Name = "Fill"
                    Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    Fill.BackgroundColor3 = Library.CurrentTheme.Scheme
                    Fill.BorderSizePixel = 0
                    Fill.Parent = Track

                    local function formatValue(v)
                        if isFloat then
                            return string.format("%.1f", v) .. suffix
                        else
                            return tostring(math.floor(v)) .. suffix
                        end
                    end

                    local function update(v, userTriggered)
                        value = math.clamp(v, min, max)
                        if not isFloat then
                            value = math.floor(value)
                        end
                        Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                        ValueLabel.Text = formatValue(value)
                        if userTriggered then
                            callback(value)
                        end
                    end

                    ValueLabel.Text = formatValue(value)

                    local dragging = false
                    Track.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                            local percent = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                            update(min + (max - min) * percent, true)
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local percent = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                            update(min + (max - min) * percent, true)
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)

                    return {
                        Set = function(_, v) update(v, true) end,
                        Get = function(_) return value end
                    }
                end

                function SectionObj:SliderInt(cfg)
                    cfg = cfg or {}
                    cfg.Float = false
                    return self:Slider(cfg)
                end

                function SectionObj:SliderFloat(cfg)
                    cfg = cfg or {}
                    cfg.Float = true
                    return self:Slider(cfg)
                end

                -- Dropdown / Combo Widget (34px total height, arrow on right, popup below)
                function SectionObj:Dropdown(cfg)
                    cfg = cfg or {}
                    local text = cfg.Name or "Dropdown"
                    local items = cfg.Items or {}
                    local default = cfg.Default or items[1] or ""
                    local callback = cfg.Callback or function() end

                    local selected = default
                    local open = false

                    local DropdownFrame = Instance.new("Frame")
                    DropdownFrame.Name = text .. "_Dropdown"
                    DropdownFrame.Size = UDim2.new(1, 0, 0, 36)
                    DropdownFrame.BackgroundTransparency = 1
                    DropdownFrame.Parent = Content
                    table.insert(allRegisteredWidgets, { Name = text, Frame = DropdownFrame })

                    local Label = Instance.new("TextLabel")
                    Label.Name = "Label"
                    Label.Size = UDim2.new(1, 0, 0, 14)
                    Label.BackgroundTransparency = 1
                    Label.Text = text
                    Label.Font = Enum.Font.SourceSans
                    Label.TextSize = 13
                    Label.TextColor3 = Library.CurrentTheme.Text
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = DropdownFrame

                    local DropBox = Instance.new("TextButton")
                    DropBox.Name = "Box"
                    DropBox.Size = UDim2.new(1, 0, 0, 19)
                    DropBox.Position = UDim2.new(0, 0, 0, 16)
                    DropBox.BackgroundColor3 = Library.CurrentTheme.WidgetBg
                    DropBox.BorderSizePixel = 1
                    DropBox.BorderColor3 = Library.CurrentTheme.Border
                    DropBox.Text = ""
                    DropBox.AutoButtonColor = false
                    DropBox.Parent = DropdownFrame

                    local DropShine = Instance.new("Frame")
                    DropShine.Name = "Shine"
                    DropShine.Size = UDim2.new(1, 0, 1, 0)
                    DropShine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    DropShine.BorderSizePixel = 0
                    DropShine.Parent = DropBox

                    local DropGrad = Instance.new("UIGradient")
                    DropGrad.Rotation = 90
                    DropGrad.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0.97),
                        NumberSequenceKeypoint.new(1, 1)
                    })
                    DropGrad.Parent = DropShine

                    local SelectedLabel = Instance.new("TextLabel")
                    SelectedLabel.Name = "Selected"
                    SelectedLabel.Size = UDim2.new(1, -24, 1, 0)
                    SelectedLabel.Position = UDim2.new(0, 7, 0, 0)
                    SelectedLabel.BackgroundTransparency = 1
                    SelectedLabel.Text = tostring(selected)
                    SelectedLabel.Font = Enum.Font.SourceSans
                    SelectedLabel.TextSize = 13
                    SelectedLabel.TextColor3 = Library.CurrentTheme.Text
                    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SelectedLabel.ZIndex = 2
                    SelectedLabel.Parent = DropBox

                    local Arrow = Instance.new("TextLabel")
                    Arrow.Name = "Arrow"
                    Arrow.Size = UDim2.new(0, 16, 1, 0)
                    Arrow.Position = UDim2.new(1, -18, 0, 0)
                    Arrow.BackgroundTransparency = 1
                    Arrow.Text = "▼"
                    Arrow.Font = Enum.Font.SourceSansBold
                    Arrow.TextSize = 9
                    Arrow.TextColor3 = Library.CurrentTheme.TextDim
                    Arrow.ZIndex = 2
                    Arrow.Parent = DropBox

                    local DropList = Instance.new("ScrollingFrame")
                    DropList.Name = text .. "_Popup"
                    DropList.Size = UDim2.new(0, 100, 0, 0)
                    DropList.BackgroundColor3 = Library.CurrentTheme.TabBg
                    DropList.BorderSizePixel = 1
                    DropList.BorderColor3 = Library.CurrentTheme.Border
                    DropList.ScrollBarThickness = 2
                    DropList.ScrollBarImageColor3 = Library.CurrentTheme.Scheme
                    DropList.Visible = false
                    DropList.ZIndex = 120
                    DropList.Parent = Library.Popups

                    local DropListLayout = Instance.new("UIListLayout")
                    DropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    DropListLayout.Parent = DropList

                    local function rebuild()
                        for _, child in ipairs(DropList:GetChildren()) do
                            if child:IsA("TextButton") then
                                child:Destroy()
                            end
                        end

                        for _, item in ipairs(items) do
                            local ItemBtn = Instance.new("TextButton")
                            ItemBtn.Name = tostring(item)
                            ItemBtn.Size = UDim2.new(1, 0, 0, 20)
                            ItemBtn.BackgroundColor3 = Library.CurrentTheme.WidgetHover
                            ItemBtn.BackgroundTransparency = (item == selected) and 0 or 1
                            ItemBtn.BorderSizePixel = 0
                            ItemBtn.Text = "   " .. tostring(item)
                            ItemBtn.Font = (item == selected) and Enum.Font.SourceSansBold or Enum.Font.SourceSans
                            ItemBtn.TextSize = 13
                            ItemBtn.TextColor3 = (item == selected) and Library.CurrentTheme.Scheme or Library.CurrentTheme.TextDim
                            ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
                            ItemBtn.ZIndex = 121
                            ItemBtn.Parent = DropList

                            ItemBtn.MouseButton1Click:Connect(function()
                                selected = item
                                SelectedLabel.Text = tostring(item)
                                open = false
                                DropList.Visible = false
                                Arrow.Text = "▼"
                                callback(selected)
                            end)

                            ItemBtn.MouseEnter:Connect(function()
                                if item ~= selected then
                                    ItemBtn.TextColor3 = Library.CurrentTheme.Text
                                    ItemBtn.BackgroundTransparency = 0.5
                                end
                            end)
                            ItemBtn.MouseLeave:Connect(function()
                                if item ~= selected then
                                    ItemBtn.TextColor3 = Library.CurrentTheme.TextDim
                                    ItemBtn.BackgroundTransparency = 1
                                end
                            end)
                        end

                        local totalH = math.min(#items * 20, 140)
                        DropList.CanvasSize = UDim2.new(0, 0, 0, #items * 20)
                        DropList.Size = UDim2.new(0, DropBox.AbsoluteSize.X, 0, totalH)
                    end

                    rebuild()

                    DropBox.MouseButton1Click:Connect(function()
                        open = not open
                        if open then
                            rebuild()
                            local absPos = DropBox.AbsolutePosition
                            DropList.Position = UDim2.new(0, absPos.X, 0, absPos.Y + DropBox.AbsoluteSize.Y + 2)
                            DropList.Size = UDim2.new(0, DropBox.AbsoluteSize.X, 0, math.min(#items * 20, 140))
                            DropList.Visible = true
                            Arrow.Text = "▲"
                        else
                            DropList.Visible = false
                            Arrow.Text = "▼"
                        end
                    end)

                    return {
                        Set = function(_, itm)
                            selected = itm
                            SelectedLabel.Text = tostring(itm)
                            callback(selected)
                        end,
                        Get = function(_) return selected end,
                        Refresh = function(_, newItems)
                            items = newItems or {}
                            rebuild()
                        end
                    }
                end

                -- Button widget
                function SectionObj:Button(cfg)
                    cfg = cfg or {}
                    local text = cfg.Name or "Button"
                    local callback = cfg.Callback or function() end

                    local Btn = Instance.new("TextButton")
                    Btn.Name = text .. "_Button"
                    Btn.Size = UDim2.new(1, 0, 0, 22)
                    Btn.BackgroundColor3 = Library.CurrentTheme.WidgetBg
                    Btn.BorderSizePixel = 1
                    Btn.BorderColor3 = Library.CurrentTheme.Border
                    Btn.Text = text
                    Btn.Font = Enum.Font.SourceSans
                    Btn.TextSize = 13
                    Btn.TextColor3 = Library.CurrentTheme.Text
                    Btn.AutoButtonColor = false
                    Btn.Parent = Content

                    Btn.MouseEnter:Connect(function()
                        tween(Btn, TweenInfo.new(0.12), { BackgroundColor3 = Library.CurrentTheme.WidgetHover })
                    end)
                    Btn.MouseLeave:Connect(function()
                        tween(Btn, TweenInfo.new(0.12), { BackgroundColor3 = Library.CurrentTheme.WidgetBg })
                    end)
                    Btn.MouseButton1Click:Connect(callback)

                    return Btn
                end

                -- Text Input
                function SectionObj:TextInput(cfg)
                    cfg = cfg or {}
                    local text = cfg.Name or "Text Input"
                    local placeholder = cfg.Placeholder or "Enter text..."
                    local callback = cfg.Callback or function() end

                    local InputHolder = Instance.new("Frame")
                    InputHolder.Name = text .. "_InputHolder"
                    InputHolder.Size = UDim2.new(1, 0, 0, 36)
                    InputHolder.BackgroundTransparency = 1
                    InputHolder.Parent = Content
                    table.insert(allRegisteredWidgets, { Name = text, Frame = InputHolder })

                    local Label = Instance.new("TextLabel")
                    Label.Name = "Label"
                    Label.Size = UDim2.new(1, 0, 0, 14)
                    Label.BackgroundTransparency = 1
                    Label.Text = text
                    Label.Font = Enum.Font.SourceSans
                    Label.TextSize = 13
                    Label.TextColor3 = Library.CurrentTheme.Text
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = InputHolder

                    local Box = Instance.new("TextBox")
                    Box.Name = "Box"
                    Box.Size = UDim2.new(1, 0, 0, 20)
                    Box.Position = UDim2.new(0, 0, 0, 16)
                    Box.BackgroundColor3 = Library.CurrentTheme.WidgetBg
                    Box.BorderSizePixel = 1
                    Box.BorderColor3 = Library.CurrentTheme.Border
                    Box.Text = ""
                    Box.PlaceholderText = placeholder
                    Box.PlaceholderColor3 = Library.CurrentTheme.TextDisabled
                    Box.Font = Enum.Font.SourceSans
                    Box.TextSize = 13
                    Box.TextColor3 = Library.CurrentTheme.Text
                    Box.ClearTextOnFocus = false
                    Box.Parent = InputHolder

                    Box.FocusLost:Connect(function(enterPressed)
                        callback(Box.Text, enterPressed)
                    end)

                    return {
                        Set = function(_, val) Box.Text = tostring(val) end,
                        Get = function(_) return Box.Text end
                    }
                end

                return SectionObj
            end

            return SubtabObj
        end

        table.insert(WindowObj.Tabs, TabObj)
        if #WindowObj.Tabs == 1 then
            TabObj:Activate()
        end

        return TabObj
    end

    local HttpService = game:GetService("HttpService")

    -- 1. Sub GUI / Floating Windows builder (e.g. keybind list, spectator list, watermark, custom panels)
    function WindowObj:CreateSubGui(subConfig)
        subConfig = subConfig or {}
        local title = subConfig.Title or "Window"
        local size = subConfig.Size or Vector2.new(180, 200)
        local position = subConfig.Position or UDim2.new(0, 50, 0, 50)

        local SubWindow = Instance.new("Frame")
        SubWindow.Name = title .. "_SubGui"
        SubWindow.Size = UDim2.new(0, size.X, 0, size.Y)
        SubWindow.Position = position
        SubWindow.BackgroundColor3 = Library.CurrentTheme.MainBg
        SubWindow.BorderSizePixel = 1
        SubWindow.BorderColor3 = Library.CurrentTheme.Border
        SubWindow.Active = true
        SubWindow.ClipsDescendants = false
        SubWindow.Visible = subConfig.Visible ~= false
        SubWindow.Parent = ScreenGui

        local TopShine = Instance.new("Frame")
        TopShine.Name = "TopShine"
        TopShine.Size = UDim2.new(1, 0, 0, 20)
        TopShine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TopShine.BorderSizePixel = 0
        TopShine.ZIndex = 2
        TopShine.Parent = SubWindow

        local Grad = Instance.new("UIGradient")
        Grad.Rotation = 90
        Grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.97),
            NumberSequenceKeypoint.new(1, 1)
        })
        Grad.Parent = TopShine

        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Name = "Title"
        TitleLabel.Size = UDim2.new(1, -12, 0, 20)
        TitleLabel.Position = UDim2.new(0, 6, 0, 0)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = title
        TitleLabel.Font = Library.FontBold
        TitleLabel.TextSize = 12
        TitleLabel.TextColor3 = Library.CurrentTheme.TextDim
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.ZIndex = 3
        TitleLabel.Parent = SubWindow

        local DragHandle = Instance.new("Frame")
        DragHandle.Name = "DragHandle"
        DragHandle.Size = UDim2.new(1, 0, 0, 20)
        DragHandle.BackgroundTransparency = 1
        DragHandle.ZIndex = 4
        DragHandle.Parent = SubWindow
        makeDraggable(DragHandle, SubWindow)

        local SubContent = Instance.new("ScrollingFrame")
        SubContent.Name = "Content"
        SubContent.Size = UDim2.new(1, -10, 1, -26)
        SubContent.Position = UDim2.new(0, 5, 0, 22)
        SubContent.BackgroundColor3 = Library.CurrentTheme.ChildBg
        SubContent.BorderSizePixel = 1
        SubContent.BorderColor3 = Library.CurrentTheme.Border
        SubContent.ScrollBarThickness = 2
        SubContent.ScrollBarImageColor3 = Library.CurrentTheme.WidgetHover
        SubContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        SubContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        SubContent.Parent = SubWindow

        local SubLayout = Instance.new("UIListLayout")
        SubLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SubLayout.Padding = UDim.new(0, 4)
        SubLayout.Parent = SubContent

        local SubPadding = Instance.new("UIPadding")
        SubPadding.PaddingLeft = UDim.new(0, 6)
        SubPadding.PaddingRight = UDim.new(0, 6)
        SubPadding.PaddingTop = UDim.new(0, 6)
        SubPadding.PaddingBottom = UDim.new(0, 6)
        SubPadding.Parent = SubContent

        local SubGuiObj = {
            Window = SubWindow,
            Content = SubContent,
            Title = TitleLabel,
        }

        function SubGuiObj:SetVisible(vis)
            SubWindow.Visible = vis
        end

        function SubGuiObj:AddLabel(text)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 0, 16)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.Font = Library.Font
            lbl.TextSize = 12
            lbl.TextColor3 = Library.CurrentTheme.Text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = SubContent
            return {
                SetText = function(_, t) lbl.Text = t end,
                SetColor = function(_, c) lbl.TextColor3 = c end,
                Remove = function() lbl:Destroy() end,
            }
        end

        function SubGuiObj:AddRow(leftText, rightText)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 16)
            row.BackgroundTransparency = 1
            row.Parent = SubContent

            local leftLbl = Instance.new("TextLabel")
            leftLbl.Size = UDim2.new(0.65, 0, 1, 0)
            leftLbl.BackgroundTransparency = 1
            leftLbl.Text = leftText
            leftLbl.Font = Library.Font
            leftLbl.TextSize = 12
            leftLbl.TextColor3 = Library.CurrentTheme.Text
            leftLbl.TextXAlignment = Enum.TextXAlignment.Left
            leftLbl.Parent = row

            local rightLbl = Instance.new("TextLabel")
            rightLbl.Size = UDim2.new(0.35, 0, 1, 0)
            rightLbl.Position = UDim2.new(0.65, 0, 0, 0)
            rightLbl.BackgroundTransparency = 1
            rightLbl.Text = rightText
            rightLbl.Font = Library.FontBold
            rightLbl.TextSize = 12
            rightLbl.TextColor3 = Library.CurrentTheme.Scheme
            rightLbl.TextXAlignment = Enum.TextXAlignment.Right
            rightLbl.Parent = row

            return {
                SetLeft = function(_, t) leftLbl.Text = t end,
                SetRight = function(_, t) rightLbl.Text = t end,
                SetColor = function(_, c) rightLbl.TextColor3 = c end,
                Remove = function() row:Destroy() end,
            }
        end

        return SubGuiObj
    end

    -- 2. Dedicated Keybind List (dynamic auto-sizing, hidden until binds exist)
    function WindowObj:KeybindList(cfg)
        cfg = cfg or {}
        local sub = self:CreateSubGui({
            Title = cfg.Title or "Keybinds",
            Size = cfg.Size or Vector2.new(165, 32),
            Position = cfg.Position or UDim2.new(0, 30, 0.5, -90),
            Visible = false,
        })

        local keybindRows = {}
        local count = 0

        local function refreshSize()
            local currentCount = 0
            for _ in pairs(keybindRows) do
                currentCount = currentCount + 1
            end
            count = currentCount

            if count == 0 then
                sub.Window.Visible = false
            else
                sub.Window.Visible = true
                local rowHeight = 18
                local topHeight = 24
                local padding = 12
                local totalHeight = topHeight + (count * rowHeight) + padding
                sub.Window.Size = UDim2.new(0, 165, 0, totalHeight)
                sub.Content.Size = UDim2.new(1, -10, 0, count * rowHeight + padding)
            end
        end

        local KeybindAPI = {
            SubGui = sub,
            Rows = keybindRows,
        }

        function KeybindAPI:SetVisible(vis)
            if vis then
                if count > 0 then sub.Window.Visible = true end
            else
                sub.Window.Visible = false
            end
        end

        function KeybindAPI:Add(name, key, state)
            if keybindRows[name] then
                keybindRows[name]:Remove()
            end
            local row = sub:AddRow(name, "[" .. formatKey(key) .. "]")
            keybindRows[name] = row
            refreshSize()
            return row
        end

        function KeybindAPI:Update(name, state)
            if keybindRows[name] then
                keybindRows[name]:SetColor(state and Library.CurrentTheme.Scheme or Library.CurrentTheme.TextDim)
            end
        end

        function KeybindAPI:Remove(name)
            if keybindRows[name] then
                keybindRows[name]:Remove()
                keybindRows[name] = nil
                refreshSize()
            end
        end

        return KeybindAPI
    end

    -- 3. Config System (JSON files saved into workspace/{FolderName}/configs/)
    function WindowObj:ConfigManager(cfgOptions)
        cfgOptions = cfgOptions or {}
        local folderName = cfgOptions.Folder or Title
        local configDir = folderName .. "/configs"

        local function ensureDir()
            if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
                pcall(function()
                    if not isfolder(folderName) then makefolder(folderName) end
                    if not isfolder(configDir) then makefolder(configDir) end
                end)
            end
        end

        ensureDir()

        local ConfigAPI = {
            Folder = folderName,
            Directory = configDir,
        }

        function ConfigAPI:Save(name, dataTable)
            ensureDir()
            local json = HttpService:JSONEncode(dataTable)
            local filePath = configDir .. "/" .. name .. ".json"
            if typeof(writefile) == "function" then
                writefile(filePath, json)
                return true, filePath
            end
            return false, "writefile not supported"
        end

        function ConfigAPI:Load(name)
            ensureDir()
            local filePath = configDir .. "/" .. name .. ".json"
            if typeof(readfile) == "function" and typeof(isfile) == "function" then
                if isfile(filePath) then
                    local content = readfile(filePath)
                    local ok, decoded = pcall(function()
                        return HttpService:JSONDecode(content)
                    end)
                    if ok then return decoded end
                end
            end
            return nil
        end

        function ConfigAPI:List()
            ensureDir()
            local configs = {}
            if typeof(listfiles) == "function" then
                local ok, files = pcall(function() return listfiles(configDir) end)
                if ok and files then
                    for _, path in ipairs(files) do
                        local fileName = string.match(path, "([^/\\]+)%.json$")
                        if fileName then
                            table.insert(configs, fileName)
                        end
                    end
                end
            end
            return configs
        end

        function ConfigAPI:ExportToClipboard(dataTable)
            local json = HttpService:JSONEncode(dataTable)
            if typeof(setclipboard) == "function" then
                setclipboard(json)
                return true
            end
            return false
        end

        function ConfigAPI:ImportFromClipboard()
            if typeof(getclipboard) == "function" then
                local clip = getclipboard()
                local ok, decoded = pcall(function()
                    return HttpService:JSONDecode(clip)
                end)
                if ok and typeof(decoded) == "table" then
                    return decoded
                end
            end
            return nil
        end

        return ConfigAPI
    end

    -- Toggle menu key (Insert or RightControl)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and (input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightControl) then
            Main.Visible = not Main.Visible
            if WindowObj.Preview then
                WindowObj.Preview:SetVisible(Main.Visible)
            end
            if not Main.Visible then
                for _, p in ipairs(Library.Popups:GetChildren()) do
                    p.Visible = false
                end
            end
        end
    end)

    return WindowObj
end

return Library
