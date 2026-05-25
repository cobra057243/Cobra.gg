local success, err = pcall(function()
local repo = "https://raw.githubusercontent.com/SAINTLTM53/Random/refs/heads/main/"
local Library = loadstring(game:HttpGet(repo .. "FUcker.lua"))()

        if _G.Cobragg_LOADED then
            warn("Cobra.gg already loading Stop Spamming Dickhead.")
            return
        end
        _G.Cobragg_LOADED = true

        local originalUnload = Library and Library.Unload
        if Library then
            Library.Unload = function(...)
                _G.Cobragg_LOADED = nil
                return originalUnload and originalUnload(...)
            end
        end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local PlaceId = game.PlaceId
local JobId = game.JobId
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")
local Terrain = workspace:WaitForChild("Terrain")
local Clouds = Terrain:FindFirstChildOfClass("Clouds") or Instance.new("Clouds", Terrain)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local HRP = Character:WaitForChild("HumanoidRootPart")

local Options = Library.Options
local Toggles = Library.Toggles
local Window = Library:CreateWindow({
    Title = "Universal",
    Footer = "v1.0.5 | Made By: Cobra | Status:Free | Executor: " .. identifyexecutor(),
    NotifySide = "Right",
    ShowCustomCursor = true,
})

    local Tabs = {
        Player = Window:AddTab("Player", "user"),
		Combat = Window:AddTab("Combat", "target"),
        World = Window:AddTab("World", "eye"),
		Settings = Window:AddTab("Settings", "settings"),
    }

local SettingsGroup = Tabs.Settings:AddLeftGroupbox("Options")

SettingsGroup:AddLabel("Made by: Cobra")

SettingsGroup:AddButton({
    Text = "Unload Script",
    Func = function()
        Library:Unload()
    end,
    DoubleClick = false,
    ShowCustomCursor = false
})

SettingsGroup:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
    Default = "Insert",
    NoUI = true,
    Text = "Menu Keybind"
})
Library.ToggleKeybind = Options.MenuKeybind

	SettingsGroup:AddButton("Load Dex Explorer", function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
	end)

local ServerGroup = Tabs.Settings:AddRightGroupbox("Server")

ServerGroup:AddButton({
    Text = "Join Low Server",
    Func = function()
        local ApiUrl = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceId)

        local function GetServerList(cursor)
            local Endpoint = ApiUrl .. (cursor and ("&cursor=" .. cursor) or "")
            local Success, Response = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(Endpoint))
            end)
            return Success and Response or nil
        end

        local NextCursor
        local FoundServer

        repeat
            local ServerList = GetServerList(NextCursor)
            if not ServerList then break end

            for _, Server in ipairs(ServerList.data) do
                if Server.playing < Server.maxPlayers and Server.id ~= game.JobId then
                    FoundServer = Server
                    break
                end
            end

            NextCursor = ServerList.nextPageCursor
        until FoundServer or not NextCursor

        if FoundServer then
            TeleportService:TeleportToPlaceInstance(PlaceId, FoundServer.id, LocalPlayer)
        else
            warn("No server found.")
        end
    end,
})

ServerGroup:AddButton("Rejoin Server", function()
	if #Players:GetPlayers() <= 1 then
		TeleportService:Teleport(PlaceId, LocalPlayer)
	else
		TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
	end
end)

local MaxPlayersInput = "19"
ServerGroup:AddInput("MaxPlayersInput", {
    Text = "Max Players (default 19)",
    Default = MaxPlayersInput,
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        MaxPlayersInput = Value
    end
})

ServerGroup:AddButton({
    Text = "Server Hop",
    Func = function()
        local ApiUrl = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(PlaceId)

        local function GetServerList(Cursor)
            local Url = ApiUrl .. (Cursor and ("&cursor=" .. Cursor) or "")
            local Success, Result = pcall(function()
                return HttpService:JSONDecode(game:HttpGet(Url))
            end)
            return Success and Result or nil
        end

        local MaxPlayers = tonumber(MaxPlayersInput) or 19
        local NextCursor
        local FoundServer

        repeat
            local ServerList = GetServerList(NextCursor)
            if not ServerList then break end

            for _, Server in ipairs(ServerList.data) do
                if Server.playing < MaxPlayers and Server.id ~= game.JobId then
                    FoundServer = Server
                    break
                end
            end

            NextCursor = ServerList.nextPageCursor
        until FoundServer or not NextCursor

        if FoundServer then
            TeleportService:TeleportToPlaceInstance(PlaceId, FoundServer.id, LocalPlayer)
        else
            warn("No server found.")
        end
    end
})

local JoinInput = ServerGroup:AddInput("JoinJobOrPlace", {
	Text = "JobId / PlaceId",
	Default = "",
	Placeholder = "JobId or PlaceId",
	Numeric = false,
	Finished = false,
})

ServerGroup:AddButton("Join Job/Place", function()
	local value = JoinInput.Value
	if not value or value == "" then return end

	value = tostring(value):gsub("%s+", "")

	if value:find("%-") then
		pcall(function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId, value, LocalPlayer)
		end)
	else
		local placeId = tonumber(value)
		if placeId then
			pcall(function()
				TeleportService:Teleport(placeId, LocalPlayer)
			end)
		end
	end
end)

ServerGroup:AddButton("Copy JobId", function()
	if setclipboard then
		setclipboard(game.JobId)
        Library:Notify("Copied Place Id", 3)
	end
end)

local PlayerBox = Tabs.Player:AddLeftGroupbox("Player Mods")

local SpeedBoostValue = 8
local WalkSpeedChangerEnabled = false
local WalkSpeedConnection, HumanoidConnection = nil, nil

local OG_HipHeight = 2.2144851207733154
local Safe_HipHeight = 2

local function stopBypassFly()
    if WalkSpeedConnection then
        WalkSpeedConnection:Disconnect()
        WalkSpeedConnection = nil
    end
    if HumanoidConnection then
        HumanoidConnection:Disconnect()
        HumanoidConnection = nil
    end

    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.HipHeight = OG_HipHeight
    end
end

local function startBypassFly(char)
    stopBypassFly()

    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")
    Humanoid.HipHeight = Safe_HipHeight

    HumanoidConnection = hum.Died:Connect(function()
        stopBypassFly()
    end)

    WalkSpeedConnection = RunService.RenderStepped:Connect(function(dt)
        if not WalkSpeedChangerEnabled then return end
        if hum and hum.Health > 0 then
            if hum:GetState() ~= Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.FallingDown)
                hum:ChangeState(Enum.HumanoidStateType.Freefall)
            end
            local dir = hum.MoveDirection
            if dir.Magnitude > 0 then
                hrp.CFrame += dir.Unit * SpeedBoostValue * dt
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if WalkSpeedChangerEnabled then
        task.wait(0.5)
        startBypassFly(char)
    end
end)

if LocalPlayer.Character then
    task.defer(function()
        if WalkSpeedChangerEnabled then
            startBypassFly(LocalPlayer.Character)
        end
    end)
end

PlayerBox:AddSlider('WalkSpeedSlider', {
    Text = 'WalkSpeed',
    Default = 8,
    Min = 1,
    Max = 1000,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        SpeedBoostValue = Value
        Library:Notify("WalkSpeed slider set to " .. Value, 3)
    end
})

local Flying = false
local FlySpeed = 75
local FlyConnection
local AnimationTrack
local AnimationThread

local AnimationId = "rbxassetid://99870380291426"

PlayerBox:AddSlider("FlySpeedSlider", {
	Text = "Change Fly Speed",
	Default = 75,
	Min = 10,
	Max = 100,
	Rounding = 1,
	Callback = function(value)
		FlySpeed = value
	end,
})

local function StartFlyAnimation(Humanoid)
	if AnimationTrack then
		AnimationTrack:Stop()
	end

	local anim = Instance.new("Animation")
	anim.AnimationId = AnimationId

	AnimationTrack = Humanoid:LoadAnimation(anim)
	AnimationTrack.Looped = true
	AnimationTrack:Play()
end

local function StartFly()
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local Humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")

	Flying = true

	local position = root.Position

	AnimationThread = task.spawn(function()
		while Flying do
			StartFlyAnimation(Humanoid)
			task.wait(3)
		end
	end)

	FlyConnection = RunService.Heartbeat:Connect(function(delta)
		if not Flying then return end

		local camCF = Camera.CFrame
		local moveDir = Humanoid.MoveDirection

		local direction
		if moveDir.Magnitude == 0 then
			direction = Vector3.zero
		else
			local localDir = camCF:VectorToObjectSpace(moveDir)
			direction = camCF:VectorToWorldSpace(
				Vector3.new(localDir.X, 0, localDir.Z).Unit * localDir.Magnitude
			)
		end

		position += direction * FlySpeed * delta

		root.CFrame = CFrame.new(
			position,
			camCF.Position + (position - camCF.Position) * 2
		)

		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
	end)
end

local function StopFly()
	Flying = false

	if FlyConnection then
		FlyConnection:Disconnect()
		FlyConnection = nil
	end

	if AnimationTrack then
		AnimationTrack:Stop()
		AnimationTrack = nil
	end

	if AnimationThread then
		task.cancel(AnimationThread)
		AnimationThread = nil
	end
end

PlayerBox:AddToggle("FlyToggle", {
	Text = "Enable Fly",
	Default = false,
	Callback = function(state)
		if state then
			StartFly()
		else
			StopFly()
		end
	end,
})

PlayerBox:AddToggle('WalkSpeedToggle', {
    Text = 'WalkSpeed Toggle',
    Default = false,
    Callback = function(Value)
        WalkSpeedChangerEnabled = Value
        Library:Notify("WalkSpeed Toggled " .. (Value and "On" or "Off"), 3)

        if Value and LocalPlayer.Character then
            startBypassFly(LocalPlayer.Character)
        else
            stopBypassFly()
        end
    end
})

local ctrl = {f = 0, b = 0, l = 0, r = 0}

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or not flying then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then ctrl.f = 1 end
    if key == Enum.KeyCode.S then ctrl.b = -1 end
    if key == Enum.KeyCode.A then ctrl.l = -1 end
    if key == Enum.KeyCode.D then ctrl.r = 1 end
end)

UserInputService.InputEnded:Connect(function(input)
    local key = input.KeyCode
    if key == Enum.KeyCode.W then ctrl.f = 0 end
    if key == Enum.KeyCode.S then ctrl.b = 0 end
    if key == Enum.KeyCode.A then ctrl.l = 0 end
    if key == Enum.KeyCode.D then ctrl.r = 0 end
end)

    PlayerBox:AddToggle('InstantInteract', {
        Text = 'Instant Interact',
        Default = false,
        Callback = function(Value)
            local excludedFolder = workspace:FindFirstChild("HouseRobb")
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and (not excludedFolder or not v:IsDescendantOf(excludedFolder)) then
                    v.HoldDuration = Value and 0 or 1
                    v.RequiresLineOfSight = not Value
                end
            end
            Library:Notify("Instant Interact Toggled", 3)
        end
    })

_G.InfJumpEnabled = false
local isHoldingSpace = false
local infJumpBounce = false

local function TryJump()
    if not _G.InfJumpEnabled or infJumpBounce then
        return
    end

    if not Character then return end

    local hum = Character:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end

    if not hum:GetStateEnabled(Enum.HumanoidStateType.Jumping) then
        return
    end

    infJumpBounce = true
    hum:ChangeState(Enum.HumanoidStateType.Jumping)
    task.wait()
    infJumpBounce = false
end

UserInputService.JumpRequest:Connect(function()
    TryJump()
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == Enum.KeyCode.Space then
        isHoldingSpace = true
        while isHoldingSpace do
            TryJump()
            task.wait()
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        isHoldingSpace = false
    end
end)

PlayerBox:AddToggle('InfJumpToggle', {
    Text = 'Infinite Jump',
    Default = false,
    Callback = function(Value)
        _G.InfJumpEnabled = Value
    end
})

local function getHumanoid()
	local char = LocalPlayer.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

local PLACE_ID = game.PlaceId

local NoClipHandler = {}
NoClipHandler.__index = NoClipHandler

function NoClipHandler.new()
	local self = setmetatable({}, NoClipHandler)
	self.character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	self.enabled = false
	self.freezeThreads = {}
	self.extraPart = nil
	return self
end

function NoClipHandler:AddExtraPart()
	if self.extraPart and self.extraPart.Parent then
		return
	end

	local part = Instance.new("Part")
	part.Name = "Part" 
	part.Size = Vector3.new(1, 1, 1)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = true 
	part.Parent = self.character

	self.extraPart = part
end

local function FreezeCollide(handler, basePart)
	while handler.enabled and basePart and basePart.Parent do
		basePart.CanCollide = false
		task.wait(0.05)
	end
end

