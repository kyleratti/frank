frank = frank || { }

/*dyndb.Insert( "log_connect", {
		{ "nick",	strNick 				},
		{ "steam",	strSteamID				},
		{ "ip", 	strIP					},
		{ "time", 	tostring( os.time( ) )	},
	} );*/

util.AddNetworkString( "player_joinleave" );

hook.Add( "PlayerConnected", "frank_Bans_PlayerPasswordAuth", function( strNick, iUserID, strSteamID, strIP )
	local objQuery = dyndb.Prepare( "SELECT `time`, `reason` FROM `player_bans` WHERE `steam` = %s LIMIT 1" );
	objQuery:Execute( { strSteamID }, function( tblData )
		if( !tblData || !tblData[1] )  then return; end
		tblData = tblData[1];

		local iTime = tonumber( tblData["time"] );
		local strReason = tblData["reason"];

		if( iTime == 0 ) then
			gatekeeper.Drop( iUserID, "Banned Forever ("..strReason..")" );
		elseif( os.time( ) > iTime ) then
			local objStatement = dyndb.Prepare( "DELETE FROM `player_bans` WHERE `steam` = %s LIMIT 1" );
			objStatement:Execute( { strSteamID } );
		else
			gatekeeper.Drop( iUserID, "Banned for "..time.Short( iTime - os.time( ) ).." ("..strReason..")" );
		end
	end );

	timer.Create( "player_join_"..iUserID, 0.2, 1, function( )
		net.Start( "player_joinleave" );
			net.WriteString( strNick );
			net.WriteString( strSteamID );
			net.WriteBit( true );
		net.Broadcast( );
	end );
end );

hook.Add( "PlayerDisconnected", "frank_Bans_PlayerDisconnected", function( objPl )
	if( !objPl.IgnoreLeave ) then
		net.Start( "player_joinleave" );
			net.WriteString( objPl:Nick( ) );
			net.WriteString( objPl:SteamID( ) );
			net.WriteBit( false );
		net.Broadcast( );
	end
end );

function frank.AddBan( strNick, strSteamID, iTime, strReason, strAdminNick, strAdminSteamID )
	if( iTime != 0 ) then
		iTime = os.time( ) + ( iTime * 60 ); -- input is in minutes, convert to seconds
	end

	local objQuery = dyndb.Prepare( "REPLACE INTO `player_bans` (nick, steam, time, reason, anick, asteam) VALUES(%s, %s, %s, %s, %s, %s)" );
	objQuery:Execute( { strNick, strSteamID, tostring( iTime ), strReason, strAdminNick, strAdminSteamID } );

	for k,v in pairs( player.GetAll( ) ) do
		if( v:SteamID( ) == strSteamID ) then
			local strTime = ( iTime == 0 && "infinity" || time.Short( iTime - os.time( ) ) );

			gatekeeper.Drop( v:UserID( ), "Banned for "..strTime.." ("..strReason..")" );
			break;
		end
	end
end

function frank.RemoveBan( strSteamID )
	local objQuery = dyndb.Prepare( "DELETE FROM `player_bans` WHERE `steam` = %s LIMIT 1" );
	objQuery:Execute( { strSteamID } );
end

-- clear player_bans

local function ClearBans( )
	dyndb.Query( "DELETE FROM `player_bans` WHERE `time` != 0 AND `time` < "..os.time( ) );
end

timer.Create( "Clear_Bans", 60 * 30, 0, function( )
	ClearBans( );
end );

hook.Add( "PlayerInitialSpawn", "frank_Bans_ClearExpired", function( )
	ClearBans( );
	hook.Remove( "PlayerInitialSpawn", "frank_Bans_ClearExpired" );
end );