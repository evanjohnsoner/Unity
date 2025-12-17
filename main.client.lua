local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("Unity")
if old then old:Destroy() end

local Unity = Instance.new("Folder")
Unity.Name = "Unity"
Unity.Parent = PlayerGui

local RadialMenu = loadstring(game:HttpGet("https://raw.githubusercontent.com/evanjohnsoner/Unity/main/ui/RadialMenu.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/evanjohnsoner/Unity/main/systems/ESP.lua"))()
local Aimbot = loadstring(game:HttpGet("https://raw.githubusercontent.com/evanjohnsoner/Unity/main/systems/Aimbot.lua"))()

RadialMenu.onOptionSelected = function(name)
	if name == "ESP" then
		ESP.Toggle()
	elseif name == "AIM" then
		Aimbot.Toggle()
	end
end

RadialMenu.Init(Unity)
