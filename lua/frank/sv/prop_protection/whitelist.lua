frank.Whitelist = {}

local tblWhitelist = {}

function frank.Whitelist.Load()
	tblWhitelist = {}

	local objQuery = dyndb.prepare("SELECT model FROM prop_whitelist")
	objQuery:Execute(function(tblData)
		for k,v in pairs(tblData) do
			local strModel = v["model"]

			tblWhitelist[string.lower(strModel)] = true
		end
	end)
end

function frank.Whitelist.Exists(strModel)
	return tblWhitelist[string.lower(strModel)]
end

frank.Whitelist.Load()

concommand.Add("whitelist_add", function(objPl, strCmd, tblArgs)
	if(not IsValid(objPl) or !objPl:IsLeadAdmin()) then return end

	local strModel = tblArgs[1]
	strModel = string.Replace(strModel, " ", "")
	strModel = string.Replace(strModel, "\\", "/")
	strModel = string.Trim(strModel)

	if(frank.Whitelist.Exists(strModel)) then
		frank.sendMessage(objPl, true, "'", colorx["Pink"], strModel, color_white, "' is already whitelisted!")
		return
	end

	local objQuery = dyndb.prepare("INSERT IGNORE INTO prop_whitelist (model, time) VALUES(%s, %s)")
	objQuery:Execute({strModel, tostring(os.time())}, function()
		frank.Whitelist.Load()

		kontrol:Log({
			["Type"] = KONTROL_LOG_ADMIN,
			["Message"] = {
				{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
				{["Log"] = " added '"..strModel.."' to the whitelist ", ["Chat"] = {" added '", colorx["Pink"], strModel, color_white, "' to the whitelist"}},
			},
		})
	end)
end)

concommand.Add("whitelist_remove", function(objPl, strCmd, tblArgs)
	if(not IsValid(objPl) or !objPl:IsLeadAdmin()) then return end

	local strModel = tblArgs[1]
	strModel = string.Replace(strModel, " ", "")
	strModel = string.Replace(strModel, "\\", "/")
	strModel = string.Trim(strModel)

	if(not frank.Whitelist.Exists(strModel)) then
		frank.sendMessage(objPl, true, "'", colorx["Pink"], strModel, color_white, "' isn't whitelisted!")
		return
	end

	local objQuery = dyndb.prepare("DELETE FROM prop_whitelist WHERE model = %s LIMIT 1")
	objQuery:Execute({strModel}, function()
		frank.Whitelist.Load()

		kontrol:Log({
			["Type"] = KONTROL_LOG_ADMIN,
			["Message"] = {
				{["Log"] = kontrol:Nick(objPl), ["Chat"] = kontrol:Nick(objPl, false, true, true)},
				{["Log"] = " removed '"..strModel.."' from the whitelist ", ["Chat"] = {" removed '", colorx["Pink"], strModel, color_white, "' from the whitelist"}},
			},
		})
	end)
end)