function NoClipHandler:Enable()
	if self.enabled then return end
	self.enabled = true

	for _, obj in ipairs(self.character:GetChildren()) do
		if obj:IsA("BasePart") and obj ~= self.extraPart then
			task.spawn(FreezeCollide, self, obj)
		end
	end

	if self.extraPart then
		self.extraPart.CanCollide = false
	end
end

function NoClipHandler:Disable()
	if not self.enabled then return end
	self.enabled = false

	for _, obj in ipairs(self.character:GetChildren()) do
		if obj:IsA("BasePart") then
			obj.CanCollide = true
		end
	end

	if self.extraPart then
		self.extraPart.CanCollide = true
	end
end

local NoclippingConnection = nil

local function EnableNoclip()

	NoclippingConnection = RunService.RenderStepped:Connect(function()
		local character = LocalPlayer.Character
		if not character then return end

		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end)
end

local function DisableNoclip()

	if NoclippingConnection then
		NoclippingConnection:Disconnect()
		NoclippingConnection = nil
	end
end

local Method1Handler = nil

local function SetupMethod1()
	Method1Handler = NoClipHandler.new()
	Method1Handler:AddExtraPart()
end

LocalPlayer.CharacterAdded:Connect(function()
	if PLACE_ID == 10179538382 then
		task.wait(1)
		SetupMethod1()
	end
end)

if PLACE_ID == 10179538382 then
	SetupMethod1()

	PlayerBox:AddToggle("NoclipToggle", {
		Text = "Noclip",
		Default = false,
		Callback = function(enabled)
			if not Method1Handler then return end

			if enabled then
				Method1Handler:Enable()
			else
				Method1Handler:Disable()
			end
		end
	})
else
	PlayerBox:AddToggle("NoclipToggle", {
		Text = "Noclip",
		Default = false,
		Callback = function(enabled)
			if enabled then
				EnableNoclip()
			else
				DisableNoclip()
			end
		end
	})
end

local nameTagGui = nil
local function enableBypassHubNameTag()
    Library:Notify("NameTag Enabled")

    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local head = character:WaitForChild("Head", 5)
    if not head then return end

    if nameTagGui then
        nameTagGui:Destroy()
    end

    nameTagGui = Instance.new("BillboardGui")
    nameTagGui.Name = "Foundation"
    nameTagGui.Size = UDim2.new(0, 300, 0, 40) 
    nameTagGui.StudsOffset = Vector3.new(0, 2.5, 0) 
    nameTagGui.AlwaysOnTop = true
    nameTagGui.MaxDistance = 150
    nameTagGui.LightInfluence = 1
    nameTagGui.Adornee = head
    nameTagGui.Parent = head

    local label = Instance.new("TextLabel")
    label.Name = "Foundation"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = "Cobra.gg #1"
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 22 
    label.TextColor3 = Color3.fromRGB(197, 191, 191)
    label.TextStrokeTransparency = 0.25
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = nameTagGui
end

local function disableBypassHubNameTag()
    if nameTagGui then
        nameTagGui:Destroy()
        nameTagGui = nil
        Library:Notify("NameTag Disabled")
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if _G.ShowBypassNameTag then
        enableBypassHubNameTag()
    end
end)

PlayerBox:AddToggle("Cobra.gg NameTag", {
    Text = "Cobra.gg NameTag",
    Default = false,
    Callback = function(state)
        _G.ShowBypassNameTag = state
        if state then
            enableBypassHubNameTag()
        else
            disableBypassHubNameTag()
        end
    end
})

local CoreGui, Players, TextService = game:GetService("CoreGui"), game:GetService("Players"), game:GetService("TextService")
local spyOn, conns, GUI, list, scroll = false, {}, nil, nil, nil

local function addMsg(p, msg)
	if not scroll then return end
	local l = Instance.new("TextLabel")
	l.Text = "[" .. p.Name .. "]: " .. msg
	l.TextWrapped, l.TextXAlignment, l.TextColor3 = true, Enum.TextXAlignment.Left, Color3.fromRGB(230, 230, 230)
	l.Font, l.TextSize, l.Size, l.BackgroundTransparency, l.Parent = Enum.Font.SourceSans, 14, UDim2.new(1, -10, 0, 0), 1, scroll

	local size = TextService:GetTextSize(l.Text, 14, l.Font, Vector2.new(scroll.AbsoluteSize.X - 20, math.huge))
	l.Size = UDim2.new(1, -10, 0, size.Y + 4)

	local y = list.AbsoluteContentSize.Y
	scroll.CanvasSize = UDim2.new(0, 0, 0, y)
	scroll.CanvasPosition = Vector2.new(0, y)
end

local function connect(p)
	table.insert(conns, p.Chatted:Connect(function(m) addMsg(p, m) end))
end

local function setup()
	GUI = Instance.new("ScreenGui", CoreGui)
	GUI.Name, GUI.ResetOnSpawn = "ChatSpyUI", false

	local f = Instance.new("Frame", GUI)
	f.Size, f.Position = UDim2.new(0, 350, 0, 220), UDim2.new(0, 10, 0.5, -110)
	f.BackgroundColor3, f.BorderColor3, f.Active, f.Draggable = Color3.fromRGB(25, 25, 25), Color3.fromRGB(80, 80, 80), true, true

	local t = Instance.new("TextLabel", f)
	t.Size, t.Text, t.TextColor3, t.Font, t.TextSize = UDim2.new(1, 0, 0, 20), "Chat Spy", Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 16
	t.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

	scroll = Instance.new("ScrollingFrame", f)
	scroll.Size, scroll.Position = UDim2.new(1, 0, 1, -20), UDim2.new(0, 0, 0, 20)
	scroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	scroll.ScrollBarImageColor3, scroll.CanvasSize, scroll.BorderSizePixel = Color3.fromRGB(150, 150, 150), UDim2.new(), 0

	list = Instance.new("UIListLayout", scroll)
	list.SortOrder, list.Padding, list.HorizontalAlignment = Enum.SortOrder.LayoutOrder, UDim.new(0, 3), Enum.HorizontalAlignment.Center
end

_G.ToggleChatSpy = function(on)
	if on then
		if spyOn then return end
		spyOn = true
		setup()
		for _, p in ipairs(Players:GetPlayers()) do connect(p) end
		table.insert(conns, Players.PlayerAdded:Connect(connect))
	else
		spyOn = false
		if GUI then GUI:Destroy() end
		for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
		table.clear(conns)
	end
end

PlayerBox:AddToggle("ChatSpy", {
    Text = "Chat Spy",
    Default = false,
    Tooltip = "View all player chat messages.",
}):OnChanged(function(val)
    if val then
        _G.ToggleChatSpy(true)
    else
        _G.ToggleChatSpy(false) 
    end
end)

local ResetBindable
local ResetEnabled = false
local CharacterAddedConnection

local function BindResetButton()
	if not ResetEnabled then return end

	if ResetBindable then
		ResetBindable:Destroy()
	end

	ResetBindable = Instance.new("BindableEvent")

	ResetBindable.Event:Connect(function()
		local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local Humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			Humanoid.Health = 0
		end
	end)

	StarterGui:SetCore("ResetButtonCallback", ResetBindable)
end

local function UnbindResetButton()
	if ResetBindable then
		ResetBindable:Destroy()
		ResetBindable = nil
	end

	pcall(function()
		StarterGui:SetCore("ResetButtonCallback", true)
	end)
end

CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.5)
	if ResetEnabled then
		BindResetButton()
	end
end)

PlayerBox:AddToggle("ResetKillToggle", {
	Text = "Enable Reset Button",
	Default = false,
	Callback = function(state)
		ResetEnabled = state

		if state then
			BindResetButton()
		else
			UnbindResetButton()
		end
	end,
})

local WallDeleteConnections = {}

PlayerBox:AddToggle("WallDelete", {
    Text = "Delete Wall (E)",
    Callback = function(state)
        local TargetPart = nil

        if state then
            WallDeleteConnections.Render = RunService.RenderStepped:Connect(function()
                local target = Mouse.Target
                if target and target:IsA("BasePart") then
                    TargetPart = target
                else
                    TargetPart = nil
                end
            end)

            WallDeleteConnections.Input = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end

                if input.KeyCode == Enum.KeyCode.E and TargetPart then
                    TargetPart:Destroy()
                    TargetPart = nil
                end
            end)
        else
            for _, conn in pairs(WallDeleteConnections) do
                if conn then conn:Disconnect() end
            end
            table.clear(WallDeleteConnections)
        end
    end
})

local JerkEnabled = false
local Tool
local Track
local LoopThread

local function IsR15(character)
	local Humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15
end

local function StopJerk()
	if LoopThread then
		task.cancel(LoopThread)
		LoopThread = nil
	end

	if Track then
		Track:Stop()
		Track = nil
	end

	if Tool then
		Tool:Destroy()
		Tool = nil
	end
end

local function StartJerk()
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local Humanoid = character:FindFirstChildOfClass("Humanoid")
	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
	if not Humanoid or not backpack then return end

	Tool = Instance.new("Tool")
	Tool.Name = "Jerk Off"
	Tool.RequiresHandle = false
	Tool.Parent = backpack

	local jerkin = false

	Tool.Equipped:Connect(function()
		jerkin = true
	end)

	Tool.Unequipped:Connect(function()
		jerkin = false
		if Track then
			Track:Stop()
			Track = nil
		end
	end)

	Humanoid.Died:Connect(StopJerk)

	LoopThread = task.spawn(function()
		while JerkEnabled do
			if not jerkin then
				task.wait()
				continue
			end

			local isR15 = IsR15(character)

			if not Track then
				local anim = Instance.new("Animation")
				anim.AnimationId = isR15
					and "rbxassetid://698251653"
					or "rbxassetid://72042024"

				Track = Humanoid:LoadAnimation(anim)
			end

			Track:Play()
			Track:AdjustSpeed(isR15 and 0.7 or 0.65)
			Track.TimePosition = 0.6

			task.wait(0.1)

			while Track and Track.TimePosition < (isR15 and 0.7 or 0.65) do
				task.wait(0.1)
			end

			if Track then
				Track:Stop()
				Track = nil
			end
		end
	end)
end

PlayerBox:AddToggle("JerkToggle", {
	Text = "Jerk Off",
	Default = false,
	Callback = function(state)
		JerkEnabled = state

		if state then
			StartJerk()
		else
			StopJerk()
		end
	end,
})

local HumanoidStates = {
	"Running",
	"RunningNoPhysics",
	"Swimming",
	"Freefall",
	"Jumping",
	"Climbing",
	"Seated",
	"Landed",
	"Ragdoll",
	"GettingUp",
	"FallingDown",
	"Physics",
	"PlatformStanding",
	"StrafingNoPhysics",
	"Flying",
	"Dead",
}

local StateMap = {}
for _, name in ipairs(HumanoidStates) do
	StateMap[name] = Enum.HumanoidStateType[name]
end

local ForcedState = nil
local StateLoopConn

local StateDropdown = PlayerBox:AddDropdown("HumanoidStateDropdown", {
	Text = "Humanoid State Changer",
	Values = HumanoidStates,
	Default = "Running",
})

local function stopStateLoop()
	if StateLoopConn then
		StateLoopConn:Disconnect()
		StateLoopConn = nil
	end
	ForcedState = nil
end

local function startStateLoop(state)
	stopStateLoop()
	ForcedState = state

	StateLoopConn = RunService.Heartbeat:Connect(function()
		local hum = getHumanoid()
		if not hum or not ForcedState then return end

		pcall(function()
			hum:SetStateEnabled(ForcedState, true)
		end)

		if hum:GetState() ~= ForcedState then
			hum:ChangeState(ForcedState)
		end
	end)
end

StateDropdown:OnChanged(function(stateName)
	local state = StateMap[stateName]
	if not state then return end

	startStateLoop(state)
	Library:Notify("State locked: " .. stateName, 2)
end)

PlayerBox:AddButton("Reset State", function()
	stopStateLoop()

	local hum = getHumanoid()
	if hum then
		pcall(function()
			hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
		end)
		hum:ChangeState(Enum.HumanoidStateType.Running)
	end

	Library:Notify("State reset to Running", 2)
end)

PlayerBox:AddLabel("Some Features Wont Work On\nAll Games Like South Bronx")

local ESPBox = Tabs.World:AddLeftGroupbox("Visuals")

local ESPManager = {}
ESPManager.__index = ESPManager

ESPManager.Settings = {
	Enabled = false,
	RenderDistance = 1000,
	
	BoxColor = Color3.fromRGB(142, 104, 231),
	TracerColor = Color3.fromRGB(255, 255, 255),
	TextColor = Color3.fromRGB(255, 255, 255),
	ChamsColor = Color3.fromRGB(142, 104, 231),
	
	Size = 1, 
	
	Features = {
		Box = false,
		Name = false,
		Health = false,
		Tracer = false,
		Distance = false,
		Weapon = false,
		Chams = false,
	},
}

