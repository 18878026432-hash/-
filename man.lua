-- 将此脚本放入 StarterPlayer > StarterPlayerScripts 中
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==========================================
-- 🛠️ 自定义调试日志系统 (按 V 键 打开/关闭)
-- ==========================================
local debugGui = Instance.new("ScreenGui")
debugGui.Name = "CustomLogUI"
debugGui.ResetOnSpawn = false
debugGui.IgnoreGuiInset = true
debugGui.DisplayOrder = 1000
debugGui.Parent = playerGui

local logFrame = Instance.new("ScrollingFrame")
logFrame.Size = UDim2.new(0, 350, 0, 200)
logFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
logFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
logFrame.BackgroundTransparency = 0.1
logFrame.BorderSizePixel = 0
logFrame.Visible = false 
logFrame.ZIndex = 100
logFrame.Parent = debugGui

local layout = Instance.new("UIListLayout")
layout.Parent = logFrame
layout.SortOrder = Enum.SortOrder.LayoutOrder

local order = 1
local function showLog(text, isWarn)
    if isWarn then warn(text) else print(text) end
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = (isWarn and "❌ " or "✅ ") .. text
    label.TextColor3 = isWarn and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(100, 255, 100)
    label.Font = Enum.Font.Code
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = order
    label.ZIndex = 101
    label.Parent = logFrame
    order = order + 1
    
    task.wait()
    logFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)
    logFrame.CanvasPosition = Vector2.new(0, layout.AbsoluteContentSize.Y)
end

-- 交互：按下 V 键打开/关闭日志
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.V then
        logFrame.Visible = not logFrame.Visible
    end
end)

-- ==========================================
-- 🚀 0. 自动下载资源 (启动时最先执行)
-- ==========================================
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/18878026432-hash/-/main/"

local function autoDownloadAssets()
    if not writefile or not isfile or not makefolder then
        showLog("当前执行器不支持文件操作 API！", true)
        return
    end

    if not isfolder("Workspace") then
        makefolder("Workspace")
        showLog("创建了 Workspace 文件夹", false)
    end

    local assets = {
        { name = "Logo.png", url = GITHUB_RAW_URL .. "Logo.png" },
        { name = "Logo.jpg", url = GITHUB_RAW_URL .. "Logo.jpg" }
    }

    for _, asset in ipairs(assets) do
        local filePath = "Workspace/" .. asset.name
        if not isfile(filePath) then
            showLog("开始尝试下载: " .. asset.name, false)
            local success, response = pcall(function()
                return game:HttpGet(asset.url, true)
            end)
            
            if success and response then
                if response == "404: Not Found" or string.find(response, "<html") then
                    showLog("下载失败：链接 404 或返回了网页", true)
                else
                    local writeSuccess, err = pcall(writefile, filePath, response)
                    if writeSuccess then
                        showLog("图片下载并写入成功！", false)
                    else
                        showLog("写入失败: " .. tostring(err), true)
                    end
                end
            else
                showLog("网络请求失败 (HttpGet)", true)
            end
        end
    end
end

autoDownloadAssets()

-- ==========================================
-- 🎬 全局状态锁
-- ==========================================
local isIntroPlaying = true 

-- ==========================================
-- 1. 开场动画部分
-- ==========================================
task.spawn(function()
    local GRID_SIZE = 12        
    local TOTAL_TIME = 5        
    local FADE_OUT_TIME = 1.5   
    local IMAGE_ID = "rbxassetid://0" 

    local function loadLocalImage()
        if not getcustomasset then
            showLog("执行器不支持 getcustomasset！", true)
            return "rbxassetid://0" 
        end
        
        local possiblePaths = {
            "Workspace/Logo.png", "Workspace/logo.png",
            "Workspace/Logo.jpg", "Workspace/logo.jpg",
            "Workspace/Logo.jpeg", "Logo.png", "logo.png"
        }
        
        for _, path in ipairs(possiblePaths) do
            if isfile and isfile(path) then
                local success, assetUrl = pcall(getcustomasset, path)
                if success and assetUrl then 
                    showLog("成功加载本地图片！", false)
                    return assetUrl 
                else
                    showLog("getcustomasset 转换失败", true)
                end
            end
        end
     