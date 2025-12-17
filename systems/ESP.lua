local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local MAX_DISTANCE = 1000
local espHighlights = {}
local espEnabled = false

local ESP = {}

function ESP.Toggle()
	espEnabled = not espEnabled

	for _, h in ipairs(espHighlights) do
		h:Destroy()
	end
	table.clear(espHighlights)

	if not espEnabled then return end

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
				hl.Parent = player.PlayerGui:WaitForChild("Unity")
				table.insert(espHighlights, hl)
			end
		end
	end
end

return ESP
