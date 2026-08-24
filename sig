local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

local KW = {}
KW.__index = KW

local GITHUB_ICONS_BASE = "https://raw.githubusercontent.com/Mrsims0/Ui/main/gig/"

local IconList = {
    "checkmark.png",
    "chevron.png",
    "eye.png",
    "flame.png",
    "gear.png",
    "keyboard.png",
    "paintbrush.png",
    "rifle.png",
    "search.png",
    "sword.png",
    "target.png",
}

local Theme = {
    MainBackground       = Color3.fromRGB(15, 16, 20),
    TitleBarBackground   = Color3.fromRGB(19, 20, 26),
    SidebarBackground    = Color3.fromRGB(12, 13, 16),
    CardBackground       = Color3.fromRGB(20, 21, 28),
    CardHover            = Color3.fromRGB(28, 30, 40),
    ControlBackground    = Color3.fromRGB(18, 19, 24),
    ControlBorder        = Color3.fromRGB(36, 38, 48),
    ControlBorderHover   = Color3.fromRGB(60, 65, 82),
    
    Accent               = Color3.fromRGB(0, 180, 255),
    AccentBright         = Color3.fromRGB(0, 215, 255),
    AccentDark           = Color3.fromRGB(0, 130, 200),
    
    HighlightYellow      = Color3.fromRGB(255, 195, 50),
    
    TextPrimary          = Color3.fromRGB(255, 255, 255),
    TextSecondary        = Color3.fromRGB(200, 202, 214),
    TextMuted            = Color3.fromRGB(130, 133, 148),
    TextDark             = Color3.fromRGB(80, 83, 96),
    
    KeybindBackground    = Color3.fromRGB(10, 24, 42),
    KeybindBorder        = Color3.fromRGB(0, 140, 230),
    KeybindText          = Color3.fromRGB(110, 210, 255),
    
    Separator            = Color3.fromRGB(26, 28, 36),
    Border               = Color3.fromRGB(34, 36, 46),
    Scrollbar            = Color3.fromRGB(0, 200, 255),
}

local FallbackIcons = {
    Flame        = "rbxassetid://10723345518",
    Sword        = "rbxassetid://10734934585",
    Target       = "rbxassetid://10734947936",
    Crosshair    = "rbxassetid://10734947936",
    Eye          = "rbxassetid://10723346959",
    Rifle        = "rbxassetid://10734934585",
    Gear         = "rbxassetid://10734950309",
    Search       = "rbxassetid://10734943725",
    Checkmark    = "rbxassetid://10709790644",
    Chevron      = "rbxassetid://10709790948",
    ChevronDown  = "rbxassetid://10709790948",
    Keyboard     = "rbxassetid://10709798950",
    Paintbrush   = "rbxassetid://10723346049",
    Palette      = "rbxassetid://10723346049",
}

local function SetupDirectories()
    if isfolder and makefolder then
        if not isfolder("cat") then
            pcall(makefolder, "cat")
        end
        if not isfolder("cat/icons") then
            pcall(makefolder, "cat/icons")
        end
    end
end

local function DownloadIcon(fileName)
    SetupDirectories()
    local path = "cat/icons/" .. fileName
    if isfile and isfile(path) then
        return path
    end
    if writefile and game and game.HttpGet then
        local success, content = pcall(function()
            return game:HttpGet(GITHUB_ICONS_BASE .. fileName)
        end)
        if success and content and #content > 0 then
            pcall(writefile, path, content)
            return path
        end
    end
    return path
end

local function ResolveIcon(name)
    if not name then return "" end
    if string.find(name, "rbxassetid://") or string.find(name, "http") then
        return name
    end

    local baseName = string.lower(name)
    if baseName == "chevrondown" then baseName = "chevron" end
    if baseName == "crosshair" then baseName = "target" end
    if baseName == "palette" then baseName = "paintbrush" end

    local fileName = baseName .. ".png"
    local localPath = "cat/icons/" .. fileName

    DownloadIcon(fileName)

    if getcustomasset then
        local success, asset = pcall(getcustomasset, localPath)
        if success and asset then return asset end
    elseif getsynasset then
        local success, asset = pcall(getsynasset, localPath)
        if success and asset then return asset end
    end

    for k, v in pairs(FallbackIcons) do
        if string.lower(k) == baseName then
            return v
        end
    end

    return localPath
end

task.spawn(function()
    SetupDirectories()
    for _, iconFile in ipairs(IconList) do
        DownloadIcon(iconFile)
    end
end)

