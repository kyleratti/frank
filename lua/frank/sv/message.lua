util.AddNetworkString("frank.player.sendMessage")

function frank.sendMessage(objPlayers, bChat, ...)
	local tblData = {...}

	for k,v in pairs(tblData) do
		if(type(v) == "table" and tblData[k].a) then
			tblData[k].a = nil
		end
	end

	local strJSON = util.TableToJSON(tblData)
	local strCompressed = util.Compress(strJSON)

	if(not strCompressed) then
		debug.getinfo(1)
		error("Unable to send net message (corrupt compression data)")
	end

	local iDataLen = string.len(strCompressed)

	net.Start("frank.player.sendMessage")
		net.WriteBit(bChat)
		net.WriteUInt(iDataLen, 32)
		net.WriteData(strCompressed, iDataLen)
	net.Send(objPlayers)
end

util.AddNetworkString("frank.player.initialSpawn")

hook.Add("PlayerInitialSpawn", "frank.player.PlayerInitialSpawn.broadcastMessage", function(objPl)
	net.Start("frank.player.initialSpawn")
		net.WriteString(objPl:Nick())
	net.SendOmit(objPl)
end)