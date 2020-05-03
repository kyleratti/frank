hook.Add( "PlayerSpawn", "frank_PlayerSpawn", function( objPl )
	if( !IsValid( objPl ) ) then return; end

	dyndb.Insert( "log_spawn", {
		{ "nick",	objPl:Nick( )			},
		{ "steam",	objPl:SteamID( )		},
		{ "ip",		objPl:IPAddress( )		},
		{ "time",	tostring( os.time( ) )	},
	} );
end );

hook.Add( "PlayerSay", "frank_PlayerSay", function( objPl, strMessage, bTeam )
	if( !IsValid( objPl ) ) then return; end

	dyndb.Insert( "log_chat", {
		{ "nick",		objPl:Nick( ) 					},
		{ "steam",		objPl:SteamID( )				},
		{ "team",		team.GetName( objPl:Team( ) )	},
		{ "rank",		objPl:GetRank( ).Name 			},
		{ "message",	strMessage 						},
		{ "team_chat",	( bTeam && 1 || 0 ) 			},
		{ "time",		tostring( os.time( ) ) 			},
	} );
end );

hook.Add( "PlayerDisconnected", "frank_PlayerDisconnect", function( objPl )
	dyndb.Insert( "log_disconnect", {
		{ "nick",	objPl:Nick( )					},
		{ "steam",	objPl:SteamID( )				},
		{ "team",	team.GetName( objPl:Team( ) )	},
		{ "time",	tostring( os.time( ) )			},
	} );
end );

hook.Add( "PlayerDeath", "frank_PlayerDeath", function( objPl, objWeapon, objKiller )
	if( !IsValid( objPl ) ) then return; end

	local strAttackerNick	= "world";
	local strAttackerSteam	= "STEAM_0:0:1";
	local strAttackerTeam	= "world";

	if( IsValid( objKiller ) && objKiller:IsPlayer( ) ) then
		strAttackerNick		= objKiller:Nick( );
		strAttackerSteam	= objKiller:SteamID( );
		strAttackerTeam		= team.GetName( objKiller:Team( ) );
	end

	dyndb.Insert( "log_kill", {
		{ "victim_nick",	objPl:Nick( )					},
		{ "victim_steam",	objPl:SteamID( )				},
		{ "victim_team",	team.GetName( objPl:Team( ) )	},
		{ "attacker_nick",	strAttackerNick					},
		{ "attacker_steam",	strAttackerSteam				},
		{ "attacker_team",	strAttackerTeam					},
		{ "time",			tostring( os.time( ) )			},
	} );
end );

util.AddNetworkString( "prop_spawn" );

hook.Add( "PlayerSpawnedProp", "frank_PlayerSpawnedProp_Log", function( objPl, strModel, objEnt )
	dyndb.Insert( "log_prop", {
		{ "nick",	objPl:Nick( )			},
		{ "steam",	objPl:SteamID( )		},
		{ "prop",	strModel 				},
		{ "time", 	tostring( os.time( ) )	},
	} );

	net.Start( "prop_spawn" );
		net.WriteEntity( objPl );
		net.WriteString( strModel );
	net.Broadcast( );
end );