ESPManager.PlayerESPs = {} 

local PlayerESP = {}
PlayerESP.__index = PlayerESP

function PlayerESP.new(player)
	local self = setmetatable({}, PlayerESP)
	
	self.Player = player
	self.Drawings = {}
	self.Highlight = nil
	self.Connections = {}
	
	self:CreateDrawings()
	self:SetupConnections()
	
	return self
end

function PlayerESP:CreateDrawings()
	local function newDrawing(type, props)
		local obj = Drawing.new(type)
		for k, v in pairs(props or {}) do
			obj[k] = v
		end
		obj.Visible = false
		return obj
	end

	self.Drawings = {
		Box = {
			TopLeftH = newDrawing("Line", {Thickness = 2}),
			TopLeftV = newDrawing("Line", {Thickness = 2}),
			TopRightH = newDrawing("Line", {Thickness = 2}),
			TopRightV = newDrawing("Line", {Thickness = 2}),
			BottomLeftH = newDrawing("Line", {Thickness = 2}),
			BottomLeftV = newDrawing("Line", {Thickness = 2}),
			BottomRightH = newDrawing("Line", {Thickness = 2}),
			BottomRightV = newDrawing("Line", {Thickness = 2}),
		},
		HealthBar = newDrawing("Line", {Thickness = 3}),
		HealthText = newDrawing("Text", {Size = 6, Center = true, Outline = true, Font = 2}),
		Name = newDrawing("Text", {Size = 6, Center = true, Outline = true, Font = 2}),
		Distance = newDrawing("Text", {Size = 6, Center = true, Outline = true, Font = 2}),
		Weapon = newDrawing("Text", {Size = 6, Center = true, Outline = true, Font = 2}),
		Tracer = newDrawing("Line", {Thickness = 1}),
	}
end

function PlayerESP:SetupConnections()
	table.insert(self.Connections, self.Player.CharacterAdded:Connect(function(Character)
		task.wait(0.3)
		local hum = Character:WaitForChild("Humanoid", 5)
		if hum then
			hum.Died:Connect(function()
				self:Hide()
			end)
		end
	end))

	table.insert(self.Connections, self.Player.AncestryChanged:Connect(function()
		if not self.Player:IsDescendantOf(game.Players) then
			self:Destroy()
		end
	end))
	
	if self.Player.Character then
		local hum = self.Player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			table.insert(self.Connections, hum.Died:Connect(function()
				self:Hide()
			end))
		end
	end
end

function PlayerESP:Destroy()
	for _, obj in pairs(self.Drawings) do
		if typeof(obj) == "table" then
			for _, v in pairs(obj) do
				pcall(function() v:Remove() end)
			end
		else
			pcall(function() obj:Remove() end)
		end
	end

	if self.Highlight then
		pcall(function() self.Highlight:Destroy() end)
		self.Highlight = nil
	end

	for _, conn in ipairs(self.Connections) do
		pcall(function() conn:Disconnect() end)
	end
	
	table.clear(self.Connections)
	table.clear(self.Drawings)

	ESPManager.PlayerESPs[self.Player] = nil
end

function PlayerESP:Hide()
	for _, obj in pairs(self.Drawings) do
		if typeof(obj) == "table" then
			for _, v in pairs(obj) do v.Visible = false end
		elseif obj.Visible ~= nil then
			obj.Visible = false
		end
	end
	
	if self.Highlight then
		self.Highlight.Enabled = false
	end
end

function PlayerESP:Update()
	if not ESPManager.Settings.Enabled then return end

	local Character = self.Player.Character
	if not Character then self:Hide() return end

	local hrp = Character:FindFirstChild("HumanoidRootPart")
	local head = Character:FindFirstChild("Head")
	local hum = Character:FindFirstChildOfClass("Humanoid")

	if not (hrp and head and hum) or hum.Health <= 0 then
		self:Hide()
		return
	end

	local origin = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not origin then self:Hide() return end

	local dist = (origin.Position - hrp.Position).Magnitude
	if dist > ESPManager.Settings.RenderDistance then
		self:Hide()
		return
	end

	local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
	local rootPos, rootOnScreen = Camera:WorldToViewportPoint(hrp.Position)
	local feetPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

	if not headOnScreen or not rootOnScreen or headPos.Z < 0 then
		self:Hide()
		return
	end

	local h = math.abs(headPos.Y - feetPos.Y)
	local w = h / 1.5
	local x = rootPos.X - w / 2
	local y = rootPos.Y - h / 2

	local sizeMult = ESPManager.Settings.Size

	local box = self.Drawings.Box
	local visibleBox = ESPManager.Settings.Features.Box
	local boxColor = ESPManager.Settings.BoxColor

	for _, seg in pairs(box) do
		seg.Visible = visibleBox
		seg.Color = boxColor
		seg.Thickness = 2 * sizeMult
	end

	if visibleBox then
		local len = w * 0.25
		box.TopLeftH.From = Vector2.new(x, y);           box.TopLeftH.To = Vector2.new(x + len, y)
		box.TopLeftV.From = Vector2.new(x, y);           box.TopLeftV.To = Vector2.new(x, y + len)
		box.TopRightH.From = Vector2.new(x + w - len, y); box.TopRightH.To = Vector2.new(x + w, y)
		box.TopRightV.From = Vector2.new(x + w, y);       box.TopRightV.To = Vector2.new(x + w, y + len)
		box.BottomLeftH.From = Vector2.new(x, y + h);     box.BottomLeftH.To = Vector2.new(x + len, y + h)
		box.BottomLeftV.From = Vector2.new(x, y + h - len); box.BottomLeftV.To = Vector2.new(x, y + h)
		box.BottomRightH.From = Vector2.new(x + w - len, y + h); box.BottomRightH.To = Vector2.new(x + w, y + h)
		box.BottomRightV.From = Vector2.new(x + w, y + h - len); box.BottomRightV.To = Vector2.new(x + w, y + h)
	end

	local health = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
	local healthVal = math.floor(hum.Health)

	local healthBar = self.Drawings.HealthBar
	local healthText = self.Drawings.HealthText

	local healthVisible = ESPManager.Settings.Features.Health
	healthBar.Visible = healthVisible
	healthText.Visible = healthVisible

	if healthVisible then
		local bh = h * health
		healthBar.From = Vector2.new(x - 6, y + h)
		healthBar.To = Vector2.new(x - 6, y + h - bh)
		healthBar.Thickness = 3

		local barColor = (healthVal <= 35 and Color3.fromRGB(255, 0, 0))
			or (healthVal <= 70 and Color3.fromRGB(255, 165, 0))
			or Color3.fromRGB(0, 255, 100)

		healthBar.Color = barColor
		healthText.Color = barColor
		healthText.Text = tostring(healthVal)
		healthText.Position = Vector2.new(x - 20, y + h - bh - 8)
		healthText.Size = 13 * sizeMult
	end

	local name = self.Drawings.Name
	name.Visible = ESPManager.Settings.Features.Name
	if name.Visible then
		name.Text = self.Player.Name
		name.Position = Vector2.new(x + w / 2, y - 18)
		name.Color = ESPManager.Settings.TextColor
		name.Size = 13 * sizeMult
	end

	local distTxt = self.Drawings.Distance
	distTxt.Visible = ESPManager.Settings.Features.Distance
	if distTxt.Visible then
		distTxt.Text = ("%dm"):format(math.floor(dist))
		distTxt.Position = Vector2.new(x + w / 2, y + h + 4)
		distTxt.Color = ESPManager.Settings.TextColor
		distTxt.Size = 13 * sizeMult
	end

	local weapon = self.Drawings.Weapon
	weapon.Visible = ESPManager.Settings.Features.Weapon
	if weapon.Visible then
		local tool = Character:FindFirstChildOfClass("Tool")
		weapon.Text = tool and tool.Name or "None"
		weapon.Position = Vector2.new(x + w / 2, y + h + 20)
		weapon.Color = ESPManager.Settings.TextColor
		weapon.Size = 13 * sizeMult
	end

	local tracer = self.Drawings.Tracer
	tracer.Visible = ESPManager.Settings.Features.Tracer
	if tracer.Visible then
		tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y - 15)
		tracer.To = Vector2.new(rootPos.X, rootPos.Y + h / 2)
		tracer.Color = ESPManager.Settings.TracerColor
		tracer.Thickness = 1.5 * sizeMult
	end

if ESPManager.Settings.Features.Chams then
	if not self.Highlight then
		self.Highlight = Instance.new("Highlight")
		self.Highlight.Name = "Chese"
		self.Highlight.Adornee = Character
		self.Highlight.FillTransparency = 0.5
		self.Highlight.OutlineTransparency = 0
		self.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		self.Highlight.Parent = Character
	end

	self.Highlight.Enabled = true

	if self.Player and self.Player.Team and self.Player.Team.Name == "Police" then
		self.Highlight.FillColor = Color3.fromRGB(0, 120, 255) 
	else
		self.Highlight.FillColor = ESPManager.Settings.ChamsColor
	end
else
	if self.Highlight then
		self.Highlight.Enabled = false
	end
end
end

function ESPManager:Update()
	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end

		if not self.PlayerESPs[player] then
			self.PlayerESPs[player] = PlayerESP.new(player)
		end

		self.PlayerESPs[player]:Update()
	end
end

function ESPManager:Clear()
	for _, esp in pairs(self.PlayerESPs) do
		esp:Destroy()
	end
	table.clear(self.PlayerESPs)
end

RunService.RenderStepped:Connect(function()
	if ESPManager.Settings.Enabled then
		ESPManager:Update()
	else
		ESPManager:Clear()
	end
end)

Players.PlayerRemoving:Connect(function(player)
	if ESPManager.PlayerESPs[player] then
		ESPManager.PlayerESPs[player]:Destroy()
	end
end)

Toggles.ESPEnabled = ESPBox:AddToggle("ESPEnabled", {
	Text = "Enable",
	Default = false,
	Tooltip = "Enable/Disable ESP"
})

Toggles.ESPEnabled:OnChanged(function()
	ESPManager.Settings.Enabled = Toggles.ESPEnabled.Value
end)

Options.ESPRenderDistance = ESPBox:AddSlider("ESPRenderDistance", {
	Text = "Render Distance",
	Default = 1000,
	Min = 100,
	Max = 5000,
	Rounding = 0,
	Compact = false,
})

Options.ESPRenderDistance:OnChanged(function()
	ESPManager.Settings.RenderDistance = Options.ESPRenderDistance.Value
end)

Options.ESPSize = ESPBox:AddSlider("ESPSize", {
	Text = "ESP Size",
	Default = 1,
	Min = 1,
	Max = 5,
	Compact = false,
})

Options.ESPSize:OnChanged(function()
	ESPManager.Settings.Size = Options.ESPSize.Value
end)

Toggles.ESPBox = ESPBox:AddToggle("ESPBox", {
	Text = "Box",
	Default = false,
})

Toggles.ESPBox:AddColorPicker("ESPBoxColor", {
	Default = ESPManager.Settings.BoxColor,
	Title = "Box Color",
})

Toggles.ESPBox:OnChanged(function()
	ESPManager.Settings.Features.Box = Toggles.ESPBox.Value
end)

Options.ESPBoxColor:OnChanged(function()
	ESPManager.Settings.BoxColor = Options.ESPBoxColor.Value
end)

Toggles.ESPName = ESPBox:AddToggle("ESPName", {
	Text = "Name",
	Default = false,
})

Toggles.ESPName:AddColorPicker("ESPTextColor", {
	Default = ESPManager.Settings.TextColor,
	Title = "Text Color",
})

Toggles.ESPName:OnChanged(function()
	ESPManager.Settings.Features.Name = Toggles.ESPName.Value
end)

Options.ESPTextColor:OnChanged(function()
	ESPManager.Settings.TextColor = Options.ESPTextColor.Value
end)

Toggles.ESPHealth = ESPBox:AddToggle("ESPHealth", {
	Text = "Health",
	Default = false,
})

Toggles.ESPHealth:OnChanged(function()
	ESPManager.Settings.Features.Health = Toggles.ESPHealth.Value
end)

Toggles.ESPTracer = ESPBox:AddToggle("ESPTracer", {
	Text = "Tracer",
	Default = false,
})

Toggles.ESPTracer:AddColorPicker("ESPTracerColor", {
	Default = ESPManager.Settings.TracerColor,
	Title = "Tracer Color",
})

Toggles.ESPTracer:OnChanged(function()
	ESPManager.Settings.Features.Tracer = Toggles.ESPTracer.Value
end)

