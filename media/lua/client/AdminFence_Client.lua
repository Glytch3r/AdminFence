----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  ------
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----------
------- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ ---
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  ---------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ --  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
 --                             --   Project Zomboid Modding Commissions                      
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ --  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----


--client
AdminFence = AdminFence or {}

local Commands = {};
Commands.AdminFence = {};


function AdminFence.setSafeZoneRecover(isActive)
    local sOpt = getSandboxOptions()
    local SafeZoneRecover = sOpt:getOptionByName("AdminFence.SafeZoneRecover")
    isActive = isActive or not SafeZoneRecover:getValue()

    if isClient() then
        sendClientCommand("AdminFence", "SafeZoneRecoverSync", {isActive = isActive})         
    end
    AdminFence.doSafeZoneRecover(isActive)
end

function AdminFence.doSafeZoneRecover(isActive)
    local sOpt = getSandboxOptions()
    local SafeZoneRecover = sOpt:getOptionByName("AdminFence.SafeZoneRecover")
    SafeZoneRecover:setValue(isActive)
    sOpt:toLua()
    sOpt:sendToServer()
    local msg = "Non-PvP Zones Safety [OFF]"
    if SafeZoneRecover:getValue() then
        msg = "Non-PvP Zones Safety [ON]"
    end
    ISChat.instance.servermsgTimer = 2000
    ISChat.instance.servermsg = tostring(msg)
end




Commands.AdminFence.SafeZoneRecoverSync = function(args)
    local source = getPlayer();
    local player = getPlayerByOnlineID(args.id)
    if source ~= player  then
        AdminFence.doSafeZoneRecover(args.isActive)
    end
end

Events.OnServerCommand.Add(function(module, command, args)
	if Commands[module] and Commands[module][command] then
		Commands[module][command](args)
	end
end)

