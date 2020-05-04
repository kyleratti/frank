--[[
	Special thanks to the following people:

	maurits150 - google proxy, metatable tutorial
	Python1320 - being awesome
]]

local tblQueries = {}

dyndb = dyndb or {}
dyndb.module = "mysqloo" -- mysqloo is default, there hasn't been a tmysql compile since July
dyndb.__database = nil

local query = {}
query.__index = query

function query.create(strQuery)
	local tblQuery = {}
	setmetatable(tblQuery, query)
	tblQuery.query = strQuery

	return tblQuery
end

local function handleCallback(tblArgs, objCallback, tblData)
	if(type(tblArgs) == "table") then
		if(objCallback and type(objCallback) == "function") then
			objCallback(tblData)
		end
	elseif(type(tblArgs) == "function") then
		tblArgs(tblData)
	end
end

function query:execute(tblArgs, objCallback)
	local tblOriginal = {}
	if(tblArgs and type(tblArgs) == "table" and #tblArgs > 0) then
		tblOriginal = table.Copy(tblArgs)
		for k,v in pairs(tblArgs) do
			if(dyndb.module == "http") then
				tblArgs[k] = dyndb.escape(v)
			else
				if(type(v) == "string") then
					tblArgs[k] = dyndb.escape(v)
				end
			end
		end

		if(dyndb.module ~= "http") then
			self.query = string.format(self.query, unpack(tblArgs))
		end
	end

	table.insert(tblQueries, {["time"] = os.time(), ["query"] = self.query})

	if(dyndb.module == "mysqloo") then
		local objQuery = dyndb.__database:query(self.query)

		if(not objQuery) then
			error("HELP! MISSING QUERY OBJECT OH PLEASE CALL SOMEONE\n")
		end

		function objQuery:onSuccess(tblData)
			if(not tblArgs and !objCallback) then return end

			handleCallback(tblArgs, objCallback, tblData)
		end

		function objQuery:onError(strError, strQuery)
			error("[dyndb] "..strQuery.." errored ("..strError..")")
		end

		objQuery:start()
	elseif(dyndb.module == "tmysql") then
		tmysql.query(self.query, function(tblData, bOkay, strError)
			if(not bOkay) then
				if(not strError or strError == "") then
					strError = "syntax error??"
				end
				error("[dyndb] "..self.query.." errored ("..strError..")")
			end

			if(not tblArgs and !objCallback) then return end

			handleCallback(tblArgs, objCallback, tblData)
		end, QUERY_FLAG_ASSOC)
	elseif(dyndb.module == "http") then
		local strQuery = self.query
		print("[DynDB Query] "..strQuery)
		local iParameters = table.Count(tblOriginal)

		local tblPostData = {
			["query"] = tostring(strQuery),
			["num_parameters"] = tostring(iParameters),
			["parameters"] = util.TableToJSON(tblOriginal),
		}

		http.Post("http:--bananabunch.net/private/dyndb.php", tblPostData, function(strBody, iLen, tblHeaders, iCode)
			if(not tblArgs and !objCallback) then return end

			local tblData = util.JSONToTable(strBody)

			handleCallback(tblArgs, objCallback, tblData)
		end, function(iCode)
			error("HTTP query failure (err: "..iCode..")")
		end)
	end

	return true
end

local tblDatabase = {
	["hostname"] = "127.0.0.1",
	["username"] = "srcds",
	["password"] = "changeme",
	["database"] = "frank"
}

function dyndb.connect()
	if(dyndb.module == "mysqloo") then
		if(not mysqloo) then
			require("mysqloo")
		end

		dyndb.__database = mysqloo.connect(tblDatabase.hostname, tblDatabase.username, tblDatabase.password, tblDatabase.database)
		dyndb.__database:connect()
	elseif(dyndb.module == "tmysql") then
		if(not tmysql) then
			require("tmysql")
		end

		tmysql.initialize(tblDatabase.hostname, tblDatabase.username, tblDatabase.password, tblDatabase.database, 3306)
	elseif(dyndb.module == "http") then
		-- nothing to do, http!
	else
		error("Invalid module! <mysqloo|tmysql|http>")
	end
end

function dyndb.getAllQueries()
	return {["num"] = table.Count(tblQueries), ["queries"] = tblQueries}
end

function dyndb.escape(strString)
	if(dyndb.module == "mysqloo") then
		return "'"..dyndb.__database:escape(strString).."'"
	elseif(dyndb.module == "tmysql") then
		return "'"..tmysql.escape(strString).."'"
	elseif(dyndb.module == "http") then
		return "?" -- let PHP handle the prepared statement
	end

	return strString
end

function dyndb.prepare(strQuery)
	return query.create(strQuery)
end

function dyndb.insert(strTable, tblStructure, funcCallback)
	local strData = ""
	local tblData = {}
	local tblColumns = {}

	for k,v in pairs(tblStructure) do
		local strColumn = v[1]
		local strValue = v[2]
		table.insert(tblColumns, strColumn)
		table.insert(tblData, strValue)

		if(k ~= 1) then
			strData = strData..", "
		end

		local strType = ""

		if(type(strValue) == "string") then
			strType = "%s"
		elseif(type(strValue) == "number") then
			strType = "%i"
		end

		strData = strData..strType
	end

	local objQuery = dyndb.prepare("INSERT INTO "..strTable.." ("..table.concat(tblColumns, ", ")..") VALUES("..strData..")")
	objQuery:execute(tblData, funcCallback)
end

function dyndb.update(strTable, tblStructure, tblWhere, iLimit)
	local tblData = {}
	local tblValues = {}
	local tblWhereData = {}

	for k,v in pairs(tblStructure) do
		local strColumn = v[1]
		local strValue = v[2]
		local strType = ""

		if(type(strValue) == "string") then
			strType = "s"
		elseif(type(strValue) == "number") then
			strType = "i"
		end

		table.insert(tblData, ""..strColumn.." = %"..strType)
		table.insert(tblValues, strValue)
	end

	for k,v in pairs(tblWhere) do
		local strColumn = v[1]
		local strValue = v[2]
		local strType = ""

		if(type(strValue) == "string") then
			strType = "%s"
		elseif(type(strValue) == "number") then
			strType = "%i"
		end

		table.insert(tblWhereData, ""..strColumn.." = "..strType)
		table.insert(tblValues, strValue)
	end

	local objQuery = dyndb.prepare("UPDATE "..strTable.." SET "..table.concat(tblData, ", ").." WHERE "..table.concat(tblWhereData, " AND ")..(iLimit and " LIMIT "..iLimit or ""))
	objQuery:execute(tblValues)
end

-- Allows querying the DB without dealing with a callback
-- Basically a compact version of a prepared statement
function dyndb.query(strQuery, ...)
	local tblArgs = {...}
	if(#tblArgs > 0) then
		strQuery = string.format(strQuery, unpack(tblArgs))
	end

	local objQuery = dyndb.prepare(strQuery)
	objQuery:execute()
end

dyndb.connect()

hook.Add("ShutDown", "dyndb.ShutDown", function()
	if(dyndb and dyndb.__database) then
		dyndb.__database = nil
	end
end)