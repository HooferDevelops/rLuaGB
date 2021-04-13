local ui = require(game.ReplicatedStorage.UI.init).new()
local main = require(game.ReplicatedStorage.LuaGB.init)
local filebrowser = require(script.filebrowser)
main:reset()

local canvas = script.Parent.Canvas.Pixels

ui:create_canvas(canvas, 159, 143)
filebrowser = filebrowser.init(ui, main)

ui.image:load_image("logo", "https://cdn.discordapp.com/attachments/830545101650526259/830555541876506644/rluagb.png")
ui.image:load_image("dango", "https://cdn.discordapp.com/attachments/830545101650526259/830545294684979230/dango_0.png")
ui.image:load_image("palette_chooser", "https://cdn.discordapp.com/attachments/830545101650526259/830545259523866674/palette_chooser.png")
ui.image:load_image("round_button", "https://cdn.discordapp.com/attachments/830545101650526259/830545262812200970/round_button.png")
ui.image:load_image("pill_button", "https://cdn.discordapp.com/attachments/830545101650526259/830545261126352896/pill_button.png")
ui.image:load_image("d_pad", "https://cdn.discordapp.com/attachments/830545101650526259/830545252669980682/d-pad.png")
ui.image:load_image("folder", "https://cdn.discordapp.com/attachments/830545101650526259/830545254590578698/folder.png")
ui.image:load_image("font", "https://cdn.discordapp.com/attachments/830545101650526259/830545282642346004/5x3font.png")

game:GetService("RunService").Stepped:Connect(function()
	if main.emulator_running then
		main.gameboy:run_until_vblank()
	end	
end)

game:GetService("RunService").RenderStepped:Connect(function()
	if main.emulator_running then
		main:draw_game_screen(0, 0, 2, ui, filebrowser.palettes[filebrowser.palette_index])	
	else
		filebrowser:draw()
	end

	local function rgbToTable(color)
		return {color.r*255,color.g*255,color.b*255}	
	end
	
	main.gameboy.graphics.palette.set_dmg_colors(
		rgbToTable(filebrowser.palettes[filebrowser.palette_index][0]),
		rgbToTable(filebrowser.palettes[filebrowser.palette_index][1]),
		rgbToTable(filebrowser.palettes[filebrowser.palette_index][2]),
		rgbToTable(filebrowser.palettes[filebrowser.palette_index][3])
	)
end)

function input_state(key)
	if not main.emulator_running then
		filebrowser:refresh_items()
		if key == "Start" then
			filebrowser:shift_palette()
		end

		if key == "Select" then	

		end
		if key == "A" then
			local cursor_item = filebrowser.items[filebrowser.cursor_pos + 1]
			if cursor_item == nil then
				return
			end
			if cursor_item.Value == "IMPORT_ROM_ENTRY" then
				game.Players.LocalPlayer.PlayerGui:WaitForChild("ImportScreen"):WaitForChild("Menu").Visible = true
				return
			end
			main:load_game(game.ReplicatedStorage.RawData:InvokeServer(cursor_item.Value))		
		end
		if key == "Up" and filebrowser.cursor_pos > 0 then
			filebrowser.cursor_pos = filebrowser.cursor_pos - 1
			if filebrowser.cursor_pos < filebrowser.scroll_pos + 1 and filebrowser.scroll_pos > 0 then
				filebrowser.scroll_pos = filebrowser.cursor_pos - 1
			end
		end
		if key == "Down" and filebrowser.cursor_pos < #filebrowser.items - 1 then
			filebrowser.cursor_pos = filebrowser.cursor_pos + 1
			if filebrowser.cursor_pos > filebrowser.scroll_pos + 9 then
				filebrowser.scroll_pos = filebrowser.cursor_pos - 9
			end
		end
	end
end

main.gameboy.input.key_pressed = input_state


local StopButton = script.Parent.Canvas.ResetButton

StopButton.MouseButton1Click:Connect(function()
	main:reset()
	main.emulator_running = false
	main.gameboy.input.key_pressed = input_state
end)

local RomImportMenu = game.Players.LocalPlayer.PlayerGui:WaitForChild("ImportScreen"):WaitForChild("Menu")

RomImportMenu.Cancel.MouseButton1Click:Connect(function()
	filebrowser:refresh_items()	
	RomImportMenu.Visible = false
end)

RomImportMenu.RomConfirm.MouseButton1Click:Connect(function()
	game.ReplicatedStorage.SaveROM:InvokeServer(RomImportMenu.RomURL.Text, RomImportMenu.RomName.Text)
	RomImportMenu.RomURL.Text = ""
	RomImportMenu.RomName.Text = ""
	filebrowser:refresh_items()
	RomImportMenu.Visible = false
end)
