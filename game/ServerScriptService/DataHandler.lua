
local Players = game:GetService("Players")

local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


-- DATASTORES

local ROMStore = DataStoreService:GetDataStore("ROMStorage")
local saveStateStore = DataStoreService:GetDataStore("SaveState")


function playerJoined(player)
	local rom_folder = Instance.new("Folder")
	rom_folder.Name = player.Name
	rom_folder.Parent = ServerStorage.PlayerROMs
	
	local stored_roms = ROMStore:GetAsync("ROMs_" .. player.UserId)
	if (stored_roms) then
		stored_roms = game:GetService("HttpService"):JSONDecode(stored_roms)
	else
		stored_roms = {}
	end
	
	for _, stored_rom in pairs(stored_roms) do
		local new_rom = Instance.new("StringValue")
		
		new_rom.Name = stored_rom.Name
		new_rom.Value = stored_rom.Value
	end
end

function playerLeaving(player)
	if ServerStorage.PlayerROMs:FindFirstChild(player.Name) then
		local compiled_roms = {}
		
		for _, rom in pairs(ServerStorage.PlayerROMs[player.Name]:GetChildren()) do
			table.insert(compiled_roms, {Name = rom.Name, Value = rom.Value})
		end
		
		ROMStore:SetAsync("ROMs_" .. player.UserId, HttpService:JSONEncode(compiled_roms))
		ServerStorage.PlayerROMs[player.Name]:Destroy()
	end
end


ReplicatedStorage.GetROMs.OnServerInvoke = function(player)
	local compiled_roms = {}
	
	for _, rom in pairs(ServerStorage.PlayerROMs[player.Name]:GetChildren()) do
		table.insert(compiled_roms, {Name = rom.Name, Value = rom.Value})
	end
	
	return compiled_roms
end

ReplicatedStorage.SaveROM.OnServerInvoke = function(player, rom_url, rom_label)
	if ServerStorage.PlayerROMs:FindFirstChild(player.Name) then
		local new_rom = Instance.new("StringValue")

		if (string.find(rom_label, "gb")) then
			new_rom.Name = rom_label
		else
			new_rom.Name = rom_label .. ".gb"
		end
		
		new_rom.Value = rom_url
		new_rom.Parent = ServerStorage.PlayerROMs:FindFirstChild(player.Name)
	end
end

ReplicatedStorage.SetSaveState.OnServerInvoke = function(player, stateData)
	saveStateStore:SetAsync("Player_"..player.UserId, stateData)
end

ReplicatedStorage.GetSaveState.OnServerInvoke = function(player, stateData)
	return saveStateStore:GetAsync("Player_"..player.UserId)
end

-- Get players that got put into the game before the PlayerAdded function could be called.
for _, player in pairs(Players:GetChildren()) do
	playerJoined(player)
end

Players.PlayerAdded:Connect(playerJoined)
Players.PlayerRemoving:Connect(playerLeaving)