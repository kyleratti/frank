net.Receive( "send_message", function( iLen )
	if( frank.Debugging ) then
		frank.Print( "Received 'send_message' (bytes: "..num.Format( iLen / 8 )..")" );
	end

	local bChat = tobool( net.ReadBit( ) );
	local iDataLen = net.ReadUInt( 32 );
	local strData = net.ReadData( iDataLen );

	local strJSON = util.Decompress( strData );

	if( !strJSON ) then
		error( "Unable to receive message 'send_message' (report this immediately)" );
	end

	local tblData = util.JSONToTable( strJSON );

	if( bChat ) then
		chat.AddText( unpack( tblData ) );
	else
		console.AddText( unpack( tblData ) );
	end
end );

net.Receive( "player_joinleave", function( iLen )
	local strNick = net.ReadString( );
	local strSteamID = net.ReadString( );
	local bJoin = ( net.ReadBit( ) == 1 && true || false );

	chat.AddText( colorx[( bJoin && "Lime" || "Red" )], "● ", Color( 255, 102, 51 ), strNick, color_white, " (", colorx["Gold"], strSteamID, color_white, ") "..( bJoin && "connected" || "left" ) );
end );

net.Receive( "player_joined", function( iLen )
	local strNick = net.ReadString( );

	chat.AddText( colorx["CoolBlue"], "● ", team.GetColor( TEAM_CITIZEN ), strNick, color_white, " joined" );
end );

hook.Add( "ChatText", "frank_Messages_ChatText", function( iPlayer, strNick, strText, strType )
	if( strType == "joinleave" ) then return true; end
end );