Options.ESPTracerColor:OnChanged(function()
	ESPManager.Settings.TracerColor = Options.ESPTracerColor.Value
end)

Toggles.ESPDistance = ESPBox:AddToggle("ESPDistance", {
	Text = "Distance",
	Default = false,
})

Toggles.ESPDistance:OnChanged(function()
	ESPManager.Settings.Features.Distance = Toggles.ESPDistance.Value
end)

Toggles.ESPWeapon = ESPBox:AddToggle("ESPWeapon", {
	Text = "Weapon",
	Default = false,
})

Toggles.ESPWeapon:OnChanged(function()
	ESPManager.Settings.Features.Weapon = Toggles.ESPWeapon.Value
end)

Toggles.ESPChams = ESPBox:AddToggle("ESPChams", {
	Text = "Chams",
	Default = false,
})

Toggles.ESPChams:AddColorPicker("ESPChamsColor", {
	Default = ESPManager.Settings.ChamsColor,
	Title = "Chams Color",
})

Toggles.ESPChams:OnChanged(function()
	ESPManager.Settings.Features.Chams = Toggles.ESPChams.Value
end)

Options.ESPChamsColor:OnChanged(function()
	ESPManager.Settings.ChamsColor = Options.ESPChamsColor.Value
end)

local LightingBox = Tabs.World:AddRightGroupbox("Lighting Modifications")

LightingBox:AddLabel("Ambient"):AddColorPicker("AmbientPicker", {
	Default = Lighting.Ambient,
	Title = "Ambient",
	Callback = function(val)
		Lighting.Ambient = val
	end
})

LightingBox:AddLabel("Outdoor Ambient"):AddColorPicker("OutdoorAmbientPicker", {
	Default = Lighting.OutdoorAmbient,
	Title = "Outdoor Ambient",
	Callback = function(val)
		Lighting.OutdoorAmbient = val
	end
})

LightingBox:AddSlider("BrightnessSlider", {
	Text = "Brightness",
	Min = 0,
	Max = 10,
	Default = Lighting.Brightness or 1,
	Rounding = 2,
	Callback = function(val)
		Lighting.Brightness = val
	end
})

LightingBox:AddSlider("ExposureSlider", {
	Text = "Exposure",
	Min = 0,
	Max = 2,
	Default = Lighting.ExposureCompensation or 0.3,
	Rounding = 2,
	Callback = function(val)
		Lighting.ExposureCompensation = val
	end
})

LightingBox:AddSlider("ClockTimeSlider", {
	Text = "ClockTime",
	Min = 0,
	Max = 24,
	Default = Lighting.ClockTime or 12,
	Rounding = 2,
	Callback = function(val)
		Lighting.ClockTime = val
	end
})

LightingBox:AddToggle("GlobalShadowsToggle", {
	Text = "Shadows",
	Default = Lighting.GlobalShadows,
	Callback = function(val)
		Lighting.GlobalShadows = val
	end
})

LightingBox:AddToggle("CloudsToggle", {
	Text = "Enable Clouds",
	Default = Clouds.Enabled,
	Callback = function(val)
		Clouds.Enabled = val
	end
})

LightingBox:AddLabel("Cloud Color"):AddColorPicker("CloudColorPicker", {
	Default = Clouds.Color,
	Title = "Cloud Color",
	Callback = function(val)
		Clouds.Color = val
	end
})

local LockBox = Tabs.Combat:AddLeftGroupbox("Mouse Lock")

local mousemoverel = mousemoverel or function() end

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local MouseLockEnabled, CurrentTarget = false, nil
local LockHeld = false
local LockKey = Enum.UserInputType.MouseButton2

local settings = {
    Smoothness = 0.2,
    MaxDistance = 1000,
    VisibleCheck = false,
    TargetPart = "Head",
    FOVEnabled = false,
    FOVRadius = 100
}

LockBox:AddToggle("MouseLockToggle", { Text = "Enable Mouse Lock", Default = false }):OnChanged(function(v)
    MouseLockEnabled = v
end)

LockBox:AddSlider("SmoothnessSlider", {
    Text = "Lock Strength", Min = 0.01, Max = 1, Rounding = 2, Default = 0.2
}):OnChanged(function(v)
    settings.Smoothness = v
end)

LockBox:AddSlider("MaxDistanceSlider", {
    Text = "Max Lock Distance", Min = 100, Max = 3000, Default = 1000
}):OnChanged(function(v)
    settings.MaxDistance = v
end)

LockBox:AddToggle("VisibleCheckToggle", { Text = "Visible Check", Default = false }):OnChanged(function(v)
    settings.VisibleCheck = v
end)

LockBox:AddDropdown("TargetPartDropdown", {
    Values = {
        "Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso",
        "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
        "LeftUpperLeg", "RightUpperLeg", "LeftFoot", "RightFoot"
    },
    Default = 1,
    Text = "Target Part"
}):OnChanged(function(v)
    settings.TargetPart = v
end)

LockBox:AddToggle("FOVToggle", { Text = "Enable FOV", Default = false }):OnChanged(function(v)
    settings.FOVEnabled = v
end)

LockBox:AddSlider("FOVRadiusSlider", {
    Text = "FOV Radius", Min = 20, Max = 500, Default = 100
}):OnChanged(function(v)
    settings.FOVRadius = v
end)

local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.NumSides = 64
fovCircle.Filled = false
fovCircle.Color = Color3.new(1,1,1)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == LockKey or i.UserInputType == LockKey then
        LockHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.KeyCode == LockKey or i.UserInputType == LockKey then
        LockHeld = false
        CurrentTarget = nil
    end
end)

local function alive(char)
    local h = char:FindFirstChildWhichIsA("Humanoid")
    return h and h.Health > 0
end

local ignore = {LocalPlayer.Character, Camera}
local function visible(part)
    return #Camera:GetPartsObscuringTarget({part.Position}, ignore) == 0
end

local function GetClosestTarget()
    local bestPlayer, bestFovDist = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char and alive(char) then
                local part = char:FindFirstChild(settings.TargetPart)
                if part then
                    
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist3D = (Camera.CFrame.Position - part.Position).Magnitude
                        if dist3D <= settings.MaxDistance then

                            local pos2D = Vector2.new(screenPos.X, screenPos.Y)
                            local fovDist = (pos2D - mousePos).Magnitude

                            if settings.FOVEnabled and fovDist > settings.FOVRadius then
                                continue
                            end

                            if settings.VisibleCheck and not visible(part) then
                                continue
                            end

                            if fovDist < bestFovDist then
                                bestFovDist = fovDist
                                bestPlayer = plr
                            end
                        end
                    end
                end
            end
        end
    end

    return bestPlayer
end

RunService.RenderStepped:Connect(function()
    fovCircle.Visible = settings.FOVEnabled
    if settings.FOVEnabled then
        fovCircle.Position = UserInputService:GetMouseLocation()
        fovCircle.Radius = settings.FOVRadius
    end
end)

RunService.RenderStepped:Connect(function()
    if not MouseLockEnabled then
        CurrentTarget = nil
        return
    end

    if not LockHeld and not IsMobile then
        CurrentTarget = nil
        return
    end

    if not CurrentTarget or not alive(CurrentTarget.Character) then
        CurrentTarget = GetClosestTarget()
    end

    if not CurrentTarget then return end

    local targetPart = CurrentTarget.Character:FindFirstChild(settings.TargetPart)
    if not targetPart then CurrentTarget = nil return end

    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if not onScreen then CurrentTarget = nil return end

    if settings.VisibleCheck and not visible(targetPart) then
        CurrentTarget = nil
        return
    end

    if settings.FOVEnabled then
        local mousePos = UserInputService:GetMouseLocation()
        local pos2D = Vector2.new(screenPos.X, screenPos.Y)
        local fovDist = (pos2D - mousePos).Magnitude

        if fovDist > settings.FOVRadius then
            CurrentTarget = nil
            return
        end
    end

    local mousePos = UserInputService:GetMouseLocation()
    local pos2D = Vector2.new(screenPos.X, screenPos.Y)
    local delta = pos2D - mousePos

    mousemoverel(delta.X * settings.Smoothness, delta.Y * settings.Smoothness)
end)

local Hitboxes = Tabs.Combat:AddRightGroupbox("Hitbox Modifications")

local HitboxManager = {}
HitboxManager.__index = HitboxManager

function HitboxManager.New()
    local Self = setmetatable({}, HitboxManager)

    Self.Enabled = false
    Self.UseCustomColor = true
    Self.Size = 15
    Self.Color = Color3.fromRGB(142, 104, 231)
    Self.Transparency = 0.7

    Self.LocalPlayer = Players.LocalPlayer
    Self.Connections = {}

    table.insert(Self.Connections, RunService.RenderStepped:Connect(function()
        if Self.Enabled then
            Self:UpdateAllPlayers()
        end
    end))

    table.insert(Self.Connections, Players.PlayerAdded:Connect(function(Player)
        if Player ~= Self.LocalPlayer then
            Player.CharacterAdded:Connect(function(Character)
                Self:StoreOriginalSize(Character)
            end)
        end
    end))

    return Self
end

function HitboxManager:IsCharacterSitting(Character)
    local Humanoid = Character and Character:FindFirstChildWhichIsA("Humanoid")
    return Humanoid and Humanoid.Sit
end

function HitboxManager:StoreOriginalSize(Character)
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 5)

    if HumanoidRootPart and not HumanoidRootPart:FindFirstChild("OriginalSize") then
        local OriginalSizeValue = Instance.new("Vector3Value")
        OriginalSizeValue.Name = "OriginalSize"
        OriginalSizeValue.Value = HumanoidRootPart.Size
        OriginalSizeValue.Parent = HumanoidRootPart
    end
end

function HitboxManager:ApplyHitbox(Character)
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then
        return
    end

    if self:IsCharacterSitting(Character) then
        local OriginalSizeValue = HumanoidRootPart:FindFirstChild("OriginalSize")

        HumanoidRootPart.Size = OriginalSizeValue and OriginalSizeValue.Value or Vector3.new(2, 2, 1)
        HumanoidRootPart.Transparency = 1
        HumanoidRootPart.BrickColor = BrickColor.new("Medium stone grey")
        HumanoidRootPart.Material = Enum.Material.Plastic
        HumanoidRootPart.CanCollide = true
        return
    end

    if not HumanoidRootPart:FindFirstChild("OriginalSize") then
        self:StoreOriginalSize(Character)
    end

    HumanoidRootPart.Size = Vector3.new(self.Size, self.Size, self.Size)
    HumanoidRootPart.Transparency = self.Transparency
    HumanoidRootPart.BrickColor = self.UseCustomColor and BrickColor.new(self.Color) or BrickColor.new("Mint")
    HumanoidRootPart.Material = Enum.Material.ForceField
    HumanoidRootPart.CanCollide = false
end

function HitboxManager:UpdateAllPlayers()
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= self.LocalPlayer and Player.Character then
            self:ApplyHitbox(Player.Character)
        end
    end
end

function HitboxManager:RestoreDefaults()
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= self.LocalPlayer and Player.Character then
            local HumanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                local OriginalSizeValue = HumanoidRootPart:FindFirstChild("OriginalSize")

                if OriginalSizeValue then
                    HumanoidRootPart.Size = OriginalSizeValue.Value
                    OriginalSizeValue:Destroy()
                else
                    HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                end

                HumanoidRootPart.Transparency = 1
                HumanoidRootPart.BrickColor = BrickColor.new("Medium stone grey")
                HumanoidRootPart.Material = Enum.Material.Plastic
                HumanoidRootPart.CanCollide = true
            end
        end
    end
end

function HitboxManager:SetEnabled(State)
    self.Enabled = State

    if State then
        self:UpdateAllPlayers()
    else
        self:RestoreDefaults()
    end
end

function HitboxManager:SetSize(NewSize)
    self.Size = NewSize
    self:UpdateAllPlayers()
end

function HitboxManager:SetColor(NewColor)
    self.Color = NewColor
    self:UpdateAllPlayers()
end

function HitboxManager:SetTransparency(NewTransparency)
    self.Transparency = NewTransparency
    self:UpdateAllPlayers()
end

local HitboxController = HitboxManager.New()

Hitboxes:AddToggle("EnableHitbox", {
    Text = "Enable Hitbox",
    Default = false,
    Tooltip = "Enlarges All Players Hitboxes",
    Callback = function(Value)
        HitboxController:SetEnabled(Value)
    end
})

Hitboxes:AddLabel("Hitbox Color"):AddColorPicker("CustomHitboxColor", {
    Text = "Hitbox Color",
    Default = HitboxController.Color,
    Tooltip = "Changes The Hitbox Color",
    Callback = function(ColorValue)
        HitboxController:SetColor(ColorValue)
    end
})

