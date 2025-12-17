local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local RadialMenu = {}
RadialMenu.onOptionSelected = function(_) end

local gui, frame, centerLabel, statusLabel
local BUTTONS = {}
local selectedIndex = 1
local altHeld = false

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

local function makeCircle(f)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = f
end

function RadialMenu.Init(parent)
	gui = Instance.new("ScreenGui")
	gui.Name = "RadialMenu"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = parent

	frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.Size = UDim2.new(0, 0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.SizeConstraint = Enum.SizeConstraint.RelativeYY
	frame.Visible = false
	frame.Parent = gui

	local centerCircle = Instance.new("Frame", frame)
	centerCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	centerCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
	centerCircle.Size = UDim2.new(0, 90, 0, 90)
	centerCircle.BackgroundColor3 = mainColor
	centerCircle.BackgroundTransparency = 0.3
	centerCircle.BorderSizePixel = 0
	makeCircle(centerCircle)

	centerLabel = Instance.new("TextLabel", centerCircle)
	centerLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	centerLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	centerLabel.Size = UDim2.new(0.9, 0, 0.6, 0)
	centerLabel.BackgroundTransparency = 1
	centerLabel.TextColor3 = Color3.new(1, 1, 1)
	centerLabel.Font = Enum.Font.GothamBold
	centerLabel.TextSize = 18
	centerLabel.TextWrapped = true

	statusLabel = Instance.new("TextLabel", centerCircle)
	statusLabel.AnchorPoint = Vector2.new(0.5, 0)
	statusLabel.Position = UDim2.new(0.5, 0, 1, 4)
	statusLabel.Size = UDim2.new(1.5, 0, 0, 22)
	statusLabel.BackgroundTransparency = 1
	statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	statusLabel.Font = Enum.Font.Gotham
	statusLabel.TextSize = 14
	statusLabel.Text = ""

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

		BUTTONS[i] = {
			frame = btn,
			dir = dir,
			name = opt.Name,
			display = opt.Display,
			currentTween = nil
		}
	end

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.LeftAlt then
			altHeld = true
			RadialMenu.Show()
		end
		if altHeld and input.UserInputType == Enum.UserInputType.MouseButton1 then
			selectedIndex += 1
			if selectedIndex > #BUTTONS then selectedIndex = 1 end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftAlt then
			altHeld = false
			RadialMenu.Hide()
			local selected = BUTTONS[selectedIndex]
			if selected.name ~= "CLOSE" then
				RadialMenu.onOptionSelected(selected.name)
			end
		end
	end)

	RunService.RenderStepped:Connect(function()
		if not altHeld then return end
		local selected = BUTTONS[selectedIndex]
		centerLabel.Text = selected.display
		statusLabel.Text = ""
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
end

function RadialMenu.Show()
	frame.Visible = true
	frame:TweenSize(UDim2.new(0.3, 0, 0.3, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
end

function RadialMenu.Hide()
	frame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.2, true)
	task.delay(0.22, function() frame.Visible = false end)
end

return RadialMenu
