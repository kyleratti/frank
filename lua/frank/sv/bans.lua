frank = frank or {}
frank.bans = frank.bans or {}

--[[dyndb.insert("log_connect", {
		{"nick",	strNick 				},
		{"steam",	strSteamID				},
		{"ip", 	strIP					},
		{"time", 	tostring(os.time())	},
	})]]--

util.AddNetworkString("frank.player.joinLeave")

local APPEAL_MESSAGE = "\nAppeal at www.google.com"

-- TODO: fix this - CheckPassword expects a return value, but ban is checked in MySQL query

hook.Add("CheckPassword", "franks.bans.CheckPassword", function(strSteam64, strIP, strServerPass, strClientPass, strNick)
	local strSteamID = util.SteamIDFrom64(strSteam64)

	local objQuery = dyndb.prepare("SELECT time, reason FROM player_bans WHERE steam = %s LIMIT 1")
	objQuery:execute({strSteam}, function(tblData)
		if(not tblData or not tblData[1]) then return end

		local iTime = tonumber(tblData[1]["time"])
		local strReason = tblData[1]["reason"]

		if(iTime == 0) then
			return false, "Banned Forever ("..strReason..")"..APPEAL_MESSAGE
		elseif(os.time() >= iTime) then
			frank.bans.remove(strSteamID)
		else
			return false, "Banned for "..time.short(iTime - os.time()).." ("..strReason..")"
		end

		net.Start("frank.player.joinLeave")
			net.WriteString(strNick)
			net.WriteString(strSteamID)
			net.WriteBit(true)
		net.Broadcast()
	end)
end)

hook.Add("PlayerDisconnected", "frank.bans.PlayerDisconnected", function(objPl)
	net.Start("frank.player.joinLeave")
		net.WriteString(objPl:Nick())
		net.WriteString(objPl:SteamID())
		net.WriteBit(false)
	net.Broadcast()
end)

function frank.bans.add(strSteamID, iTime, strReason, strAdminSteamID)
	if(iTime ~= 0) then
		iTime = os.time() + (iTime * 60)
	end

	local objQuery = dyndb.prepare("REPLACE INTO player_bans (steam, time, reason, asteam) VALUES(%s, %s, %s, %s)")
	objQuery:execute({strSteamID, iTime, strReason, strAdminSteamID})

	for k,v in pairs(player.GetAll()) do
		if(v:SteamID() == strSteamID) then
			local strTime = (iTime == 0 and "infinity") or time.short(iTime - os.time())

			v:Kick("Banned for "..((iTime == 0 and "infinity" or time.short(iTime - os.time()))).." ("..strReason..")"..APPEAL_MESSAGE)
			break
		end
	end
end

function frank.bans.remove(strSteamID)
	local objQuery = dyndb.prepare("DELETE FROM player_bans, WHERE steam = %s LIMIT 1")
	objQuery:execute({strSteamID})
end

-- clear expired bans

local function clearBans()
	dyndb.query("DELETE FROM player_bans WHERE time ~= 0 AND time < "..os.time())
end

timer.Create("Clear_Bans", 60 * 30, 0, function()
	clearBans()
end)

hook.Add("PlayerInitialSpawn", "frank_Bans_ClearExpired", function()
	clearBans()
	hook.Remove("PlayerInitialSpawn", "frank_Bans_ClearExpired")
end)