Hitboxes:AddSlider("HitboxSizeSlider", {
    Text = "Hitbox Size",
    Min = 1,
    Max = 200,
    Rounding = 1,
    Default = HitboxController.Size,
    Callback = function(SizeValue)
        HitboxController:SetSize(SizeValue)
    end
})

Hitboxes:AddSlider("HitboxTransparencySlider", {
    Text = "Hitbox Transparency",
    Min = 0,
    Max = 1,
    Rounding = 2,
    Default = HitboxController.Transparency,
    Callback = function(TransparencyValue)
        HitboxController:SetTransparency(TransparencyValue)
    end
})

local PlayerBox = Tabs.Combat:AddLeftGroupbox("Target Options")

local SelectedPlayer

local function updatePlayerList()
    local list = {"-"}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    return list
end

local playerDropdown = PlayerBox:AddDropdown("PlayerDropdown", {
    Values = updatePlayerList(),
    Default = "-",
    Multi = false,
    Text = "Select Player",
})

playerDropdown:OnChanged(function(name)
    if name == "-" then
        SelectedPlayer = nil
        return
    end

    local plr = Players:FindFirstChild(name)
    if plr then
        SelectedPlayer = plr
        Library:Notify("Selected: " .. name, 2)
    else
        SelectedPlayer = nil
        Library:Notify("Player not found!", 3)
    end
end)

local function refreshDropdown()
    local values = updatePlayerList()
    playerDropdown:SetValues(values)

    if SelectedPlayer and not Players:FindFirstChild(SelectedPlayer.Name) then
        playerDropdown:SetValue("-")
        SelectedPlayer = nil
    end
end

Players.PlayerAdded:Connect(function()
    task.defer(refreshDropdown)
end)

Players.PlayerRemoving:Connect(function()
    task.defer(refreshDropdown)
end)

PlayerBox:AddButton("Deselect", function()
    if SelectedPlayer then
        Library:Notify("Deselected: " .. SelectedPlayer.Name, 2)
        SelectedPlayer = nil
        playerDropdown:SetValue("-")
    end
end):AddButton("Goto Player", function()
	if not SelectedPlayer then
		Library:Notify("Select a player first", 3)
		return
	end

	task.spawn(function()
		local character = SelectedPlayer.Character or SelectedPlayer.CharacterAdded:Wait()
		local hrp = character:FindFirstChild("HumanoidRootPart")

		local timeout, elapsed = 5, 0
		while not hrp and elapsed < timeout do
			task.wait(0.2)
			elapsed += 0.2
			hrp = character:FindFirstChild("HumanoidRootPart")
		end

		if not hrp then
			Library:Notify("Target HRP not loaded", 3)
			return
		end

		local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local myRoot = myChar:FindFirstChild("HumanoidRootPart")
		if not myRoot then
			Library:Notify("Your HRP not loaded", 3)
			return
		end

		local targetPos = hrp.Position
		local targetCF  = hrp.CFrame

		local mode = tostring(TeleportMode or "Instant"):lower():gsub("%s+", "")

		local function tryCall(fn, a1)
			if typeof(fn) ~= "function" then return false end
			local ok = pcall(fn, a1)
			return ok
		end

		local did = false

		if mode == "instant" or mode == "instanttp" or mode == "instantteleport" then
			did = tryCall(InstantTeleport, targetPos) or tryCall(InstantTeleport, targetCF)
			if did then
				Library:Notify("Goto: Instant", 2)
			end

		elseif mode == "walktween" or mode == "walk" then
			if typeof(WalkPathfindTo) == "function" then
				local ok1 = pcall(task.spawn, WalkPathfindTo, targetPos)
				local ok2 = (not ok1) and pcall(task.spawn, WalkPathfindTo, targetCF) or false
				did = ok1 or ok2
			end
			if did then
				Library:Notify("Goto: Walk Tween", 2)
			end

		elseif mode == "airtween" or mode == "air" then
			if typeof(AirPathfindTo) == "function" then
				local ok1 = pcall(task.spawn, AirPathfindTo, targetPos)
				local ok2 = (not ok1) and pcall(task.spawn, AirPathfindTo, targetCF) or false
				did = ok1 or ok2
			end
			if did then
				Library:Notify("Goto: Air Tween", 2)
			end
		end

		if not did then
			myRoot.CFrame = targetCF + Vector3.new(0, 3, 0)
			Library:Notify("Goto fallback: HRP.CFrame set", 3)
		end

		Library:Notify("Teleported to " .. SelectedPlayer.Name, 3)
	end)
end)


local SpectateConnection
PlayerBox:AddToggle("SpectateToggle", {
    Text = "Spectate Player",
    Default = false,
}):OnChanged(function(Value)
    if SpectateConnection then
        SpectateConnection:Disconnect()
        SpectateConnection = nil
    end

    if Value then
        if not SelectedPlayer then
            Library:Notify("Select a player first", 3)
            return
        end

        local function spectatePlayer()
            local char = SelectedPlayer.Character or SelectedPlayer.CharacterAdded:Wait()
            local hum = char:FindFirstChildOfClass("Humanoid")
            local timeout = 5
            local elapsed = 0

            while not hum and elapsed < timeout do
                task.wait(0.2)
                elapsed += 0.2
                hum = char:FindFirstChildOfClass("Humanoid")
            end

            if hum then
                workspace.CurrentCamera.CameraSubject = hum
                Library:Notify("Spectating " .. SelectedPlayer.Name, 3)
            else
                Library:Notify("Humanoid not found on target", 3)
            end
        end

        task.spawn(spectatePlayer)

        SpectateConnection = SelectedPlayer.CharacterAdded:Connect(function(newChar)
            local newHumanoid = newChar:WaitForChild("Humanoid", 5)
            if newHumanoid then
                workspace.CurrentCamera.CameraSubject = newHumanoid
            end
        end)
    else
        task.spawn(function()
            local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local myHumanoid = myChar:WaitForChild("Humanoid", 5)
            if myHumanoid then
                workspace.CurrentCamera.CameraSubject = myHumanoid
                Library:Notify("Stopped spectating", 3)
            end
        end)
    end
end)

PlayerBox:AddToggle("ViewInventory", {
    Text = "View Inventory",
    Default = false,
}):OnChanged(function(Value)
    if not Value then return end
    if SelectedPlayer then
        local items = {}
        local backpack = SelectedPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, item in pairs(backpack:GetChildren()) do
                table.insert(items, item.Name)
            end
        end
        Library:Notify(#items > 0 and "🎒 " .. table.concat(items, ", ") or "Inventory is empty", 6)
    else
        Library:Notify("Select a player first", 3)
    end
end)

local bringT = {}          
local bringCF = {}         
local BringThread
local BringLoopRunning = false

local BRING_DISTANCE = 3
local BRING_DELAY = 0.05

local function getRoot(char)
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function removeBring(playerName)
	bringT[playerName] = nil

	local plr = Players:FindFirstChild(playerName)
	if plr and bringCF[playerName] then
		local char = plr.Character
		local root = getRoot(char)
		if root then
			root.CFrame = bringCF[playerName]
		end
	end

	bringCF[playerName] = nil
end

PlayerBox:AddToggle("LoopBring", {
	Text = "Loop Bring",
	Default = false,
}):OnChanged(function(Value)
	BringLoopRunning = Value

	if not Value then
		if BringThread then
			task.cancel(BringThread)
			BringThread = nil
		end

		if SelectedPlayer then
			removeBring(SelectedPlayer.Name)
		end

		Library:Notify("Loop Bring disabled", 2)
		return
	end

	if not SelectedPlayer then
		Library:Notify("Select a player first", 3)
		return
	end

	local targetName = SelectedPlayer.Name
	if bringT[targetName] then return end

	local char = SelectedPlayer.Character
	local root = getRoot(char)
	if root then
		bringCF[targetName] = root.CFrame
	end

	bringT[targetName] = true

	BringThread = task.spawn(function()
		while BringLoopRunning and bringT[targetName] do
			local myChar = LocalPlayer.Character
			local myRoot = getRoot(myChar)

			local plr = Players:FindFirstChild(targetName)
			if not plr then
				removeBring(targetName)
				break
			end

			local targetChar = plr.Character
			local targetRoot = getRoot(targetChar)

			if myRoot and targetRoot then
				targetRoot.CFrame =
					myRoot.CFrame * CFrame.new(BRING_DISTANCE, 1, 0)
			end

			task.wait(BRING_DELAY)
		end
	end)

	Library:Notify("Loop Bring enabled", 2)
end)

local Tp = Tabs.Player:AddRightGroupbox("Teleports")

local TeleportMode = "Instant"
local TweenSpeed = 20
local AIR_HEIGHT = 6

local SAVE_FILE = "Cobra_Teleports_" .. game.PlaceId .. ".json"
local SavedCFrames = {}

local function GetCharacter()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRoot()
	return GetCharacter():WaitForChild("HumanoidRootPart")
end

local function GetHumanoid()
	return GetCharacter():WaitForChild("Humanoid")
end

local function SafeTeleport(position)
	local Humanoid = GetHumanoid()
	local root = GetRoot()

	root.Anchored = true
	Humanoid.PlatformStand = true

	root.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))

	task.wait()

	Humanoid.PlatformStand = false
	root.Anchored = false

	Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	task.wait()
	Humanoid:ChangeState(Enum.HumanoidStateType.Running)
end

local function InstantTeleport(position)
	SafeTeleport(position)
end

local function WalkPathfindTo(position)
	local Humanoid = GetHumanoid()
	local root = GetRoot()

	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
	})

	path:ComputeAsync(root.Position, position)

	if path.Status ~= Enum.PathStatus.Success then
		SafeTeleport(position)
		return
	end

	Humanoid.WalkSpeed = TweenSpeed

	for _, wp in ipairs(path:GetWaypoints()) do
		Humanoid:MoveTo(wp.Position)
		Humanoid.MoveToFinished:Wait()
	end
end

local function AirPathfindTo(position)
	local root = GetRoot()

	root.Anchored = true

	local target = position + Vector3.new(0, AIR_HEIGHT, 0)
	local dist = (root.Position - target).Magnitude
	local duration = dist / TweenSpeed

	local tween = TweenService:Create(
		root,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{ CFrame = CFrame.new(target) }
	)

	tween:Play()
	tween.Completed:Wait()

	root.Anchored = false

	SafeTeleport(position)
end

local function GetClickPosition()
	return Mouse and Mouse.Hit and Mouse.Hit.Position or nil
end

local function CFrameToTable(cf)
	return { cf:GetComponents() }
end

local function TableToCFrame(tbl)
	return CFrame.new(unpack(tbl))
end

local function LoadCFrames()
	if isfile(SAVE_FILE) then
		local ok, data = pcall(function()
			return HttpService:JSONDecode(readfile(SAVE_FILE))
		end)
		if ok and type(data) == "table" then
			SavedCFrames = data
		end
	end
end

local function SaveCFrames()
	writefile(SAVE_FILE, HttpService:JSONEncode(SavedCFrames))
end

LoadCFrames()

local TeleportTool

local function CreateTeleportTool()
	if TeleportTool then return end

	TeleportTool = Instance.new("Tool")
	TeleportTool.Name = "TP Tool"
	TeleportTool.RequiresHandle = false
	TeleportTool.Parent = LocalPlayer.Backpack

	TeleportTool.Activated:Connect(function()
		local pos = GetClickPosition()
		if not pos then return end

		if TeleportMode == "Instant" then
			InstantTeleport(pos)
		elseif TeleportMode == "Walk Tween" then
			task.spawn(WalkPathfindTo, pos)
		elseif TeleportMode == "Air Tween" then
			task.spawn(AirPathfindTo, pos)
		end
	end)
end

local function RemoveTeleportTool()
	if TeleportTool then
		TeleportTool:Destroy()
		TeleportTool = nil
	end
end

local ParsedTarget

local function ParsePosition(text)
	if not text or text == "" then return nil end
	text = text:gsub("%s+", "")

	local x, y, z = text:match("([%-%.%d]+),([%-%.%d]+),([%-%.%d]+)")
	if x and y and z then
		return Vector3.new(tonumber(x), tonumber(y), tonumber(z))
	end

	local ok, result = pcall(function()
		return loadstring("return " .. text)()
	end)

	if not ok or not result then return nil end

	if typeof(result) == "Vector3" then
		return result
	elseif typeof(result) == "CFrame" then
		return result.Position
	elseif typeof(result) == "Instance" then
		if result:IsA("BasePart") then
			return result.Position
		elseif result:IsA("Model") then
			return result:GetPivot().Position
		end
	end

	return nil
end

local CurrentCFrameName = ""
local SavedDropdown

Tp:AddToggle("TPToolToggle", {
	Text = "Teleport Tool",
	Default = false,
	Callback = function(v)
		if v then
			CreateTeleportTool()
		else
			RemoveTeleportTool()
		end
	end
})

