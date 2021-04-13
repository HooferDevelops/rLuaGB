game.ReplicatedStorage.RawData.OnServerInvoke = function(player, url)
	local res = game:GetService("HttpService"):GetAsync(url)
	return res
end