--[[
	Special thanks to the following people:

	maurits150 - google proxy, metatable tutorial
	Python1320 - being awesome
]]

local tblQueries = { }

dyndb = dyndb || { }
dyndb.module = "mysqloo"; -- mysqloo is default, there hasn't been a tmysql compile since July
dyndb.m_Database = nil;

local query = { }
query.__index = query;

function query.Create( strQuery )
	local tblQuery = { }
	setmetatable( tblQuery, query );
	tblQuery.m_Query = strQuery;

	return tblQuery;
end

local function HandleCallback( tblArgs, objCallback, tblData )
	if( type( tblArgs ) == "table" ) then
		if( objCallback && type( objCallback ) == "function" ) then
			objCallback( tblData );
		end
	elseif( type( tblArgs ) == "function" ) then
		tblArgs( tblData );
	end
end

function query:Execute( tblArgs, objCallback )
	local tblOriginal = { }
	if( tblArgs && type( tblArgs ) == "table" && #tblArgs > 0 ) then
		tblOriginal = table.Copy( tblArgs );
		for k,v in pairs( tblArgs ) do
			if( dyndb.module == "http" ) then
				tblArgs[k] = dyndb.Escape( v );
			else
				if( type( v ) == "string" ) then
					tblArgs[k] = dyndb.Escape( v );
				end
			end
		end

		if( dyndb.module != "http" ) then
			self.m_Query = string.format( self.m_Query, unpack( tblArgs ) );
		end
	end

	table.insert( tblQueries, { ["time"] = os.time( ), ["query"] = self.m_Query } );

	if( dyndb.module == "mysqloo" ) then
		local objQuery = dyndb.m_Database:query( self.m_Query );

		if( !objQuery ) then
			error( "HELP! MISSING QUERY OBJECT OH PLEASE CALL SOMEONE\n" );
		end

		function objQuery:onSuccess( tblData )
			if( !tblArgs && !objCallback ) then return; end

			HandleCallback( tblArgs, objCallback, tblData );
		end

		function objQuery:onError( strError, strQuery )
			error( "[dyndb] "..strQuery.." errored ("..strError..")" );
		end

		objQuery:start( );
	elseif( dyndb.module == "tmysql" ) then
		tmysql.query( self.m_Query, function( tblData, bOkay, strError )
			if( !bOkay ) then
				if( !strError || strError == "" ) then
					strError = "syntax error??";
				end
				error( "[dyndb] "..self.m_Query.." errored ("..strError..")" );
			end

			if( !tblArgs && !objCallback ) then return; end

			HandleCallback( tblArgs, objCallback, tblData );
		end, QUERY_FLAG_ASSOC );
	elseif( dyndb.module == "http" ) then
		local strQuery = self.m_Query;
		print( "[DynDB Query] "..strQuery );
		local iParameters = table.Count( tblOriginal );

		local tblPostData = {
			["query"] = tostring( strQuery ),
			["num_parameters"] = tostring( iParameters ),
			["parameters"] = util.TableToJSON( tblOriginal ),
		}

		http.Post( "http://bananabunch.net/private/dyndb.php", tblPostData, function( strBody, iLen, tblHeaders, iCode )
			if( !tblArgs && !objCallback ) then return; end

			local tblData = util.JSONToTable( strBody );

			HandleCallback( tblArgs, objCallback, tblData );
		end, function( iCode )
			error( "HTTP query failure (err: "..iCode..")" );
		end );
	end

	return true;
end

local strHost = "66.150.121.145";
local strUser = "srcds";
local strPass = "KUfrUSpAdUjeth4v";
local strDB = "gm_frank";

function dyndb.Connect( )
	if( dyndb.module == "mysqloo" ) then
		if( !mysqloo ) then
			require( "mysqloo" );
		end

		dyndb.m_Database = mysqloo.connect( strHost, strUser, strPass, strDB );
		dyndb.m_Database:connect( );
	elseif( dyndb.module == "tmysql" ) then
		if( !tmysql ) then
			require( "tmysql" );
		end

		tmysql.initialize( strHost, strUser, strPass, strDB, 3306 );
	elseif( dyndb.module == "http" ) then
		-- nothing to do, http!
	else
		error( "Invalid module! <mysqloo|tmysql|http>" );
	end
end

function dyndb.GetQueries( )
	return { ["num"] = table.Count( tblQueries ), ["queries"] = tblQueries }
end

function dyndb.Escape( strString )
	if( dyndb.module == "mysqloo" ) then
		return "'"..dyndb.m_Database:escape( strString ).."'";
	elseif( dyndb.module == "tmysql" ) then
		return "'"..tmysql.escape( strString ).."'";
	elseif( dyndb.module == "http" ) then
		return "?"; -- let PHP handle the prepared statement
	end

	return strString;
end

function dyndb.Prepare( strQuery )
	return query.Create( strQuery );
end

function dyndb.Insert( strTable, tblStructure, funcCallback )
	local strData = "";
	local tblData = { }
	local tblColumns = { }

	for k,v in pairs( tblStructure ) do
		local strColumn = v[1];
		local strValue = v[2];
		table.insert( tblColumns, strColumn );
		table.insert( tblData, strValue );

		if( k != 1 ) then
			strData = strData..", ";
		end

		local strType = "";

		if( type( strValue ) == "string" ) then
			strType = "%s";
		elseif( type( strValue ) == "number" ) then
			strType = "%i";
		end

		strData = strData..strType;
	end

	local objQuery = dyndb.Prepare( "INSERT INTO `"..strTable.."` ("..table.concat( tblColumns, ", " )..") VALUES("..strData..")" );
	objQuery:Execute( tblData, funcCallback );
end

function dyndb.Update( strTable, tblStructure, tblWhere, iLimit )
	local tblData = { }
	local tblValues = { }
	local tblWhereData = { }

	for k,v in pairs( tblStructure ) do
		local strColumn = v[1];
		local strValue = v[2];
		local strType = "";

		if( type( strValue ) == "string" ) then
			strType = "s";
		elseif( type( strValue ) == "number" ) then
			strType = "i";
		end

		table.insert( tblData, "`"..strColumn.."` = %"..strType );
		table.insert( tblValues, strValue );
	end

	for k,v in pairs( tblWhere ) do
		local strColumn = v[1];
		local strValue = v[2];
		local strType = "";

		if( type( strValue ) == "string" ) then
			strType = "%s";
		elseif( type( strValue ) == "number" ) then
			strType = "%i";
		end

		table.insert( tblWhereData, "`"..strColumn.."` = "..strType );
		table.insert( tblValues, strValue );
	end

	local objQuery = dyndb.Prepare( "UPDATE `"..strTable.."` SET "..table.concat( tblData, ", " ).." WHERE "..table.concat( tblWhereData, " AND " )..( iLimit && " LIMIT "..iLimit || "" ) );
	objQuery:Execute( tblValues );
end

-- Allows querying the DB without dealing with a callback
-- Basically a compact version of a prepared statement
function dyndb.Query( strQuery, ... )
	local tblArgs = { ... }
	if( #tblArgs > 0 ) then
		strQuery = string.format( strQuery, unpack( tblArgs ) );
	end

	local objQuery = dyndb.Prepare( strQuery );
	objQuery:Execute( );
end

dyndb.Connect( );

hook.Add( "ShutDown", "dyndb_cleanup", function( )
	if( dyndb && dyndb.m_Database ) then
		dyndb.m_Database = nil;
	end
end );