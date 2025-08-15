--[[ AdminFence = AdminFence or {}
MiniToolkitPanel = MiniToolkitPanel or {}
MiniToolkitPanel.__index = MiniToolkitPanel

function MiniToolkitPanel:setTitle(newTitle) 
    if AdminFence.window then
        AdminFence.window:setTitle(newTitle or self.title)
    end
end

function MiniToolkitPanel:new(x, y, width, height, title)
    local o = ISCollapsableWindow.new(self, x, y, width, height)
    o.buttons = {}
    o.rows = {}
    o.buttonSize = 42
    o.spacing = 2
    o.bgColor = {r=0.1,g=0.1,b=0.1,a=0.8}
    o.x = x
    o.y = y
    o.title = title or "Mini Toolkit"
    o.lastZoneCount = 0
    o.lastSelectedIndex = -1
    o.lastSelectedName = ""
    o.updateTimer = 0
    o.updateInterval = 30
    o:buildWindow()
    return o
end

function MiniToolkitPanel:updateZoneData()
    local zones = NonPvpZone.getAllZones()
    local total = zones:size()
    if total > 0 then
        if not AdminFence.selectedIndex or AdminFence.selectedIndex >= total then
            AdminFence.selectedIndex = 0
        end
        AdminFence.selected = zones:get(AdminFence.selectedIndex)
    else
        AdminFence.selected = nil
        AdminFence.selectedIndex = 0
    end

    for _, row in pairs(self.rows) do
        for _, btn in ipairs(row) do
            if btn.tooltipFunc then
                btn.tooltip = btn.tooltipFunc()
            end
            if btn.colorFunc then
                btn.activeColor = btn.colorFunc()
            end
        end
    end

    self:refreshButtons()
end

function MiniToolkitPanel:addFeature(textFunc, callback, sprite, colorFunc, rowIndex)
    rowIndex = rowIndex or 1
    self.rows[rowIndex] = self.rows[rowIndex] or {}
    local btn = {
        textFunc = textFunc,
        callback = callback,
        sprite = sprite,
        colorFunc = colorFunc,
        active = false
    }
    table.insert(self.rows[rowIndex], btn)
end

function MiniToolkitPanel:refreshButtons()
    if not AdminFence.window then return end

    for _, child in ipairs(AdminFence.window:getChildren()) do
        if child ~= AdminFence.window.closeButton then
            AdminFence.window:removeChild(child)
        end
    end

    local th = AdminFence.window:titleBarHeight()
    local yOffset = th
    local maxWidth = 0

    for _, row in ipairs(self.rows) do
        if row then
            local xOffset = 4
            for _, btn in ipairs(row) do
                if btn then
                    local b = ISButton:new(xOffset, yOffset, self.buttonSize, self.buttonSize, "", nil, nil)
                    b:initialise()
                    b.borderColor = {r=0,g=0,b=0,a=0}

                    local bgColor
                    if type(btn.activeColor) == "function" then
                        bgColor = btn.activeColor()
                    else
                        bgColor = btn.activeColor
                    end

                    b.backgroundColor = bgColor or {r=0,g=0,b=0,a=0}
                    b.backgroundColorMouseOver = {r=0,g=1,b=0,a=1}

                    if btn.sprite then b:setImage(getTexture(btn.sprite)) end
                    if btn.tooltip then b:setTooltip(btn.tooltip) end

                    b:setOnClick(function(button)
                        if btn.toggle then
                            btn.active = not btn.active
                            local newColor = type(btn.activeColor) == "function" and btn.activeColor() or btn.activeColor
                            button.backgroundColor = newColor or {r=0,g=0,b=0,a=0}
                        end
                        if btn.callback then btn.callback() end
                        self:updateZoneData()
                    end)

                    AdminFence.window:addChild(b)
                    xOffset = xOffset + self.buttonSize + self.spacing
                end
            end
            maxWidth = math.max(maxWidth, xOffset + 4)
            yOffset = yOffset + self.buttonSize + self.spacing
        end
    end

    AdminFence.window:setWidth(maxWidth)
    AdminFence.window:setHeight(yOffset + 4)

    if AdminFence.window.NewTitle and AdminFence.window.NewTitle ~= "" then
        self:setTitle(AdminFence.window.NewTitle)
    end
end

function MiniToolkitPanel:buildWindow()
    local minWidth = math.max(160, #self.title*8 + 50)
    AdminFence.panel = ISCollapsableWindow:new(self.x, self.y, minWidth+15, self.buttonSize + 20)
    AdminFence.panel.collapseButton = nil

    function AdminFence.panel:createChildren()
        ISCollapsableWindow.createChildren(self)
        if self.collapseButton then
            self:removeChild(self.collapseButton)
            self.collapseButton = nil
        end
        if self.closeButton then
           -- self.closeButton:setVisible(false);
            self:removeChild(self.closeButton)
            self.closeButton = nil
        end
    end

    function AdminFence.panel:update()
        ISCollapsableWindow.update(self)
        if self.panelRef and self.panelRef.onUpdate then
            self.panelRef:onUpdate()
        end
    end

    AdminFence.panel:initialise()
    if AdminFence.panel.closeButton then
        AdminFence.panel.closeButton:setVisible(false);
    end

    AdminFence.panel:addToUIManager()
    AdminFence.panel.resizable = false
    AdminFence.panel:setTitle(self.title)
    AdminFence.panel.defaultTitle = self.title
    AdminFence.panel:setHeight(self.buttonSize + AdminFence.panel:titleBarHeight())
    AdminFence.panel.panelRef = self
    AdminFence.window = AdminFence.panel
end

function MiniToolkitPanel:onUpdate()
    self.updateTimer = (self.updateTimer or 0) + 1
    if self.updateTimer < (self.updateInterval or 30) then return end
    self.updateTimer = 0

    local zones = NonPvpZone.getAllZones()
    local total = zones:size()
    local needsRefresh = false

    if total ~= (self.lastZoneCount or 0) then
        self.lastZoneCount = total
        needsRefresh = true
    end

    if AdminFence.selectedIndex ~= (self.lastSelectedIndex or 0) then
        self.lastSelectedIndex = AdminFence.selectedIndex or 0
        needsRefresh = true
    end

    local selectedValid = AdminFence.selected and NonPvpZone.getAllZones():contains(AdminFence.selected)
    if not selectedValid then
        AdminFence.selected = nil
        needsRefresh = true
    end

    if needsRefresh then
        self:updateZoneData()
    end
end

function MiniToolkitPanel.Launch()
    local pl = getPlayer()
    if not pl then return end

    if MiniToolkitPanel.panel1 and AdminFence.window then
        AdminFence.window:close()
        AdminFence.window = nil
        MiniToolkitPanel.panel1 = nil
        return
    end

    MiniToolkitPanel.panel1 = MiniToolkitPanel:new(getCore():getScreenWidth() / 3, getCore():getScreenHeight() / 3, 200, 100, "Mini Toolkit")
   -- MiniToolkitPanel.panel1:updateZoneData()

    function MiniToolkitPanel.prevZone()
        local zones = NonPvpZone.getAllZones()
        local total = zones:size()
        if total == 0 then return end
        AdminFence.selectedIndex = (AdminFence.selectedIndex - 1 + total) % total
        AdminFence.selected = zones:get(AdminFence.selectedIndex)
    end

    function MiniToolkitPanel.nextZone()
        local zones = NonPvpZone.getAllZones()
        local total = zones:size()
        if total == 0 then return end
        AdminFence.selectedIndex = (AdminFence.selectedIndex + 1) % total
        AdminFence.selected = zones:get(AdminFence.selectedIndex)
    end

    local row = 2

    MiniToolkitPanel.panel1:addFeature( 
        function() return "AdminFence" end,
        function()
            MiniToolkitPanel.panel1:updateZoneData()
            if MiniToolkitPanel.panel1.rows[row] then
                MiniToolkitPanel.panel1.rows[row] = nil
                MiniToolkitPanel.panel1:setTitle("Mini Toolkit")
            else
                MiniToolkitPanel.panel1.rows[row] = {}

                MiniToolkitPanel.panel1:addFeature(
                    function()
                        if AdminFence.selected then
                            return "Teleport to Zone " .. AdminFence.selected:getX() .. "," .. AdminFence.selected:getY()
                        else
                            return "Teleport (No Zone Selected)"
                        end
                    end,
                    function()
                        if AdminFence.selected then
                            SendCommandToServer("/teleportto " .. AdminFence.selected:getX() .. "," .. AdminFence.selected:getY() .. ",0")
                            pl:playSoundLocal("RemoveBarricadeMetal")
                        end
                    end,
                    "media/ui/LootableMaps/map_sun.png",
                    nil,
                    row
                )

                MiniToolkitPanel.panel1:addFeature(
                    function() return "Add Fence" end,
                    function()
                        if AdminFence.selected then
                            AdminFence.setZoneFence(AdminFence.selected, true)
                        end
                    end,
                    "media/ui/LootableMaps/map_medcross.png",
                    nil,
                    row
                )

                MiniToolkitPanel.panel1:addFeature(
                    function() return "Remove Fence" end,
                    function()
                        if AdminFence.selected then
                            AdminFence.setZoneFence(AdminFence.selected, false)
                            pl:playSoundLocal("ForkBreak")
                        end
                    end,
                    "media/ui/LootableMaps/map_garbage.png",
                    nil,
                    row
                )

                MiniToolkitPanel.panel1:addFeature(
                    function()
                        return "Zone Recovery " .. (AdminFence.isSafeZoneRecover() and "[ON]" or "[OFF]")
                    end,
                    function()
                        AdminFence.setSafeZoneRecover(not AdminFence.isSafeZoneRecover())
                    end,
                    "media/ui/LootableMaps/map_heart.png",
                    function()
                        return AdminFence.isSafeZoneRecover() and {r=0.5,g=0.91,b=0.32,a=1} or {r=0.5,g=0,b=0,a=1}
                    end,
                    row
                )

                MiniToolkitPanel.panel1:addFeature(
                    function() return "Previous Zone" end,
                    function()
                        MiniToolkitPanel.prevZone()
                        if AdminFence.selected then
                            MiniToolkitPanel.panel1:setTitle("AdminFence: " .. AdminFence.selected:getTitle())
                            pl:addLineChatElement(AdminFence.selected:getTitle())
                            pl:playSoundLocal("StakeBreak")
                        end
                    end,
                    "media/ui/LootableMaps/map_arrowwest.png",
                    nil,
                    row
                )

                MiniToolkitPanel.panel1:addFeature(
                    function() return "Next Zone" end,
                    function()
                        MiniToolkitPanel.nextZone()
                        if AdminFence.selected then
                            MiniToolkitPanel.panel1:setTitle("AdminFence: " .. AdminFence.selected:getTitle())
                            pl:addLineChatElement(AdminFence.selected:getTitle())
                            pl:playSoundLocal("StakeBreak")
                        end
                    end,
                    "media/ui/LootableMaps/map_arroweast.png",
                    nil,
                    row
                )


                MiniToolkitPanel.panel1:addFeature(
                    function()
                        return "Zone Visibility " .. tostring(pl:isSeeNonPvpZone())
                    end,
                    function() pl:setSeeNonPvpZone(not pl:isSeeNonPvpZone()) end,
                    "media/ui/LootableMaps/map_target.png",
                    nil,
                    row
                )

 

            end



            MiniToolkitPanel.panel1:refreshButtons()
        end
    )
    local cred = "Modded by:\nGlytch3r\n\nCommissioned by:\nProject One/Life Server"
    MiniToolkitPanel.panel1:addFeature(
        function() return "Credits" end,
        function()
            pl:setHaloNote(tostring(cred), 111, 219, 21, 260)
            pl:playSoundLocal("BreakFishingLine")
        end,
        "media/ui/LootableMaps/map_star.png",
        nil,
        1
    )

    MiniToolkitPanel.panel1:addFeature(
        function() return "Exit" end,
        function()
            MiniToolkitPanel.Launch()
        end,
        "media/ui/LootableMaps/map_x.png",
        nil,
        1

    )
    local trapBtnRow = MiniToolkitPanel.panel1.rows[1]
    if trapBtnRow and trapBtnRow[1] then
        trapBtnRow[1].sprite = "media/ui/LootableMaps/map_trap.png"
    end
    MiniToolkitPanel.panel1:refreshButtons()


end
 ]]