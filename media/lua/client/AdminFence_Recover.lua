AdminFence = AdminFence or {}

function AdminFence.isSafeZoneRecover()
    return getSandboxOptions():getOptionByName("AdminFence.SafeZoneRecover"):getValue()
end

function AdminFence.isAdm(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return isClient() and string.lower(pl:getAccessLevel()) == "admin"
end

function AdminFence.SafeHandler(pl)
    if not pl or AdminFence.isAdm(pl) then return end

    local x, y = round(pl:getX()), round(pl:getY())
    if not x or not y then return end

    local isInSafe = NonPvpZone.getNonPvpZone(x, y) or false
    local isGodMod = pl:isGodMod()
    local allowRecover = AdminFence.isSafeZoneRecover()
    local md = pl:getModData()

    if allowRecover then
        if isInSafe and not isGodMod then
            pl:setGodMod(true)
            md.AdminFenceRecover = true
        end
        if not isInSafe and isGodMod and md.AdminFenceRecover then
            pl:setGodMod(false)
            md.AdminFenceRecover = nil
        end
    else
        if isGodMod then
            pl:setGodMod(false)
            md.AdminFenceRecover = nil
        end
    end
end

Events.OnPlayerUpdate.Add(AdminFence.SafeHandler)
