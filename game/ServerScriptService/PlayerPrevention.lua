function playerAdded(player)
	player.CanLoadCharacterAppearance = false
	for _,v in pairs(game.StarterGui:GetChildren()) do
		v:Clone().Parent = player:WaitForChild("PlayerGui")
	end
end
game.Players.PlayerAdded:Connect(playerAdded)
for _,player in pairs(game.Players:GetChildren()) do
	playerAdded(player)
end