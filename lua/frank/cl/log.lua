CreateClientConVar( "log_show_props", "1", true );

net.Receive( "prop_spawn", function( iLen )
	if( !GetConVar( "log_show_props" ):GetBool( ) ) then return; end
	
	local objPl = net.ReadEntity( );
	if( !IsValid( objPl ) ) then return; end
	local strModel = net.ReadString( );

	MsgC( Color( 150, 150, 150, 255 ), "● " );
	MsgC( team.GetColor( objPl:Team( ) ), objPl:Nick( ) );
	MsgC( color_white, " (" );
	MsgC( colorx["Gold"], objPl:SteamID( ) );
	MsgC( color_white, ") spawned '" );
	MsgC( colorx["Lime"], strModel );
	MsgC( color_white, "'\n" );
end );