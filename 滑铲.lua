-- 将此脚本放入 StarterPlayer > StarterPlayerScripts 中
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==========================================
-- 🚀 0. 自动下载资源 (启动时最先执行)
-- ==========================================
-- ⚠️ 请将这里的链接替换为你自己的 GitHub Raw 链接！
-- 注意：链接最后必须带斜杠 /
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/18878026432-hash/-/refs/heads/main/Logo.png/"

local function autoDownloadAssets()
    if not writefile or not isfile or not makefolder then return end

    -- 确保 Workspace 文件夹存在
    if not isfolder("Workspace") then
        makefolder("Workspace")
    end

    local assets = {
        { name = "Logo.png", url = GITHUB_RAW_URL .. "Logo.png" },
        { name = "Logo.jpg", url = GITHUB_RAW_URL .. "Logo.jpg" }
    }

    for _, asset in ipairs(assets) do
        local filePath = "Workspace/" .. asset.name
        -- 如果文件已存在，跳过下载
        if not isfile(filePath) then
            print("[自动下载] 正在尝试下载: " .. asset.name)
            local success, response = pcall(function()
                -- 使用 true 参数，尽可能以二进制模式请求（部分执行器支持）
                return game:HttpGet(asset.url, true)
            end)
            if success and response and response ~= "404: Not Found" then
                local writeSuccess = pcall(writefile, filePath, response)
                if writeSuccess then
                    print("[自动下载] ✅ 保存成功: " .. filePath)
                else
                    warn("[自动下载] ❌ 写入失败，请检查执行器权限")
                end
            else
                warn("[自动下载] ❌ 下载失败或文件不存在: " .. asset.url)
            end
        end
    end
end

-- 执行下载任务
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

    -- 读取本地 Logo 图片
    local function loadLocalImage()
        if not getcustomasset then return "rbxassetid://0" end
        local possiblePaths = {
            "Workspace/Logo.png", "Workspace/logo.png",
            "Workspace/Logo.jpg", "Workspace/logo.jpg",
            "Workspace/Logo.jpeg", "Logo.png", "logo.png"
        }
        for _, path in ipairs(possiblePaths) do
            if isfile and isfile(path) then
                local success, assetUrl = pcall(getcustomasset, path)
                if success and assetUrl then return assetUrl end
            end
        end
        return "rbxassetid://0"
    end

    IMAGE_ID = loadLocalImage()

    local introGui = Instance.new("ScreenGui")
    introGui.Name = "IntroAnimation"
    introGui.IgnoreGuiInset = true
    introGui.DisplayOrder = 999
    introGui.Parent = playerGui

    local bgFrame = Instance.new("Frame")
    bgFrame.Size = UDim2.new(1, 0, 1, 0)
    bgFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    bgFrame.ZIndex = 1
    bgFrame.Parent = introGui

    local leftBracket = Instance.new("TextLabel")
    leftBracket.Text = "《"
    leftBracket.TextColor3 = Color3.new(1, 1, 1)
    leftBracket.TextSize = 10
    leftBracket.Font = Enum.Font.GothamBold
    leftBracket.Size = UDim2.new(0, 200, 0, 200)
    leftBracket.Position = UDim2.new(0.5, -100, 0.5, -100)
    leftBracket.BackgroundTransparency = 1
    leftBracket.TextTransparency = 1
    leftBracket.ZIndex = 10
    leftBracket.Parent = introGui

    local rightBracket = leftBracket:Clone()
    rightBracket.Text = "》"
    rightBracket.Parent = introGui

    local bracketTweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(leftBracket, bracketTweenInfo, {Position = UDim2.new(0.5, -250, 0.5, -100), TextSize = 120, TextTransparency = 0}):Play()
    TweenService:Create(rightBracket, bracketTweenInfo, {Position = UDim2.new(0.5, 50, 0.5, -100), TextSize = 120, TextTransparency = 0}):Play()

    local puzzleContainer = Instance.new("Frame")
    puzzleContainer.Size = UDim2.new(0, 400, 0, 400) 
    puzzleContainer.Position = UDim2.new(0.5, -200, 0.5, -200)
    puzzleContainer.BackgroundTransparency = 1
    puzzleContainer.ZIndex = 2
    puzzleContainer.Parent = introGui

    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(0, 300, 0, 10)
    progressBg.Position = UDim2.new(0.5, -150, 0.8, 0) 
    progressBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    progressBg.BorderSizePixel = 0
    progressBg.BackgroundTransparency = 1
    progressBg.ZIndex = 10
    progressBg.Parent = introGui
    
    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(0, 0, 1, 0)
    progr