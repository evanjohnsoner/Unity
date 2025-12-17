local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local MAX_DISTANCE = 1000
local espEnabled = false
local highlights = {}

local ESP = {}

function ESP.Toggle()
	espEnabled = not espEnabled
	if not espEnabled then
		for _, h in pairs(highlights) do
			h:Destroy()
		end
		table.clear(highlights)
	end
end

local function updateESP()
	if not espEnabled then return end
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end

	for _, p in Players:GetPlayers() do
		if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
			if dist <= MAX_DISTANCE then
				if not highlights[p] then
					local hl = Instance.new("Highlight")
					hl.Adornee = p.Character
					hl.FillTransparency = 0.5
					hl.OutlineTransparency = 1
					hl.FillColor = (p.Team == player.Team)
						and Color3.fromRGB(0, 100, 255)
						or Color3.fromRGB(255, 0, 0)
					hl.Parent = player:WaitForChild("PlayerGui"):WaitForChild("Unity")
					highlights[p] = hl
				else
					highlights[p].Adornee = p.Character
				end
			else
				if highlights[p] then
					highlights[p]:Destroy()
					highlights[p] = nil
				end
			end
		else
			if highlights[p] then
				highlights[p]:Destroy()
				highlights[p] = nil
			end
		end
	end
end

Players.PlayerRemoving:Connect(function(p)
	if highlights[p] then
		highlights[p]:Destroy()
		highlights[p] = nil
	end
end)

RunService.RenderStepped:Connect(function()
	if espEnabled then
		updateESP()
	end
end)

return ESP
