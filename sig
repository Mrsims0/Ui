local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

local Ignite = {}
Ignite.__index = Ignite

local GITHUB_ICONS_BASE = "https://raw.githubusercontent.com/Mrsims0/Ui/main/gig/"

local IconList = {
    "checkmark.png",
    "chevron.png",
    "eye.png",
    "flame.png",
    "gear.png",
    "keyboard.png",
    "rifle.png",
    "search.png",
    "sword.png",
    "target.png",
}

local Theme = {
    MainBackground       = Color3.fromRGB(18, 18, 20),
    TitleBarBackground   = Color3.fromRGB(15, 15, 17),
    SidebarBackground    = Color3.fromRGB(14, 14, 16),
    CardBackground       = Color3.fromRGB(20, 20, 24),
    CardHover            = Color3.fromRGB(26, 26, 32),
    ControlBackground    = Color3.fromRGB(20, 20, 24),
    ControlBorder        = Color3.fromRGB(34, 34, 40),
    ControlBorderHover   = Color3.fromRGB(50, 50, 60),
    
    Accent               = Color3.fromRGB(0, 170, 255),
    AccentGlow           = Color3.fromRGB(0, 195, 255),
    AccentDark           = Color3.fromRGB(0, 120, 190),
    
    HighlightYellow      = Color3.fromRGB(255, 195, 50),
    
    TextPrimary          = Color3.fromRGB(255, 255, 255),
    TextSecondary        = Color3.fromRGB(185, 185, 195),
    TextMuted            = Color3.fromRGB(120, 120, 130),
    TextDark             = Color3.fromRGB(75, 75, 85),
    
    KeybindBackground    = Color3.fromRGB(14, 28, 44),
    KeybindBorder        = Color3.fromRGB(0, 110, 190),
    KeybindText          = Color3.fromRGB(140, 215, 255),
    
    Separator            = Color3.fromRGB(26, 26, 30),
    Border               = Color3.fromRGB(30, 30, 36),
    Scrollbar            = Color3.fromRGB(0, 170, 255),
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

function Ignite:CreateWindow(options)
    options = options or {}
    local windowTitle = options.Title or "Ignite"
    local windowVersion = options.Version or "v1.0.5"
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "IgniteGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = GetSafeGuiParent()

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 780, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -390, 0.5, -260)
    MainFrame.BackgroundColor3 = Theme.MainBackground
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui

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
    TitleBar.Size = UDim2.new(1, 0, 0, 48)
    TitleBar.BackgroundColor3 = Theme.TitleBarBackground
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 8)
    TitleBarCorner.Parent = TitleBar

    local TitleBarBottomCover = Instance.new("Frame")
    TitleBarBottomCover.Size = UDim2.new(1, 0, 0, 10)
    TitleBarBottomCover.Position = UDim2.new(0, 0, 1, -10)
    TitleBarBottomCover.BackgroundColor3 = Theme.TitleBarBackground
    TitleBarBottomCover.BorderSizePixel = 0
    TitleBarBottomCover.Parent = TitleBar

    local TitleBarBorder = Instance.new("Frame")
    TitleBarBorder.Size = UDim2.new(1, 0, 0, 1)
    TitleBarBorder.Position = UDim2.new(0, 0, 1, 0)
    TitleBarBorder.BackgroundColor3 = Theme.Separator
    TitleBarBorder.BorderSizePixel = 0
    TitleBarBorder.Parent = TitleBar

    EnableDragging(MainFrame, TitleBar)

    local LogoIcon = Instance.new("ImageLabel")
    LogoIcon.Name = "LogoIcon"
    LogoIcon.Size = UDim2.new(0, 22, 0, 22)
    LogoIcon.Position = UDim2.new(0, 14, 0.5, -11)
    LogoIcon.BackgroundTransparency = 1
    LogoIcon.Image = ResolveIcon("flame")
    LogoIcon.ImageColor3 = Theme.Accent
    LogoIcon.ScaleType = Enum.ScaleType.Fit
    LogoIcon.Parent = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Text = windowTitle
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 15
    TitleLabel.TextColor3 = Theme.TextPrimary
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(0, 50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 42, 0, 0)
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
    VersionLabel.Position = UDim2.new(0, 94, 0, 0)
    VersionLabel.Parent = TitleBar

    local SearchContainer = Instance.new("Frame")
    SearchContainer.Name = "SearchContainer"
    SearchContainer.Size = UDim2.new(0, 190, 0, 28)
    SearchContainer.Position = UDim2.new(1, -204, 0.5, -14)
    SearchContainer.BackgroundColor3 = Theme.ControlBackground
    SearchContainer.BorderSizePixel = 0
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
    SearchIcon.Position = UDim2.new(0, 8, 0.5, -7)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Image = ResolveIcon("search")
    SearchIcon.ImageColor3 = Theme.TextMuted
    SearchIcon.ScaleType = Enum.ScaleType.Fit
    SearchIcon.Parent = SearchContainer

    local SearchInput = Instance.new("TextBox")
    SearchInput.Name = "SearchInput"
    SearchInput.Size = UDim2.new(1, -30, 1, 0)
    SearchInput.Position = UDim2.new(0, 26, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.PlaceholderText = "Search..."
    SearchInput.PlaceholderColor3 = Theme.TextDark
    SearchInput.Text = ""
    SearchInput.TextColor3 = Theme.TextPrimary
    SearchInput.TextSize = 12
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    SearchInput.ClearTextOnFocus = false
    SearchInput.Parent = SearchContainer

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 84, 1, -48)
    Sidebar.Position = UDim2.new(0, 0, 0, 48)
    Sidebar.BackgroundColor3 = Theme.SidebarBackground
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 8)
    SidebarCorner.Parent = Sidebar

    local SidebarRightCover = Instance.new("Frame")
    SidebarRightCover.Size = UDim2.new(0, 10, 1, 0)
    SidebarRightCover.Position = UDim2.new(1, -10, 0, 0)
    SidebarRightCover.BackgroundColor3 = Theme.SidebarBackground
    SidebarRightCover.BorderSizePixel = 0
    SidebarRightCover.Parent = Sidebar

    local SidebarTopCover = Instance.new("Frame")
    SidebarTopCover.Size = UDim2.new(1, 0, 0, 10)
    SidebarTopCover.Position = UDim2.new(0, 0, 0, 0)
    SidebarTopCover.BackgroundColor3 = Theme.SidebarBackground
    SidebarTopCover.BorderSizePixel = 0
    SidebarTopCover.Parent = Sidebar

    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Name = "SidebarDivider"
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
    SidebarDivider.BackgroundColor3 = Theme.Separator
    SidebarDivider.BorderSizePixel = 0
    SidebarDivider.Parent = Sidebar

    local TabButtonsHolder = Instance.new("ScrollingFrame")
    TabButtonsHolder.Name = "TabButtonsHolder"
    TabButtonsHolder.Size = UDim2.new(1, 0, 1, -10)
    TabButtonsHolder.Position = UDim2.new(0, 0, 0, 8)
    TabButtonsHolder.BackgroundTransparency = 1
    TabButtonsHolder.BorderSizePixel = 0
    TabButtonsHolder.ScrollBarThickness = 0
    TabButtonsHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabButtonsHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabButtonsHolder.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.Parent = TabButtonsHolder

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -85, 1, -48)
    ContentArea.Position = UDim2.new(0, 85, 0, 48)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local PopupsLayer = Instance.new("Frame")
    PopupsLayer.Name = "PopupsLayer"
    PopupsLayer.Size = UDim2.new(1, 0, 1, 0)
    PopupsLayer.BackgroundTransparency = 1
    PopupsLayer.ZIndex = 50
    PopupsLayer.Parent = MainFrame

    local WindowState = {
        Tabs = {},
        CurrentTab = nil,
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        PopupsLayer = PopupsLayer,
        SearchQuery = "",
    }

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchInput.Text)
        WindowState.SearchQuery = query

        for _, item in ipairs(SearchableElements) do
            if query == "" then
                item.Frame.Visible = true
                if item.Label then
                    item.Label.TextColor3 = item.OriginalColor or Theme.TextSecondary
                end
            else
                local match = string.find(string.lower(item.Name), query, 1, true) ~= nil
                item.Frame.Visible = match
                if match and item.Label then
                    item.Label.TextColor3 = Theme.Accent
                elseif item.Label then
                    item.Label.TextColor3 = item.OriginalColor or Theme.TextSecondary
                end
            end
        end
    end)

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
        TabButton.Size = UDim2.new(0, 72, 0, 56)
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
        IndicatorBar.Size = UDim2.new(0, 32, 0, 2)
        IndicatorBar.Position = UDim2.new(0.5, -16, 1, -4)
        IndicatorBar.BackgroundColor3 = Theme.Accent
        IndicatorBar.BorderSizePixel = 0
        IndicatorBar.BackgroundTransparency = 1
        IndicatorBar.Parent = TabButton

        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 2)
        IndicatorCorner.Parent = IndicatorBar

        local TabIconImage = Instance.new("ImageLabel")
        TabIconImage.Name = "TabIcon"
        TabIconImage.Size = UDim2.new(0, 20, 0, 20)
        TabIconImage.Position = UDim2.new(0.5, -10, 0, 8)
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
        TabLabel.Position = UDim2.new(0, 0, 0, 32)
        TabLabel.Parent = TabButton

        local TabPage = Instance.new("Frame")
        TabPage.Name = "TabPage_" .. tabName
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.Parent = ContentArea

        local SubNavBar = Instance.new("Frame")
        SubNavBar.Name = "SubNavBar"
        SubNavBar.Size = UDim2.new(1, 0, 0, 36)
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
        SubNavList.Size = UDim2.new(1, -20, 1, 0)
        SubNavList.Position = UDim2.new(0, 14, 0, 0)
        SubNavList.BackgroundTransparency = 1
        SubNavList.Parent = SubNavBar

        local SubNavLayout = Instance.new("UIListLayout")
        SubNavLayout.FillDirection = Enum.FillDirection.Horizontal
        SubNavLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SubNavLayout.Padding = UDim.new(0, 18)
        SubNavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        SubNavLayout.Parent = SubNavList

        local SubTabContentArea = Instance.new("Frame")
        SubTabContentArea.Name = "SubTabContentArea"
        SubTabContentArea.Size = UDim2.new(1, 0, 1, -37)
        SubTabContentArea.Position = UDim2.new(0, 0, 0, 37)
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
            Tween(TabIconImage, { ImageColor3 = Theme.Accent })
            Tween(TabLabel, { TextColor3 = Theme.Accent })
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
            }

            local textWidth = TextService:GetTextSize(subTabName, 13, Enum.Font.GothamMedium, Vector2.new(1000, 36)).X

            local SubTabButton = Instance.new("TextButton")
            SubTabButton.Name = "SubTabBtn_" .. subTabName
            SubTabButton.Size = UDim2.new(0, textWidth + 12, 1, 0)
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
            SubIndicator.BackgroundColor3 = Theme.Accent
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
            ContentScroll.ScrollBarThickness = 3
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
            ContentScroll.Visible = false
            ContentScroll.Parent = SubTabContentArea

            local ColumnsContainer = Instance.new("Frame")
            ColumnsContainer.Name = "ColumnsContainer"
            ColumnsContainer.Size = UDim2.new(1, -20, 1, -10)
            ColumnsContainer.Position = UDim2.new(0, 12, 0, 10)
            ColumnsContainer.BackgroundTransparency = 1
            ColumnsContainer.Parent = ContentScroll

            local ColumnsLayout = Instance.new("UIListLayout")
            ColumnsLayout.FillDirection = Enum.FillDirection.Horizontal
            ColumnsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ColumnsLayout.Padding = UDim.new(0, 14)
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
                SectionColumn.Size = UDim2.new(0.315, 0, 0, 0)
                SectionColumn.AutomaticSize = Enum.AutomaticSize.Y
                SectionColumn.BackgroundTransparency = 1
                SectionColumn.LayoutOrder = order
                SectionColumn.Parent = ColumnsContainer

                local SectionLayout = Instance.new("UIListLayout")
                SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
                SectionLayout.Padding = UDim.new(0, 8)
                SectionLayout.Parent = SectionColumn

                local SectionHeader = Instance.new("TextLabel")
                SectionHeader.Name = "SectionHeader"
                SectionHeader.Text = sectionName
                SectionHeader.Font = Enum.Font.GothamBold
                SectionHeader.TextSize = 13
                SectionHeader.TextColor3 = Theme.TextPrimary
                SectionHeader.TextXAlignment = Enum.TextXAlignment.Left
                SectionHeader.BackgroundTransparency = 1
                SectionHeader.Size = UDim2.new(1, 0, 0, 22)
                SectionHeader.LayoutOrder = 0
                SectionHeader.Parent = SectionColumn

                local SectionState = {
                    Column = SectionColumn,
                    Name = sectionName,
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
                    ToggleRow.Size = UDim2.new(1, 0, 0, 24)
                    ToggleRow.BackgroundTransparency = 1
                    ToggleRow.Parent = SectionColumn

                    local CheckBox = Instance.new("Frame")
                    CheckBox.Name = "CheckBox"
                    CheckBox.Size = UDim2.new(0, 15, 0, 15)
                    CheckBox.Position = UDim2.new(0, 0, 0.5, -7.5)
                    CheckBox.BackgroundColor3 = default and Theme.Accent or Theme.ControlBackground
                    CheckBox.BorderSizePixel = 0
                    CheckBox.Parent = ToggleRow

                    local CheckCorner = Instance.new("UICorner")
                    CheckCorner.CornerRadius = UDim.new(0, 3)
                    CheckCorner.Parent = CheckBox

                    local CheckStroke = Instance.new("UIStroke")
                    CheckStroke.Color = default and Theme.Accent or Theme.ControlBorder
                    CheckStroke.Thickness = 1
                    CheckStroke.Parent = CheckBox

                    local CheckIcon = Instance.new("ImageLabel")
                    CheckIcon.Name = "CheckIcon"
                    CheckIcon.Size = UDim2.new(0, 11, 0, 11)
                    CheckIcon.Position = UDim2.new(0.5, -5.5, 0.5, -5.5)
                    CheckIcon.BackgroundTransparency = 1
                    CheckIcon.Image = ResolveIcon("checkmark")
                    CheckIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                    CheckIcon.ScaleType = Enum.ScaleType.Fit
                    CheckIcon.ImageTransparency = default and 0 or 1
                    CheckIcon.Parent = CheckBox

                    local LabelButton = Instance.new("TextButton")
                    LabelButton.Name = "LabelButton"
                    LabelButton.Size = UDim2.new(1, -70, 1, 0)
                    LabelButton.Position = UDim2.new(0, 22, 0, 0)
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
                    RightItemsContainer.Size = UDim2.new(0, 70, 1, 0)
                    RightItemsContainer.Position = UDim2.new(1, -70, 0, 0)
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
                            Tween(CheckStroke, { Color = Theme.Accent })
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
                        Frame = ToggleRow,
                        Label = LabelButton,
                        OriginalColor = customTextColor,
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
                            Tween(PillStroke, { Color = Theme.Accent })

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

                            local SwatchBtn = Instance.new("TextButton")
                            SwatchBtn.Name = "Swatch_" .. i
                            SwatchBtn.Size = UDim2.new(0, 13, 0, 13)
                            SwatchBtn.BackgroundColor3 = currentColor
                            SwatchBtn.BorderSizePixel = 0
                            SwatchBtn.Text = ""
                            SwatchBtn.AutoButtonColor = false
                            SwatchBtn.Parent = RightItemsContainer

                            local SwatchCorner = Instance.new("UICorner")
                            SwatchCorner.CornerRadius = UDim.new(1, 0)
                            SwatchCorner.Parent = SwatchBtn

                            local SwatchStroke = Instance.new("UIStroke")
                            SwatchStroke.Color = Theme.Border
                            SwatchStroke.Thickness = 1
                            SwatchStroke.Parent = SwatchBtn

                            SwatchBtn.MouseButton1Click:Connect(function()
                                local Popup = PopupsLayer:FindFirstChild("ColorPickerPopup")
                                if Popup then Popup:Destroy() end

                                Popup = Instance.new("Frame")
                                Popup.Name = "ColorPickerPopup"
                                Popup.Size = UDim2.new(0, 160, 0, 150)
                                
                                local absPos = SwatchBtn.AbsolutePosition
                                local mainPos = MainFrame.AbsolutePosition
                                Popup.Position = UDim2.new(0, absPos.X - mainPos.X - 165, 0, absPos.Y - mainPos.Y - 20)
                                Popup.BackgroundColor3 = Theme.CardBackground
                                Popup.BorderSizePixel = 0
                                Popup.ZIndex = 60
                                Popup.Parent = PopupsLayer

                                local PopCorner = Instance.new("UICorner")
                                PopCorner.CornerRadius = UDim.new(0, 6)
                                PopCorner.Parent = Popup

                                local PopStroke = Instance.new("UIStroke")
                                PopStroke.Color = Theme.Accent
                                PopStroke.Thickness = 1
                                PopStroke.Parent = Popup

                                local PopTitle = Instance.new("TextLabel")
                                PopTitle.Text = title .. " Color " .. i
                                PopTitle.Font = Enum.Font.GothamBold
                                PopTitle.TextSize = 11
                                PopTitle.TextColor3 = Theme.TextPrimary
                                PopTitle.Size = UDim2.new(1, -16, 0, 22)
                                PopTitle.Position = UDim2.new(0, 8, 0, 4)
                                PopTitle.BackgroundTransparency = 1
                                PopTitle.TextXAlignment = Enum.TextXAlignment.Left
                                PopTitle.Parent = Popup

                                local PresetPalette = {
                                    Color3.fromRGB(255, 60, 60),
                                    Color3.fromRGB(255, 140, 0),
                                    Color3.fromRGB(255, 210, 0),
                                    Color3.fromRGB(0, 230, 120),
                                    Color3.fromRGB(0, 170, 255),
                                    Color3.fromRGB(180, 70, 255),
                                    Color3.fromRGB(255, 255, 255),
                                    Color3.fromRGB(100, 100, 100),
                                }

                                local Grid = Instance.new("Frame")
                                Grid.Size = UDim2.new(1, -16, 0, 80)
                                Grid.Position = UDim2.new(0, 8, 0, 30)
                                Grid.BackgroundTransparency = 1
                                Grid.Parent = Popup

                                local UIGrid = Instance.new("UIGridLayout")
                                UIGrid.CellSize = UDim2.new(0, 32, 0, 32)
                                UIGrid.CellPadding = UDim2.new(0, 5, 0, 5)
                                UIGrid.Parent = Grid

                                for _, col in ipairs(PresetPalette) do
                                    local Dot = Instance.new("TextButton")
                                    Dot.BackgroundColor3 = col
                                    Dot.BorderSizePixel = 0
                                    Dot.Text = ""
                                    Dot.Parent = Grid

                                    local DC = Instance.new("UICorner")
                                    DC.CornerRadius = UDim.new(0, 4)
                                    DC.Parent = Dot

                                    Dot.MouseButton1Click:Connect(function()
                                        currentColor = col
                                        SwatchBtn.BackgroundColor3 = col
                                        Popup:Destroy()
                                    end)
                                end

                                local CloseBtn = Instance.new("TextButton")
                                CloseBtn.Size = UDim2.new(1, -16, 0, 22)
                                CloseBtn.Position = UDim2.new(0, 8, 1, -26)
                                CloseBtn.BackgroundColor3 = Theme.ControlBackground
                                CloseBtn.Text = "Done"
                                CloseBtn.Font = Enum.Font.GothamMedium
                                CloseBtn.TextSize = 10
                                CloseBtn.TextColor3 = Theme.TextPrimary
                                CloseBtn.Parent = Popup

                                local CBCorner = Instance.new("UICorner")
                                CBCorner.CornerRadius = UDim.new(0, 4)
                                CBCorner.Parent = CloseBtn

                                CloseBtn.MouseButton1Click:Connect(function()
                                    Popup:Destroy()
                                end)
                            end)

                            table.insert(ControlApi.ColorPickers, {
                                GetColor = function() return currentColor end,
                                SetColor = function(newCol)
                                    currentColor = newCol
                                    SwatchBtn.BackgroundColor3 = newCol
                                end,
                            })
                        end
                    end

                    return ControlApi
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
                    SliderContainer.Size = UDim2.new(1, 0, 0, 38)
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
                    Track.Position = UDim2.new(0, 0, 0, 24)
                    Track.BackgroundColor3 = Theme.ControlBackground
                    Track.BorderSizePixel = 0
                    Track.Parent = SliderContainer

                    local TrackCorner = Instance.new("UICorner")
                    TrackCorner.CornerRadius = UDim.new(1, 0)
                    TrackCorner.Parent = Track

                    local Fill = Instance.new("Frame")
                    Fill.Name = "Fill"
                    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                    Fill.BackgroundColor3 = Theme.Accent
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
                    KnobStroke.Color = Theme.Accent
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
                    Hitbox.Size = UDim2.new(1, 0, 0, 16)
                    Hitbox.Position = UDim2.new(0, 0, 0, 18)
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
                        Frame = SliderContainer,
                        Label = Label,
                        OriginalColor = Theme.TextSecondary,
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
                    DropdownContainer.Size = UDim2.new(1, 0, 0, 52)
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
                    SelectBox.Size = UDim2.new(1, 0, 0, 28)
                    SelectBox.Position = UDim2.new(0, 0, 0, 20)
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
                            Tween(BoxStroke, { Color = Theme.Accent })
                            Tween(ChevronIcon, { Rotation = 180, ImageColor3 = Theme.Accent })

                            local absPos = SelectBox.AbsolutePosition
                            local mainPos = MainFrame.AbsolutePosition

                            local ListPopup = Instance.new("Frame")
                            ListPopup.Name = "DropdownList_" .. title
                            ListPopup.Size = UDim2.new(0, SelectBox.AbsoluteSize.X, 0, math.min(#options * 26 + 6, 140))
                            ListPopup.Position = UDim2.new(0, absPos.X - mainPos.X, 0, absPos.Y - mainPos.Y + 32)
                            ListPopup.BackgroundColor3 = Theme.CardBackground
                            ListPopup.BorderSizePixel = 0
                            ListPopup.ZIndex = 65
                            ListPopup.Parent = PopupsLayer

                            local ListCorner = Instance.new("UICorner")
                            ListCorner.CornerRadius = UDim.new(0, 5)
                            ListCorner.Parent = ListPopup

                            local ListStroke = Instance.new("UIStroke")
                            ListStroke.Color = Theme.Accent
                            ListStroke.Thickness = 1
                            ListStroke.Parent = ListPopup

                            local Scroll = Instance.new("ScrollingFrame")
                            Scroll.Size = UDim2.new(1, 0, 1, 0)
                            Scroll.BackgroundTransparency = 1
                            Scroll.BorderSizePixel = 0
                            Scroll.ScrollBarThickness = 2
                            Scroll.ScrollBarImageColor3 = Theme.Accent
                            Scroll.CanvasSize = UDim2.new(0, 0, 0, #options * 26 + 4)
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
                                ItemBtn.Size = UDim2.new(1, 0, 0, 24)
                                ItemBtn.BackgroundColor3 = (opt == currentSelected) and Theme.CardHover or Theme.CardBackground
                                ItemBtn.BorderSizePixel = 0
                                ItemBtn.Text = "  " .. opt
                                ItemBtn.Font = Enum.Font.GothamMedium
                                ItemBtn.TextSize = 11
                                ItemBtn.TextColor3 = (opt == currentSelected) and Theme.Accent or Theme.TextSecondary
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
                                        TextColor3 = (opt == currentSelected) and Theme.Accent or Theme.TextSecondary
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
                        Frame = DropdownContainer,
                        Label = Label,
                        OriginalColor = Theme.TextSecondary,
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
                    Btn.Size = UDim2.new(1, 0, 0, 28)
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
                        Tween(BStroke, { Color = Theme.Accent })
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
                        Frame = Btn,
                        Label = Btn,
                        OriginalColor = Theme.TextPrimary,
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

return Ignite
