AdminFence = AdminFence or {}

AdminFence.fenceList = {
	["fencing_01_48"]=true,
	["fencing_01_49"]=true,
	["fencing_01_50"]=true,
	["fencing_01_51"]=true,
	["fencing_01_52"]=true,
	["fencing_01_53"]=true,
}
AdminFence.fenceStr = {
	"fencing_01_48",
	"fencing_01_49",
	"fencing_01_50",
	"fencing_01_51",
	"fencing_01_52",
	"fencing_01_53",
}
AdminFence.dirFence = {
	["CornerN"]="fencing_01_48",
	["N"]="fencing_01_49",
	["W"]="fencing_01_50",
	["CornerW"]="fencing_01_51",
	["CornerNW"]="fencing_01_52",
	[""]="fencing_01_53",
}
AdminFence.wallStyles = {
	["fencing_01_48"]="NorthWallTrans",
	["fencing_01_49"]="NorthWallTrans",
	["fencing_01_50"]="WestWallTrans",
	["fencing_01_51"]="WestWallTrans",
	["fencing_01_52"]="NorthWestWallCornerTrans",
	["fencing_01_53"]="",
}

function AdminFence.isWall(sprName)
	if not sprName then return false end
	return AdminFence.fenceList[sprName]
end

function AdminFence.isFence(sprName)
	if not sprName then return false end
	return AdminFence.fenceList[sprName]
end

function AdminFence.isHoppable(obj)
	if not obj then return false end
	return obj:isHoppable()
end


function AdminFence.getSpr(obj)
	if not obj then return nil end
	local spr = obj:getSprite()
	return spr or nil
end

function AdminFence.getSprName(obj)
	if not obj then return nil end
	local spr = obj:getSprite()
	return spr and spr:getName() or nil
end


function AdminFence.getFenceObj(sq)
    local fence
    for i=1, sq:getObjects():size() do
        local obj = sq:getObjects():get(i-1)
        if obj and instanceof(obj, "IsoObject") then
            local sprName = AdminFence.getSprName(obj)
            if sprName and AdminFence.isFence(sprName) then
                fence = obj
                break
            end
        end
    end
    return fence
end

function AdminFence.doSledge(obj)
    if isClient() then
        sledgeDestroy(obj)
    else
        local sq = obj:getSquare()
        if sq then
            sq:RemoveTileObject(obj)
            sq:getSpecialObjects():remove(obj)
            sq:getObjects():remove(obj)
            sq:transmitRemoveItemFromSquare(obj)
        end
    end
end



--[[ 
	ISBuildMenu.cheat = true;
	local pl = getPlayer()
	if not pl:isBuildCheat() then
		pl:setBuildCheat(true);
		print('isBuildCheat: '..tostring(pl:isBuildCheat()))
	end
	getCell():setDrag(ISDestroyCursor:new(pl, true), pl:getPlayerNum())
 ]]
--[[ 
local isWall = obj.spriteProps:Is("WallNW") or obj.spriteProps:Is("WallN") or obj.spriteProps:Is("WallW");
local isWallTrans = obj.spriteProps:Is("WallNWTrans") or obj.spriteProps:Is("WallNTrans") or obj.spriteProps:Is("WallWTrans");
for i=0, self.spriteProps:getPropertyNames():size()-1 do
    local name = self.spriteProps:getPropertyNames():get(i);
    infoTable = ISMoveableSpriteProps.addLineToInfoTable( infoTable, name, 255, 255, 255, tostring(self.spriteProps:Val(name)), gR,gG,gB );
end
 ]]