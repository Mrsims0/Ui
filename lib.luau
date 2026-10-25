--[[
    Millionware UI Library for Roblox (Luau)
    1:1 Port from C++ ImGui / Slate Implementation
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse() or nil

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
    local LogoId = config.LogoId or ""
    local Size = config.Size or Vector2.new(740, 532)

    -- Cleanup existing if any with same name
    if Library.ScreenGui then
        Library.ScreenGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Millionware_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = getGuiParent()
    Library.ScreenGui = ScreenGui

    -- Popups holder to guarantee highest ZIndex over everything
    local Popups = Instance.new("Frame")
    Popups.Name = "Popups"
    Popups.BackgroundTransparency = 1
    Popups.Size = UDim2.new(1, 0, 1, 0)
    Popups.ZIndex = 50
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

    -- Subtle Top Window Gradient (from C++: 31px high gradient, alpha 0.03 to 0.00)
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

    -- Drag Top Handle
    local DragBar = Instance.new("Frame")
    DragBar.Name = "DragBar"
    DragBar.Size = UDim2.new(1, 0, 0, 31)
    DragBar.BackgroundTransparency = 1
    DragBar.ZIndex = 3
    DragBar.Parent = Main
    makeDraggable(DragBar, Main)

    -- Inner Container: 720 x 491 at (10, 31)
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Size = UDim2.new(0, 720, 0, 491)
    ContentHolder.Position = UDim2.new(0, 10, 0, 31)
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Parent = Main

    -- Left Sidebar: width 140
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
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
    LogoImage.Size = UDim2.new(0, 101, 0, 45)
    LogoImage.Position = UDim2.new(0, 18, 0, 10)
    LogoImage.BackgroundTransparency = 1
    LogoImage.ScaleType = Enum.ScaleType.Fit
    if LogoId and LogoId ~= "" then
        LogoImage.Image = LogoId
    else
        -- If no asset ID provided, create 1-1 MW$ vector-style typography
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

    -- Tabs Container in Sidebar
    local TabList = Instance.new("Frame")
    TabList.Name = "TabList"
    TabList.Size = UDim2.new(0, 134, 1, -74)
    TabList.Position = UDim2.new(0, 3, 0, 74)
    TabList.BackgroundTransparency = 1
    TabList.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 3)
    TabListLayout.Parent = TabList

    -- Right Main Area (width 574, height 479)
    local MainArea = Instance.new("Frame")
    MainArea.Name = "MainArea"
    MainArea.Size = UDim2.new(0, 574, 0, 485)
    MainArea.Position = UDim2.new(0, 143, 0, 3)
    MainArea.BackgroundTransparency = 1
    MainArea.Parent = ContentHolder

    -- Subtabs bar (height 22)
    local SubtabsBar = Instance.new("Frame")
    SubtabsBar.Name = "SubtabsBar"
    SubtabsBar.Size = UDim2.new(1, 0, 0, 22)
    SubtabsBar.BackgroundTransparency = 1
    SubtabsBar.BorderSizePixel = 0
    SubtabsBar.Parent = MainArea

    local SubtabsLine = Instance.new("Frame")
    SubtabsLine.Name = "BottomLine"
    SubtabsLine.Size = UDim2.new(1, 0, 0, 1)
    SubtabsLine.Position = UDim2.new(0, 0, 1, -1)
    SubtabsLine.BackgroundColor3 = Library.CurrentTheme.Border
    SubtabsLine.BorderSizePixel = 0
    SubtabsLine.ZIndex = 2
    SubtabsLine.Parent = SubtabsBar

    local SubtabsLayout = Instance.new("UIListLayout")
    SubtabsLayout.FillDirection = Enum.FillDirection.Horizontal
    SubtabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SubtabsLayout.Parent = SubtabsBar

    -- Page Container
    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "PageContainer"
    PageContainer.Size = UDim2.new(1, 0, 1, -26)
    PageContainer.Position = UDim2.new(0, 0, 0, 26)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainArea

    local WindowObj = {
        Tabs = {},
        CurrentTab = nil,
    }

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

        function TabObj:Activate()
            for _, otherTab in ipairs(WindowObj.Tabs) do
                otherTab.Button.BackgroundTransparency = 1
                otherTab.Button.BackgroundColor3 = Library.CurrentTheme.TabBg
                otherTab.Indicator.Visible = false
                otherTab.Button.Label.Font = Enum.Font.SourceSans
                otherTab.Button.Label.TextColor3 = Library.CurrentTheme.TextDim
                for _, sub in ipairs(otherTab.Subtabs) do
                    sub.Button.Visible = false
                    sub.PageFrame.Visible = false
                end
            end

            WindowObj.CurrentTab = TabObj
            TabBtn.BackgroundTransparency = 0
            TabBtn.BackgroundColor3 = Library.CurrentTheme.TabBg
            TabIndicator.Visible = true
            TabLabel.Font = Enum.Font.SourceSansBold
            TabLabel.TextColor3 = Library.CurrentTheme.Text

            if #TabObj.Subtabs > 0 then
                SubtabsBar.Visible = true
                PageContainer.Size = UDim2.new(1, 0, 1, -26)
                PageContainer.Position = UDim2.new(0, 0, 0, 26)
                for _, sub in ipairs(TabObj.Subtabs) do
                    sub.Button.Visible = true
                end
                if TabObj.CurrentSubtab then
                    TabObj.CurrentSubtab:Activate()
                else
                    TabObj.Subtabs[1]:Activate()
                end
            else
                SubtabsBar.Visible = false
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
            SubBtn.Size = UDim2.new(0, 100, 1, 0)
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
            SubIndicator.ZIndex = 3
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

            table.insert(TabObj.Subtabs, SubtabObj)

            -- Recalculate subtab widths dynamically (1 / count of subtabs)
            local count = #TabObj.Subtabs
            for _, s in ipairs(TabObj.Subtabs) do
                s.Button.Size = UDim2.new(1 / count, 0, 1, 0)
            end

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

                -- Title label at top (-10 offset in ImGui style)
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

                -- Content Container (11px horizontal padding, 6px spacing)
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

                    -- Extras frame on the far right (for Keybind or Colorpicker)
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

                    -- Keybind attached to Checkbox
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

                        -- Colorpicker popup window
                        local open = false
                        local CPPopup = Instance.new("Frame")
                        CPPopup.Name = "CPPopup"
                        CPPopup.Size = UDim2.new(0, 215, 0, 175)
                        CPPopup.BackgroundColor3 = Library.CurrentTheme.WidgetBg
                        CPPopup.BorderSizePixel = 1
                        CPPopup.BorderColor3 = Library.CurrentTheme.Border
                        CPPopup.Visible = false
                        CPPopup.ZIndex = 60
                        CPPopup.Parent = Library.Popups

                        local CPInnerPad = Instance.new("UIPadding")
                        CPInnerPad.PaddingLeft = UDim.new(0, 8)
                        CPInnerPad.PaddingRight = UDim.new(0, 8)
                        CPInnerPad.PaddingTop = UDim.new(0, 8)
                        CPInnerPad.PaddingBottom = UDim.new(0, 8)
                        CPInnerPad.Parent = CPPopup

                        -- Saturation / Value square (193 x 115)
                        local SVMap = Instance.new("ImageButton")
                        SVMap.Name = "SVMap"
                        SVMap.Size = UDim2.new(0, 193, 0, 110)
                        SVMap.Image = "rbxassetid://4155801252" -- Standard Roblox HSV Saturation/Value gradient
                        SVMap.BackgroundColor3 = curCol
                        SVMap.BorderSizePixel = 1
                        SVMap.BorderColor3 = Library.CurrentTheme.Border
                        SVMap.AutoButtonColor = false
                        SVMap.ZIndex = 61
                        SVMap.Parent = CPPopup

                        local PickerCircle = Instance.new("Frame")
                        PickerCircle.Name = "Circle"
                        PickerCircle.Size = UDim2.new(0, 6, 0, 6)
                        PickerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
                        PickerCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        PickerCircle.BorderSizePixel = 1
                        PickerCircle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        PickerCircle.ZIndex = 62
                        PickerCircle.Parent = SVMap

                        -- Hue Bar below SVMap
                        local HueBar = Instance.new("ImageButton")
                        HueBar.Name = "HueBar"
                        HueBar.Size = UDim2.new(0, 193, 0, 10)
                        HueBar.Position = UDim2.new(0, 0, 0, 116)
                        HueBar.Image = "rbxassetid://3641079629" -- Horizontal Hue gradient
                        HueBar.BorderSizePixel = 1
                        HueBar.BorderColor3 = Library.CurrentTheme.Border
                        HueBar.AutoButtonColor = false
                        HueBar.ZIndex = 61
                        HueBar.Parent = CPPopup

                        local HuePicker = Instance.new("Frame")
                        HuePicker.Name = "HuePicker"
                        HuePicker.Size = UDim2.new(0, 3, 1, 2)
                        HuePicker.Position = UDim2.new(0, 0, 0, -1)
                        HuePicker.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        HuePicker.BorderSizePixel = 1
                        HuePicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
                        HuePicker.ZIndex = 62
                        HuePicker.Parent = HueBar

                        -- Hex / Text status
                        local HexLabel = Instance.new("TextLabel")
                        HexLabel.Name = "HexLabel"
                        HexLabel.Size = UDim2.new(1, 0, 0, 20)
                        HexLabel.Position = UDim2.new(0, 0, 0, 132)
                        HexLabel.BackgroundTransparency = 1
                        HexLabel.Font = Enum.Font.Code
                        HexLabel.TextSize = 12
                        HexLabel.TextColor3 = Library.CurrentTheme.TextDim
                        HexLabel.Text = "#" .. curCol:ToHex():upper()
                        HexLabel.ZIndex = 61
                        HexLabel.Parent = CPPopup

                        local curH, curS, curV = curCol:ToHSV()

                        local function updateColor()
                            local finalCol = Color3.fromHSV(curH, curS, curV)
                            CPBtn.BackgroundColor3 = finalCol
                            SVMap.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
                            HexLabel.Text = "#" .. finalCol:ToHex():upper()
                            onColChanged(finalCol)
                        end

                        -- Drag SV Map
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

                        -- Drag Hue Bar
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

                    -- Track (6px high, positioned at bottom)
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

                    -- Subtle shine inside combo box
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

                    -- Popup list
                    local DropList = Instance.new("ScrollingFrame")
                    DropList.Name = text .. "_Popup"
                    DropList.Size = UDim2.new(0, 100, 0, 0)
                    DropList.BackgroundColor3 = Library.CurrentTheme.TabBg
                    DropList.BorderSizePixel = 1
                    DropList.BorderColor3 = Library.CurrentTheme.Border
                    DropList.ScrollBarThickness = 2
                    DropList.ScrollBarImageColor3 = Library.CurrentTheme.Scheme
                    DropList.Visible = false
                    DropList.ZIndex = 70
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
                            ItemBtn.ZIndex = 71
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

    -- Toggle menu key (Insert or Delete like classic cheats)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and (input.KeyCode == Enum.KeyCode.Insert or input.KeyCode == Enum.KeyCode.RightControl) then
            Main.Visible = not Main.Visible
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
