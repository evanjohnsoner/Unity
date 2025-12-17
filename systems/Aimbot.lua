local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local MAX_DISTANCE = 1000
local aimbotEnabled = false

local Aimbot = {}

function Aimbot.Toggle()
	aimbotEnabled = not aimbotEnabled
end

RunService.RenderStepped:Connect(function()
	if not aimbotEnabled then return end
	if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
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
end)

return Aimbot
