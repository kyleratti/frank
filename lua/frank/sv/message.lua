util.AddNetworkString( "send_message" );

function frank.SendMessage( objPlayers, bChat, ... )
	local tblData = { ... }

	for k,v in pairs( tblData ) do
		if( type( v ) == "table" && tblData[k].a ) then
			tblData[k].a = nil;
		end
	end

	local strJSON = util.TableToJSON( tblData );
	local strCompressed = util.Compress( strJSON );

	if( !strCompressed ) then
		debug.getinfo( 1 );
		error( "Unable to send net message (corrupt compression data)" );
	end

	local iDataLen = string.len( strCompressed );

	net.Start( "send_message" );
		net.WriteBit( bChat );
		net.WriteUInt( iDataLen, 32 );
		net.WriteData( strCompressed, iDataLen );
	net.Send( objPlayers );
end

util.AddNetworkString( "player_joined" );

hook.Add( "PlayerInitialSpawn", "frank_Message_PlayerInitialSpawn", function( objPl )
	net.Start( "player_joined" );
		net.WriteString( objPl:Nick( ) );
	net.SendOmit( objPl );
end );