Tp:AddDropdown("TPModeDropdown", {
	Text = "Teleport Mode",
	Values = { "Instant", "Walk Tween", "Air Tween" },
	Default = "Instant",
	Callback = function(v)
		TeleportMode = v
	end
})

Tp:AddSlider("TPSpeedSlider", {
	Text = "Tween Speed",
	Min = 10,
	Max = 200,
	Default = 20,
	Rounding = 0,
	Callback = function(v)
		TweenSpeed = v
	end
})

Tp:AddInput("UniversalTPInput", {
	Text = "Teleport Position",
	Placeholder = "Vector3 / CFrame / x,y,z / instance",
	Callback = function(v)
		ParsedTarget = ParsePosition(v)
	end
})

Tp:AddButton("Teleport To Input", function()
	if not ParsedTarget then return end

	if TeleportMode == "Instant" then
		InstantTeleport(ParsedTarget)
	elseif TeleportMode == "Walk Tween" then
		task.spawn(WalkPathfindTo, ParsedTarget)
	elseif TeleportMode == "Air Tween" then
		task.spawn(AirPathfindTo, ParsedTarget)
	end
end)

Tp:AddInput("CFrameNameInput", {
	Text = "Position Name",
	Placeholder = "Enter name...",
	Callback = function(v)
		CurrentCFrameName = v
	end
})

Tp:AddButton("Save Input Position", function()
	if CurrentCFrameName == "" then return end

	local savePos

	if FreecamEnabled then
		savePos = workspace.CurrentCamera.CFrame.Position

	elseif ParsedTarget then
		savePos = ParsedTarget

	else
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		savePos = hrp.Position
	end

	SavedCFrames[CurrentCFrameName] = CFrameToTable(CFrame.new(savePos))
	SaveCFrames()

	local names = {}
	for name in pairs(SavedCFrames) do
		table.insert(names, name)
	end
	table.sort(names)
	SavedDropdown:SetValues(names)

	Library:Notify(
		FreecamEnabled and "Saved Freecam position"
		or ParsedTarget and "Saved input position"
		or "Saved current position",
		2
	)
end)


SavedDropdown = Tp:AddDropdown("SavedCFrameDropdown", {
	Text = "Saved Positions",
	Values = {},
	Callback = function(name)
		local data = SavedCFrames[name]
		if not data then return end

		local pos = TableToCFrame(data).Position

		if TeleportMode == "Instant" then
			InstantTeleport(pos)
		elseif TeleportMode == "Walk Tween" then
			task.spawn(WalkPathfindTo, pos)
		elseif TeleportMode == "Air Tween" then
			task.spawn(AirPathfindTo, pos)
		end
	end
})

do
	local names = {}
	for name in pairs(SavedCFrames) do
		table.insert(names, name)
	end
	table.sort(names)
	SavedDropdown:SetValues(names)
end

local UseFire = typeof(fireproximityprompt) == "function"

local function FirePrompt(prompt)
	if UseFire then
		fireproximityprompt(prompt)
	else
		prompt:InputHoldBegin()
		task.wait(prompt.HoldDuration or 0)
		prompt:InputHoldEnd()
	end
end

local function FirePromptN(prompt, n)
	for _ = 1, n do
		FirePrompt(prompt)
	end
end

local function CreateOverlay(parent)
	local gui = Instance.new("ScreenGui")
	gui.Name = "FoundationOverlay"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 100000
	gui.Parent = parent or PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.Parent = gui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "FARM ACTIVE\nPLEASE WAIT"
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.ZIndex = 101
	label.Parent = frame

	return gui, label
end

local function GetAnyBasePart(model)
	for _, obj in ipairs(model:GetDescendants()) do
		if obj:IsA("BasePart") then return obj end
	end
end

local function FindFirstPrompt(parent)
	for _, d in ipairs(parent:GetDescendants()) do
		if d:IsA("ProximityPrompt") then return d end
	end
end

local function RunWithOverlay(fn)
	local hrp = GetRoot()
	local startCF = hrp.CFrame
	local overlay = CreateOverlay()

	local function cleanup()
		hrp.CFrame = startCF
		overlay:Destroy()
	end

	local ok, err = pcall(fn, hrp, cleanup)
	if not ok then
		warn(err)
		cleanup()
	end
end

if game.PlaceId == 139873419998113 then
	Tabs.GameSupported = Window:AddTab("Da Streets", "dollar-sign")
	local farmRunning = false

	Tabs.GameSupported:AddLeftGroupbox("Vuln"):AddButton("Infinite Money", function()
		if farmRunning then return end
		farmRunning = true

		RunWithOverlay(function(hrp, cleanup)
			local objects = workspace:FindFirstChild("Robbery_Framework")
				and workspace.Robbery_Framework:FindFirstChild("Objects")
			if not objects then return cleanup() end

			local targetModel
			for _, obj in ipairs(objects:GetChildren()) do
				if obj:IsA("Model") then targetModel = obj; break end
			end
			if not targetModel then return cleanup() end

			local prompt = FindFirstPrompt(targetModel)
			if not prompt or not prompt.Parent:IsA("BasePart") then return cleanup() end

			hrp.CFrame = prompt.Parent.CFrame + Vector3.new(0, 2, 0)
			task.wait(0.3)
			FirePromptN(prompt, 2500)
			task.wait(0.2)
			cleanup()
			farmRunning = false
		end)
	end)
end

if game.PlaceId == 90596694224567 then
	Tabs.GameSupported = Window:AddTab("Hiddenville", "dollar-sign")

	local ChooseTool = ReplicatedStorage:WaitForChild("ChooseTool")
	local SendMoneyEvent = ReplicatedStorage:WaitForChild("SendMoneyEvent")
	local GiveMoney = ReplicatedStorage:WaitForChild("GiveMoney")

	local GunGroup = Tabs.GameSupported:AddRightGroupbox("Gun Spawner")
	local Guns = {"Mac10", "Mac11", "G20", "G20D", "G20Switch", "Mini-Uzi"}
	local selectedGun = Guns[1]

	GunGroup:AddDropdown("GunSelect", {
		Text = "Select Gun", Values = Guns, Default = 1,
	}):OnChanged(function(v) selectedGun = v end)

	GunGroup:AddButton("Spawn Gun", function()
		if selectedGun then ChooseTool:FireServer(selectedGun, 4) end
	end)
	GunGroup:AddLabel("You can only spawn")
	GunGroup:AddLabel("one of each per game")

	local SendGroup = Tabs.GameSupported:AddLeftGroupbox("Send Money")
	local sendAmount, selectedPlayer, playerDropdown = 30000000, nil, nil

	local function RefreshPlayerList()
		local names = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then table.insert(names, p.Name) end
		end
		if playerDropdown then
			playerDropdown:SetValues(names)
			if not selectedPlayer and #names > 0 then
				selectedPlayer = names[1]
				playerDropdown:SetValue(selectedPlayer)
			end
		end
	end

	SendGroup:AddInput("MoneyAmountInput", {
		Text = "Amount", Default = tostring(sendAmount), Numeric = true, Finished = true,
	}):OnChanged(function(v)
		local n = tonumber(v)
		if n and n > 0 then sendAmount = math.floor(n) end
	end)

	playerDropdown = SendGroup:AddDropdown("PlayerSelect", {
		Text = "Select Player", Values = {},
	})
	playerDropdown:OnChanged(function(v) selectedPlayer = v end)

	SendGroup:AddButton("Send Money", function()
		if not selectedPlayer or not sendAmount or sendAmount <= 0 then return end
		SendMoneyEvent:FireServer(selectedPlayer, sendAmount, "yw king")
	end)

	SendGroup:AddButton("Removes Players Money", function()
		if not selectedPlayer then return end
		SendMoneyEvent:FireServer(selectedPlayer, 0/0, "yw king")
	end)

	RefreshPlayerList()
	Players.PlayerAdded:Connect(function() task.wait(0.2); RefreshPlayerList() end)
	Players.PlayerRemoving:Connect(function() task.wait(0.2); RefreshPlayerList() end)

	local queue, processed = {}, {}
	local running, processing, playerAddedConn = false, false, nil

	local function HasEnoughMoney(plr)
		local stats = plr:FindFirstChild("leaderstats")
		local money = stats and stats:FindFirstChild("Money")
		return money and money.Value >= 30000000
	end

	local function AddToQueue(plr)
		if not running or not plr or plr == LocalPlayer or processed[plr] or HasEnoughMoney(plr) then return end
		processed[plr] = true
		table.insert(queue, plr)
	end

	local function StopAll()
		running = false
		table.clear(queue)
		table.clear(processed)
		if playerAddedConn then playerAddedConn:Disconnect(); playerAddedConn = nil end
	end

	local function StartLoop(giveAmt, giveType, sendAmt, note)
		if processing then return end
		processing = true
		task.spawn(function()
			while running do
				local plr = table.remove(queue, 1)
				if plr and plr.Parent == Players and not HasEnoughMoney(plr) then
					GiveMoney:FireServer(giveAmt, giveType)
					task.wait(0.75)
					SendMoneyEvent:FireServer(plr.Name, sendAmt, note)
					task.wait(1)
				end
				task.wait(0.2)
			end
			processing = false
		end)
	end

	local function StartToggle(sendAmt, note)
		running = true
		table.clear(queue); table.clear(processed)
		for _, p in ipairs(Players:GetPlayers()) do AddToQueue(p) end
		playerAddedConn = Players.PlayerAdded:Connect(function(p) task.wait(1); AddToQueue(p) end)
		StartLoop(30000000, 1, sendAmt, note)
	end

	SendGroup:AddToggle("AutoPayToggle", {
		Text = "Auto Send Max To All", Default = false,
	}):OnChanged(function(state)
		if state then StartToggle(30000000, "yw king") else StopAll() end
	end)

	SendGroup:AddToggle("ZeroAllToggle", {
		Text = "Set All Players Cash To 0", Default = false,
	}):OnChanged(function(state)
		if state then StartToggle(0/0, "sorry king") else StopAll() end
	end)

	local VulnGroup = Tabs.GameSupported:AddLeftGroupbox("Vuln")
	local moneyAmount, farmRunning = 0, false

	VulnGroup:AddInput("MoneyInput", {
		Default = "", Numeric = true, Finished = true,
		Text = "Money Amount", Placeholder = "Enter amount",
		Callback = function(v) moneyAmount = tonumber(v) or 0 end,
	})

	VulnGroup:AddButton("Give Money", function()
		if moneyAmount <= 0 then return end
		GiveMoney:FireServer(moneyAmount, 1)
	end)

	VulnGroup:AddButton("Max Money + Max Level", function()
		if farmRunning then return end
		farmRunning = true

		RunWithOverlay(function(hrp, cleanup)
			local car = workspace.CarRobberySystem.Car
			local interact = car.Glass:WaitForChild("InteractPat")
			local anchor = car.Fusion.Model.PrimaryPart
				or car.Fusion.Model:FindFirstChildWhichIsA("BasePart", true)

			if anchor then hrp.CFrame = anchor.CFrame + Vector3.new(0, 3, 0) end
			task.wait(1)
			FirePrompt(interact:WaitForChild("Prox1"))
			task.wait(1)
			FirePromptN(interact:WaitForChild("Prox2"), 3000)
			task.wait(0.5)
			cleanup()
			farmRunning = false
		end)
	end)
end

