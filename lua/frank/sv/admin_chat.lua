util.AddNetworkString( "admin_chat" );

hook.Add( "PlayerSay", "frank_AdminChat_PlayerSay", function( objPl, strText, bTeam )
	if( string.sub( strText, 1, 1 ) == "@" ) then
		strText = string.Trim( string.sub( strText, 2 ), " " );

		if( string.len( strText ) < 2 ) then
			objPl:PrintMessage( HUD_PRINTTALK, "Admin chat message too short" );
			return "";
		end

		local tblPlayers = { }
		for k,v in pairs( player.GetAll( ) ) do
			if( v:IsMod( ) || v == objPl ) then
				table.insert( tblPlayers, v );
			end
		end

		net.Start( "admin_chat" );
			net.WriteEntity( objPl );
			net.WriteString( strText );
		net.Send( tblPlayers );
		return "";
	end
end );