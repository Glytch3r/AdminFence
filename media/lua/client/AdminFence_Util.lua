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
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------
AdminFence = AdminFence or {}

function AdminFence.getStateStr()
	local prefix = "Zone Recovery:"
	local recover = AdminFence.isSafeZoneRecover()
	local state = tostring(prefix) .." [OFF]"
	if recover then 
		state = tostring(prefix) .." [ON]"
	end
	return state
end
local menuTitle = "Admin Fence Panel"
if getActivatedMods():contains("AdminRadZone") or getActivatedMods():contains("AdminWarp") then
	menuTitle = "Mini Toolkit Panel"
end

function AdminFence.context(player, context, worldobjects, test)
	local pl = getSpecificPlayer(player)
	local sq = clickedSquare
	if not  AdminFence.isAdm(pl) then return end
	local title = ""

	local x, y = round(pl:getX()), round(pl:getY())
	if not x or not y then return end
	if  getCore():getDebug() or	sq:DistTo(x, y) <= 3 or sq == pl:getCurrentSquare() then
		if not x or not y then return end
		local isInSafe = NonPvpZone.getNonPvpZone(x, y) or false
		if isInSafe then
			title =  isInSafe:getTitle()
		end

		local mainMenu = "AdminFence: "..tostring(title)
		if getActivatedMods():contains("AdminWarp") or getActivatedMods():contains("AdminRadZone") then
			mainMenu = "MiniToolkit"
		end
		local Main = context:addOptionOnTop(mainMenu)
		Main.iconTexture = getTexture("media/ui/LootableMaps/map_trap.png")
		local opt = ISContextMenu:getNew(context)
		context:addSubMenu(Main, opt)
	
		
		local optTip = opt:addOption("Mini Toolkit Panel", worldobjects, function()
			MiniToolkitPanel.Launch()
			getSoundManager():playUISound("UIActivateMainMenuItem")
			context:hideAndChildren()
		end)

		local optTip = opt:addOption(tostring(AdminFence.getStateStr()), worldobjects, function()
			AdminFence.setSafeZoneRecover(not AdminFence.isSafeZoneRecover())
			getSoundManager():playUISound("UIActivateMainMenuItem")
			context:hideAndChildren()
		end)
		context:setOptionChecked(optTip, AdminFence.isSafeZoneRecover())
	
	end
end
Events.OnFillWorldObjectContextMenu.Remove(AdminFence.context)
Events.OnFillWorldObjectContextMenu.Add(AdminFence.context)

function AdminFence.getCenter(x1,y1,x2,y2)
	local x = (x1 + x2) / 2
	local y = (y1 + y2) / 2
	return x, y
end