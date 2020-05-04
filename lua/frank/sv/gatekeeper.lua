gatekeeper={}
local spawning={}
  
gameevent.Listen("player_connect")
gameevent.Listen("player_disconnect")
  
function gatekeeper.Drop(userid, reason)
    if(timer.Exists("player_join_"..userid)) then
        timer.Destroy("player_join_"..userid)
    end

    for k,v in pairs(player.GetAll()) do
        if(v:UserID() == userid) then
            v.IgnoreLeave = true
            break
        end
    end

    game.ConsoleCommand(string.format("kickid %d %s\n",userid,reason:gsub('|\n','')))
end
  
function gatekeeper.GetNumClients()
    local active=#player.GetAll()
    return {spawning=#spawning, active=active, total=#spawning+active}
end
  
function gatekeeper.GetUserByAddress(addr)
    for k,v in pairs(player.GetAll()) do
        if(v:IPAddress()==addr) then
            return v:UserID()
        end
    end
end
  
hook.Add("player_connect", "GateKeeper", function(data)
    local ret=hook.Call("PlayerPasswordAuth", GAMEMODE, data.name, "", data.networkid, data.address)
    if(type(ret)=="string") then
        gatekeeper.Drop(data.userid, ret)
        return
    elseif(type(ret)=="boolean") then
        if(ret) then
            gatekeeper.Drop(data.userid, "Bad Password")
            return
        end
    end

    hook.Call("PlayerConnected", GAMEMODE, data.name, data.userid, data.networkid, data.address)
    
    table.insert(spawning, data.userid)
end)
  
hook.Add("player_disconnect", "GateKeeper", function(data)
    for k,v in pairs(spawning) do
        if(data.userid==v) then
            table.remove(spawning, k)
            break
        end
    end
end)
  
hook.Add("PlayerInitialSpawn", "GateKeeper", function(ply)
    for k,v in pairs(spawning) do
        if(ply:UserID()==v) then
            table.remove(spawning, k)
            break
        end
    end
end)