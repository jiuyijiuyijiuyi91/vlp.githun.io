local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ScreenGuiRef = nil
local WinRef = nil

local TransparentValue = 0.6

local Window = WindUI:CreateWindow({
    Title = "XJW ui",
    Author = "制作:Xavi",
    Icon = "https://n.uguu.se/vMZrMwub.png",
    IconSize = 46,
    Topbar = {
        Height = 64,
        ButtonsType = "Default",
    },
    Theme = "Dark",
    Radius = 24,
})

local function rainbowBorder()
    local roots = {}
    local g = gethui and gethui()
    if g then table.insert(roots, g) end
    local core = game:GetService("CoreGui")
    if core then table.insert(roots, core) end
    local plr0 = Players.LocalPlayer
    local pg = plr0 and plr0:FindFirstChild("PlayerGui")
    if pg then table.insert(roots, pg) end

    local sg
    local win
    task.wait(1)

    local function findWin(screen)
        if not screen or not screen:IsA("ScreenGui") then return nil end
        local folder = screen:FindFirstChild("Window")
        local target
        if folder then
            for _, ch in ipairs(folder:GetChildren()) do
                if ch:IsA("GuiObject") then
                    target = ch
                    break
                end
            end
        end
        if not target then
            local best
            for _, d in ipairs(screen:GetDescendants()) do
                if d:IsA("GuiObject") and d.AbsoluteSize.X > 50 and d.AbsoluteSize.Y > 50 then
                    if not best or (d.AbsoluteSize.X * d.AbsoluteSize.Y) > (best.AbsoluteSize.X * best.AbsoluteSize.Y) then
                        best = d
                    end
                end
            end
            target = best
        end
        return target
    end

    for _, r in ipairs(roots) do
        if r.Name == "WindUI" and r:IsA("ScreenGui") then
            sg = r
        else
            sg = r:FindFirstChild("WindUI")
        end
        if sg then
            win = findWin(sg)
            if win then break end
        end
    end

    if not win or not sg then
        warn("WindUI window frame not found")
        return
    end

    ScreenGuiRef = sg
    WinRef = win

    local spacer
    local function ensureSpacer()
        local uie = win:FindFirstChild("UIElements")
        local m = uie and uie:FindFirstChild("Main")
        if not m then return end
        if not spacer or not spacer.Parent then
            spacer = Instance.new("Frame")
            spacer.Name = "MarvisSpacer"
            spacer.BackgroundTransparency = 1
            spacer.BorderSizePixel = 0
            spacer.Size = UDim2.new(1, 0, 0, 60)
            spacer.ZIndex = 0
            spacer.Parent = m
        end
    end
    ensureSpacer()

    local strokeFrame
    local stroke
    local strokeGrad
    local function createStroke()
        strokeFrame = Instance.new("Frame")
        strokeFrame.Name = "MarvisRainbowStroke"
        strokeFrame.BackgroundTransparency = 1
        strokeFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        strokeFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        strokeFrame.Size = UDim2.new(1, 0, 1, 0)
        strokeFrame.ZIndex = 98
        strokeFrame.Parent = win

        local strokeCorner = Instance.new("UICorner")
        strokeCorner.CornerRadius = UDim.new(0, 24)
        strokeCorner.Parent = strokeFrame

        stroke = Instance.new("UIStroke")
        stroke.Thickness = 4
        stroke.Color = Color3.new(1, 1, 1)
        stroke.Transparency = 0
        stroke.Parent = strokeFrame

        local okGrad, errGrad = pcall(function()
            strokeGrad = stroke.UIGradient
            local kpts = {}
            for i = 0, 11 do
                kpts[i + 1] = ColorSequenceKeypoint.new(i / 11, Color3.fromHSV(i / 11, 1, 1))
            end
            strokeGrad.Color = ColorSequence.new(kpts)
            strokeGrad.Rotation = 0
        end)
    end
    createStroke()

    RunService.RenderStepped:Connect(function(dt)
        if not win.Parent then
            if strokeFrame then strokeFrame:Destroy() end
            return
        end
        if not strokeFrame or not strokeFrame.Parent then
            createStroke()
        end
        ensureSpacer()
        win.ClipsDescendants = false
        local bgNow
        local uie = win:FindFirstChild("UIElements")
        local m = uie and uie:FindFirstChild("Main")
        if m then
            bgNow = m:FindFirstChild("Background")
        end
        if not bgNow then
            for _, d in ipairs(win:GetDescendants()) do
                if d:IsA("ImageLabel") and d.Name == "Background" and d.AbsoluteSize.X > 50 then
                    bgNow = d
                    break
                end
            end
        end
        if bgNow then
            bgNow.ImageTransparency = TransparentValue
        end
        if strokeGrad then
            strokeGrad.Rotation = (strokeGrad.Rotation + dt * 40) % 360
        elseif stroke then
            stroke.Color = Color3.fromHSV((os.clock() * 0.3) % 1, 1, 1)
        end
        if strokeFrame then
            strokeFrame.Visible = win.Visible
        end
    end)
