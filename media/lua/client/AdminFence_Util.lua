

function AdminFence.getStateStr()
	local prefix = "Zone Recovery:"
	local recover = AdminFence.isSafeZoneRecover()
	local state = tostring(prefix) .." [OFF]"
	if recover then 
		state = tostring(prefix) .." [ON]"
	end
	return state
end
function AdminFence.context(player, context, worldobjects, test)
	local pl = getSpecificPlayer(player)
	local sq = clickedSquare
	if not  AdminFence.isAdm(pl) then return end
	local title = ""
	
	
	local x, y = round(pl:getX()), round(pl:getY())

	if 	sq:DistTo(x, y) <= 3 or sq == pl:getCurrentSquare() then
		if not x or not y then return end
		local isInSafe = NonPvpZone.getNonPvpZone(x, y) or false
		if isInSafe then
			title =  isInSafe:getTitle()
		end

		local mainMenu = "AdminFence: "..tostring(title)
		local Main = context:addOptionOnTop(mainMenu)
		Main.iconTexture = getTexture("media/ui/LootableMaps/map_trap.png")
		local opt = ISContextMenu:getNew(context)
		context:addSubMenu(Main, opt)

		
		local optTip = opt:addOption("Admin Fence Panel", worldobjects, function()
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

