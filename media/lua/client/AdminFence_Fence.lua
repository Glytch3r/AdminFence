

AdminFence = AdminFence or {}

AdminFence.FenceTiles = {
    top_left     = "fencing_01_52", -- upper-left corner
    top_edge     = "fencing_01_49", -- top straight
    top_right    = "fencing_01_51", -- upper-right corner
    bottom_left  = "fencing_01_48", -- bottom-left
    bottom_edge  = "fencing_01_49", -- bottom straight
    bottom_right = "fencing_01_53", -- bottom-right
    left_edge    = "fencing_01_50", -- left straight
    right_edge   = "fencing_01_50", -- right straight (use same)
}
-----------------------            ---------------------------
--AdminFence.addFence(sprName, sq)
--AdminFence.addFence(sprName, x, y, z)
function AdminFence.addFence(sprName, xOrSq, y, z)
    sprName = sprName or "fencing_01_52"
    local pl = getPlayer()
    local sq = nil
    local x = nil
    if xOrSq and type(xOrSq) ~= "number" then
        sq = xOrSq     
    else
        x = xOrSq
        sq = getCell():getOrCreateGridSquare(x, y, z)    
    end
    if not sq and pl then
        sq = pl:getCurrentSquare() 
    end
    if not sq then return end
    local obj = IsoObject.new(sq, sprName, "", false)
    sq:AddTileObject(obj)
    obj:transmitCompleteItemToServer();
    obj:transmitUpdatedSpriteToClients()
    getSoundManager():PlayWorldSound('ZombieThumpGarageDoor', sq, 0, 5, 5, false);

end

--AdminFence.delFence(sq)
--AdminFence.delFence(x, y, z)
function AdminFence.delFence(xOrSq, y, z)
    local pl = getPlayer()
    local sq = nil
    local x = nil
    
    if xOrSq and type(xOrSq) ~= "number" then
        sq = xOrSq
    else
        x = xOrSq
        sq = getCell():getGridSquare(x, y, z)
    end

    if not sq and pl then
        sq = pl:getCurrentSquare()
    end
    if not sq then return end

    local fence = AdminFence.getFenceObj(sq)
    if fence then AdminFence.doSledge(fence) end
    getSoundManager():PlayWorldSound('BreakObject', sq, 0, 5, 5, false);

end


-----------------------            ---------------------------
function AdminFence.doFence(startX, startY, endX, endY, z, isSet)
    if isSet == nil then isSet = true end
    if not startX or not startY or not endX or not endY then
        print("AdminFence.doFence: invalid coords")
        return
    end
    z = z or 0

    local sX = math.floor(math.min(startX, endX))
    local eX = math.floor(math.max(startX, endX))
    local sY = math.floor(math.min(startY, endY))
    local eY = math.floor(math.max(startY, endY))

    -- top
    for x = sX, eX do
        local sprName
        if x == sX then
            sprName = AdminFence.FenceTiles.top_left
        elseif x == eX then
            sprName = AdminFence.FenceTiles.top_right
        else
            sprName = AdminFence.FenceTiles.top_edge
        end
        if isSet then
            AdminFence.addFence(sprName, x, sY, z)
        else
            AdminFence.delFence(x, sY, z)
        end
    end

    -- bottom
    if eY ~= sY then
        for x = sX, eX do
            local sprName
            if x == sX then
                sprName = AdminFence.FenceTiles.bottom_left
            elseif x == eX then
                sprName = AdminFence.FenceTiles.bottom_right
            else
                sprName = AdminFence.FenceTiles.bottom_edge
            end
            if isSet then
                AdminFence.addFence(sprName, x, eY, z)
            else
                AdminFence.delFence(x, eY, z)
            end
        end
    end

    -- left
    for y = sY + 1, eY - 1 do
        if isSet then
            AdminFence.addFence(AdminFence.FenceTiles.left_edge, sX, y, z)
        else
            AdminFence.delFence(sX, y, z)
        end
    end

    -- right
    if eX ~= sX then
        for y = sY + 1, eY - 1 do
            if isSet then
                AdminFence.addFence(AdminFence.FenceTiles.right_edge, eX, y, z)
            else
                AdminFence.delFence(eX, y, z)
            end
        end
    end
end

--[[ 
local pl = getPlayer()
local x, y = round(pl:getX()),  round(pl:getY())
local  zone = NonPvpZone.getNonPvpZone(x, y)
local x1 = zone:getX()
local y1 = zone:getY()
local x2 = zone:getX2()
local y2 = zone:getY2()
AdminFence.doFence(x1, y1, x2, y2, 0)
 ]]


-----------------------            ---------------------------
function AdminFence.setZoneFence(zone, isSet)
    local pl = getPlayer()
    local x, y
    if zone == nil and pl then
        x, y = round(pl:getX()),  round(pl:getY())
        zone = NonPvpZone.getNonPvpZone(x, y)
    elseif type(zone) == "string" then
        zone = NonPvpZone.getZoneByTitle(zone)   
    end  
    if not zone then return end    
    x = zone:getX()
    y = zone:getY()
    local x2 = zone:getX2()
    local y2 = zone:getY2()
    if x and y and x2 and y2 then
        AdminFence.doFence(x, y, x2, y2, 0, isSet)
    end
end
-- AdminFence.setZoneFence(nil, true)
-- AdminFence.setZoneFence(nil, false)