local function GetSafeGuiParent()
    local success, parent = pcall(function()
        if gethui then
            return gethui()
        elseif CoreGui and not RunService:IsStudio() then
            return CoreGui
        elseif LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
            return LocalPlayer.PlayerGui
        end
        return nil
    end)
    if success and parent then
        return parent
    end
    return (LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")) or game:GetService("StarterGui")
end

local function Tween(instance, properties, duration, style, direction)
    duration = duration or 0.2
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

local function EnableDragging(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function KW:CreateWindow(options)
    options = options or {}
    local windowTitle = options.Title or "KW"
    local windowVersion = options.Version or "v1.0.5"
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KWGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = GetSafeGuiParent()

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 850, 0, 560)
    MainFrame.Position = UDim2.new(0.5, -425, 0.5, -280)
    MainFrame.BackgroundColor3 = Theme.MainBackground
    MainFrame.BackgroundTransparency = 0
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.ZIndex = 2
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui

    local MainScale = Instance.new("UIScale")
    MainScale.Scale = 0.92
    MainScale.Parent = MainFrame

    local function PlayIntroAnimation(onComplete)
        local IntroOverlay = Instance.new("Frame")
        IntroOverlay.Name = "KW_IntroOverlay"
        IntroOverlay.Size = UDim2.new(1, 0, 1, 0)
        IntroOverlay.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
        IntroOverlay.BackgroundTransparency = 1
        IntroOverlay.BorderSizePixel = 0
        IntroOverlay.ZIndex = 200
        IntroOverlay.Parent = ScreenGui

        local Blur = nil
        pcall(function()
            Blur = Instance.new("BlurEffect")
            Blur.Name = "KW_IntroBlur"
            Blur.Size = 0
            Blur.Parent = Lighting
        end)

        local CenterContainer = Instance.new("Frame")
        CenterContainer.Name = "CenterContainer"
        CenterContainer.Size = UDim2.new(1, 0, 0, 100)
        CenterContainer.Position = UDim2.new(0, 0, 0.5, -50)
        CenterContainer.BackgroundTransparency = 1
        CenterContainer.ZIndex = 201
        CenterContainer.Parent = IntroOverlay

        local KittyLabel = Instance.new("TextLabel")
        KittyLabel.Name = "KittyLabel"
        KittyLabel.Text = "KITTY"
        KittyLabel.Font = Enum.Font.GothamBlack
        KittyLabel.TextSize = 64
        KittyLabel.TextColor3 = Theme.TextPrimary
        KittyLabel.TextXAlignment = Enum.TextXAlignment.Right
        KittyLabel.BackgroundTransparency = 1
        KittyLabel.Size = UDim2.new(0, 320, 0, 80)
        KittyLabel.Position = UDim2.new(0.5, -1400, 0.5, -40)
        KittyLabel.TextTransparency = 1
        KittyLabel.ZIndex = 202
        KittyLabel.Parent = CenterContainer

        local WareLabel = Instance.new("TextLabel")
        WareLabel.Name = "WareLabel"
        WareLabel.Text = "WARE"
        WareLabel.Font = Enum.Font.GothamBlack
        WareLabel.TextSize = 64
        WareLabel.TextColor3 = Theme.AccentBright
        WareLabel.TextXAlignment = Enum.TextXAlignment.Left
        WareLabel.BackgroundTransparency = 1
        WareLabel.Size = UDim2.new(0, 320, 0, 80)
        WareLabel.Position = UDim2.new(0.5, 1400, 0.5, -40)
        WareLabel.TextTransparency = 1
        WareLabel.ZIndex = 202
        WareLabel.Parent = CenterContainer

        task.spawn(function()
            Tween(IntroOverlay, { BackgroundTransparency = 0.35 }, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            if Blur then
                Tween(Blur, { Size = 24 }, 0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            end

            task.wait(0.1)

            -- 1. Slide in KITTY from far off-screen left
            Tween(KittyLabel, { Position = UDim2.new(0.5, -330, 0.5, -40), TextTransparency = 0 }, 0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            -- 2. Wait before sliding in WARE
            task.wait(0.35)

            -- 3. Slide in WARE from far off-screen right
            Tween(WareLabel, { Position = UDim2.new(0.5, 10, 0.5, -40), TextTransparency = 0 }, 0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            -- 4. Hold full display
            task.wait(0.8)

            -- 5. Outro fade and slide up
            Tween(KittyLabel, { Position = UDim2.new(0.5, -330, 0.5, -70), TextTransparency = 1 }, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            Tween(WareLabel, { Position = UDim2.new(0.5, 10, 0.5, -70), TextTransparency = 1 }, 0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            Tween(IntroOverlay, { BackgroundTransparency = 1 }, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            if Blur then
                Tween(Blur, { Size = 0 }, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            end

            task.wait(0.4)
            if Blur then pcall(function() Blur:Destroy() end) end
            IntroOverlay:Destroy()

            if onComplete then
                onComplete()
            end
        end)
    end

    if options.Intro == false then
        MainFrame.Visible = true
        MainScale.Scale = 1
    else
        PlayIntroAnimation(function()
            MainFrame.Visible = true
            Tween(MainScale, { Scale = 1 }, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end)
    end

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Border
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    local SearchableElements = {}

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = Theme.TitleBarBackground
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 3
    TitleBar.Parent = MainFrame

    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 8)
    TitleBarCorner.Parent = TitleBar

    local TitleBarBottomCover = Instance.new("Frame")
    TitleBarBottomCover.Size = UDim2.new(1, 0, 0, 10)
    TitleBarBottomCover.Position = UDim2.new(0, 0, 1, -10)
    TitleBarBottomCover.BackgroundColor3 = Theme.TitleBarBackground
    TitleBarBottomCover.BorderSizePixel = 0
    TitleBarBottomCover.ZIndex = 3
    TitleBarBottomCover.Parent = TitleBar

    local TitleBarBorder = Instance.new("Frame")
    TitleBarBorder.Size = UDim2.new(1, 0, 0, 1)
    TitleBarBorder.Position = UDim2.new(0, 0, 1, 0)
    TitleBarBorder.BackgroundColor3 = Theme.Separator
    TitleBarBorder.BorderSizePixel = 0
    TitleBarBorder.ZIndex = 3
    TitleBarBorder.Parent = TitleBar

    EnableDragging(MainFrame, TitleBar)

    local LogoIcon = Instance.new("ImageLabel")
    LogoIcon.Name = "LogoIcon"
    LogoIcon.Size = UDim2.new(0, 24, 0, 24)
    LogoIcon.Position = UDim2.new(0, 16, 0.5, -12)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Image = ResolveIcon("flame")
    LogoIcon.ImageColor3 = Theme.Accent
    LogoIcon.ScaleType = Enum.ScaleType.Fit
    LogoIcon.ZIndex = 4
    LogoIcon.Parent = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Text = windowTitle
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 15
    TitleLabel.TextColor3 = Theme.TextPrimary
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(0, 52, 1, 0)
    TitleLabel.Position = UDim2.new(0, 48, 0, 0)
    TitleLabel.ZIndex = 4
    TitleLabel.Parent = TitleBar

    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Name = "VersionLabel"
    VersionLabel.Text = windowVersion
    VersionLabel.Font = Enum.Font.GothamMedium
    VersionLabel.TextSize = 12
    VersionLabel.TextColor3 = Theme.TextMuted
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Size = UDim2.new(0, 60, 1, 0)
    VersionLabel.Position = UDim2.new(0, 102, 0, 0)
    VersionLabel.ZIndex = 4
    VersionLabel.Parent = TitleBar

    local SearchContainer = Instance.new("Frame")
    SearchContainer.Name = "SearchContainer"
    SearchContainer.Size = UDim2.new(0, 220, 0, 30)
    SearchContainer.Position = UDim2.new(1, -236, 0.5, -15)
    SearchContainer.BackgroundColor3 = Theme.ControlBackground
    SearchContainer.BorderSizePixel = 0
    SearchContainer.ZIndex = 4
    SearchContainer.Parent = TitleBar

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchContainer

    local SearchStroke = Instance.new("UIStroke")
    SearchStroke.Color = Theme.ControlBorder
    SearchStroke.Thickness = 1
    SearchStroke.Parent = SearchContainer

    local SearchIcon = Instance.new("ImageLabel")
    SearchIcon.Name = "SearchIcon"
    SearchIcon.Size = UDim2.new(0, 14, 0, 14)
    SearchIcon.Position = UDim2.new(0, 9, 0.5, -7)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = ResolveIcon("search")
    SearchIcon.ImageColor3 = Theme.TextMuted
    SearchIcon.ScaleType = Enum.ScaleType.Fit
    SearchIcon.ZIndex = 5
    SearchIcon.Parent = SearchContainer

    local SearchInput = Instance.new("TextBox")
    SearchInput.Name = "SearchInput"
    SearchInput.Size = UDim2.new(1, -32, 1, 0)
    SearchInput.Position = UDim2.new(0, 28, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.PlaceholderText = "Search features..."
    SearchInput.PlaceholderColor3 = Theme.TextDark
    SearchInput.Text = ""
    SearchInput.TextColor3 = Theme.TextPrimary
    SearchInput.TextSize = 12
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    SearchInput.ClearTextOnFocus = false
    SearchInput.ZIndex = 5
    SearchInput.Parent = SearchContainer

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 90, 1, -50)
    Sidebar.Position = UDim2.new(0, 0, 0, 50)
    Sidebar.BackgroundColor3 = Theme.SidebarBackground
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 3
    Sidebar.Parent = MainFrame

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 8)
    SidebarCorner.Parent = Sidebar

    local SidebarRightCover = Instance.new("Frame")
    SidebarRightCover.Size = UDim2.new(0, 10, 1, 0)
    SidebarRightCover.Position = UDim2.new(1, -10, 0, 0)
    SidebarRightCover.BackgroundColor3 = Theme.SidebarBackground
    SidebarRightCover.BorderSizePixel = 0
    SidebarRightCover.ZIndex = 3
    SidebarRightCover.Parent = Sidebar

    local SidebarTopCover = Instance.new("Frame")
    SidebarTopCover.Size = UDim2.new(1, 0, 0, 10)
    SidebarTopCover.Position = UDim2.new(0, 0, 0, 0)
    SidebarTopCover.BackgroundColor3 = Theme.SidebarBackground
    SidebarTopCover.BorderSizePixel = 0
    SidebarTopCover.ZIndex = 3
    SidebarTopCover.Parent = Sidebar

    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Name = "SidebarDivider"
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
    SidebarDivider.BackgroundColor3 = Theme.Separator
    SidebarDivider.BorderSizePixel = 0
    SidebarDivider.ZIndex = 3
    SidebarDivider.Parent = Sidebar

    local TabButtonsHolder = Instance.new("ScrollingFrame")
    TabButtonsHolder.Name = "TabButtonsHolder"
    TabButtonsHolder.Size = UDim2.new(1, 0, 1, -12)
    TabButtonsHolder.Position = UDim2.new(0, 0, 0, 8)
    TabButtonsHolder.BackgroundTransparency = 1
    TabButtonsHolder.BorderSizePixel = 0
    TabButtonsHolder.ScrollBarThickness = 0
    TabButtonsHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabButtonsHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabButtonsHolder.ZIndex = 4
    TabButtonsHolder.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 6)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.Parent = TabButtonsHolder

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -91, 1, -50)
    ContentArea.Position = UDim2.new(0, 91, 0, 50)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ZIndex = 3
    ContentArea.Parent = MainFrame

    local PopupsLayer = Instance.new("Frame")
    PopupsLayer.Name = "PopupsLayer"
    PopupsLayer.Size = UDim2.new(1, 0, 1, 0)
    PopupsLayer.BackgroundTransparency = 1
    PopupsLayer.ZIndex = 50
    PopupsLayer.Parent = MainFrame

    local SearchResultsPopup = Instance.new("Frame")
    SearchResultsPopup.Name = "SearchResultsPopup"
    SearchResultsPopup.Size = UDim2.new(0, 360, 0, 260)
    SearchResultsPopup.Position = UDim2.new(1, -376, 0, 46)
    SearchResultsPopup.BackgroundColor3 = Theme.CardBackground
    SearchResultsPopup.BorderSizePixel = 0
    SearchResultsPopup.Visible = false
    SearchResultsPopup.ZIndex = 90
    SearchResultsPopup.Parent = PopupsLayer

    local SRPCorner = Instance.new("UICorner")
    SRPCorner.CornerRadius = UDim.new(0, 8)
    SRPCorner.Parent = SearchResultsPopup

    local SRPStroke = Instance.new("UIStroke")
    SRPStroke.Color = Theme.Accent
    SRPStroke.Thickness = 1.5
    SRPStroke.Parent = SearchResultsPopup

    local SRPHeader = Instance.new("Frame")
    SRPHeader.Size = UDim2.new(1, 0, 0, 28)
    SRPHeader.BackgroundColor3 = Theme.ControlBackground
    SRPHeader.BorderSizePixel = 0
    SRPHeader.ZIndex = 91
    SRPHeader.Parent = SearchResultsPopup

    local SRPHeaderCorner = Instance.new("UICorner")
    SRPHeaderCorner.CornerRadius = UDim.new(0, 8)
    SRPHeaderCorner.Parent = SRPHeader

    local SRPHeaderTitle = Instance.new("TextLabel")
    SRPHeaderTitle.Text = "GLOBAL SEARCH RESULTS"
    SRPHeaderTitle.Font = Enum.Font.GothamBold
    SRPHeaderTitle.TextSize = 10
    SRPHeaderTitle.TextColor3 = Theme.Accent
    SRPHeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    SRPHeaderTitle.Size = UDim2.new(1, -16, 1, 0)
    SRPHeaderTitle.Position = UDim2.new(0, 10, 0, 0)
    SRPHeaderTitle.BackgroundTransparency = 1
    SRPHeaderTitle.ZIndex = 92
    SRPHeaderTitle.Parent = SRPHeader

    local SRPScroll = Instance.new("ScrollingFrame")
    SRPScroll.Name = "SRPScroll"
    SRPScroll.Size = UDim2.new(1, -12, 1, -36)
    SRPScroll.Position = UDim2.new(0, 6, 0, 32)
    SRPScroll.BackgroundTransparency = 1
    SRPScroll.BorderSizePixel = 0
    SRPScroll.ScrollBarThickness = 3
    SRPScroll.ScrollBarImageColor3 = Theme.Scrollbar
    SRPScroll.ScrollBarImageTransparency = 0
    SRPScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    SRPScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SRPScroll.ZIndex = 91
    SRPScroll.Parent = SearchResultsPopup

    local SRPLayout = Instance.new("UIListLayout")
    SRPLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SRPLayout.Padding = UDim.new(0, 4)
    SRPLayout.Parent = SRPScroll

    local ResizeHandle = Instance.new("TextButton")
    ResizeHandle.Name = "ResizeHandle"
    ResizeHandle.Size = UDim2.new(0, 22, 0, 22)
    ResizeHandle.Position = UDim2.new(1, -22, 1, -22)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Text = ""
    ResizeHandle.AutoButtonColor = false
    ResizeHandle.ZIndex = 40
    ResizeHandle.Parent = MainFrame

    local GripFrame = Instance.new("Frame")
    GripFrame.Size = UDim2.new(1, 0, 1, 0)
    GripFrame.BackgroundTransparency = 1
    GripFrame.ZIndex = 41
    GripFrame.Parent = ResizeHandle

    local dot1 = Instance.new("Frame")
    dot1.Size = UDim2.new(0, 3, 0, 3)
    dot1.Position = UDim2.new(1, -7, 1, -7)
    dot1.BackgroundColor3 = Theme.TextMuted
    dot1.BorderSizePixel = 0
    dot1.ZIndex = 42
    dot1.Parent = GripFrame
    local c1 = Instance.new("UICorner")
    c1.CornerRadius = UDim.new(1, 0)
    c1.Parent = dot1

    local dot2 = Instance.new("Frame")
    dot2.Size = UDim2.new(0, 3, 0, 3)
    dot2.Position = UDim2.new(1, -13, 1, -7)
    dot2.BackgroundColor3 = Theme.TextMuted
    dot2.BorderSizePixel = 0
    dot2.ZIndex = 42
    dot2.Parent = GripFrame
    local c2 = Instance.new("UICorner")
    c2.CornerRadius = UDim.new(1, 0)
    c2.Parent = dot2

    local dot3 = Instance.new("Frame")
    dot3.Size = UDim2.new(0, 3, 0, 3)
    dot3.Position = UDim2.new(1, -7, 1, -13)
    dot3.BackgroundColor3 = Theme.TextMuted
    dot3.BorderSizePixel = 0
    dot3.ZIndex = 42
    dot3.Parent = GripFrame
    local c3 = Instance.new("UICorner")
    c3.CornerRadius = UDim.new(1, 0)
    c3.Parent = dot3

    ResizeHandle.MouseEnter:Connect(function()
        dot1.BackgroundColor3 = Theme.Accent
        dot2.BackgroundColor3 = Theme.Accent
        dot3.BackgroundColor3 = Theme.Accent
    end)

    ResizeHandle.MouseLeave:Connect(function()
        dot1.BackgroundColor3 = Theme.TextMuted
        dot2.BackgroundColor3 = Theme.TextMuted
        dot3.BackgroundColor3 = Theme.TextMuted
    end)

    local isResizing = false
    local resizeStartMouse, resizeStartSize

    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = true
            resizeStartMouse = input.Position
            resizeStartSize = Vector2.new(MainFrame.AbsoluteSize.X, MainFrame.AbsoluteSize.Y)

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isResizing = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStartMouse
            local newW = math.clamp(resizeStartSize.X + delta.X, 680, 1600)
            local newH = math.clamp(resizeStartSize.Y + delta.Y, 420, 1100)
            MainFrame.Size = UDim2.new(0, newW, 0, newH)
        end
    end)

    local WindowState = {
        Tabs = {},
        CurrentTab = nil,
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        PopupsLayer = PopupsLayer,
        SearchQuery = "",
    }

    local function OpenInteractiveColorPicker(titleText, initialColor, onColorChanged, anchorElement)
        local existingPopup = PopupsLayer:FindFirstChild("HSVColorPickerPopup")
        if existingPopup then existingPopup:Destroy() end

        local h, s, v = Color3.toHSV(initialColor)
        local currentColor = initialColor

        local Popup = Instance.new("Frame")
        Popup.Name = "HSVColorPickerPopup"
        Popup.Size = UDim2.new(0, 230, 0, 240)

        local absPos = anchorElement.AbsolutePosition
        local mainPos = MainFrame.AbsolutePosition
        local posX = math.clamp(absPos.X - mainPos.X - 235, 10, MainFrame.AbsoluteSize.X - 240)
        local posY = math.clamp(absPos.Y - mainPos.Y - 10, 10, MainFrame.AbsoluteSize.Y - 250)

        Popup.Position = UDim2.new(0, posX, 0, posY)
        Popup.BackgroundColor3 = Theme.CardBackground
        Popup.BorderSizePixel = 0
        Popup.ZIndex = 80
        Popup.Parent = PopupsLayer

        local PopCorner = Instance.new("UICorner")
        PopCorner.CornerRadius = UDim.new(0, 8)
        PopCorner.Parent = Popup

        local PopStroke = Instance.new("UIStroke")
        PopStroke.Color = Theme.Accent
        PopStroke.Thickness = 1.5
        PopStroke.Parent = Popup

        local TopRow = Instance.new("Frame")
        TopRow.Size = UDim2.new(1, -16, 0, 24)
        TopRow.Position = UDim2.new(0, 8, 0, 6)
        TopRow.BackgroundTransparency = 1
        TopRow.ZIndex = 81
        TopRow.Parent = Popup

        local Title = Instance.new("TextLabel")
        Title.Text = titleText
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 11
        Title.TextColor3 = Theme.TextPrimary
        Title.Size = UDim2.new(1, -50, 1, 0)
        Title.BackgroundTransparency = 1
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.ZIndex = 81
        Title.Parent = TopRow

        local PreviewBox = Instance.new("Frame")
        PreviewBox.Size = UDim2.new(0, 18, 0, 18)
        PreviewBox.Position = UDim2.new(1, -44, 0.5, -9)
        PreviewBox.BackgroundColor3 = currentColor
        PreviewBox.BorderSizePixel = 0
        PreviewBox.ZIndex = 81
        PreviewBox.Parent = TopRow

        local PrevCorner = Instance.new("UICorner")
        PrevCorner.CornerRadius = UDim.new(0, 4)
        PrevCorner.Parent = PreviewBox

        local PrevStroke = Instance.new("UIStroke")
        PrevStroke.Color = Theme.Border
        PrevStroke.Thickness = 1
        PrevStroke.Parent = PreviewBox

        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0, 18, 0, 18)
        CloseBtn.Position = UDim2.new(1, -20, 0.5, -9)
        CloseBtn.BackgroundColor3 = Theme.ControlBackground
        CloseBtn.Text = "×"
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.TextSize = 14
        CloseBtn.TextColor3 = Theme.TextMuted
        CloseBtn.AutoButtonColor = false
        CloseBtn.ZIndex = 81
        CloseBtn.Parent = TopRow

        local CloseCorner = Instance.new("UICorner")
        CloseCorner.CornerRadius = UDim.new(0, 4)
        CloseCorner.Parent = CloseBtn

        CloseBtn.MouseButton1Click:Connect(function()
            Popup:Destroy()
        end)

        local SVCanvas = Instance.new("Frame")
        SVCanvas.Name = "SVCanvas"
        SVCanvas.Size = UDim2.new(1, -16, 0, 105)
        SVCanvas.Position = UDim2.new(0, 8, 0, 32)
        SVCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        SVCanvas.BorderSizePixel = 0
        SVCanvas.ClipsDescendants = true
        SVCanvas.ZIndex = 82
        SVCanvas.Parent = Popup

        local SVCorner = Instance.new("UICorner")
        SVCorner.CornerRadius = UDim.new(0, 5)
        SVCorner.Parent = SVCanvas

        local WhiteGradFrame = Instance.new("Frame")
        WhiteGradFrame.Size = UDim2.new(1, 0, 1, 0)
        WhiteGradFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        WhiteGradFrame.BorderSizePixel = 0
        WhiteGradFrame.ZIndex = 83
        WhiteGradFrame.Parent = SVCanvas

        local WhiteGrad = Instance.new("UIGradient")
        WhiteGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        WhiteGrad.Rotation = 0
        WhiteGrad.Parent = WhiteGradFrame

        local BlackGradFrame = Instance.new("Frame")
        BlackGradFrame.Size = UDim2.new(1, 0, 1, 0)
        BlackGradFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        BlackGradFrame.BorderSizePixel = 0
        BlackGradFrame.ZIndex = 84
        BlackGradFrame.Parent = SVCanvas

        local BlackGrad = Instance.new("UIGradient")
        BlackGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0)
        })
        BlackGrad.Rotation = 90
        BlackGrad.Parent = BlackGradFrame

        local SVKnob = Instance.new("Frame")
        SVKnob.Name = "SVKnob"
        SVKnob.Size = UDim2.new(0, 10, 0, 10)
        SVKnob.Position = UDim2.new(s, -5, 1 - v, -5)
        SVKnob.BackgroundColor3 = currentColor
        SVKnob.BorderSizePixel = 0
        SVKnob.ZIndex = 85
        SVKnob.Parent = SVCanvas

        local SVKCorner = Instance.new("UICorner")
        SVKCorner.CornerRadius = UDim.new(1, 0)
        SVKCorner.Parent = SVKnob

        local SVKStroke = Instance.new("UIStroke")
        SVKStroke.Color = Color3.fromRGB(255, 255, 255)
        SVKStroke.Thickness = 1.5
        SVKStroke.Parent = SVKnob

        local HueBar = Instance.new("Frame")
        HueBar.Name = "HueBar"
        HueBar.Size = UDim2.new(1, -16, 0, 12)
        HueBar.Position = UDim2.new(0, 8, 0, 144)
        HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HueBar.BorderSizePixel = 0
        HueBar.ZIndex = 82
        HueBar.Parent = Popup

        local HueCorner = Instance.new("UICorner")
        HueCorner.CornerRadius = UDim.new(0, 3)
        HueCorner.Parent = HueBar

        local HueGrad = Instance.new("UIGradient")
        HueGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
        })
        HueGrad.Parent = HueBar

        local HueKnob = Instance.new("Frame")
        HueKnob.Name = "HueKnob"
        HueKnob.Size = UDim2.new(0, 6, 1, 4)
        HueKnob.Position = UDim2.new(h, -3, 0.5, -8)
        HueKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        HueKnob.BorderSizePixel = 0
        HueKnob.ZIndex = 85
        HueKnob.Parent = HueBar

        local HKCorner = Instance.new("UICorner")
        HKCorner.CornerRadius = UDim.new(0, 2)
        HKCorner.Parent = HueKnob

        local HKStroke = Instance.new("UIStroke")
        HKStroke.Color = Color3.fromRGB(20, 20, 24)
        HKStroke.Thickness = 1
        HKStroke.Parent = HueKnob

        local PaletteRow = Instance.new("Frame")
        PaletteRow.Size = UDim2.new(1, -16, 0, 18)
        PaletteRow.Position = UDim2.new(0, 8, 0, 162)
        PaletteRow.BackgroundTransparency = 1
        PaletteRow.ZIndex = 82
        PaletteRow.Parent = Popup

        local PaletteLayout = Instance.new("UIListLayout")
        PaletteLayout.FillDirection = Enum.FillDirection.Horizontal
        PaletteLayout.Padding = UDim.new(0, 5)
        PaletteLayout.Parent = PaletteRow

        local QuickColors = {
            Color3.fromRGB(255, 50, 50),
            Color3.fromRGB(255, 140, 0),
            Color3.fromRGB(255, 210, 0),
            Color3.fromRGB(0, 230, 120),
            Color3.fromRGB(0, 180, 255),
            Color3.fromRGB(180, 70, 255),
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(100, 100, 110),
        }

        local function RefreshColor()
            currentColor = Color3.fromHSV(h, s, v)
            SVCanvas.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            SVKnob.Position = UDim2.new(s, -5, 1 - v, -5)
            SVKnob.BackgroundColor3 = currentColor
            HueKnob.Position = UDim2.new(h, -3, 0.5, -8)
            PreviewBox.BackgroundColor3 = currentColor
            if onColorChanged then
                pcall(onColorChanged, currentColor)
            end
        end

        for _, qcol in ipairs(QuickColors) do
            local QDot = Instance.new("TextButton")
            QDot.Size = UDim2.new(0, 20, 0, 16)
            QDot.BackgroundColor3 = qcol
            QDot.BorderSizePixel = 0
            QDot.Text = ""
            QDot.AutoButtonColor = false
            QDot.ZIndex = 83
            QDot.Parent = PaletteRow

            local QC = Instance.new("UICorner")
            QC.CornerRadius = UDim.new(0, 3)
            QC.Parent = QDot

            QDot.MouseButton1Click:Connect(function()
                h, s, v = Color3.toHSV(qcol)
                RefreshColor()
            end)
        end

        local BottomInputs = Instance.new("Frame")
        BottomInputs.Size = UDim2.new(1, -16, 0, 24)
        BottomInputs.Position = UDim2.new(0, 8, 0, 186)
        BottomInputs.BackgroundTransparency = 1
        BottomInputs.ZIndex = 82
        BottomInputs.Parent = Popup

        local HexBox = Instance.new("TextBox")
        HexBox.Size = UDim2.new(0, 70, 0, 22)
        HexBox.Position = UDim2.new(0, 0, 0, 1)
        HexBox.BackgroundColor3 = Theme.ControlBackground
        HexBox.Text = "#" .. currentColor:ToHex():upper()
        HexBox.Font = Enum.Font.GothamBold
        HexBox.TextSize = 10
        HexBox.TextColor3 = Theme.TextPrimary
        HexBox.ZIndex = 83
        HexBox.ClearTextOnFocus = false
        HexBox.Parent = BottomInputs

        local HexCorner = Instance.new("UICorner")
        HexCorner.CornerRadius = UDim.new(0, 4)
        HexCorner.Parent = HexBox

        local HexStroke = Instance.new("UIStroke")
        HexStroke.Color = Theme.ControlBorder
        HexStroke.Thickness = 1
        HexStroke.Parent = HexBox

        local RGBLabel = Instance.new("TextLabel")
        RGBLabel.Size = UDim2.new(1, -78, 0, 22)
        RGBLabel.Position = UDim2.new(0, 78, 0, 1)
        RGBLabel.BackgroundTransparency = 1
        RGBLabel.Font = Enum.Font.GothamMedium
        RGBLabel.TextSize = 10
        RGBLabel.TextColor3 = Theme.TextMuted
        RGBLabel.TextXAlignment = Enum.TextXAlignment.Right
        RGBLabel.ZIndex = 83
        RGBLabel.Text = string.format("RGB: %d, %d, %d", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
        RGBLabel.Parent = BottomInputs

        local DoneBtn = Instance.new("TextButton")
        DoneBtn.Size = UDim2.new(1, -16, 0, 20)
        DoneBtn.Position = UDim2.new(0, 8, 1, -24)
        DoneBtn.BackgroundColor3 = Theme.ControlBackground
        DoneBtn.Text = "Done"
        DoneBtn.Font = Enum.Font.GothamMedium
        DoneBtn.TextSize = 11
        DoneBtn.TextColor3 = Theme.TextPrimary
        DoneBtn.AutoButtonColor = false
        DoneBtn.ZIndex = 82
        DoneBtn.Parent = Popup

        local DoneCorner = Instance.new("UICorner")
        DoneCorner.CornerRadius = UDim.new(0, 4)
        DoneCorner.Parent = DoneBtn

        DoneBtn.MouseButton1Click:Connect(function()
            Popup:Destroy()
        end)

        HexBox.FocusLost:Connect(function()
            local cleanHex = HexBox.Text:gsub("#", "")
            local success, parsedColor = pcall(function()
                return Color3.fromHex(cleanHex)
            end)
            if success and parsedColor then
                h, s, v = Color3.toHSV(parsedColor)
                RefreshColor()
                HexBox.Text = "#" .. currentColor:ToHex():upper()
                RGBLabel.Text = string.format("RGB: %d, %d, %d", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
            else
                HexBox.Text = "#" .. currentColor:ToHex():upper()
            end
        end)

        local draggingSV = false
        local draggingHue = false

        local function UpdateSV(inputX, inputY)
            local absX = SVCanvas.AbsolutePosition.X
            local absY = SVCanvas.AbsolutePosition.Y
            local sizeX = SVCanvas.AbsoluteSize.X
            local sizeY = SVCanvas.AbsoluteSize.Y

            s = math.clamp((inputX - absX) / sizeX, 0, 1)
            v = math.clamp(1 - ((inputY - absY) / sizeY), 0, 1)
            RefreshColor()
            HexBox.Text = "#" .. currentColor:ToHex():upper()
            RGBLabel.Text = string.format("RGB: %d, %d, %d", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
        end

        local function UpdateHue(inputX)
            local absX = HueBar.AbsolutePosition.X
            local sizeX = HueBar.AbsoluteSize.X
            h = math.clamp((inputX - absX) / sizeX, 0, 1)
            RefreshColor()
            HexBox.Text = "#" .. currentColor:ToHex():upper()
            RGBLabel.Text = string.format("RGB: %d, %d, %d", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
        end

        local SVHitbox = Instance.new("TextButton")
        SVHitbox.Size = UDim2.new(1, 0, 1, 0)
        SVHitbox.BackgroundTransparency = 1
        SVHitbox.Text = ""
        SVHitbox.ZIndex = 86
        SVHitbox.Parent = SVCanvas

        SVHitbox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSV = true
                UpdateSV(input.Position.X, input.Position.Y)
            end
        end)

        local HueHitbox = Instance.new("TextButton")
        HueHitbox.Size = UDim2.new(1, 0, 1, 0)
        HueHitbox.BackgroundTransparency = 1
        HueHitbox.Text = ""
        HueHitbox.ZIndex = 86
        HueHitbox.Parent = HueBar

        HueHitbox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingHue = true
                UpdateHue(input.Position.X)
            end
        end)

        local dragConnection
        dragConnection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                if draggingSV then
                    UpdateSV(input.Position.X, input.Position.Y)
                elseif draggingHue then
                    UpdateHue(input.Position.X)
                end
            end
        end)

        local endConnection
        endConnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSV = false
                draggingHue = false
            end
        end)

        Popup.Destroying:Connect(function()
            if dragConnection then dragConnection:Disconnect() end
            if endConnection then endConnection:Disconnect() end
        end)
    end

    local function PerformGlobalSearch()
        local query = string.lower(SearchInput.Text)
        WindowState.SearchQuery = query

        for _, child in ipairs(SRPScroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                child:Destroy()
            end
        end

        if query == "" then
            SearchResultsPopup.Visible = false
            for _, item in ipairs(SearchableElements) do
                item.Frame.Visible = true
                if item.Label then
                    item.Label.TextColor3 = item.OriginalColor or Theme.TextSecondary
                end
            end
            return
        end

        local matches = {}
        for _, item in ipairs(SearchableElements) do
            local itemNameLower = string.lower(item.Name)
            local match = string.find(itemNameLower, query, 1, true) ~= nil
            if match then
                table.insert(matches, item)
            end
        end

        SRPHeaderTitle.Text = string.format("GLOBAL SEARCH (%d MATCHES)", #matches)
        SearchResultsPopup.Visible = true

        if #matches == 0 then
            local NoMatch = Instance.new("TextLabel")
            NoMatch.Size = UDim2.new(1, 0, 0, 40)
            NoMatch.BackgroundTransparency = 1
            NoMatch.Text = "No features found matching '" .. query .. "'"
            NoMatch.Font = Enum.Font.GothamMedium
            NoMatch.TextSize = 11
            NoMatch.TextColor3 = Theme.TextMuted
            NoMatch.ZIndex = 92
            NoMatch.Parent = SRPScroll
            return
        end

        for _, item in ipairs(matches) do
            local ItemCard = Instance.new("TextButton")
            ItemCard.Size = UDim2.new(1, 0, 0, 32)
            ItemCard.BackgroundColor3 = Theme.ControlBackground
            ItemCard.BorderSizePixel = 0
            ItemCard.Text = ""
            ItemCard.AutoButtonColor = false
            ItemCard.ZIndex = 92
            ItemCard.Parent = SRPScroll

            local ICCorner = Instance.new("UICorner")
            ICCorner.CornerRadius = UDim.new(0, 5)
            ICCorner.Parent = ItemCard

            local ICStroke = Instance.new("UIStroke")
            ICStroke.Color = Theme.ControlBorder
            ICStroke.Thickness = 1
            ICStroke.Parent = ItemCard

            local ItemName = Instance.new("TextLabel")
            ItemName.Text = item.Name
            ItemName.Font = Enum.Font.GothamBold
            ItemName.TextSize = 12
            ItemName.TextColor3 = Theme.TextPrimary
            ItemName.TextXAlignment = Enum.TextXAlignment.Left
            ItemName.Size = UDim2.new(0.55, -10, 1, 0)
            ItemName.Position = UDim2.new(0, 10, 0, 0)
            ItemName.BackgroundTransparency = 1
            ItemName.ZIndex = 93
            ItemName.Parent = ItemCard

            local BreadcrumbPill = Instance.new("TextLabel")
            BreadcrumbPill.Text = item.Breadcrumb or ""
            BreadcrumbPill.Font = Enum.Font.GothamMedium
            BreadcrumbPill.TextSize = 9
            BreadcrumbPill.TextColor3 = Theme.KeybindText
            BreadcrumbPill.TextXAlignment = Enum.TextXAlignment.Right
            BreadcrumbPill.Size = UDim2.new(0.45, -10, 1, 0)
            BreadcrumbPill.Position = UDim2.new(0.55, 0, 0, 0)
            BreadcrumbPill.BackgroundTransparency = 1
            BreadcrumbPill.ZIndex = 93
            BreadcrumbPill.Parent = ItemCard

            ItemCard.MouseEnter:Connect(function()
                Tween(ItemCard, { BackgroundColor3 = Theme.CardHover })
                Tween(ICStroke, { Color = Theme.Accent })
                Tween(ItemName, { TextColor3 = Theme.AccentBright })
            end)

            ItemCard.MouseLeave:Connect(function()
                Tween(ItemCard, { BackgroundColor3 = Theme.ControlBackground })
                Tween(ICStroke, { Color = Theme.ControlBorder })
                Tween(ItemName, { TextColor3 = Theme.TextPrimary })
            end)

            ItemCard.MouseButton1Click:Connect(function()
                SearchResultsPopup.Visible = false
                SearchInput.Text = ""

                if item.Tab and item.Tab.Select then
                    item.Tab:Select()
                end
                if item.SubTab and item.SubTab.Select then
                    item.SubTab:Select()
                end

                if item.Frame then
                    task.spawn(function()
                        for _ = 1, 2 do
                            Tween(item.Frame, { BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Accent })
                            task.wait(0.2)
                            Tween(item.Frame, { BackgroundTransparency = 1 })
                            task.wait(0.2)
                        end
                    end)
                end
            end)
        end
    end

    SearchInput:GetPropertyChangedSignal("Text"):Connect(PerformGlobalSearch)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    function WindowState:CreateTab(tabConfig)
        local tabName = tabConfig.Name or "Tab"
        local tabIcon = ResolveIcon(tabConfig.Icon or "flame")

        local TabState = {
            Name = tabName,
            SubTabs = {},
            CurrentSubTab = nil,
            SubTabNavFrame = nil,
            ContentFrame = nil,
        }

        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TabButton_" .. tabName
        TabButton.Size = UDim2.new(0, 76, 0, 58)
        TabButton.BackgroundColor3 = Theme.CardBackground
        TabButton.BackgroundTransparency = 1
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabButtonsHolder

        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 6)
        TabButtonCorner.Parent = TabButton

        local IndicatorBar = Instance.new("Frame")
        IndicatorBar.Name = "IndicatorBar"
        IndicatorBar.Size = UDim2.new(0, 36, 0, 2)
        IndicatorBar.Position = UDim2.new(0.5, -18, 1, -4)
        IndicatorBar.BackgroundColor3 = Theme.AccentBright
        IndicatorBar.BorderSizePixel = 0
        IndicatorBar.BackgroundTransparency = 1
        IndicatorBar.Parent = TabButton

        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 2)
        IndicatorCorner.Parent = IndicatorBar

        local TabIconImage = Instance.new("ImageLabel")
        TabIconImage.Name = "TabIcon"
        TabIconImage.Size = UDim2.new(0, 22, 0, 22)
        TabIconImage.Position = UDim2.new(0.5, -11, 0, 8)
        TabIconImage.BackgroundTransparency = 1
        TabIconImage.Image = tabIcon
        TabIconImage.ImageColor3 = Theme.TextMuted
        TabIconImage.ScaleType = Enum.ScaleType.Fit
        TabIconImage.Parent = TabButton

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Name = "TabLabel"
        TabLabel.Text = tabName
        TabLabel.Font = Enum.Font.GothamMedium
        TabLabel.TextSize = 11
        TabLabel.TextColor3 = Theme.TextMuted
        TabLabel.BackgroundTransparency = 1
        TabLabel.Size = UDim2.new(1, 0, 0, 16)
        TabLabel.Position = UDim2.new(0, 0, 0, 34)
        TabLabel.Parent = TabButton

        local TabPage = Instance.new("Frame")
        TabPage.Name = "TabPage_" .. tabName
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.Parent = ContentArea

        local SubNavBar = Instance.new("Frame")
        SubNavBar.Name = "SubNavBar"
        SubNavBar.Size = UDim2.new(1, 0, 0, 38)
        SubNavBar.BackgroundTransparency = 1
        SubNavBar.Parent = TabPage

        local SubNavBottomBorder = Instance.new("Frame")
        SubNavBottomBorder.Size = UDim2.new(1, 0, 0, 1)
        SubNavBottomBorder.Position = UDim2.new(0, 0, 1, 0)
        SubNavBottomBorder.BackgroundColor3 = Theme.Separator
        SubNavBottomBorder.BorderSizePixel = 0
        SubNavBottomBorder.Parent = SubNavBar

        local SubNavList = Instance.new("Frame")
        SubNavList.Name = "SubNavList"
        SubNavList.Size = UDim2.new(1, -24, 1, 0)
        SubNavList.Position = UDim2.new(0, 16, 0, 0)
        SubNavList.BackgroundTransparency = 1
        SubNavList.Parent = SubNavBar

        local SubNavLayout = Instance.new("UIListLayout")
        SubNavLayout.FillDirection = Enum.FillDirection.Horizontal
        SubNavLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SubNavLayout.Padding = UDim.new(0, 20)
        SubNavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        SubNavLayout.Parent = SubNavList

        local SubTabContentArea = Instance.new("Frame")
        SubTabContentArea.Name = "SubTabContentArea"
        SubTabContentArea.Size = UDim2.new(1, 0, 1, -39)
        SubTabContentArea.Position = UDim2.new(0, 0, 0, 39)
        SubTabContentArea.BackgroundTransparency = 1
        SubTabContentArea.Parent = TabPage

        TabState.TabPage = TabPage
        TabState.SubNavList = SubNavList
        TabState.SubTabContentArea = SubTabContentArea

        local function SelectTab()
            for _, otherTab in ipairs(WindowState.Tabs) do
                otherTab.TabPage.Visible = false
                Tween(otherTab.Button, { BackgroundTransparency = 1 })
                Tween(otherTab.Icon, { ImageColor3 = Theme.TextMuted })
                Tween(otherTab.Label, { TextColor3 = Theme.TextMuted })
                Tween(otherTab.Indicator, { BackgroundTransparency = 1 })
            end

            TabPage.Visible = true
            Tween(TabButton, { BackgroundTransparency = 0.88, BackgroundColor3 = Theme.CardHover })
            Tween(TabIconImage, { ImageColor3 = Theme.AccentBright })
            Tween(TabLabel, { TextColor3 = Theme.AccentBright })
            Tween(IndicatorBar, { BackgroundTransparency = 0 })

            WindowState.CurrentTab = TabState

            if TabState.CurrentSubTab then
                TabState.CurrentSubTab:Select()
            elseif #TabState.SubTabs > 0 then
                TabState.SubTabs[1]:Select()
            end
        end

        TabButton.MouseEnter:Connect(function()
            if WindowState.CurrentTab ~= TabState then
                Tween(TabButton, { BackgroundTransparency = 0.92, BackgroundColor3 = Theme.CardHover })
                Tween(TabIconImage, { ImageColor3 = Theme.TextSecondary })
                Tween(TabLabel, { TextColor3 = Theme.TextSecondary })
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if WindowState.CurrentTab ~= TabState then
                Tween(TabButton, { BackgroundTransparency = 1 })
                Tween(TabIconImage, { ImageColor3 = Theme.TextMuted })
                Tween(TabLabel, { TextColor3 = Theme.TextMuted })
            end
        end)

        TabButton.MouseButton1Click:Connect(SelectTab)

        TabState.Button = TabButton
        TabState.Icon = TabIconImage
        TabState.Label = TabLabel
        TabState.Indicator = IndicatorBar
        TabState.Select = SelectTab

        table.insert(WindowState.Tabs, TabState)

        function TabState:CreateSubTab(subTabConfig)
            local subTabName = type(subTabConfig) == "string" and subTabConfig or subTabConfig.Name or "SubTab"

            local SubTabState = {
                Name = subTabName,
                Columns = {},
                Tab = TabState,
            }

            local textWidth = TextService:GetTextSize(subTabName, 13, Enum.Font.GothamMedium, Vector2.new(1000, 38)).X

            local SubTabButton = Instance.new("TextButton")
            SubTabButton.Name = "SubTabBtn_" .. subTabName
            SubTabButton.Size = UDim2.new(0, textWidth + 14, 1, 0)
            SubTabButton.BackgroundTransparency = 1
            SubTabButton.Text = subTabName
            SubTabButton.Font = Enum.Font.GothamMedium
            SubTabButton.TextSize = 13
            SubTabButton.TextColor3 = Theme.TextMuted
            SubTabButton.AutoButtonColor = false
            SubTabButton.Parent = SubNavList

            local SubIndicator = Instance.new("Frame")
            SubIndicator.Name = "SubIndicator"
            SubIndicator.Size = UDim2.new(1, 0, 0, 2)
            SubIndicator.Position = UDim2.new(0, 0, 1, -1)
            SubIndicator.BackgroundColor3 = Theme.AccentBright
            SubIndicator.BorderSizePixel = 0
            SubIndicator.BackgroundTransparency = 1
            SubIndicator.Parent = SubTabButton

            local SubIndicatorCorner = Instance.new("UICorner")
            SubIndicatorCorner.CornerRadius = UDim.new(0, 1)
            SubIndicatorCorner.Parent = SubIndicator

            local ContentScroll = Instance.new("ScrollingFrame")
            ContentScroll.Name = "ContentScroll_" .. subTabName
            ContentScroll.Size = UDim2.new(1, 0, 1, 0)
            ContentScroll.Position = UDim2.new(0, 0, 0, 0)
            ContentScroll.BackgroundTransparency = 1
            ContentScroll.BorderSizePixel = 0
            ContentScroll.ScrollBarImageColor3 = Theme.Scrollbar
            ContentScroll.ScrollBarImageTransparency = 0
            ContentScroll.ScrollBarThickness = 4
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ContentScroll.Visible = false
            ContentScroll.Parent = SubTabContentArea

            local ColumnsContainer = Instance.new("Frame")
            ColumnsContainer.Name = "ColumnsContainer"
            ColumnsContainer.Size = UDim2.new(1, -32, 1, -16)
            ColumnsContainer.Position = UDim2.new(0, 16, 0, 10)
            ColumnsContainer.BackgroundTransparency = 1
            ColumnsContainer.Parent = ContentScroll

            local ColumnsLayout = Instance.new("UIListLayout")
            ColumnsLayout.FillDirection = Enum.FillDirection.Horizontal
            ColumnsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ColumnsLayout.Padding = UDim.new(0, 18)
            ColumnsLayout.Parent = ColumnsContainer

            local function SelectSubTab()
                for _, otherSub in ipairs(TabState.SubTabs) do
                    otherSub.ContentScroll.Visible = false
                    Tween(otherSub.Button, { TextColor3 = Theme.TextMuted })
                    Tween(otherSub.Indicator, { BackgroundTransparency = 1 })
                end

                ContentScroll.Visible = true
                Tween(SubTabButton, { TextColor3 = Theme.TextPrimary })
                Tween(SubIndicator, { BackgroundTransparency = 0 })
                TabState.CurrentSubTab = SubTabState
            end

            SubTabButton.MouseEnter:Connect(function()
                if TabState.CurrentSubTab ~= SubTabState then
                    Tween(SubTabButton, { TextColor3 = Theme.TextSecondary })
                end
            end)

            SubTabButton.MouseLeave:Connect(function()
                if TabState.CurrentSubTab ~= SubTabState then
                    Tween(SubTabButton, { TextColor3 = Theme.TextMuted })
                end
            end)

            SubTabButton.MouseButton1Click:Connect(SelectSubTab)

            SubTabState.Button = SubTabButton
            SubTabState.Indicator = SubIndicator
            SubTabState.ContentScroll = ContentScroll
            SubTabState.ColumnsContainer = ColumnsContainer
            SubTabState.Select = SelectSubTab

            table.insert(TabState.SubTabs, SubTabState)

            function SubTabState:CreateSection(sectionConfig)
                local sectionName = type(sectionConfig) == "string" and sectionConfig or sectionConfig.Name or "Section"
                local order = sectionConfig.Order or #SubTabState.Columns + 1

                local SectionColumn = Instance.new("Frame")
                SectionColumn.Name = "Column_" .. sectionName
                SectionColumn.Size = UDim2.new(0.31, 0, 0, 0)
                SectionColumn.AutomaticSize = Enum.AutomaticSize.Y
                SectionColumn.BackgroundTransparency = 1
                SectionColumn.LayoutOrder = order
                SectionColumn.Parent = ColumnsContainer

                local SectionLayout = Instance.new("UIListLayout")
                SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
                SectionLayout.Padding = UDim.new(0, 9)
                SectionLayout.Parent = SectionColumn

                local SectionHeader = Instance.new("TextLabel")
                SectionHeader.Name = "SectionHeader"
                SectionHeader.Text = sectionName
                SectionHeader.Font = Enum.Font.GothamBold
                SectionHeader.TextSize = 13
                SectionHeader.TextColor3 = Theme.TextPrimary
                SectionHeader.TextXAlignment = Enum.TextXAlignment.Left
                SectionHeader.BackgroundTransparency = 1
                SectionHeader.Size = UDim2.new(1, 0, 0, 24)
                SectionHeader.LayoutOrder = 0
                SectionHeader.Parent = SectionColumn

                local SectionState = {
                    Column = SectionColumn,
                    Name = sectionName,
                    Tab = TabState,
                    SubTab = SubTabState,
                }

                table.insert(SubTabState.Columns, SectionState)

                function SectionState:AddToggle(toggleConfig)
                    local title = toggleConfig.Name or "Toggle"
                    local default = toggleConfig.Default or false
                    local callback = toggleConfig.Callback or function() end
                    local customTextColor = toggleConfig.TextColor or Theme.TextSecondary
                    local keybindDefault = toggleConfig.Keybind
                    local colorPickerDefaults = toggleConfig.ColorPickers

                    local ToggleRow = Instance.new("Frame")
                    ToggleRow.Name = "Toggle_" .. title
                    ToggleRow.Size = UDim2.new(1, 0, 0, 26)
                    ToggleRow.BackgroundTransparency = 1
                    ToggleRow.Parent = SectionColumn

                    local CheckBox = Instance.new("Frame")
                    CheckBox.Name = "CheckBox"
                    CheckBox.Size = UDim2.new(0, 16, 0, 16)
                    CheckBox.Position = UDim2.new(0, 0, 0.5, -8)
                    CheckBox.BackgroundColor3 = default and Theme.Accent or Theme.ControlBackground
                    CheckBox.BorderSizePixel = 0
                    CheckBox.Parent = ToggleRow

                    local CheckCorner = Instance.new("UICorner")
                    CheckCorner.CornerRadius = UDim.new(0, 3)
                    CheckCorner.Parent = CheckBox

                    local CheckStroke = Instance.new("UIStroke")
                    CheckStroke.Color = default and Theme.AccentBright or Theme.ControlBorder
                    CheckStroke.Thickness = 1
                    CheckStroke.Parent = CheckBox

                    local CheckIcon = Instance.new("ImageLabel")
                    CheckIcon.Name = "CheckIcon"
                    CheckIcon.Size = UDim2.new(0, 12, 0, 12)
                    CheckIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
                    CheckIcon.BackgroundTransparency = 1
                    CheckIcon.Image = ResolveIcon("checkmark")
                    CheckIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                    CheckIcon.ScaleType = Enum.ScaleType.Fit
                    CheckIcon.ImageTransparency = default and 0 or 1
                    CheckIcon.Parent = CheckBox

                    local LabelButton = Instance.new("TextButton")
                    LabelButton.Name = "LabelButton"
                    LabelButton.Size = UDim2.new(1, -85, 1, 0)
                    LabelButton.Position = UDim2.new(0, 24, 0, 0)
                    LabelButton.BackgroundTransparency = 1
                    LabelButton.Text = title
                    LabelButton.Font = Enum.Font.GothamMedium
                    LabelButton.TextSize = 12
                    LabelButton.TextColor3 = customTextColor
                    LabelButton.TextXAlignment = Enum.TextXAlignment.Left
                    LabelButton.AutoButtonColor = false
                    LabelButton.Parent = ToggleRow

                    local RightItemsContainer = Instance.new("Frame")
                    RightItemsContainer.Name = "RightItemsContainer"
                    RightItemsContainer.Size = UDim2.new(0, 80, 1, 0)
                    RightItemsContainer.Position = UDim2.new(1, -80, 0, 0)
                    RightItemsContainer.BackgroundTransparency = 1
                    RightItemsContainer.Parent = ToggleRow

                    local RightItemsLayout = Instance.new("UIListLayout")
                    RightItemsLayout.FillDirection = Enum.FillDirection.Horizontal
                    RightItemsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                    RightItemsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                    RightItemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    RightItemsLayout.Padding = UDim.new(0, 5)
                    RightItemsLayout.Parent = RightItemsContainer

                    local isChecked = default

                    local function SetState(val)
                        isChecked = val
                        if isChecked then
                            Tween(CheckBox, { BackgroundColor3 = Theme.Accent })
                            Tween(CheckStroke, { Color = Theme.AccentBright })
                            Tween(CheckIcon, { ImageTransparency = 0 })
                        else
                            Tween(CheckBox, { BackgroundColor3 = Theme.ControlBackground })
                            Tween(CheckStroke, { Color = Theme.ControlBorder })
                            Tween(CheckIcon, { ImageTransparency = 1 })
                        end
                        pcall(callback, isChecked)
                    end

                    local function Toggle()
                        SetState(not isChecked)
                    end

                    LabelButton.MouseButton1Click:Connect(Toggle)
                    
                    local ClickHitbox = Instance.new("TextButton")
                    ClickHitbox.Size = UDim2.new(1, 0, 1, 0)
                    ClickHitbox.BackgroundTransparency = 1
                    ClickHitbox.Text = ""
                    ClickHitbox.Parent = CheckBox
                    ClickHitbox.MouseButton1Click:Connect(Toggle)

                    table.insert(SearchableElements, {
                        Name = title,
                        Type = "Toggle",
                        Frame = ToggleRow,
                        Label = LabelButton,
                        OriginalColor = customTextColor,
                        Tab = TabState,
                        SubTab = SubTabState,
                        Section = SectionState,
                        Breadcrumb = tabName .. " > " .. subTabName .. " > " .. sectionName,
                    })

                    local ControlApi = {
                        Row = ToggleRow,
                        SetValue = SetState,
                        GetValue = function() return isChecked end,
                    }

                    if keybindDefault ~= nil then
                        local currentKey = keybindDefault == "None" and "None" or tostring(keybindDefault)
                        local isBinding = false

                        local KeybindPill = Instance.new("TextButton")
                        KeybindPill.Name = "KeybindPill"
                        KeybindPill.Size = UDim2.new(0, currentKey == "None" and 46 or 28, 0, 18)
                        KeybindPill.BackgroundColor3 = Theme.KeybindBackground
                        KeybindPill.BorderSizePixel = 0
                        KeybindPill.Text = ""
                        KeybindPill.AutoButtonColor = false
                        KeybindPill.Parent = RightItemsContainer

                        local PillCorner = Instance.new("UICorner")
                        PillCorner.CornerRadius = UDim.new(0, 4)
                        PillCorner.Parent = KeybindPill

                        local PillStroke = Instance.new("UIStroke")
                        PillStroke.Color = Theme.KeybindBorder
                        PillStroke.Thickness = 1
                        PillStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                        PillStroke.Parent = KeybindPill

                        local PillLayout = Instance.new("UIListLayout")
                        PillLayout.FillDirection = Enum.FillDirection.Horizontal
                        PillLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                        PillLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        PillLayout.Padding = UDim.new(0, 3)
                        PillLayout.Parent = KeybindPill

                        local KeyIcon = Instance.new("ImageLabel")
                        KeyIcon.Name = "KeyIcon"
                        KeyIcon.Size = UDim2.new(0, 10, 0, 10)
                        KeyIcon.BackgroundTransparency = 1
                        KeyIcon.Image = ResolveIcon("keyboard")
                        KeyIcon.ImageColor3 = Theme.KeybindText
                        KeyIcon.ScaleType = Enum.ScaleType.Fit
                        KeyIcon.Parent = KeybindPill

                        local KeyLabel = Instance.new("TextLabel")
                        KeyLabel.Name = "KeyLabel"
                        KeyLabel.Size = UDim2.new(0, 0, 1, 0)
                        KeyLabel.AutomaticSize = Enum.AutomaticSize.X
                        KeyLabel.BackgroundTransparency = 1
                        KeyLabel.Text = currentKey
                        KeyLabel.Font = Enum.Font.GothamBold
                        KeyLabel.TextSize = 10
                        KeyLabel.TextColor3 = Theme.KeybindText
                        KeyLabel.Parent = KeybindPill

                        local function UpdateKey(newKey)
                            currentKey = newKey
                            KeyLabel.Text = newKey
                            KeybindPill.Size = UDim2.new(0, newKey == "None" and 46 or (newKey == "..." and 32 or 28), 0, 18)
                        end

                        KeybindPill.MouseButton1Click:Connect(function()
                            if isBinding then return end
                            isBinding = true
                            UpdateKey("...")
                            Tween(PillStroke, { Color = Theme.AccentBright })

                            local connection
                            connection = UserInputService.InputBegan:Connect(function(input)
                                if input.UserInputType == Enum.UserInputType.Keyboard then
                                    local keyName = input.KeyCode.Name
                                    if input.KeyCode == Enum.KeyCode.Escape then
                                        keyName = "None"
                                    end
                                    UpdateKey(keyName)
                                    isBinding = false
                                    Tween(PillStroke, { Color = Theme.KeybindBorder })
                                    connection:Disconnect()
                                end
                            end)
                        end)

                        ControlApi.Keybind = {
                            GetKey = function() return currentKey end,
                            SetKey = UpdateKey,
                        }
                    end

                    if colorPickerDefaults ~= nil then
                        local colorList = type(colorPickerDefaults) == "table" and colorPickerDefaults or { colorPickerDefaults }
                        ControlApi.ColorPickers = {}

                        for i, initColor in ipairs(colorList) do
                            local currentColor = initColor

                            local BrushBtn = Instance.new("TextButton")
                            BrushBtn.Name = "ColorBrush_" .. i
                            BrushBtn.Size = UDim2.new(0, 18, 0, 18)
                            BrushBtn.BackgroundColor3 = Theme.ControlBackground
                            BrushBtn.BorderSizePixel = 0
                            BrushBtn.Text = ""
                            BrushBtn.AutoButtonColor = false
                            BrushBtn.Parent = RightItemsContainer

                            local BrushCorner = Instance.new("UICorner")
                            BrushCorner.CornerRadius = UDim.new(0, 4)
                            BrushCorner.Parent = BrushBtn

                            local BrushStroke = Instance.new("UIStroke")
                            BrushStroke.Color = Theme.ControlBorder
                            BrushStroke.Thickness = 1
                            BrushStroke.Parent = BrushBtn

                            local BrushIcon = Instance.new("ImageLabel")
                            BrushIcon.Name = "BrushIcon"
                            BrushIcon.Size = UDim2.new(0, 13, 0, 13)
                            BrushIcon.Position = UDim2.new(0.5, -6.5, 0.5, -6.5)
                            BrushIcon.BackgroundTransparency = 1
                            BrushIcon.Image = ResolveIcon("paintbrush")
                            BrushIcon.ImageColor3 = currentColor
                            BrushIcon.ScaleType = Enum.ScaleType.Fit
                            BrushIcon.Parent = BrushBtn

                            local function OnColorSelected(newCol)
                                currentColor = newCol
                                BrushIcon.ImageColor3 = newCol
                            end

                            BrushBtn.MouseButton1Click:Connect(function()
                                OpenInteractiveColorPicker(title .. " Color " .. i, currentColor, OnColorSelected, BrushBtn)
                            end)

                            BrushBtn.MouseEnter:Connect(function()
                                Tween(BrushStroke, { Color = Theme.AccentBright })
                            end)
                            BrushBtn.MouseLeave:Connect(function()
                                Tween(BrushStroke, { Color = Theme.ControlBorder })
                            end)

                            table.insert(ControlApi.ColorPickers, {
                                GetColor = function() return currentColor end,
                                SetColor = function(newCol)
                                    currentColor = newCol
                                    BrushIcon.ImageColor3 = newCol
                                end,
                            })
                        end
                    end

                    return ControlApi
                end

                function SectionState:AddColorPicker(colorConfig)
                    local title = colorConfig.Name or "Color Picker"
                    local default = colorConfig.Default or Color3.fromRGB(0, 180, 255)
                    local callback = colorConfig.Callback or function() end

                    local ColorRow = Instance.new("Frame")
                    ColorRow.Name = "ColorPickerRow_" .. title
                    ColorRow.Size = UDim2.new(1, 0, 0, 26)
                    ColorRow.BackgroundTransparency = 1
                    ColorRow.Parent = SectionColumn

                    local Label = Instance.new("TextLabel")
                    Label.Name = "Label"
                    Label.Text = title
                    Label.Font = Enum.Font.GothamMedium
                    Label.TextSize = 12
                    Label.TextColor3 = Theme.TextSecondary
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.BackgroundTransparency = 1
                    Label.Size = UDim2.new(1, -30, 1, 0)
                    Label.Position = UDim2.new(0, 0, 0, 0)
                    Label.Parent = ColorRow

                    local BrushBtn = Instance.new("TextButton")
                    BrushBtn.Name = "ColorBrushBtn"
                    BrushBtn.Size = UDim2.new(0, 18, 0, 18)
                    BrushBtn.Position = UDim2.new(1, -20, 0.5, -9)
                    BrushBtn.BackgroundColor3 = Theme.ControlBackground
                    BrushBtn.BorderSizePixel = 0
                    BrushBtn.Text = ""
                    BrushBtn.AutoButtonColor = false
                    BrushBtn.Parent = ColorRow

                    local BrushCorner = Instance.new("UICorner")
                    BrushCorner.CornerRadius = UDim.new(0, 4)
                    BrushCorner.Parent = BrushBtn

                    local BrushStroke = Instance.new("UIStroke")
                    BrushStroke.Color = Theme.ControlBorder
                    BrushStroke.Thickness = 1
                    BrushStroke.Parent = BrushBtn

                    local BrushIcon = Instance.new("ImageLabel")
                    BrushIcon.Name = "BrushIcon"
                    BrushIcon.Size = UDim2.new(0, 13, 0, 13)
                    BrushIcon.Position = UDim2.new(0.5, -6.5, 0.5, -6.5)
                    BrushIcon.BackgroundTransparency = 1
                    BrushIcon.Image = ResolveIcon("paintbrush")
                    BrushIcon.ImageColor3 = default
                    BrushIcon.ScaleType = Enum.ScaleType.Fit
                    BrushIcon.Parent = BrushBtn

                    local currentColor = default

                    local function OnColorSelected(newCol)
                        currentColor = newCol
                        BrushIcon.ImageColor3 = newCol
                        pcall(callback, newCol)
                    end

                    BrushBtn.MouseButton1Click:Connect(function()
                        OpenInteractiveColorPicker(title, currentColor, OnColorSelected, BrushBtn)
                    end)

                    BrushBtn.MouseEnter:Connect(function()
                        Tween(BrushStroke, { Color = Theme.AccentBright })
                    end)
                    BrushBtn.MouseLeave:Connect(function()
                        Tween(BrushStroke, { Color = Theme.ControlBorder })
                    end)

                    table.insert(SearchableElements, {
                        Name = title,
                        Type = "ColorPicker",
                        Frame = ColorRow,
                        Label = Label,
                        OriginalColor = Theme.TextSecondary,
                        Tab = TabState,
                        SubTab = SubTabState,
                        Section = SectionState,
                        Breadcrumb = tabName .. " > " .. subTabName .. " > " .. sectionName,
                    })

                    return {
                        Row = ColorRow,
                        GetColor = function() return currentColor end,
                        SetColor = function(newCol)
                            currentColor = newCol
                            BrushIcon.ImageColor3 = newCol
                            pcall(callback, newCol)
                        end,
                    }
                end

                function SectionState:AddSlider(sliderConfig)
                    local title = sliderConfig.Name or "Slider"
                    local min = sliderConfig.Min or 0
                    local max = sliderConfig.Max or 100
                    local default = sliderConfig.Default or min
                    local step = sliderConfig.Step or 1
                    local callback = sliderConfig.Callback or function() end

                    local SliderContainer = Instance.new("Frame")
                    SliderContainer.Name = "Slider_" .. title
                    SliderContainer.Size = UDim2.new(1, 0, 0, 40)
                    SliderContainer.BackgroundTransparency = 1
                    SliderContainer.Parent = SectionColumn

                    local Label = Instance.new("TextLabel")
                    Label.Name = "Label"
                    Label.Text = title
                    Label.Font = Enum.Font.GothamMedium
                    Label.TextSize = 12
                    Label.TextColor3 = Theme.TextSecondary
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.BackgroundTransparency = 1
                    Label.Size = UDim2.new(1, -50, 0, 16)
                    Label.Position = UDim2.new(0, 0, 0, 0)
                    Label.Parent = SliderContainer

                    local ValueLabel = Instance.new("TextLabel")
                    ValueLabel.Name = "ValueLabel"
                    ValueLabel.Text = tostring(default)
                    ValueLabel.Font = Enum.Font.GothamBold
                    ValueLabel.TextSize = 12
                    ValueLabel.TextColor3 = Theme.TextPrimary
                    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                    ValueLabel.BackgroundTransparency = 1
                    ValueLabel.Size = UDim2.new(0, 50, 0, 16)
                    ValueLabel.Position = UDim2.new(1, -50, 0, 0)
                    ValueLabel.Parent = SliderContainer

                    local Track = Instance.new("Frame")
                    Track.Name = "Track"
                    Track.Size = UDim2.new(1, 0, 0, 4)
                    Track.Position = UDim2.new(0, 0, 0, 26)
                    Track.BackgroundColor3 = Theme.ControlBackground
                    Track.BorderSizePixel = 0
                    Track.Parent = SliderContainer

                    local TrackCorner = Instance.new("UICorner")
                    TrackCorner.CornerRadius = UDim.new(1, 0)
                    TrackCorner.Parent = Track

                    local Fill = Instance.new("Frame")
                    Fill.Name = "Fill"
                    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                    Fill.BackgroundColor3 = Theme.AccentBright
                    Fill.BorderSizePixel = 0
                    Fill.Parent = Track

                    local FillCorner = Instance.new("UICorner")
                    FillCorner.CornerRadius = UDim.new(1, 0)
                    FillCorner.Parent = Fill

                    local Knob = Instance.new("Frame")
                    Knob.Name = "Knob"
                    Knob.Size = UDim2.new(0, 10, 0, 10)
                    Knob.Position = UDim2.new(1, -5, 0.5, -5)
                    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    Knob.BorderSizePixel = 0
                    Knob.Parent = Fill

                    local KnobCorner = Instance.new("UICorner")
                    KnobCorner.CornerRadius = UDim.new(1, 0)
                    KnobCorner.Parent = Knob

                    local KnobStroke = Instance.new("UIStroke")
                    KnobStroke.Color = Theme.AccentBright
                    KnobStroke.Thickness = 1.5
                    KnobStroke.Parent = Knob

                    local isDragging = false
                    local currentValue = default

                    local function UpdateSlider(inputX)
                        local trackAbsPos = Track.AbsolutePosition.X
                        local trackAbsSize = Track.AbsoluteSize.X
                        local relX = math.clamp(inputX - trackAbsPos, 0, trackAbsSize)
                        local ratio = relX / trackAbsSize

                        local rawVal = min + (max - min) * ratio
                        local roundedVal
                        if step < 1 then
                            local decimals = tostring(step):match("%.(%d+)") and #tostring(step):match("%.(%d+)") or 1
                            roundedVal = math.floor(rawVal / step + 0.5) * step
                            ValueLabel.Text = string.format("%." .. decimals .. "f", roundedVal)
                        else
                            roundedVal = math.floor(rawVal / step + 0.5) * step
                            ValueLabel.Text = tostring(math.floor(roundedVal))
                        end

                        currentValue = roundedVal
                        Fill.Size = UDim2.new(ratio, 0, 1, 0)
                        pcall(callback, currentValue)
                    end

                    local Hitbox = Instance.new("TextButton")
                    Hitbox.Name = "SliderHitbox"
                    Hitbox.Size = UDim2.new(1, 0, 0, 18)
                    Hitbox.Position = UDim2.new(0, 0, 0, 19)
                    Hitbox.BackgroundTransparency = 1
                    Hitbox.Text = ""
                    Hitbox.Parent = SliderContainer

                    Hitbox.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            isDragging = true
                            UpdateSlider(input.Position.X)
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            isDragging = false
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            UpdateSlider(input.Position.X)
                        end
                    end)

                    table.insert(SearchableElements, {
                        Name = title,
                        Type = "Slider",
                        Frame = SliderContainer,
                        Label = Label,
                        OriginalColor = Theme.TextSecondary,
                        Tab = TabState,
                        SubTab = SubTabState,
                        Section = SectionState,
                        Breadcrumb = tabName .. " > " .. subTabName .. " > " .. sectionName,
                    })

                    return {
                        Container = SliderContainer,
                        GetValue = function() return currentValue end,
                        SetValue = function(val)
                            currentValue = math.clamp(val, min, max)
                            local ratio = (currentValue - min) / (max - min)
                            Fill.Size = UDim2.new(ratio, 0, 1, 0)
                            ValueLabel.Text = tostring(currentValue)
                            pcall(callback, currentValue)
                        end,
                    }
                end

                function SectionState:AddDropdown(dropdownConfig)
                    local title = dropdownConfig.Name or "Dropdown"
                    local options = dropdownConfig.Options or {}
                    local default = dropdownConfig.Default or options[1] or "Select"
                    local callback = dropdownConfig.Callback or function() end

                    local DropdownContainer = Instance.new("Frame")
                    DropdownContainer.Name = "Dropdown_" .. title
                    DropdownContainer.Size = UDim2.new(1, 0, 0, 54)
                    DropdownContainer.BackgroundTransparency = 1
                    DropdownContainer.Parent = SectionColumn

                    local Label = Instance.new("TextLabel")
                    Label.Name = "Label"
                    Label.Text = title
                    Label.Font = Enum.Font.GothamMedium
                    Label.TextSize = 12
                    Label.TextColor3 = Theme.TextSecondary
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.BackgroundTransparency = 1
                    Label.Size = UDim2.new(1, 0, 0, 16)
                    Label.Parent = DropdownContainer

                    local SelectBox = Instance.new("TextButton")
                    SelectBox.Name = "SelectBox"
                    SelectBox.Size = UDim2.new(1, 0, 0, 30)
                    SelectBox.Position = UDim2.new(0, 0, 0, 21)
                    SelectBox.BackgroundColor3 = Theme.ControlBackground
                    SelectBox.BorderSizePixel = 0
                    SelectBox.AutoButtonColor = false
                    SelectBox.Text = ""
                    SelectBox.Parent = DropdownContainer

                    local BoxCorner = Instance.new("UICorner")
                    BoxCorner.CornerRadius = UDim.new(0, 5)
                    BoxCorner.Parent = SelectBox

                    local BoxStroke = Instance.new("UIStroke")
                    BoxStroke.Color = Theme.ControlBorder
                    BoxStroke.Thickness = 1
                    BoxStroke.Parent = SelectBox

                    local SelectedText = Instance.new("TextLabel")
                    SelectedText.Name = "SelectedText"
                    SelectedText.Text = default
                    SelectedText.Font = Enum.Font.GothamMedium
                    SelectedText.TextSize = 12
                    SelectedText.TextColor3 = Theme.TextPrimary
                    SelectedText.TextXAlignment = Enum.TextXAlignment.Left
                    SelectedText.BackgroundTransparency = 1
                    SelectedText.Size = UDim2.new(1, -28, 1, 0)
                    SelectedText.Position = UDim2.new(0, 10, 0, 0)
                    SelectedText.Parent = SelectBox

                    local ChevronIcon = Instance.new("ImageLabel")
                    ChevronIcon.Name = "ChevronIcon"
                    ChevronIcon.Size = UDim2.new(0, 14, 0, 14)
                    ChevronIcon.Position = UDim2.new(1, -20, 0.5, -7)
                    ChevronIcon.BackgroundTransparency = 1
                    ChevronIcon.Image = ResolveIcon("chevron")
                    ChevronIcon.ImageColor3 = Theme.TextMuted
                    ChevronIcon.ScaleType = Enum.ScaleType.Fit
                    ChevronIcon.Parent = SelectBox

                    local isOpen = false
                    local currentSelected = default

                    SelectBox.MouseEnter:Connect(function()
                        Tween(BoxStroke, { Color = Theme.ControlBorderHover })
                    end)

                    SelectBox.MouseLeave:Connect(function()
                        if not isOpen then
                            Tween(BoxStroke, { Color = Theme.ControlBorder })
                        end
                    end)

                    local function ToggleDropdown()
                        isOpen = not isOpen
                        local existingList = PopupsLayer:FindFirstChild("DropdownList_" .. title)
                        if existingList then
                            existingList:Destroy()
                        end

                        if isOpen then
                            Tween(BoxStroke, { Color = Theme.AccentBright })
                            Tween(ChevronIcon, { Rotation = 180, ImageColor3 = Theme.AccentBright })

                            local absPos = SelectBox.AbsolutePosition
                            local mainPos = MainFrame.AbsolutePosition

                            local ListPopup = Instance.new("Frame")
                            ListPopup.Name = "DropdownList_" .. title
                            ListPopup.Size = UDim2.new(0, SelectBox.AbsoluteSize.X, 0, math.min(#options * 28 + 6, 150))
                            ListPopup.Position = UDim2.new(0, absPos.X - mainPos.X, 0, absPos.Y - mainPos.Y + 34)
                            ListPopup.BackgroundColor3 = Theme.CardBackground
                            ListPopup.BorderSizePixel = 0
                            ListPopup.ZIndex = 65
                            ListPopup.Parent = PopupsLayer

                            local ListCorner = Instance.new("UICorner")
                            ListCorner.CornerRadius = UDim.new(0, 5)
                            ListCorner.Parent = ListPopup

                            local ListStroke = Instance.new("UIStroke")
                            ListStroke.Color = Theme.AccentBright
                            ListStroke.Thickness = 1
                            ListStroke.Parent = ListPopup

                            local Scroll = Instance.new("ScrollingFrame")
                            Scroll.Size = UDim2.new(1, 0, 1, 0)
                            Scroll.BackgroundTransparency = 1
                            Scroll.BorderSizePixel = 0
                            Scroll.ScrollBarThickness = 3
                            Scroll.ScrollBarImageColor3 = Theme.Scrollbar
                            Scroll.ScrollBarImageTransparency = 0
                            Scroll.CanvasSize = UDim2.new(0, 0, 0, #options * 28 + 4)
                            Scroll.Parent = ListPopup

                            local SLayout = Instance.new("UIListLayout")
                            SLayout.Padding = UDim.new(0, 2)
                            SLayout.Parent = Scroll

                            local SPad = Instance.new("UIPadding")
                            SPad.PaddingTop = UDim.new(0, 2)
                            SPad.PaddingLeft = UDim.new(0, 4)
                            SPad.PaddingRight = UDim.new(0, 4)
                            SPad.Parent = Scroll

                            for _, opt in ipairs(options) do
                                local ItemBtn = Instance.new("TextButton")
                                ItemBtn.Name = "Option_" .. opt
                                ItemBtn.Size = UDim2.new(1, 0, 0, 26)
                                ItemBtn.BackgroundColor3 = (opt == currentSelected) and Theme.CardHover or Theme.CardBackground
                                ItemBtn.BorderSizePixel = 0
                                ItemBtn.Text = "  " .. opt
                                ItemBtn.Font = Enum.Font.GothamMedium
                                ItemBtn.TextSize = 11
                                ItemBtn.TextColor3 = (opt == currentSelected) and Theme.AccentBright or Theme.TextSecondary
                                ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
                                ItemBtn.AutoButtonColor = false
                                ItemBtn.Parent = Scroll

                                local IBCorner = Instance.new("UICorner")
                                IBCorner.CornerRadius = UDim.new(0, 4)
                                IBCorner.Parent = ItemBtn

                                ItemBtn.MouseEnter:Connect(function()
                                    Tween(ItemBtn, { BackgroundColor3 = Theme.CardHover, TextColor3 = Theme.TextPrimary })
                                end)

                                ItemBtn.MouseLeave:Connect(function()
                                    Tween(ItemBtn, {
                                        BackgroundColor3 = (opt == currentSelected) and Theme.CardHover or Theme.CardBackground,
                                        TextColor3 = (opt == currentSelected) and Theme.AccentBright or Theme.TextSecondary
                                    })
                                end)

                                ItemBtn.MouseButton1Click:Connect(function()
                                    currentSelected = opt
                                    SelectedText.Text = opt
                                    isOpen = false
                                    ListPopup:Destroy()
                                    Tween(BoxStroke, { Color = Theme.ControlBorder })
                                    Tween(ChevronIcon, { Rotation = 0, ImageColor3 = Theme.TextMuted })
                                    pcall(callback, currentSelected)
                                end)
                            end
                        else
                            Tween(BoxStroke, { Color = Theme.ControlBorder })
                            Tween(ChevronIcon, { Rotation = 0, ImageColor3 = Theme.TextMuted })
                        end
                    end

                    SelectBox.MouseButton1Click:Connect(ToggleDropdown)

                    table.insert(SearchableElements, {
                        Name = title,
                        Type = "Dropdown",
                        Frame = DropdownContainer,
                        Label = Label,
                        OriginalColor = Theme.TextSecondary,
                        Tab = TabState,
                        SubTab = SubTabState,
                        Section = SectionState,
                        Breadcrumb = tabName .. " > " .. subTabName .. " > " .. sectionName,
                    })

                    return {
                        Container = DropdownContainer,
                        GetValue = function() return currentSelected end,
                        SetValue = function(newVal)
                            currentSelected = newVal
                            SelectedText.Text = newVal
                            pcall(callback, newVal)
                        end,
                    }
                end

                function SectionState:AddButton(buttonConfig)
                    local title = buttonConfig.Name or "Button"
                    local callback = buttonConfig.Callback or function() end

                    local Btn = Instance.new("TextButton")
                    Btn.Name = "Button_" .. title
                    Btn.Size = UDim2.new(1, 0, 0, 30)
                    Btn.BackgroundColor3 = Theme.ControlBackground
                    Btn.BorderSizePixel = 0
                    Btn.Text = title
                    Btn.Font = Enum.Font.GothamMedium
                    Btn.TextSize = 12
                    Btn.TextColor3 = Theme.TextPrimary
                    Btn.AutoButtonColor = false
                    Btn.Parent = SectionColumn

                    local BCorner = Instance.new("UICorner")
                    BCorner.CornerRadius = UDim.new(0, 5)
                    BCorner.Parent = Btn

                    local BStroke = Instance.new("UIStroke")
                    BStroke.Color = Theme.ControlBorder
                    BStroke.Thickness = 1
                    BStroke.Parent = Btn

                    Btn.MouseEnter:Connect(function()
                        Tween(Btn, { BackgroundColor3 = Theme.CardHover })
                        Tween(BStroke, { Color = Theme.AccentBright })
                    end)

                    Btn.MouseLeave:Connect(function()
                        Tween(Btn, { BackgroundColor3 = Theme.ControlBackground })
                        Tween(BStroke, { Color = Theme.ControlBorder })
                    end)

                    Btn.MouseButton1Click:Connect(function()
                        Tween(Btn, { BackgroundColor3 = Theme.AccentDark })
                        task.wait(0.08)
                        Tween(Btn, { BackgroundColor3 = Theme.CardHover })
                        pcall(callback)
                    end)

                    table.insert(SearchableElements, {
                        Name = title,
                        Type = "Button",
                        Frame = Btn,
                        Label = Btn,
                        OriginalColor = Theme.TextPrimary,
                        Tab = TabState,
                        SubTab = SubTabState,
                        Section = SectionState,
                        Breadcrumb = tabName .. " > " .. subTabName .. " > " .. sectionName,
                    })

                    return Btn
                end

                return SectionState
            end

            return SubTabState
        end

        if #WindowState.Tabs == 1 then
            TabState:Select()
        end

        return TabState
    end

    return WindowState
end

return KW
