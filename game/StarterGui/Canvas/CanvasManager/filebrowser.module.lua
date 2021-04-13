local filebrowser = {}
filebrowser.__index = filebrowser

filebrowser.palettes = {}
filebrowser.palette_index = 3
filebrowser.palettes[1] = {[0]=Color3.fromRGB(255, 255, 255), [1]=Color3.fromRGB(192, 192, 192), [2]=Color3.fromRGB(128, 128, 128), [3]=Color3.fromRGB(0, 0, 0)}
filebrowser.palettes[2] = {[0]=Color3.fromRGB(215, 215, 215), [1]=Color3.fromRGB(140, 124, 114), [2]=Color3.fromRGB(100, 82, 73), [3]=Color3.fromRGB(45, 45, 45)}
filebrowser.palettes[3] = {[0]=Color3.fromRGB(224, 248, 208), [1]=Color3.fromRGB(136, 192, 112), [2]=Color3.fromRGB(52, 104, 86), [3]=Color3.fromRGB(8, 24, 32)}


filebrowser.init = function(canvas, main)	
	local filebrowser_new = setmetatable({}, filebrowser)
	filebrowser_new.ui = canvas
	filebrowser_new.gameboy = main
	filebrowser_new.game_screen = {}
	filebrowser_new.frame_counter = 0
	filebrowser_new.cursor_pos = 0
	filebrowser_new.scroll_pos = 0
	filebrowser_new.items = {}
	filebrowser_new:refresh_items()
	
	for y=0,canvas.canvas_height do
		filebrowser_new.game_screen[y] = {}
		for x=0,canvas.canvas_width do
			filebrowser_new.game_screen[y][x] = Color3.fromRGB(255,255,255)
		end
	end
	return filebrowser_new
end

function filebrowser:draw_background(sx, sy)
	for x = 0, self.ui.canvas_width do
		for y = 0, self.ui.canvas_height do
			local tx = math.floor((x + sx) / 8)
			local ty = math.floor((y + sy) / 8)
			if (tx + ty) % 2 == 0 then
				self.game_screen[y][x] = self.palettes[self.palette_index][0]
			else
				self.game_screen[y][x] = self.palettes[self.palette_index][1]
			end
		end
	end
end

function filebrowser:draw_shadow_pixel(x, y)
	local palette = self.palettes[self.palette_index]
	if self.game_screen[y][x] == palette[2] then
		self.game_screen[y][x] = palette[3]
	end
	if self.game_screen[y][x] == palette[1] then
		self.game_screen[y][x] = palette[2]
	end
	if self.game_screen[y][x] == palette[0] then
		self.game_screen[y][x] = palette[1]
	end
end

function filebrowser:draw_shadow(dx, dy, width, height)
	for x = dx, dx + width - 1 do
		for y = dy, dy + height - 1 do
			self:draw_shadow_pixel(x, y)
		end
	end
end

function filebrowser:shadow_box(x, y, width, height)
	local palette = self.palettes[self.palette_index]
	self:draw_shadow(x + 1, y + 1, width, height)
	self:draw_rectangle(x, y, width, height, palette[0], true)
	self:draw_rectangle(x, y, width, height, palette[3])
end

function filebrowser:draw_rectangle(dx, dy, width, height, color, filled)
	for x = dx, dx + width - 1 do
		for y = dy, dy + height - 1 do
			if filled or y == dy or y == dy + height - 1 or x == dx or x == dx + width - 1 then
				self.game_screen[y][x] = color
			end
		end
	end
end

function filebrowser:shift_palette()
	self.palette_index = self.palette_index + 1
	if (self.palette_index > 3) then
		self.palette_index = 1
	end
end

function filebrowser:draw_string(str, dx, dy, color, max_x)
	max_x = max_x or 159
	for i = 1, #str do
		local char = string.byte(str, i)
		if 31 < char and char < 128 then
			char = char - 32
			local font_x = char * 4
			local font_y = 0
			for x = 0, 3 do
				if i * 4 - 4 + x + dx < max_x then
					for y = 0, 5 do
						if y + dy <= 143 then
							local rgb, alpha = self.ui.image:get_pixel(font_x + x + 1, font_y + y + 1, "font")
							if alpha > 0 then
								self.game_screen[y + dy][i * 4 - 4 + x + dx] = color
							end
						end
					end
				end
			end
		end
	end
end

function filebrowser:refresh_items()
	coroutine.wrap(function()
		local roms = game.ReplicatedStorage.GetROMs:InvokeServer()
		for _,rom in pairs(game.ReplicatedStorage.ROMs:GetChildren()) do
			table.insert(roms, rom)
		end
		self.items = {
			{
				["Name"] = "Import ROM",
				["Value"] = "IMPORT_ROM_ENTRY"
			}
		}
		for _,rom in pairs(roms) do
			table.insert(self.items, rom)
		end
	end)()
end

function filebrowser:draw()
	-- queue up everything and then draw.
	local frames = self.frame_counter
	local scroll_amount = math.floor(frames / 8)
	self:draw_background(scroll_amount, scroll_amount * -1)
	self:shadow_box(7, 15, 146, 81)
	self.ui.image.palette = self.palettes[self.palette_index]
	
	-- highlight box
	self:draw_rectangle(8, 17 + ((self.cursor_pos - self.scroll_pos) * 7), 144, 7, self.palettes[self.palette_index][2], true)

	-- Filebrowser / game selection menu
	local y = 18
	local i = 0 - self.scroll_pos
	for _, item in pairs(self.items) do
		if i >= 0 and i < 11 then
			local color = self.palettes[self.palette_index][2]
			if i + self.scroll_pos == self.cursor_pos then
				color = self.palettes[self.palette_index][3]
			end
			self:draw_string(item.Name or item["Name"] or "ERR", 10, y, color, 152)
			y = y + 7
		end
		i = i + 1
	end	
	
	-- Logo
	self.ui.image:draw_image(22, 0, "logo", self.game_screen)
	self.ui.image:draw_image(7, 0, "dango", self.game_screen)
	
	self.ui.image:draw_image(133, 4, "palette_chooser", self.game_screen)
	self.ui.image:draw_image(136, 108, "round_button", self.game_screen)    -- A
	self.ui.image:draw_image(124, 120, "round_button", self.game_screen)    -- B
	self.ui.image:draw_image(86, 114, "pill_button", self.game_screen)     -- Start
	self.ui.image:draw_image(51, 114, "pill_button", self.game_screen)     -- Select
	self.ui.image:draw_image(12, 104, "d_pad", self.game_screen)
	--self.ui.image:draw_image(111, 0, "folder", self.game_screen)
	
	self:draw_string("X", 140, 111, self.palettes[self.palette_index][3])      -- A
	self:draw_string("Z", 128, 123, self.palettes[self.palette_index][3])      -- B
	self:draw_string("ENTER", 92, 117, self.palettes[self.palette_index][3])   -- Start
	self:draw_string("RSHIFT", 55, 117, self.palettes[self.palette_index][3])  -- Select
	
	for y=0,self.ui.canvas_height do
		for x=0,self.ui.canvas_width do
			self.ui:set_canvas_pixel(x, y, self.game_screen[y][x])
		end
	end
	
	self.frame_counter = self.frame_counter + 2
end

return filebrowser