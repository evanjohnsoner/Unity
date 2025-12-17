local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

-- 🧼 Cleanup old
local old = playerGui:FindFirstChild("Unity")
if old then old:Destroy() end

-- 📁 Unity folder
local Unity = Instance.new("Folder")
Unity.Name = "Unity"
Unity.Parent = playerGui

-- 🖥️ GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RadialMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = Unity

-- 🧱 Main Frame
local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(0, 0, 0, 0)
frame.SizeConstraint = Enum.SizeConstraint.RelativeYY
frame.BackgroundTransparency = 1
frame.Visible = false
frame.Parent = screenGui

-- 🔊 Sounds
local selectSound = Instance.new("Sound", frame)
selectSound.SoundId = "rbxassetid://876939830"
selectSound.Volume = 0.6

local confirmSound = Instance.new("Sound", frame)
confirmSound.SoundId = "rbxassetid://90698049598280"
confirmSound.Volume = 0.6

-- 🔘 Helper
local function makeCircle(frame)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = frame
end

-- ⚙️ Config
local OPTIONS = {
	{ Name = "ESP", Display = "ESP" },
	{ Name = "AIM", Display = "Aimbot" },
	{ Name = "CLOSE", Display = "Close" }
}

local mainColor = Color3.fromRGB(30, 30, 30)
local hoverColor = Color3.fromRGB(255, 255, 255)
local radius = 100
local baseSize = 44
local hoverSize = 56
local outwardOffset = 24
local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- 🔘 Main Circle
local centerCircle = Instance.new("Frame", frame)
centerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
centerCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
centerCircle.Size = UDim2.new(0, 0, 0, 0)
centerCircle.BackgroundColor3 = mainColor
centerCircle.BackgroundTransparency = 0.3
centerCircle.BorderSizePixel = 0
makeCircle(centerCircle)

-- 📄 Label
local centerLabel = Instance.new("TextLabel", centerCircle)
centerLabel.AnchorPoint = Vector2.new(0.5, 0.5)
centerLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
centerLabel.Size = UDim2.new(0.9, 0, 0.6, 0)
centerLabel.BackgroundTransparency = 1
centerLabel.TextColor3 = Color3.new(1, 1, 1)
centerLabel.Font = Enum.Font.GothamBold
centerLabel.TextSize = 18
centerLabel.TextWrapped = true

-- 🟡 Status label
local statusLabel = Instance.new("TextLabel", centerCircle)
statusLabel.AnchorPoint = Vector2.new(0.5, 0)
statusLabel.Position = UDim2.new(0.5, 0, 1, 4)
statusLabel.Size = UDim2.new(1.5, 0, 0, 22)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.Text = ""
statusLabel.TextTransparency = 0.1

-- 🔘 Create Buttons
local BUTTONS = {}
for i, opt in ipairs(OPTIONS) do
	local angle = math.rad((i - 1) * 120 - 90)
	local dir = Vector2.new(math.cos(angle), math.sin(angle)).Unit

	local btn = Instance.new("Frame")
	btn.AnchorPoint = Vector2.new(0.5, 0.5)
	btn.Size = UDim2.new(0, baseSize, 0, baseSize)
	btn.Position = UDim2.new(0.5, 0, 0.5, 0)
	btn.BackgroundColor3 = mainColor
	btn.BackgroundTransparency = 0.2
	btn.BorderSizePixel = 0
	btn.Parent = frame
	makeCircle(btn)

	local icon = Instance.new("ImageLabel", btn)
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.new(0.5, 0, 0.5, 0)
	icon.Size = UDim2.new(0.7, 0, 0.7, 0)
	icon.BackgroundTransparency = 1
	icon.ImageColor3 = Color3.new(1, 1, 1)
	icon.ScaleType = Enum.ScaleType.Stretch

	if opt.Name == "AIM" then
		icon.Image = "rbxassetid://8445471713"
		icon.ImageRectOffset = Vector2.new(204, 504)
		icon.ImageRectSize = Vector2.new(96, 96)
	elseif opt.Name == "ESP" then
		icon.Image = "rbxassetid://8445470984"
		icon.ImageRectOffset = Vector2.new(804, 804)
		icon.ImageRectSize = Vector2.new(96, 96)
	elseif opt.Name == "CLOSE" then
		icon.Image = "rbxassetid://8445470559"
		icon.ImageRectOffset = Vector2.new(804, 604)
		icon.ImageRectSize = Vector2.new(96, 96)
	end

	BUTTONS[i] = {
		frame = btn,
		icon = icon,
		dir = dir,
		name = opt.Name,
		display = opt.Display,
		currentTween = nil
	}
end

