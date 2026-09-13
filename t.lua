local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local SECRET_KEY = "kittyauth_secure_key"
local API_URL = (getgenv and getgenv().KittyApiUrl) or "http://212.192.28.18:8110/sync"
local AUTH_KEY = (getgenv and getgenv().KittyKey) or ""

-- Universal Base64 Encoder with pure-Lua fallback for all executors
local function base64_encode(data)
    if typeof(crypt) == "table" and type(crypt.base64encode) == "function" then
        return crypt.base64encode(data)
    elseif typeof(crypt) == "table" and type(crypt.base64_encode) == "function" then
        return crypt.base64_encode(data)
    elseif typeof(syn) == "table" and typeof(syn.crypt) == "table" and type(syn.crypt.base64) == "table" and type(syn.crypt.base64.encode) == "function" then
        return syn.crypt.base64.encode(data)
    elseif type(base64_encode) == "function" then
        return base64_encode(data)
    end

    -- Pure Lua Base64 fallback
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x) 
        local r, b_val = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b_val % 2 ^ i - b_val % 2 ^ (i - 1) > 0 and '1' or '0') end
        return r
    end) .. '0000'):gsub('%d%d%d?%d?%d?', function(x)
        if #x < 6 then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2 ^ (6 - i) or 0) end
        return b:sub(c + 1, c + 1)
    end) .. ({ '', '==', '=' })[#data % 3 + 1])
end

-- Universal HTTP Request Dispatcher
local function sendHttpRequest(url, method, headers, body)
    local reqFn = request or http_request or (syn and syn.request) or (http and http.request)
    if reqFn then
        return reqFn({
            Url = url,
            Method = method or "POST",
            Headers = headers or { ["Content-Type"] = "text/plain" },
            Body = body
        })
    end
    
    -- Fallback to HttpService if allowed
    local resBody = HttpService:PostAsync(url, body, Enum.HttpContentType.TextPlain)
    return {
        StatusCode = 200,
        Body = resBody
    }
end

-- Safe HWID Resolver
local function getHWID()
    local hwid = "UNKNOWN-HWID"
    pcall(function()
        if type(gethwid) == "function" then
            hwid = gethwid()
        elseif type(get_hwid) == "function" then
            hwid = get_hwid()
        elseif RbxAnalyticsService then
            hwid = RbxAnalyticsService:GetClientId()
        end
    end)
    return hwid
end

local function encrypt(data)
    local result = {}
    for i = 1, #data do
        local charCode = string.byte(data, i)
        local keyCode = string.byte(SECRET_KEY, ((i - 1) % #SECRET_KEY) + 1)
        table.insert(result, string.char(bit32.bxor(charCode, keyCode)))
    end
    return base64_encode(table.concat(result))
end

-- Get Safe User & UI container
local localPlayer = Players.LocalPlayer
local userId = localPlayer and localPlayer.UserId or 0
local coreGui = game:GetService("CoreGui")

-- Remove previous UI if re-executed
if coreGui:FindFirstChild("KittyUI") then
    coreGui.KittyUI:Destroy()
end

local KittyUI = Instance.new("ScreenGui")
KittyUI.Name = "KittyUI"
KittyUI.ResetOnSpawn = false
pcall(function()
    KittyUI.Parent = coreGui
end)
if not KittyUI.Parent and localPlayer and localPlayer:FindFirstChild("PlayerGui") then
    KittyUI.Parent = localPlayer.PlayerGui
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 210)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 105, 180) 
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = KittyUI

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "🐱 Kitty Cloud Configs"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

local ConfigBox = Instance.new("TextBox")
ConfigBox.Size = UDim2.new(0, 260, 0, 32)
ConfigBox.Position = UDim2.new(0, 20, 0, 45)
ConfigBox.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
ConfigBox.PlaceholderText = "Config Name (e.g. Rage, Legit)"
ConfigBox.Text = ""
ConfigBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfigBox.Font = Enum.Font.GothamSemibold
ConfigBox.TextSize = 13
ConfigBox.BorderSizePixel = 0
ConfigBox.Parent = MainFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = ConfigBox

local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Size = UDim2.new(0, 260, 0, 32)
AimbotToggle.Position = UDim2.new(0, 20, 0, 85)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
AimbotToggle.Text = "Toggle Aimbot: OFF"
AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotToggle.Font = Enum.Font.GothamSemibold
AimbotToggle.TextSize = 13
AimbotToggle.BorderSizePixel = 0
AimbotToggle.Parent = MainFrame

local AimCorner = Instance.new("UICorner")
AimCorner.CornerRadius = UDim.new(0, 6)
AimCorner.Parent = AimbotToggle

local SendBtn = Instance.new("TextButton")
SendBtn.Size = UDim2.new(0, 260, 0, 36)
SendBtn.Position = UDim2.new(0, 20, 0, 145)
SendBtn.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
SendBtn.Text = "Save & Sync Cloud Config"
SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SendBtn.Font = Enum.Font.GothamBold
SendBtn.TextSize = 14
SendBtn.BorderSizePixel = 0
SendBtn.Parent = MainFrame

local SendCorner = Instance.new("UICorner")
SendCorner.CornerRadius = UDim.new(0, 6)
SendCorner.Parent = SendBtn

local aimbotState = false
AimbotToggle.MouseButton1Click:Connect(function()
    aimbotState = not aimbotState
    AimbotToggle.Text = "Toggle Aimbot: " .. (aimbotState and "ON" or "OFF")
    AimbotToggle.BackgroundColor3 = aimbotState and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(0, 191, 255)
end)

local isSyncing = false
SendBtn.MouseButton1Click:Connect(function()
    if isSyncing then return end
    isSyncing = true
    SendBtn.Text = "Syncing with Cloud..."
    
    local resolvedKey = (getgenv and getgenv().KittyKey) or AUTH_KEY or ""
    local targetUrl = (getgenv and getgenv().KittyApiUrl) or API_URL

    local payload = {
        key = resolvedKey,
        hwid = getHWID(),
        roblox_id = userId,
        game_id = game.PlaceId,
        config = {
            config_name = ConfigBox.Text ~= "" and ConfigBox.Text or "Default",
            aimbot_enabled = aimbotState,
            saved_at = os.time()
        }
    }
    
    local jsonSuccess, jsonPayload = pcall(function()
        return HttpService:JSONEncode(payload)
    end)
    
    if not jsonSuccess then
        SendBtn.Text = "JSON Encode Error"
        task.wait(2)
        SendBtn.Text = "Save & Sync Cloud Config"
        isSyncing = false
        return
    end
    
    local encSuccess, encryptedData = pcall(function()
        return encrypt(jsonPayload)
    end)
    
    if not encSuccess then
        SendBtn.Text = "Encryption Error"
        task.wait(2)
        SendBtn.Text = "Save & Sync Cloud Config"
        isSyncing = false
        return
    end
    
    local reqSuccess, resp = pcall(function()
        return sendHttpRequest(targetUrl, "POST", { ["Content-Type"] = "text/plain" }, encryptedData)
    end)
    
    if reqSuccess and resp then
        local statusCode = resp.StatusCode or resp.status_code or 200
        local body = resp.Body or resp.body or ""
        local parsed = nil
        
        pcall(function()
            parsed = HttpService:JSONDecode(body)
        end)
        
        if parsed and parsed.status == "success" then
            SendBtn.Text = "✅ Synced Successfully!"
        elseif parsed and parsed.message then
            SendBtn.Text = "❌ " .. tostring(parsed.message)
        elseif statusCode >= 200 and statusCode < 300 then
            SendBtn.Text = "✅ Synced!"
        else
            SendBtn.Text = "❌ Sync Failed (" .. tostring(statusCode) .. ")"
        end
    else
        SendBtn.Text = "❌ Sync Failed (Connection Error)"
    end
    
    task.wait(2.5)
    SendBtn.Text = "Save & Sync Cloud Config"
    isSyncing = false
end)
