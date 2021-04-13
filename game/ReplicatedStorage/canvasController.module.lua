local canvasController = {}
canvasController.__index = canvasController

canvasController.new = function(canvas, width, height)
	local canvasControllerMeta = setmetatable({}, canvasController)

	canvasControllerMeta.canvas = canvas
	canvasControllerMeta.width = width
	canvasControllerMeta.height = height

	canvasControllerMeta.rawPixelData = {}
	canvasControllerMeta.frameStorage = {}
	canvasControllerMeta.frames = {}

	for y = 0, height do
		canvasControllerMeta.rawPixelData[y] = {}		
		for x = 0, width do
			canvasControllerMeta.rawPixelData[y][x] = Color3.fromRGB(0,0,0)
		end
	end	

	return canvasControllerMeta
end

function canvasController:createFrame(x,y,sX,sY,color)
	local frame
	if (self.frameStorage[1]) then
		frame = self.frameStorage[1]
		table.remove(self.frameStorage, 1)
	end
	if (not frame) then
		frame = Instance.new("Frame")
		frame.BorderSizePixel = 0
		frame.ZIndex = 99
	end
	frame.Size = UDim2.new(0,sX,0,sY)
	frame.Name = sX.."x"..sY
	frame.Parent = self.canvas
	frame.Position = UDim2.new(0,x,0,y)
	frame.BackgroundColor3 = color

	return frame
end

function canvasController:draw()
	for _,frame in pairs(self.frames) do
		frame.Parent = nil
		table.insert(self.frameStorage, frame)
	end

	local optimizedPixelData = {}
	for y = 0, self.height do
		optimizedPixelData[y] = {}
		for x = 0, self.width do

			optimizedPixelData[y][x] = {
				Color = self.rawPixelData[y][x],
				Size = Vector2.new(1,1),
				Reference = nil
			}

			if (optimizedPixelData[y][x-1]) then
				if (optimizedPixelData[y][x-1].Color == optimizedPixelData[y][x].Color) then

					if (optimizedPixelData[y][x-1].Reference) then
						optimizedPixelData[y][x].Reference = optimizedPixelData[y][x-1].Reference
						optimizedPixelData[y][x-1].Reference.Size += Vector2.new(1,0)
					else
						optimizedPixelData[y][x].Reference = optimizedPixelData[y][x-1]
						optimizedPixelData[y][x-1].Size += Vector2.new(1,0)
					end
				end
			end

		end
	end

	for y = 0, self.height do
		for x = 0, self.width do
			if (optimizedPixelData[y] and optimizedPixelData[y][x]) then
				local pixel = optimizedPixelData[y][x]
				if (not pixel.Reference) then
					table.insert(self.frames, self:createFrame(x,y,pixel.Size.X,pixel.Size.Y,pixel.Color))
				end
			end
		end
	end
end

return canvasController