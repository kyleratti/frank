util.AddNetworkString("frank.player.adminChat")

hook.Add("PlayerSay", "frank.player.adminChat", function(objPl, strText, bTeam)
	if(string.sub(strText, 1, 1) == "@") then
		strText = string.Trim(string.sub(strText, 2), " ")

		if(string.len(strText) < 2) then
			objPl:PrintMessage(HUD_PRINTTALK, "Message too short")
			return ""
		end

		local tblPlayers = {}
		for k,v in pairs(player.GetAll()) do
			if(v:IsMod() or v == objPl) then
				table.insert(tblPlayers, v)
			end
		end

		net.Start("frank.player.adminChat")
			net.WriteEntity(objPl)
			net.WriteString(strText)
		net.Send(tblPlayers)
		
		return ""
	end
end)