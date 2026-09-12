local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")

local SECRET_KEY = "kittyauth_secure_key"
local API_URL = "http://212.192.28.18:8110/sync"
local AUTH_KEY = getgenv().KittyKey or ""

local function encrypt(data)
    local result = {}
    for i = 1, #data do
        local charCode = string.byte(data, i)
        local keyCode = string.byte(SECRET_KEY, ((i - 1) % #SECRET_KEY) + 1)
        table.insert(result, string.char(bit32.bxor(charCode, keyCode)))
    end
    return crypt.base64encode(table.concat(result))
end

local KittyUI = Instance.new("ScreenGui")
KittyUI.Name = "KittyUI"
KittyUI.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 210)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -105)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 105, 180) 
MainFrame.BorderSizePixel = 0
MainFrame.Parent = KittyUI

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "kitty configs"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.Code
Title.TextSize = 18
Title.Parent = MainFrame

local ConfigBox = Instance.new("TextBox")
ConfigBox.Size = UDim2.new(0, 260, 0, 30)
ConfigBox.Position = UDim2.new(0, 20, 0, 50)
ConfigBox.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
ConfigBox.PlaceholderText = "Config Name"
ConfigBox.Text = ""
ConfigBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfigBox.Font = Enum.Font.Code
ConfigBox.TextSize = 14
ConfigBox.BorderSizePixel = 0
ConfigBox.Parent = MainFrame

local AimbotToggle = Instance.new("TextButton")
AimbotToggle.Size = UDim2.new(0, 260, 0, 30)
AimbotToggle.Position = UDim2.new(0, 20, 0, 90)
AimbotToggle.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
AimbotToggle.Text = "Toggle Aimbot: OFF"
AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotToggle.Font = Enum.Font.Code
AimbotToggle.TextSize = 14
AimbotToggle.BorderSizePixel = 0
AimbotToggle.Parent = MainFrame

local SendBtn = Instance.new("TextButton")
SendBtn.Size = UDim2.new(0, 260, 0, 30)
SendBtn.Position = UDim2.new(0, 20, 0, 150)
SendBtn.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
SendBtn.Text = "Save & Sync Cloud Config"
SendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SendBtn.Font = Enum.Font.Code
SendBtn.TextSize = 14
SendBtn.BorderSizePixel = 0
SendBtn.Parent = MainFrame

local aimbotState = false
AimbotToggle.MouseButton1Click:Connect(function()
    aimbotState = not aimbotState
    AimbotToggle.Text = "Toggle Aimbot: " .. (aimbotState and "ON" or "OFF")
end)

SendBtn.MouseButton1Click:Connect(function()
    local payload = {
        key = AUTH_KEY,
        hwid = RbxAnalyticsService:GetClientId(),
        roblox_id = Players.LocalPlayer.UserId,
        game_id = game.PlaceId,
        config = {
            config_name = ConfigBox.Text,
            aimbot_enabled = aimbotState
        }
    }
    
    local jsonPayload = HttpService:JSONEncode(payload)
    local encryptedData = encrypt(jsonPayload)
    
    local exec_request = request or http_request or (http and http.request) or (syn and syn.request)
    
    if not exec_request then
        SendBtn.Text = "Executor not supported"
        task.wait(2)
        SendBtn.Text = "Save & Sync Cloud Config"
        return
    end

    local success, response = pcall(function()
        return exec_request({
            Url = API_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "text/plain"
            },
            Body = encryptedData
        })
    end)
    
    if success and response and (response.StatusCode == 200 or response.StatusCode == 204) then
        SendBtn.Text = "Synced!"
        task.wait(2)
        SendBtn.Text = "Save & Sync Cloud Config"
    else
        SendBtn.Text = "Sync Failed"
        task.wait(2)
        SendBtn.Text = "Save & Sync Cloud Config"
    end
end)