if game.PlaceId == 126194330110954 then
	Tabs.GameSupported = Window:AddTab("Chicago Life", "dollar-sign")

	local function GetPlayerPositions()
		local positions = {}
		for _, plr in ipairs(Players:GetPlayers()) do
			local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp then table.insert(positions, hrp.Position) end
		end
		return positions
	end

	local function GetMinDistanceToPlayers(pos, positions)
		local minDist = math.huge
		for _, p in ipairs(positions) do
			minDist = math.min(minDist, (pos - p).Magnitude)
		end
		return minDist
	end

	local function FindFarthestRobbableVan()
		local positions = GetPlayerPositions()
		local farthestVan, farthestDist = nil, -math.huge

		for _, van in ipairs(workspace:GetChildren()) do
			if van:IsA("Model") and van.Name == "Robbable Van" then
				local basePart = GetAnyBasePart(van)
				if basePart then
					local stealScript = van:FindFirstChild("Steal Script", true)
					local scriptsPart = stealScript and stealScript:FindFirstChild("Scripts")
					if scriptsPart and scriptsPart:IsA("BasePart") then
						local dist = GetMinDistanceToPlayers(basePart.Position, positions)
						if dist > farthestDist then
							farthestDist = dist
							farthestVan = van
						end
					end
				end
			end
		end
		return farthestVan
	end

	Tabs.GameSupported:AddRightGroupbox("Infinite Money"):AddButton("Generate Infinite Money", function()
		task.spawn(function()
			local hrp = GetRoot()
			local originalCF = hrp.CFrame
			local overlay = CreateOverlay()

			local van = FindFarthestRobbableVan()
			if not van then overlay:Destroy(); return end

			local basePart = GetAnyBasePart(van)
			local stealScript = van:FindFirstChild("Steal Script", true)
			local scriptsPart = stealScript and stealScript:FindFirstChild("Scripts")
			local prompt = scriptsPart and scriptsPart:FindFirstChildOfClass("ProximityPrompt")

			if not (basePart and prompt) then overlay:Destroy(); return end

			hrp.CFrame = basePart.CFrame * CFrame.new(0, 3, 0)
			task.wait(1)
			FirePrompt(prompt)
			task.wait(1)
			FirePromptN(prompt, 10000)
			task.wait(0.2)
			hrp.CFrame = originalCF
			overlay:Destroy()
		end)
	end)

	local NameGroup = Tabs.GameSupported:AddLeftGroupbox("Character Creation")
	local PlayerData = LocalPlayer:WaitForChild("PlayerData")
	local CharacterCreation = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CharacterCreation")
	local FirstName, LastName = "", ""

	NameGroup:AddInput("FirstNameInput", { Text = "First Name", Finished = true })
		:OnChanged(function(v) FirstName = tostring(v) end)

	NameGroup:AddInput("LastNameInput", { Text = "Last Name", Finished = true })
		:OnChanged(function(v) LastName = tostring(v) end)

	NameGroup:AddButton("Finish Creating", function()
		if FirstName == "" or LastName == "" then return end
		CharacterCreation:FireServer("FinishCreating", {
			FirstName = FirstName,
			LastName  = LastName,
			Skin   = tostring(PlayerData:WaitForChild("Skin").Value),
			Hair   = tostring(PlayerData:WaitForChild("Hair").Value),
			Face   = tonumber(PlayerData:WaitForChild("Face").Value),
			Gender = tostring(PlayerData:WaitForChild("Gender").Value),
		})
	end)
end

if game.PlaceId == 73771248610396 then
	Tabs.GameSupported = Tabs.GameSupported or Window:AddTab("Cali Streets", "dollar-sign")
	local LeftGroup = Tabs.GameSupported:AddLeftGroupbox("Infinite Money")
	local RightGroup = Tabs.GameSupported:AddRightGroupbox("Teleports")

	local Cash = LocalPlayer:WaitForChild("stats"):WaitForChild("Cash")
	local ContextActionService = game:GetService("ContextActionService")

	local overlay, cashLabel = CreateOverlay(cloneref(LocalPlayer:WaitForChild("PlayerGui")))
	overlay.ZIndexBehavior = Enum.ZIndexBehavior.Global
	overlay.DisplayOrder = 1000000
	overlay.Enabled = false
	cashLabel.Text = "Cash: 0"
	cashLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	cashLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	cashLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
	cashLabel.ZIndex = 1000002

	local function BlockInputs(_, inputState)
		if inputState == Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Sink
		end
	end

	local isRunning = false

	LeftGroup:AddButton("Infinite Money", function()
		if isRunning then Library:Notify("Already running...", 2); return end
		isRunning = true
		overlay.Enabled = true

		ContextActionService:BindAction("BlockAllInput", BlockInputs, false,
			table.unpack(Enum.KeyCode:GetEnumItems()),
			table.unpack(Enum.UserInputType:GetEnumItems())
		)

		cashLabel.Text = "Cash: " .. tostring(Cash.Value)
		local cashConn = Cash:GetPropertyChangedSignal("Value"):Connect(function()
			cashLabel.Text = "Cash: " .. tostring(Cash.Value)
		end)

		local hrp = GetRoot()
		local originalCF = hrp.CFrame

		local function cleanup()
			pcall(function() hrp.CFrame = originalCF end)
			overlay.Enabled = false
			isRunning = false
			ContextActionService:UnbindAction("BlockAllInput")
			if cashConn then cashConn:Disconnect() end
		end

		local vans = workspace:WaitForChild("GameStuff"):WaitForChild("Jobs"):WaitForChild("Vans"):GetChildren()
		local targetVan = vans[5]
		if not targetVan then return cleanup() end

		hrp.CFrame = targetVan:GetPivot()

		local promptPath = targetVan:FindFirstChild("Steal Script")
		local scripts = promptPath and promptPath:FindFirstChild("Scripts")
		local prompt = scripts and scripts:FindFirstChildOfClass("ProximityPrompt")
		if not prompt then return cleanup() end

		FirePrompt(prompt)
		task.wait(1)
		FirePrompt(prompt)
		task.wait(0.5)
		FirePromptN(prompt, 10000)
		task.wait(2)
		cleanup()
	end)

	LeftGroup:AddLabel("Approximately 4m per click")

	local locations = {
		["Accessory Store"] = Vector3.new(-494, 692, 145),
		["Activate Blank"] = Vector3.new(-427, 693, 21),
		["Apartment 1"] = Vector3.new(-455, 693, 695),
		["Apartment 2"] = Vector3.new(236, 693, -49),
		["Bank"] = Vector3.new(-263, 693, 14),
		["Barber Shop"] = Vector3.new(-81, 693, 235),
		["Black Market"] = Vector3.new(-326, 693, 361),
		["Box Job"] = Vector3.new(-524, 692, 219),
		["Chips Job"] = Vector3.new(-363, 693, 657),
		["Clothing Store"] = Vector3.new(-162, 693, 243),
		["Dealership"] = Vector3.new(6, 692, 34),
		["Donuts"] = Vector3.new(-557, 692, 131),
		["Gun Store"] = Vector3.new(9, 693, 400),
		["House Invasion"] = Vector3.new(194, 693, 621),
		["Ice Box"] = Vector3.new(-441, 693, 608),
		["Mop Job"] = Vector3.new(-8, 692, 647),
		["Music Studio"] = Vector3.new(211, 693, 174),
		["Rent A Scooter"] = Vector3.new(-44, 693, 4),
		["Sell Chips"] = Vector3.new(-543, 692, 411),
		["Store"] = Vector3.new(-460, 695, -91),
	}

	local sortedNames = {}
	for name in pairs(locations) do table.insert(sortedNames, name) end
	table.sort(sortedNames)

	RightGroup:AddDropdown("LocationTP", {
		Values = sortedNames, Default = "", Text = "Teleport To Location",
		Tooltip = "Select a place to teleport",
		Callback = function(name)
			local pos = locations[name]
			if pos then InstantTeleport(CFrame.new(pos + Vector3.new(0, 3, 0))) end
		end,
	})

	local CL_NameBusy = false

	local CL_FirstNameInput = RightGroup:AddInput("CL_FirstNameInput", {
		Text = "First Name", Placeholder = "First Name", Finished = false,
	})
	local CL_LastNameInput = RightGroup:AddInput("CL_LastNameInput", {
		Text = "Last Name", Placeholder = "Last Name", Finished = false,
	})

	RightGroup:AddButton("Set Character Name", function()
		if CL_NameBusy then return end
		CL_NameBusy = true

		local first = CL_FirstNameInput.Value
		if not first or first == "" then CL_NameBusy = false; return end

		local last = CL_LastNameInput.Value
		local finalName = (last and last ~= "") and (first .. " " .. last) or first

		local nameEvent = ReplicatedStorage.Cosmetic.Remote.SetCharacter
		if nameEvent then nameEvent:FireServer({Name = finalName}) end

		Library:Notify("Name set to: " .. finalName, 3)
		CL_NameBusy = false
	end)
end

if game.PlaceId == 84866901748045 then
	Tabs.GameSupported = Tabs.GameSupported or Window:AddTab("Bronx Hood", "dollar-sign")
    local group = Tabs.GameSupported:AddLeftGroupbox("Infinite Money")
    group:AddButton({
		Text = "Auto Grab Robbery Money",
		Func = function()
			local character = LocalPlayer.Character
			if not character then return end

			local root = character:FindFirstChild("HumanoidRootPart")
			if not Humanoid or not root then return end

			local originalCF = root.CFrame
			local overlay = CreateOverlay()

			local function cleanup()
				root.CFrame = originalCF
				overlay:Destroy()
                Humanoid:ChangeState(Enum.HumanoidStateType.Running)
			end

			Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

			local robberyFolder = workspace:FindFirstChild("Robbery_Framework")
			if not robberyFolder then return cleanup() end

			local moneyModel
			for _, v in ipairs(robberyFolder:GetDescendants()) do
				if v.Name:lower():find("money") and v:IsA("Model") then
					moneyModel = v; break
				end
			end
			if not moneyModel then return cleanup() end

			local prompt = FindFirstPrompt(moneyModel)
			if not prompt then return cleanup() end

			local moneyPart = moneyModel:FindFirstChildWhichIsA("BasePart")
			if not moneyPart then return cleanup() end

			root.CFrame = moneyPart.CFrame + Vector3.new(0, 2, 0)
			task.wait(0.2)
			FirePromptN(prompt, 5000)
			task.wait(1)
			cleanup()
		end,
	})
    group:AddLabel("Use Fly To Get Around")
end

