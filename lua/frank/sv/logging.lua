util.AddNetworkString("frank.logging.propSpawn")

hook.Add("PlayerSpawn", "frank.logging.PlayerSpawn", function(objPl)
	if(not IsValid(objPl)) then return end

	dyndb.insert("log_spawn", {
		{"nick",	objPl:Nick()			},
		{"steam",	objPl:SteamID()		},
		{"ip",		objPl:IPAddress()		},
		{"time",	tostring(os.time())	},
	})
end)

hook.Add("PlayerSay", "frank.logging.PlayerSay", function(objPl, strMessage, bTeam)
	if(not IsValid(objPl)) then return end

	dyndb.insert("log_chat", {
		{"nick",		objPl:Nick() 					},
		{"steam",		objPl:SteamID()				},
		{"team",		team.GetName(objPl:Team())	},
		{"rank",		objPl:GetRank().Name 			},
		{"message",	strMessage 						},
		{"team_chat",	(bTeam and 1 or 0) 			},
		{"time",		tostring(os.time()) 			},
	})
end)

hook.Add("PlayerDisconnected", "frank.logging.PlayerDisconnect", function(objPl)
	dyndb.insert("log_disconnect", {
		{"nick",	objPl:Nick()					},
		{"steam",	objPl:SteamID()				},
		{"team",	team.GetName(objPl:Team())	},
		{"time",	tostring(os.time())			},
	})
end)

hook.Add("PlayerDeath", "frank.logging.PlayerDeath", function(objPl, objWeapon, objKiller)
	if(not IsValid(objPl)) then return end

	local strAttackerNick	= "world"
	local strAttackerSteam	= "STEAM_0:0:1"
	local strAttackerTeam	= "world"

	if(IsValid(objKiller) and objKiller:IsPlayer()) then
		strAttackerNick		= objKiller:Nick()
		strAttackerSteam	= objKiller:SteamID()
		strAttackerTeam		= team.GetName(objKiller:Team())
	end

	dyndb.insert("log_kill", {
		{"victim_nick",	objPl:Nick()					},
		{"victim_steam",	objPl:SteamID()				},
		{"victim_team",	team.GetName(objPl:Team())	},
		{"attacker_nick",	strAttackerNick					},
		{"attacker_steam",	strAttackerSteam				},
		{"attacker_team",	strAttackerTeam					},
		{"time",			tostring(os.time())			},
	})
end)

hook.Add("PlayerSpawnedProp", "frank.logging.PlayerSpawnedProp", function(objPl, strModel, objEnt)
	dyndb.insert("log_prop", {
		{"nick",	objPl:Nick()			},
		{"steam",	objPl:SteamID()		},
		{"prop",	strModel 				},
		{"time", 	tostring(os.time())	},
	})

	net.Start("frank.logging.propSpawn")
		net.WriteEntity(objPl)
		net.WriteString(strModel)
	net.Broadcast()
end)