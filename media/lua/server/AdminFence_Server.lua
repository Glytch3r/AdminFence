AdminFence = AdminFence or {}
--server

if isClient() then return; end

local Commands = {};
Commands.AdminFence = {};

Commands.AdminFence.SafeZoneRecoverSave = function(player, args)
    local sOpt = getSandboxOptions()
    if not sOpt then return end
    local isActive = args.isActive
    if isActive ~= nil then
        local SafeZoneRecover = sOpt:getOptionByName("AdminFence.SafeZoneRecover")
        if SafeZoneRecover then 
            SafeZoneRecover:setValue(args.isActive)
            sOpt:toLua()
            --sOpt:sendToServer()
        end
    end
end


Commands.AdminFence.SafeZoneRecoverSync = function(player, args)
    local playerId = player:getOnlineID();
    if args.isActive ~= nil then
        sendServerCommand("AdminFence", "SafeZoneRecoverSync", {id = playerId, isActive = args.isActive})
    end
end

Events.OnClientCommand.Add(function(module, command, player, args)
	if Commands[module] and Commands[module][command] then
	    Commands[module][command](player, args)
	end
end)

