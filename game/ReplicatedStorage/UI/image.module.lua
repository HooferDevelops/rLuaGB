local Image = {}
Image.__index = Image

function Image:load_image(image_name, url)
	if self.cache[image_name] then
		return self.cache[image_name]
	end
	
	local buffer = game.ReplicatedStorage.RawData:InvokeServer(url)
	
	if (buffer) then
		local parsed_image = self.PNG.new(buffer)
		if (parsed_image) then
			self.cache[image_name] = parsed_image
		end
	end
end

function Image:get_pixel(x, y, image_name)
	if (not self.cache[image_name]) then
		print("Image has not been loaded: " .. image_name)
	end
	
	return self.cache[image_name]:GetPixel(x or 0, y or 0)
end

function Image:draw_image(x, y, image_name, raw_image_table)
	if (not self.cache[image_name]) then
		print("Image has not been loaded: " .. image_name)
	end
	
	local image_width = self.cache[image_name].Width
	local image_height = self.cache[image_name].Height
	
	
	for pX=1,image_width do
		for pY=1,image_height do
			local color, alpha = self.cache[image_name]:GetPixel(pX,pY)
			local r = color.r
			r = math.floor(r * 255 + 0.5)
			
			if (self.palette and raw_image_table[y+pY-1] and raw_image_table[y+pY-1][x+pX-1]) then								
				if r == 0 then
					color = self.palette[3]
				end
				if r == 64 then
					color = self.palette[2]
				end
				if r == 128 then
					color = self.palette[1]
				end
				if r == 255 then
					color = self.palette[0]
				end
				if r == 127 then
					local current_color = raw_image_table[y+pY-1][x+pX-1]
					if current_color == self.palette[2] then
						color = self.palette[3]
					end
					if current_color == self.palette[1] then
						color = self.palette[2]
					end
					if current_color == self.palette[0] then
						color = self.palette[1]
					end
				end
			end
			
			
			if (not raw_image_table) then
				self.canvas:set_canvas_pixel(x+pX-1,y+pY-1, color, alpha)
			else
				if (alpha == 255) then
					if (raw_image_table[y+pY-1] and raw_image_table[y+pY-1][x+pX-1]) then
						raw_image_table[y+pY-1][x+pX-1] = color
					end
				end
			end
		end
	end
end

Image.new = function(canvas)
	local new_image = setmetatable({}, Image)
	
	new_image.PNG = require(script.PNG)
	new_image.canvas = canvas
	new_image.cache = {}
	
	return new_image	
end

return Image