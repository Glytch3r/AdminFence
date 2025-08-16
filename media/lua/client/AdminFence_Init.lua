----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------



AdminFence = AdminFence or {}

Events.OnGameStart.Add(function()
	local function isDontSledgeTile(obj)
		if not obj then return false end
		local spr = obj:getSprite()
		if not spr then return false end
		local sprName = spr:getName()
		return sprName and AdminFence.isFence(sprName)
	end


	local sledgeHook = ISDestroyCursor.canDestroy
	function ISDestroyCursor:canDestroy(obj)
		if obj and (isDontSledgeTile(obj)) and not isAdmin() then
			return false
		end
		return sledgeHook(self, obj)
	end

end)

--     ▄▄▄▄ ▄▄▄▄   ▄     ▄    ▄▄▄  ▄   ▄  ▄▄▄  ▄   ▄    
--    █  ▄█ █      █     █   █   ▀ █   █ ▀   █ █   █       
--    █   ▄ █    █▀▀▀█   █   █   ▄ █▀▀▀█ ▄  ▀█ █ ▀▀▄    
--     ▀▀▀  ▀    ▀   ▀ ▀▀▀▀▀  ▀▀▀  ▀   ▀  ▀▀▀   ▀▀▀     

----------------------------------------------------------------

--[[ 
local isWall = obj.spriteProps:Is("WallNW") or obj.spriteProps:Is("WallN") or obj.spriteProps:Is("WallW");
local isWallTrans = obj.spriteProps:Is("WallNWTrans") or obj.spriteProps:Is("WallNTrans") or obj.spriteProps:Is("WallWTrans");
for i=0, self.spriteProps:getPropertyNames():size()-1 do
    local name = self.spriteProps:getPropertyNames():get(i);
    infoTable = ISMoveableSpriteProps.addLineToInfoTable( infoTable, name, 255, 255, 255, tostring(self.spriteProps:Val(name)), gR,gG,gB );
end
 ]]