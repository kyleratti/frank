net.Receive("frank.player.adminChat", function(iLen)
	local objPl = net.ReadEntity()

	if(not IsValid(objPl)) then error("Invalid player!") end

	chat.AddText(team.GetColor(objPl:Team()), objPl:Nick(), color_white, " to staff: ", colorx.gold, net.ReadString())
end)