local UI = {}
UI.__index = UI

local gameboy = game.ReplicatedStorage.LuaGB.gameboy
local ui = game.ReplicatedStorage.UI

function UI:create_canvas(ui_parent, size_x, size_y)
	if (not ui_parent or not size_x or not size_y) then
		print("Invalid input for canvas creation.")
	end
	self.canvasPixels = {}
	self.canvas_width = size_x
	self.canvas_height = size_y
	self.canvasParent = ui_parent
	for y = 0, size_y do
		for x = 0, size_x do
			self:create_canvas_pixel(x,y,Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255)))
		end
		if (y%(math.floor(size_y/4 + 0.5)) == 0) then
			wait()
		end
	end	
end

function UI:create_canvas_pixel(x, y, color)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0,1,0,1)
	frame.BorderSizePixel = 0
	frame.Name = "pixel"
	frame.Parent = self.canvasParent
	frame.Position = UDim2.new(0,x,0,y)
	frame.BackgroundColor3 = color
	frame.ZIndex = 99
	if (not self.canvasPixels[x]) then
		self.canvasPixels[x] = {}
	end
	if (self.canvasPixels[x][y]) then
		self.canvasPixels[x][y]:Destroy()
	end
	self.canvasPixels[x][y] = frame
end
 
function UI:get_canvas_pixel_color(x, y)
	if (self.canvasPixels[x] and self.canvasPixels[x][y]) then
		return self.canvasPixels[x][y].BackgroundColor3
	end
end

function UI:set_canvas_pixel(x, y, color, transparent)
	if (not transparent or transparent == 255) then
		if (self.canvasPixels[x] and self.canvasPixels[x][y]) then
			if (self.canvasPixels[x][y].BackgroundColor3 ~= color) then
				self.canvasPixels[x][y].BackgroundColor3 = color
			end
		else
			--self:create_canvas_pixel(x, y, color)
		end
	end
end

UI.new = function()
	local new_ui = setmetatable({}, UI)
	
	new_ui.image = require(ui.image).new(new_ui)

	return new_ui
end

return UI