-- 🌐 States
local espEnabled = false
local aimEnabled = false
local selectedIndex = 1
local altHeld = false
local espHighlights = {}
local MAX_DISTANCE = 1000

-- 🔍 ESP LOGIC (TEAM DIFFERENTIAL)
local function toggleESP(on)
	for _, h in ipairs(espHighlights) do
		h:Destroy()
	end
	table.clear(espHighlights)

	if not on then return end
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

	for _, target in Players:GetPlayers() do
		if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (player.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude
			if dist <= MAX_DISTANCE then
				local hl = Instance.new("Highlight")
				hl.Adornee = target.Character
				hl.FillTransparency = 0.5
				hl.OutlineTransparency = 1
				hl.FillColor = (target.Team == player.Team)
					and Color3.fromRGB(0, 100, 255)
					or Color3.fromRGB(255, 0, 0)
				hl.Parent = Unity
				table.insert(espHighlights, hl)
			end
		end
	end
end

-- 🎯 Aimbot Logic (unchanged)
RunService.RenderStepped:Connect(function()
	if aimEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local closest, shortest = nil, math.huge
		for _, p in Players:GetPlayers() do
			if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
				local dist = (p.Character.Head.Position - camera.CFrame.Position).Magnitude
				if dist <= MAX_DISTANCE then
					local pos, onScreen = camera:WorldToViewportPoint(p.Character.Head.Position)
					if onScreen then
						local delta = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
						if delta < 120 and delta < shortest then
							shortest = delta
							closest = p
						end
					end
				end
			end
		end
		if closest and closest.Character and closest.Character:FindFirstChild("Head") then
			camera.CFrame = CFrame.new(camera.CFrame.Position, closest.Character.Head.Position)
		end
	end
end)

-- 🟢 Show Menu
local function showMenu()
	frame.Visible = true
	frame.Size = UDim2.new(0, 0, 0, 0)
	centerCircle.Size = UDim2.new(0, 0, 0, 0)

	TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.3, 0, 0.3, 0)
	}):Play()

	TweenService:Create(centerCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
		Size = UDim2.new(0, 90, 0, 90)
	}):Play()

	for _, b in ipairs(BUTTONS) do
		b.frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	end

	task.delay(0.05, function()
		for _, b in ipairs(BUTTONS) do
			local dist = radius
			local targetPos = UDim2.new(0.5, b.dir.X * dist, 0.5, b.dir.Y * dist)
			TweenService:Create(b.frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
				Position = targetPos
			}):Play()
		end
	end)
end

-- 🔴 Hide Menu
local function hideMenu()
	TweenService:Create(frame, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 0, 0) }):Play()
	TweenService:Create(centerCircle, TweenInfo.new(0.2), { Size = UDim2.new(0, 0, 0, 0) }):Play()
	task.delay(0.22, function() frame.Visible = false end)
end

-- 🔑 Input Handling
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.LeftAlt then
		altHeld = true
		showMenu()
	end
	if altHeld and input.UserInputType == Enum.UserInputType.MouseButton1 then
		selectedIndex += 1
		if selectedIndex > #BUTTONS then selectedIndex = 1 end
		selectSound:Play()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftAlt then
		altHeld = false
		hideMenu()
		confirmSound:Play()

		local selected = BUTTONS[selectedIndex]
		if selected.name == "CLOSE" then return end

		if selected.name == "ESP" then
			espEnabled = not espEnabled
			toggleESP(espEnabled)
		elseif selected.name == "AIM" then
			aimEnabled = not aimEnabled
		end
	end
end)

-- 🔁 UI Update
RunService.RenderStepped:Connect(function()
	if not altHeld then return end
	local selected = BUTTONS[selectedIndex]

	centerLabel.Text = selected.display
	statusLabel.Text =
		(selected.name == "ESP" and (espEnabled and "Status: ON" or "Status: OFF"))
		or (selected.name == "AIM" and (aimEnabled and "Status: ON" or "Status: OFF"))
		or ""

	for i, b in ipairs(BUTTONS) do
		local isSelected = (i == selectedIndex)
		local size = isSelected and hoverSize or baseSize
		local dist = radius + (isSelected and outwardOffset or 0)

		if b.currentTween then b.currentTween:Cancel() end
		b.currentTween = TweenService:Create(b.frame, tweenInfo, {
			Size = UDim2.new(0, size, 0, size),
			Position = UDim2.new(0.5, b.dir.X * dist, 0.5, b.dir.Y * dist),
			BackgroundColor3 = isSelected and hoverColor or mainColor,
			BackgroundTransparency = isSelected and 0.1 or 0.2
		})
		b.currentTween:Play()
	end
end)
