local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "RadialMenu"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = false
gui.Parent = nil

local RadialMenu = {}
RadialMenu.onOptionSelected = function(_) end

local OPTIONS = {
	{ Name = "ESP", Display = "ESP" },
	{ Name = "AIM", Display = "Aimbot" },
	{ Name = "CLOSE", Display = "Close" }
}

local BUTTONS = {}
local frame, centerLabel, statusLabel
local selectedIndex, altHeld = 1, false
local espState, aimState = false, false

-- helper functions omitted for brevity
-- [you'll paste full RadialMenu code here from your existing script and move logic]

-- Instead of calling toggleESP/aim inside RadialMenu,
-- we'll call RadialMenu.onOptionSelected(name)

return RadialMenu