local cali = function()
	if game.PlaceId ~= 12077443856 then return end

	Tabs.GameSupported = Tabs.GameSupported or Window:AddTab("Cali Shootout", "dollar-sign")
	local VulnGroup = Tabs.GameSupported:AddLeftGroupbox("Auto Farms")
	local TeleGroup = Tabs.GameSupported:AddRightGroupbox("Teleports")

	local TP_OFFSET = Vector3.new(0, 2, 0)

	local function TweenTo(targetCF)
		local hrp = GetRoot()
		local tween = TweenService:Create(hrp, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {CFrame = targetCF})
		tween:Play()
		tween.Completed:Wait()
	end

	local function TeleportTo(partOrCF)
		local hrp = GetRoot()
		if typeof(partOrCF) == "CFrame" then
			hrp.CFrame = partOrCF + TP_OFFSET
		elseif typeof(partOrCF) == "Instance" and partOrCF:IsA("BasePart") then
			hrp.CFrame = partOrCF.CFrame + TP_OFFSET
		end
		task.wait(0.25)
	end

	local function FirePromptCS(prompt)
		if prompt and prompt:IsA("ProximityPrompt") then
			prompt.HoldDuration = 0
			fireproximityprompt(prompt)
			task.wait(0.3)
			return true
		end
		return false
	end

	local function FireAnyPromptUnder(inst)
		if not inst then return false end
		return FirePromptCS(inst:FindFirstChildOfClass("ProximityPrompt", true))
	end

	local function FindBankByGoldCount(count)
		for _, bank in ipairs(workspace:GetChildren()) do
			if bank:IsA("Model") and bank.Name == "Bank" then
				local loot = bank:FindFirstChild("Loot")
				if loot then
					local n = 0
					for _, d in ipairs(loot:GetDescendants()) do
						if d.Name == "GoldIngot" then n += 1 end
					end
					if n == count then return bank end
				end
			end
		end
	end

	local function CheckCooldown(bank, label)
		local cd = bank:FindFirstChild("Cooldown")
		if cd then
			if (cd:IsA("BoolValue") and cd.Value)
				or (cd:IsA("StringValue") and tostring(cd.Value):lower() == "active") then
				Library:Notify(label .. " is on cooldown.", 3)
				return true
			end
		end
		return false
	end

	local function OpenDoor(bank, name)
		local door = bank:FindFirstChild(name)
		if door and door:FindFirstChild("Main") then
			TeleportTo(door.Main)
			FireAnyPromptUnder(door.Main)
			return door
		end
	end

	local function CollectLoot(bank, filter)
		local root = bank:FindFirstChild("Loot") or bank
		for _, inst in ipairs(root:GetDescendants()) do
			if filter(inst) then
				TeleportTo(inst)
				FireAnyPromptUnder(inst)
			end
		end
	end

	local function CollectFirstLoot(bank, name, class)
		local root = bank:FindFirstChild("Loot") or bank
		for _, inst in ipairs(root:GetDescendants()) do
			if inst.Name == name and inst.ClassName == class then
				TeleportTo(inst)
				FireAnyPromptUnder(inst)
				return true
			end
		end
		return false
	end

	VulnGroup:AddToggle("BankAutoFarmToggle", {
		Text = "Auto Bank Robbery", Default = false,
	}):OnChanged(function(enabled)
		if not enabled then return end

		task.spawn(function()
			local bank = FindBankByGoldCount(5)
			if not bank or CheckCooldown(bank, "Bank") then return end

			local laser = bank:FindFirstChild("LaserDisabler")
			if laser and laser:FindFirstChild("Main") then
				TweenTo(CFrame.new(-2340, 4, 138))
				TweenTo(laser.Main.CFrame + TP_OFFSET)
				task.wait(2)
				FireAnyPromptUnder(laser.Main)
			end

			task.wait(1.5)
			OpenDoor(bank, "VaultDoor")
			task.wait(5)

			local metalDoor = OpenDoor(bank, "MetalDoor")
			local vaultDoor = bank:FindFirstChild("VaultDoor")

			for _, obj in ipairs(bank:GetChildren()) do
				if obj:IsA("Model") and obj:FindFirstChild("Main")
					and obj ~= laser and obj ~= vaultDoor and obj ~= metalDoor then
					local prompt = obj.Main:FindFirstChildOfClass("ProximityPrompt", true)
					if prompt then
						TeleportTo(obj.Main)
						FirePromptCS(prompt)
						FirePromptCS(prompt)
						task.wait(1)
					end
				end
			end

			CollectLoot(bank, function(i) return i.Name == "GoldIngot" and i:IsA("UnionOperation") end)
			CollectFirstLoot(bank, "MoneyBag", "Part")
			TeleportTo(CFrame.new(-2370, 3, -20))
		end)
	end)

	VulnGroup:AddToggle("CasinoRobbery13Toggle", {
		Text = "Auto Casino Robbery", Default = false,
	}):OnChanged(function(enabled)
		if not enabled then return end

		task.spawn(function()
			local bank = FindBankByGoldCount(13)
			if not bank or CheckCooldown(bank, "Casino") then return end

			local laser = bank:FindFirstChild("LaserDisabler")
			if laser and laser:FindFirstChild("Main") then
				TweenTo(laser.Main.CFrame + TP_OFFSET)
				task.wait(1.25)
				FireAnyPromptUnder(laser.Main)
			end

			task.wait(1.5)
			OpenDoor(bank, "VaultDoor")
			task.wait(63)

			CollectFirstLoot(bank, "GoldIngot", "UnionOperation")
			CollectFirstLoot(bank, "MoneyBag", "Part")
			TeleportTo(CFrame.new(-2609, 3, -493))
		end)
	end)

	VulnGroup:AddToggle("NightClubRobbery4Toggle", {
		Text = "Auto NightClub Robbery", Default = false,
	}):OnChanged(function(enabled)
		if not enabled then return end

		task.spawn(function()
			local bank = FindBankByGoldCount(4)
			if not bank or CheckCooldown(bank, "NightClub") then return end

			local laser = bank:FindFirstChild("LaserDisabler")
			if laser and laser:FindFirstChild("Main") then
				TweenTo(laser.Main.CFrame + TP_OFFSET)
				task.wait(1.25)
				FireAnyPromptUnder(laser.Main)
			end

			task.wait(1.5)
			OpenDoor(bank, "VaultDoor")
			task.wait(42)

			local metalDoor = OpenDoor(bank, "MetalDoor")
			local vaultDoor = bank:FindFirstChild("VaultDoor")

			for _, obj in ipairs(bank:GetChildren()) do
				if obj:IsA("Model") and obj:FindFirstChild("Main")
					and obj ~= laser and obj ~= vaultDoor and obj ~= metalDoor then
					local prompt = obj.Main:FindFirstChildOfClass("ProximityPrompt", true)
					if prompt then
						TeleportTo(obj.Main)
						FirePromptCS(prompt)
						FirePromptCS(prompt)
					end
				end
			end

			CollectLoot(bank, function(i) return i.Name == "GoldIngot" and i:IsA("UnionOperation") end)
			CollectFirstLoot(bank, "MoneyBag", "Part")
			CollectLoot(bank, function(i) return i.Name == "Money" and i.ClassName == "MeshPart" end)
			TeleportTo(CFrame.new(-1306, 3, -191))
		end)
	end)

	local BoxJobRunning = false

	VulnGroup:AddToggle("BoxPickingJobToggle", {
		Text = "Auto Box Job", Default = false,
	}):OnChanged(function(enabled)
		BoxJobRunning = enabled
		if not enabled then return end

		task.spawn(function()
			local jobSystem = workspace:FindFirstChild("Job System")
			local box = jobSystem and jobSystem:FindFirstChild("BoxPickingJob")
				and jobSystem.BoxPickingJob:FindFirstChild("BOX1")
			if not box then Library:Notify("Box job not found.", 3); return end

			local prompt = box:FindFirstChildOfClass("ProximityPrompt", true)
			if not prompt then Library:Notify("Box prompt not found.", 3); return end

			for _ = 1, 5 do
				if not BoxJobRunning then break end
				TeleportTo(box)
				task.wait(0.1)
				FirePromptCS(prompt)
				task.wait(1)

				local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				local tool = LocalPlayer.Backpack:FindFirstChild("BOX")
				if Humanoid and tool then Humanoid:EquipTool(tool) end

				task.wait(0.4)
				TweenTo(CFrame.new(-1924, 3, -19))
				task.wait(2.6)
			end
		end)
	end)

	local CarRobberyRunning = false

	VulnGroup:AddToggle("CarRobberyToggle", {
		Text = "Auto Car Robbery", Default = false,
	}):OnChanged(function(enabled)
		CarRobberyRunning = enabled
		if not enabled then return end

		task.spawn(function()
			local folder = workspace:FindFirstChild("CarRobberys")
			if not folder then Library:Notify("No car robberies found.", 3); return end

			for _, model in ipairs(folder:GetChildren()) do
				if not CarRobberyRunning then break end
				if model:IsA("Model") then
					local scripts = model:FindFirstChild("Scripts")
					local proxPart = scripts and scripts:FindFirstChild("ProxPart")
					local prompt = proxPart and proxPart:FindFirstChildWhichIsA("ProximityPrompt")
					if proxPart and prompt then
						TweenTo(proxPart.CFrame)
						task.wait(0.2)
						FirePromptCS(prompt)
						task.wait(2)
					end
				end
			end
		end)
	end)

	local GarbageJobRunning = false

	VulnGroup:AddToggle("GarbageJobToggle", {
		Text = "Auto Garbage Job", Default = false,
	}):OnChanged(function(enabled)
		GarbageJobRunning = enabled
		if not enabled then return end

		task.spawn(function()
			local jobSystem = workspace:FindFirstChild("Job System")
			local box = jobSystem and jobSystem:FindFirstChild("GarbageJob")
				and jobSystem.GarbageJob:FindFirstChild("BOX1")
			if not box then Library:Notify("Garbage job not found.", 3); return end

			local prompt = box:FindFirstChildOfClass("ProximityPrompt", true)
			if not prompt then Library:Notify("Prompt not found.", 3); return end

			local jobPos = Vector3.new(-1410, 3, 29)

			local function PathfindTo(position)
				local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				local Humanoid = char:WaitForChild("Humanoid")
				local hrp = char:WaitForChild("HumanoidRootPart")
				Humanoid.WalkSpeed = 20

				local path = PathfindingService:CreatePath({
					AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, WaypointSpacing = 3,
				})
				path:ComputeAsync(hrp.Position, position)
				if path.Status ~= Enum.PathStatus.Success then return false end

				for _, wp in ipairs(path:GetWaypoints()) do
					Humanoid:MoveTo(wp.Position)
					Humanoid.MoveToFinished:Wait()
					if wp.Action == Enum.PathWaypointAction.Jump then
						Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end
					task.wait(0.05)
				end
				return true
			end

			local function JiggleAtJob()
				local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				local Humanoid = char:WaitForChild("Humanoid")
				local base = char:WaitForChild("HumanoidRootPart").Position
				for _, offset in ipairs({
					Vector3.new(1.5, 0, 0), Vector3.new(-1.5, 0, 0),
					Vector3.new(0, 0, 1.5), Vector3.new(0, 0, -1.5),
				}) do
					Humanoid:MoveTo(base + offset)
					Humanoid.MoveToFinished:Wait(0.6)
					task.wait(0.1)
				end
			end

			for _ = 1, 5 do
				if not GarbageJobRunning then break end
				TeleportTo(box)
				task.wait(0.2)
				FirePromptCS(prompt)
				task.wait(0.2)

				local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				local tool = LocalPlayer.Backpack:FindFirstChild("Garbage")
				if Humanoid and tool then Humanoid:EquipTool(tool) end

				task.wait(0.3)
				if PathfindTo(jobPos) then
					task.wait(0.2)
					JiggleAtJob()
				end
				task.wait(0.3)
			end
		end)
	end)

	local Vault12Running = false

	VulnGroup:AddToggle("Vault12RobberyToggle", {
		Text = "Auto Gold Robbery", Default = false,
	}):OnChanged(function(enabled)
		Vault12Running = enabled
		if not enabled then return end

		task.spawn(function()
			local bank = FindBankByGoldCount(12)
			if not bank then Library:Notify("No Vault Bank with 12 Gold found.", 3); return end
			if CheckCooldown(bank, "Vault bank") then return end

			OpenDoor(bank, "LaserDisabler")
			task.wait(1.2)
			OpenDoor(bank, "VaultDoor")
			task.wait(65)
			OpenDoor(bank, "MetalDoor")
			task.wait(1)

			for _, obj in ipairs(bank:GetChildren()) do
				if obj:IsA("Model") and obj:FindFirstChild("Main") then
					OpenDoor(bank, obj.Name)
					task.wait(0.6)
				end
			end

			local lootRoot = bank:FindFirstChild("Loot") or bank
			local emptyPasses = 0

			while emptyPasses < 3 and Vault12Running do
				local looted = false
				for _, inst in ipairs(lootRoot:GetDescendants()) do
					if (inst.Name == "GoldIngot" or inst.Name == "PlatinumIngot" or inst.Name == "MoneyBag")
						and (inst:IsA("UnionOperation") or inst:IsA("MeshPart") or inst:IsA("Part")) then
						local p = inst:FindFirstChildOfClass("ProximityPrompt", true)
						if p and p.Enabled then
							looted = true
							TeleportTo(inst)
							task.wait(0.12)
							FirePromptCS(p)
							task.wait(0.15)
						end
					end
				end
				emptyPasses = looted and 0 or emptyPasses + 1
				task.wait(0.15)
			end

			TweenTo(CFrame.new(-1784, 3, -803))
		end)
	end)
    VulnGroup:AddLabel("For Best Performance")
    VulnGroup:AddLabel("Join A Private Server")
    VulnGroup:AddLabel("Only 10 Robux")
	local Locations = {
		["Main GunStore"] = Vector3.new(-1641, 4, -87),
		["Mop Job"] = Vector3.new(-1666, 5, 45),
		["Gas Station"] = Vector3.new(-1913, 3, 93),
		["Weed Job"] = Vector3.new(-1994, 3, 177),
		["Box Job"] = Vector3.new(-1941, 3, -25),
		["Swipe Area"] = Vector3.new(-1541, 7, -320),
		["2nd GunStore"] = Vector3.new(-1860, 4, -752),
		["Hardware Store"] = Vector3.new(-1924, 4, -850),
		["Juice Factory"] = Vector3.new(-1971, 5, -724),
		["Car Upgrades"] = Vector3.new(-2062, 6, -382),
		["Car Dealer"] = Vector3.new(-1417, 3, -134),
		["Car Upgrades 2"] = Vector3.new(-1529, 4, -181),
		["Studio"] = Vector3.new(-1929, 3, 269),
		["Apts"] = Vector3.new(-2432, 8, -309),
		["Garbage Job"] = Vector3.new(-1396, 6, 27),
		["Bank"] = Vector3.new(-2339, 4, 136),
		["NightClub"] = Vector3.new(-1173, -12, -117),
		["Casino"] = Vector3.new(-2358, -25, -731),
		["Gold Depo"] = Vector3.new(-1619, -23, -844),
		["Big House"] = Vector3.new(-1971, 5, -724),
	}

	local sortedNames = {}
	for name in pairs(Locations) do table.insert(sortedNames, name) end
	table.sort(sortedNames)

	local TeleportMethod = "Instant"
	TeleGroup:AddDropdown("TeleportTypeDropdown", {
		Values = {"Instant", "Tween"}, Default = "Instant", Text = "Teleport Method",
		Callback = function(v) TeleportMethod = v end,
	})

	TeleGroup:AddDropdown("LocationTP", {
		Values = sortedNames, Default = "", Text = "Teleport To Location",
		Callback = function(selected)
			local pos = Locations[selected]
			if not pos then return end
			if TeleportMethod == "Tween" then
				TweenTo(CFrame.new(pos))
			else
				GetRoot().CFrame = CFrame.new(pos) + TP_OFFSET
			end
		end,
	})

	TeleGroup:AddLabel("Using Instant Can Make You")
    TeleGroup:AddLabel("Teleport Before The Map Has")
    TeleGroup:AddLabel("Loaded In")
end
cali()
end)


if not success then
    warn("UI Load Error:", err)
end
