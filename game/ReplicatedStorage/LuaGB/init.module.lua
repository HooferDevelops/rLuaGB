local LuaGB = {}

LuaGB.Version = "ROBLOX PORT"

local binser = require(game.ReplicatedStorage.LuaGB.vendor.binser)
local gameboy = require(game.ReplicatedStorage.LuaGB.gameboy.init)

LuaGB.game_screen_image = nil
LuaGB.game_screen_imagedata = nil

local panels = {}

function LuaGB:from_hex(p1)
	return p1:gsub("..", function(p2)
		return string.char(tonumber(p2, 16))
	end)
end

function LuaGB:to_hex(p3)
	return p3:gsub(".", function(p4)
		return string.format("%02X", string.byte(p4))
	end)
end

LuaGB.TemporaryState = nil

function LuaGB:save_state(number)
	local state_data = self.gameboy:save_state()
	local filename = "states/" .. self.game_filename .. ".s" .. number
	--local state_string = binser.serialize(state_data)
	
	self.TemporaryState = state_data
end

function LuaGB:load_state(number)
	LuaGB:reset()
	LuaGB:load_game(LuaGB.game_path)

	local filename = "states/" .. self.game_filename .. ".s" .. number
	--local file_data = game.ReplicatedStorage.GetSaveData:InvokeServer()
	
	--local state_data, elements = binser.deserialize(file_data)
	if self.TemporaryState then
		self.gameboy:load_state(self.TemporaryState)
		print("Loaded state: ", filename)
	else
		print("Error parsing state data for ", filename)
	end
end
function LuaGB:play_gameboy_audio(buffer)
end

function LuaGB:reset()
	self.gameboy = gameboy.new{}
	self.gameboy:initialize()
	self.gameboy:reset()
	self.gameboy.audio.on_buffer_full(self.play_gameboy_audio)
	self.audio_dump_running = false
	self.emulator_running = false
	self.game_loaded = false

	-- Initialize Debug Panels
	for _, panel in pairs(panels) do
		panel.init(self.gameboy)
	end
end


function LuaGB:load_game(game_path)
	self:reset()

	local file_data = game_path
	if file_data then
		self.game_path = game_path
		self.game_filename = game_path
		while string.find(self.game_filename, "/") do
			self.game_filename = string.sub(self.game_filename, string.find(self.game_filename, "/") + 1)
		end
		
		self.gameboy.cartridge.load(file_data, #file_data or string.len(file_data))
		--self:load_ram()
		self.gameboy:reset()

		print("Successfully loaded ", self.game_filename)
	else
		print("Couldn't open ", game_path, " giving up.")
		return
	end

	--self.window_title = "LuaGB v" .. self.version .. " - " .. self.gameboy.cartridge.header.title
	
	self.menu_active = false
	self.emulator_running = true
	self.game_loaded = true
end

function LuaGB:draw_game_screen(dx, dy, scale, ui)
	local pixels = self.gameboy.graphics.game_screen
	
	for y = 0, 143 do
		for x = 0, 159 do
			ui:set_canvas_pixel(x, y, Color3.fromRGB(pixels[y][x][1], pixels[y][x][2], pixels[y][x][3]))
		end
	end
	
	return pixels
end

return LuaGB
