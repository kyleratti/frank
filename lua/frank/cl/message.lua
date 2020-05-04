net.Receive("frank.player.sendMessage", function(iLen)
	frank.debugPrint("Received 'frank.player.sendMessage' (bytes: "..num.format(iLen / 8)..")")

	local bChat = tobool(net.ReadBit())
	local iDataLen = net.ReadUInt(32)
	local strData = net.ReadData(iDataLen)

	local strJSON = util.Decompress(strData)

	if(not strJSON) then
		error("Unable to receive message 'frank.player.sendMessage' (report this immediately)")
	end

	local tblData = util.JSONToTable(strJSON)

	if(bChat) then
		chat.AddText(unpack(tblData))
	else
		console.AddText(unpack(tblData))
	end
end)

net.Receive("frank.player.joinLeave", function(iLen)
	local strNick = net.ReadString()
	local strSteamID = net.ReadString()
	local bJoin = tobool(net.ReadBit())

	chat.AddText(colorx[(bJoin and "Lime" or "Red")], "● ", Color(255, 102, 51), strNick, color_white, " (", colorx["Gold"], strSteamID, color_white, ") "..(bJoin and "connected" or "left"))
end)

net.Receive("frank.player.initialSpawn", function(iLen)
	chat.AddText(colorx["CoolBlue"], "● ", team.GetColor(TEAM_CITIZEN), net.ReadString(), color_white, " joined")
end)

hook.Add("ChatText", "frank.hideJoinLeave", function(iPlayer, strNick, strText, strType)
	if(strType == "joinleave") then return true end
end)