end

task.spawn(rainbowBorder)local function addAvatar()
    local plr = Players.LocalPlayer
    if not plr then return end
    task.wait(1.5)

    local img
    local ok1, t1 = pcall(function()
        return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    if ok1 and typeof(t1) == "string" and t1 ~= "" then
        img = t1
    else
        local ok2, t2 = pcall(function()
            return game:GetService("Thumbnails"):GetPlayerThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
        if ok2 and typeof(t2) == "string" and t2 ~= "" then
            img = t2
        else
            img = "rbxthumb://type=AvatarHeadShot&id=" .. plr.UserId .. "&w=420&h=420"
        end
    end

    local function findWinRef()
        if WinRef and WinRef.Parent then return WinRef end
        if ScreenGuiRef then
            local folder = ScreenGuiRef:FindFirstChild("Window")
            if folder then
                for _, ch in ipairs(folder:GetChildren()) do
                    if ch:IsA("GuiObject") then return ch end
                end
            end
        end
        return nil
    end

    local win
    for i = 1, 5 do
        win = findWinRef()
        if win then break end
        task.wait(0.5)
    end
    if not win then
        warn("MarvisAvatar: window not found")
        return
    end

    local box, av, nameLbl, idLbl
    local function createBox()
        box = Instance.new("Frame")
        box.Name = "MarvisAvatarBox"
        box.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        box.BackgroundTransparency = 1
        box.AnchorPoint = Vector2.new(0, 1)
        box.Position = UDim2.new(0, 10, 1, -10)
        box.Size = UDim2.new(0, 132, 0, 34)
        box.ZIndex = 98
        box.Parent = win

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = box

        av = Instance.new("ImageLabel")
        av.Name = "MarvisAvatar"
        av.Image = img
        av.BackgroundTransparency = 1
        av.AnchorPoint = Vector2.new(0, 0.5)
        av.Position = UDim2.new(0, 4, 0.5, 0)
        av.Size = UDim2.new(0, 26, 0, 26)
        av.ZIndex = 99
        av.Parent = box

        local avCorner = Instance.new("UICorner")
        avCorner.CornerRadius = UDim.new(0, 6)
        avCorner.Parent = av

        nameLbl = Instance.new("TextLabel")
        nameLbl.Name = "MarvisAvatarName"
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.Text = plr.DisplayName
        nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLbl.TextSize = 12
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.AnchorPoint = Vector2.new(0, 0.5)
        nameLbl.Position = UDim2.new(0, 36, 0, 9)
        nameLbl.Size = UDim2.new(0, 92, 0, 16)
        nameLbl.ZIndex = 99
        nameLbl.Parent = box

        idLbl = Instance.new("TextLabel")
        idLbl.Name = "MarvisAvatarId"
        idLbl.BackgroundTransparency = 1
        idLbl.Font = Enum.Font.Gotham
        idLbl.Text = "@" .. plr.Name
        idLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        idLbl.TextSize = 10
        idLbl.TextXAlignment = Enum.TextXAlignment.Left
        idLbl.AnchorPoint = Vector2.new(0, 0.5)
        idLbl.Position = UDim2.new(0, 36, 0, 22)
        idLbl.Size = UDim2.new(0, 92, 0, 12)
        idLbl.ZIndex = 99
        idLbl.Parent = box
    end
    createBox()

    RunService.RenderStepped:Connect(function(dt)
        if not win.Parent then
            if box then box:Destroy() end
            return
        end
        if not box or not box.Parent then
            createBox()
        end
    end)
end

task.spawn(addAvatar)

task.spawn(function()
    task.wait(1.5)
    local openBtnGrad = nil
    while true do
        local btn = Window and Window.OpenButtonMain and Window.OpenButtonMain.Button
        if btn then
            btn.BackgroundTransparency = 0.6
            local stroke = btn:FindFirstChildOfClass("UIStroke")
            if stroke then
                pcall(function()
                    if not openBtnGrad then
                        local grad = stroke.UIGradient
                        local kpts = {}
                        for i = 0, 11 do
                            kpts[i + 1] = ColorSequenceKeypoint.new(i / 11, Color3.fromHSV(i / 11, 1, 1))
                        end
                        grad.Color = ColorSequence.new(kpts)
                        grad.Rotation = 0
                        openBtnGrad = grad
                    end
                    stroke.Thickness = 4
                end)
            end
            if openBtnGrad then
                openBtnGrad.Rotation = (openBtnGrad.Rotation + 1.3) % 360
            end
        end
        task.wait(1 / 30)
    end
end)

task.spawn(function()
    task.wait(1.5)
    local clockLbl
    local clockGrad
    local function ensureClock()
        if clockLbl and clockLbl.Parent then return true end
        local win = WinRef
        if not win or not win.Parent then return false end
        clockLbl = Instance.new("TextLabel")
        clockLbl.Name = "MarvisClock"
        clockLbl.BackgroundTransparency = 1
        clockLbl.Font = Enum.Font.GothamBold
        clockLbl.TextSize = 18
        clockLbl.Text = "00:00:00"
        clockLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        clockLbl.AnchorPoint = Vector2.new(0, 0.5)
        clockLbl.Size = UDim2.new(0, 96, 0, 22)
        clockLbl.ZIndex = 120
        clockLbl.Parent = win
        pcall(function()
            local g = clockLbl.UIGradient
            local kpts = {}
            for i = 0, 11 do
                kpts[i + 1] = ColorSequenceKeypoint.new(i / 11, Color3.fromHSV(i / 11, 1, 1))
            end
            g.Color = ColorSequence.new(kpts)
            g.Rotation = 0
            clockGrad = g
        end)
        return true
    end
    local function findTitle(win)
        for _, d in ipairs(win:GetDescendants()) do
            if d:IsA("TextLabel") and d.Text == "XJW ui" then
                return d
            end
        end
        return nil
    end
    while true do
        pcall(function()
            if ensureClock() then
                local win = WinRef
                if win and win.Parent then
                    clockLbl.Visible = win.Visible
                    if win.Visible then
                        local title = findTitle(win)
                        if title then
                            local winPos = win.AbsolutePosition
                            local tPos = title.AbsolutePosition
                            local yOff = (tPos.Y - winPos.Y) + (title.AbsoluteSize.Y - 22) / 2 + 12
                            clockLbl.Position = UDim2.fromOffset(tPos.X - winPos.X + title.AbsoluteSize.X + 8, yOff)
                        else
                            clockLbl.Position = UDim2.new(1, -72, 0, 32)
                        end
                        local t = os.date("*t")
                        clockLbl.Text = string.format("%02d:%02d:%02d", t.hour, t.min, t.sec)
                        if clockGrad then
                            clockGrad.Rotation = (clockGrad.Rotation + 1.3) % 360
                        else
                            clockLbl.TextColor3 = Color3.fromHSV((os.clock() * 0.3) % 1, 1, 1)
                        end
                    end
                end
            end
        end)
        task.wait(1 / 30)
    end
end)

local BIG_ICON = 46
task.spawn(function()
    task.wait(1.5)
    while true do
        if Window then
            pcall(function()
                for _, d in ipairs(Window:GetDescendants()) do
                    if d:IsA("Frame") and d.Name == "Topbar" then
                        local left = d:FindFirstChild("Left")
                        if left then
                            for _, ch in ipairs(left:GetChildren()) do
                                if ch:IsA("Frame") and ch:FindFirstChildOfClass("ImageLabel") then
                                    ch.Size = UDim2.fromOffset(BIG_ICON, BIG_ICON)
                                end
                            end
                            for _, lbl in ipairs(left:GetDescendants()) do
                                if lbl:IsA("TextLabel") and lbl.Text == "XJW ui" then
                                    lbl.TextSize = 26
                                end
                            end
                        end
                    end
                    if d:IsA("TextLabel") and d.Text == "制作:Xavi" then
                        d.TextSize = 20
                    end
                end
            end)
        end
        task.wait(0.3)
    end
end)
