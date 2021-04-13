local mouse = game.Players.LocalPlayer:GetMouse()
mouse.Icon = "rbxassetid://6674260576"

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = game.Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local ControllerUI = PlayerGui:WaitForChild("Controller")
local Canvas = PlayerGui:WaitForChild("Canvas")


local main = require(game.ReplicatedStorage.LuaGB.init)

RunService.RenderStepped:Connect(function()
	if LocalPlayer and LocalPlayer.PlayerGui and LocalPlayer.PlayerGui:FindFirstChild("Controller") then
		local LastInput = UserInputService:GetLastInputType()

		if LastInput == Enum.UserInputType.Gamepad1 then
			LocalPlayer.PlayerGui.Controller.Enabled = false
		else
			LocalPlayer.PlayerGui.Controller.Enabled = true
		end
	end
end) -- Check if controller is plugged in so we can hide the bottom screen controller.



local input_mappings = {
	["Up"] = {
		["PC"] = "Enum.KeyCode.W",
		
		["Controller"] = "Enum.KeyCode.DPadUp"
	},
	
	["Down"] = {
		["PC"] = "Enum.KeyCode.S",
		
		["Controller"] = "Enum.KeyCode.DPadDown"
	},
	
	["Left"] = {
		["PC"] = "Enum.KeyCode.A",
		
		["Controller"] = "Enum.KeyCode.DPadLeft"
	},
	
	["Right"] = {
		["PC"] = "Enum.KeyCode.D",
		
		["Controller"] = "Enum.KeyCode.DPadRight"
	},
	
	["A"] = {
		["PC"] = "Enum.KeyCode.X",
		
		["Controller"] = "Enum.KeyCode.ButtonA"
	},
	
	["B"] = {
		["PC"] = "Enum.KeyCode.Z",
		
		["Controller"] = "Enum.KeyCode.ButtonB"
	},
	
	["Start"] = {
		["PC"] = "Enum.KeyCode.Return",
		
		["Controller"] = "Enum.KeyCode.ButtonStart"
	},
	
	["Select"] = {
		["PC"] = "Enum.KeyCode.RightShift",
		
		["Controller"] = "Enum.KeyCode.ButtonSelect"
	},
	
	["Pause"] = {
		["PC"] = "Enum.KeyCode.P"
	}
}


function modifyBind(gb_button, new_bind)
	input_mappings[gb_button]["PC"] = new_bind
end

function inputDown(key)
	if (key and not key.KeyCode) then
		key = {["KeyCode"] = key}
	end
	if (not key) then
		return
	end
	if (not main.gameboy or not main.gameboy.input or not main.gameboy.input.keys) then
		return
	end
	
	local gameboy_key
	

	for gb_key, gb_keybinds in pairs(input_mappings) do
		for _, keybind in pairs(gb_keybinds) do
			if keybind == tostring(key.KeyCode) then
				gameboy_key = gb_key
			end
		end
	end
	
	if gameboy_key then
		main.gameboy.input.keys[gameboy_key] = 1
		main.gameboy.input.key_pressed(gameboy_key)
		main.gameboy.input.update()
	end
end

function inputUp(key)
	if (key and not key.KeyCode) then
		key = {["KeyCode"] = key}
	end
	if (not key) then
		return
	end
	if (not main.gameboy or not main.gameboy.input or not main.gameboy.input.keys) then
		return
	end
	if (tostring(key.KeyCode) == "Enum.KeyCode.P") then
		main.emulator_running = not main.emulator_running
	end
	
	local gameboy_key
	
	
	for gb_key, gb_keybinds in pairs(input_mappings) do
		for _, keybind in pairs(gb_keybinds) do
			if keybind == tostring(key.KeyCode) then
				gameboy_key = gb_key
			end
		end
	end

	if gameboy_key then
		main.gameboy.input.keys[gameboy_key] = 0
		main.gameboy.input.update()
	end
	
end

game:GetService("UserInputService").InputBegan:Connect(inputDown)
game:GetService("UserInputService").InputEnded:Connect(inputUp)



for _,button in pairs(ControllerUI:GetDescendants()) do
	if (button:IsA("GuiButton")) and string.find(button.Name, "Enum") then
		button.MouseButton1Down:Connect(function()
			inputDown(button.Name)
		end)
		button.MouseButton1Up:Connect(function()
			inputUp(button.Name)
		end)
	end
end