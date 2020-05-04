hook.Add("PlayerInitialSpawn", "frank.player.loadAccount", function(objPl)
	if(not IsValid(objPl)) then return end

	objPl.joinTime = os.time()
	objPl:getAccount()

	local strSteamID = objPl:SteamID()

	dyndb.query("UPDATE player_account SET last_join = '"..os.time().."' WHERE steam = '"..strSteamID.."' LIMIT 1")

	timer.Create("frank.player.updatePlaytime."..strSteamID, 60 * 2, 0, function()
		if(IsValid(objPl)) then
			objPl:savePlaytime()
		else
			timer.Destroy("frank.player.updatePlaytime."..strSteamID)
		end
	end)
end)

hook.Add("PlayerDisconnected", "frank.player.saveAccount", function(objPl)
	objPl:savePlaytime()

	dyndb.update("player_account", {
		{"last_nick", objPl:Nick()},
	}, {
		{"steam", objPl:SteamID()},
	}, 1)

	if(timer.Exists("frank.player.updatePlaytime."..objPl:SteamID())) then
		timer.Destroy("frank.player.updatePlaytime."..objPl:SteamID())
	end

	if(timer.Exists("frank.player.vipExpire."..objPl:SteamID())) then
		timer.Destroy("frank.player.vipExpire."..objPl:SteamID())
	end
end)

local meta = FindMetaTable("Player")

function meta:savePlaytime()
	dyndb.update("player_account", {
		{"playtime", tostring(self:getPlaytime())},
	}, {
		{"steam", self:SteamID()},
	}, 1)
end

function meta:getPlaytime()
	local iPlaytime = self:getNWVar("Playtime", 0)

	return (os.time() - self.joinTime) + iPlaytime
end

function meta:RemoveVIP(bNotify)
	dyndb.update("player_account", {
		{"vip_expire",	0},
	}, {
		{"steam", self:SteamID()},
	}, 1)

	if(bNotify) then
		frank.sendMessage(self, true, colorx.red, "Your VIP has expired!")
	end
end

function meta:createAccount()
	dyndb.insert("player_account", {
		{"nick",		self:Nick()			},
		{"last_nick",	self:Nick()				},
		{"steam",		self:SteamID()			},
		{"first_join",	tostring(os.time())	},
		{"last_join",	0						},
		{"playtime",	0						},
		{"vip_expire",	0						},
		{"coins",		25						},
		--{"rank",		KONTROL_GUEST			}, -- ???
	}, function(tblData)
		if(IsValid(self)) then
			self:getAccount()
		end
	end)
end

function meta:getAccount()
	local objQuery = dyndb.prepare("SELECT * FROM player_account WHERE steam = %s LIMIT 1")
	objQuery:execute({self:SteamID()}, function(tblData)
		if(not IsValid(self)) then return end

		if(table.Count(tblData) == 0) then
			self:createAccount()
		else
			local iRank = tonumber(tblData[1]["rank"])
			local iPlaytime = tonumber(tblData[1]["playtime"])
			local iVIPExpire = tonumber(tblData[1]["vip_expire"])

			self:setNWVar("Playtime", iPlaytime, true)
			self:setNWVar("Rank", iRank)

			frank.sendMessage(self, true, colorx.Lime, "Rank: ", color_white, kontrol.ranks[iRank].Name)

			if(iVIPExpire ~= 0) then
				self:setNWVar("VIP", iVIPExpire)

				local strMsg = ""
				if(iVIPExpire == -1) then
					strMsg = "Infinite"
				elseif(iVIPExpire > os.time()) then
					strMsg = time.simple(iVIPExpire - os.time()).." remaining"

					timer.Create("frank.player.vipExpire."..self:SteamID(), iVIPExpire - os.time(), 1, function()
						if(IsValid(self)) then
							self:RemoveVIP(true)
						end
					end)
				else
					strMsg = "Expired"
					self:RemoveVIP(true)
				end


				frank.sendMessage(self, true, colorx.Lime, "VIP: ", color_white, strMsg)
			else

				frank.sendMessage(self, true, colorx.Lime, "VIP: ", color_white, "None - donate? :3")
			end
		end
	end)
end

--[[function meta:SendMessage(bChat, ...)
	local tblData = {...}

	for k,v in pairs(tblData) do
		if(type(v) == "table") then
			if(tblData[k].a) then
				tblData[k].a = nil
			end
		end
	end

	local strJSON = util.TableToJSON(tblData)

	net.Start("send_message")
		net.WriteBit(bChat)
		net.WriteString(strJSON)
	net.Send(self)
end]]--

function meta:sendMessage(bChat, ...)
	frank.sendMessage(self, bChat, unpack({...}))
end

concommand.Add("frank_account_reload", function(objPl, strCmd, tblArgs)
	if(not IsValid(objPl)) then return end

	if(not objPl.lastAccountReload or CurTime() - objPl.lastAccountReload > 5) then
		objPl.lastAccountReload = CurTime()
		objPl:getAccount()
	else
		objPl:ChatPrint("Please wait "..math.ceil((objPl.lastAccountReload + 5) - CurTime()).."s before reloading your account again")
	end
end)