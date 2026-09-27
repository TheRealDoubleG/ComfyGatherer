ComfyGatherer = ComfyGatherer or {}
local A = ComfyGatherer

local ICONS = {
    Herbalism = "Interface\\Icons\\INV_Misc_Herb_07",
    Mining = "Interface\\Icons\\INV_Ore_Copper_01",
    Skinning = "Interface\\Icons\\INV_Misc_LeatherScrap_02",
    Other = "Interface\\Icons\\INV_Misc_Bag_10",
}

local function Epoch() return type(time)=="function" and time() or 0 end

local function CurrentPosition()
    if not C_Map or type(C_Map.GetBestMapForUnit)~="function" or type(C_Map.GetPlayerMapPosition)~="function" then return nil end
    local ok,mapID=pcall(C_Map.GetBestMapForUnit,"player")
    if not ok or not mapID then return nil end
    local ok2,pos=pcall(C_Map.GetPlayerMapPosition,mapID,"player")
    if not ok2 or not pos or type(pos.GetXY)~="function" then return mapID end
    local x,y=pos:GetXY()
    return mapID,tonumber(x),tonumber(y)
end

local function ItemID(link)
    if type(GetItemInfoInstant)=="function" then
        local ok,id=pcall(GetItemInfoInstant,link)
        if ok and tonumber(id) then return tonumber(id) end
    end
    return tonumber(tostring(link or ""):match("item:(%d+)"))
end

local function DetectProfession(link)
    local subtype
    if type(GetItemInfoInstant)=="function" then
        local ok,_,_,itemSubType=pcall(GetItemInfoInstant,link)
        if ok then subtype=itemSubType end
    end
    if not subtype and type(GetItemInfo)=="function" then
        local ok,_,_,_,_,_,sub=pcall(GetItemInfo,link)
        if ok then subtype=sub end
    end
    local text=tostring(subtype or ""):lower()
    if text:find("herb",1,true) or text:find("kräuter",1,true) then return "Herbalism",subtype end
    if text:find("metal",1,true) or text:find("stone",1,true) or text:find("metall",1,true) or text:find("stein",1,true) then return "Mining",subtype end
    if text:find("leather",1,true) or text:find("scale",1,true) or text:find("leder",1,true) or text:find("schuppe",1,true) then return "Skinning",subtype end
    return "Other",subtype
end

function A:ShouldTrack(profession)
    local c=self.db and self.db.gather
    if not c then return false end
    if profession=="Herbalism" then return c.trackHerbalism end
    if profession=="Mining" then return c.trackMining end
    if profession=="Skinning" then return c.trackSkinning end
    return c.trackOther
end

function A:CaptureLootWindow()
    if not self.db or not self.db.enabled or type(ComfyData)~="table" or type(ComfyData.RecordGather)~="function" then return end
    if type(GetNumLootItems)~="function" or type(GetLootSlotLink)~="function" then return end

    local mapID,x,y=CurrentPosition()
    local zoneName=type(GetZoneText)=="function" and GetZoneText() or nil
    local visitID=tostring(Epoch())..":"..tostring(mapID or 0)..":"..string.format("%.4f",x or 0)..":"..string.format("%.4f",y or 0)

    self.pendingLoot={}
    local count=tonumber(GetNumLootItems()) or 0
    for slot=1,count do
        local ok,link=pcall(GetLootSlotLink,slot)
        if ok and link then
            local itemID=ItemID(link)
            local name,quantity
            if type(GetLootSlotInfo)=="function" then
                local good,_,itemName,itemQuantity=pcall(GetLootSlotInfo,slot)
                if good then name=itemName; quantity=tonumber(itemQuantity) end
            end
            if not name and type(GetItemInfo)=="function" then
                local good,itemName=pcall(GetItemInfo,link)
                if good then name=itemName end
            end

            local profession,category=DetectProfession(link)
            if itemID and self:ShouldTrack(profession) then
                local sourceGUID
                if type(GetLootSourceInfo)=="function" then
                    local values={pcall(GetLootSourceInfo,slot)}
                    if values[1] and tonumber(values[2]) and tonumber(values[2])>0 then sourceGUID=values[3] end
                end
                self.pendingLoot[slot]={
                    itemID=itemID,itemName=name,quantity=quantity or 1,
                    profession=profession,category=category,sourceGUID=sourceGUID,
                    mapID=mapID,x=x,y=y,zoneName=zoneName,visitID=visitID,time=Epoch(),
                }
            end
        end
    end
end

function A:RecordLootSlot(slot)
    if not self.pendingLoot then return end
    local data=self.pendingLoot[tonumber(slot) or 0]
    if not data then return end
    self.pendingLoot[tonumber(slot) or 0]=nil
    if type(ComfyData)=="table" and type(ComfyData.RecordGather)=="function" then
        ComfyData:RecordGather(data)
    end
    self:RefreshFeature()
end

local function WorldPosition(mapID,x,y)
    if not C_Map or type(C_Map.GetWorldPosFromMapPos)~="function" or type(CreateVector2D)~="function" then return nil end
    local vector=CreateVector2D(x,y)
    local ok,continent,world=pcall(C_Map.GetWorldPosFromMapPos,mapID,vector)
    if not ok or not world or type(world.GetXY)~="function" then return nil end
    local wx,wy=world:GetXY()
    return continent,tonumber(wx),tonumber(wy)
end

function A:GetPin(index)
    self.pins=self.pins or {}
    if self.pins[index] then return self.pins[index] end
    local p=CreateFrame("Frame",nil,Minimap,"BackdropTemplate")
    p:SetFrameLevel((Minimap:GetFrameLevel() or 1)+8)
    p.icon=p:CreateTexture(nil,"ARTWORK"); p.icon:SetAllPoints(); p.icon:SetTexCoord(0.08,0.92,0.08,0.92)
    p:SetScript("OnEnter",function(self)
        if not self.node or not GameTooltip then return end
        GameTooltip:SetOwner(self,"ANCHOR_LEFT")
        GameTooltip:AddLine("ComfyGatherer",1,0.82,0)
        GameTooltip:AddLine((self.node.profession or self.node.category or "Gathering").." · "..tostring(self.node.visits or 0).." visits",1,1,1)
        for itemID,amount in pairs(self.node.items or {}) do
            local item=type(ComfyData)=="table" and ComfyData:GetGatherItem(itemID)
            GameTooltip:AddDoubleLine(item and item.name or ("Item "..tostring(itemID)),tostring(amount),1,1,1,0.2,1,0.2)
        end
        GameTooltip:Show()
    end)
    p:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
    self.pins[index]=p
    return p
end

function A:HidePins(from)
    for i=from or 1,#(self.pins or {}) do self.pins[i]:Hide() end
end

function A:RefreshMinimapPins()
    if not self.db or not self.db.enabled or not self.db.gather.showMinimapPins or not Minimap or type(ComfyData)~="table" then
        self:HidePins(1); return
    end
    if not C_Minimap or type(C_Minimap.GetViewRadius)~="function" then self:HidePins(1); return end
    local mapID,px,py=CurrentPosition()
    if not mapID or not px or not py then self:HidePins(1); return end
    local continent,pwx,pwy=WorldPosition(mapID,px,py)
    if not continent or not pwx or not pwy then self:HidePins(1); return end
    local ok,radius=pcall(C_Minimap.GetViewRadius)
    radius=ok and tonumber(radius) or nil
    if not radius or radius<=0 then self:HidePins(1); return end

    local candidates={}
    for _,node in ipairs(ComfyData:GetGatherNodesForMap(mapID) or {}) do
        if tonumber(node.x) and tonumber(node.y) and self:ShouldTrack(node.profession or "Other") then
            local c,wx,wy=WorldPosition(mapID,node.x,node.y)
            if c==continent and wx and wy then
                local dx,dy=wx-pwx,wy-pwy
                local dist=math.sqrt(dx*dx+dy*dy)
                if dist<=radius*1.2 then candidates[#candidates+1]={node=node,dx=dx,dy=dy,dist=dist} end
            end
        end
    end
    table.sort(candidates,function(a,b) return a.dist<b.dist end)

    local maxPins=math.max(1,math.min(100,tonumber(self.db.gather.maxPins) or 50))
    local size=math.max(8,math.min(28,tonumber(self.db.gather.pinSize) or 14))
    local width,height=Minimap:GetWidth() or 140,Minimap:GetHeight() or 140
    local count=0
    for i=1,math.min(#candidates,maxPins) do
        local c=candidates[i]
        local dx,dy=c.dx,c.dy
        if GetCVar and GetCVar("rotateMinimap")=="1" and type(GetPlayerFacing)=="function" then
            local facing=tonumber(GetPlayerFacing()) or 0
            local sinF,cosF=math.sin(facing),math.cos(facing)
            dx,dy=dx*cosF-dy*sinF,dx*sinF+dy*cosF
        end
        local x=(dx/radius)*(width/2)
        local y=(dy/radius)*(height/2)
        if x*x/((width/2)^2)+y*y/((height/2)^2)<=1 then
            count=count+1
            local pin=self:GetPin(count)
            pin.node=c.node
            pin:SetSize(size,size)
            pin.icon:SetTexture(ICONS[c.node.profession] or ICONS.Other)
            pin:ClearAllPoints()
            pin:SetPoint("CENTER",Minimap,"CENTER",x,y)
            pin:Show()
        end
    end
    self:HidePins(count+1)
end

function A:AddItemTooltip(tooltip,link)
    if not self.db or not self.db.enabled or not self.db.gather.showItemTooltip or type(ComfyData)~="table" then return end
    local itemID=ItemID(link)
    if not itemID then return end
    local item=ComfyData:GetGatherItem(itemID)
    if not item or not tonumber(item.total) or item.total<=0 then return end
    tooltip:AddLine(" ")
    tooltip:AddLine("ComfyGatherer",1,0.82,0)
    tooltip:AddDoubleLine(self:T("DATABASE"),tostring(item.total).." gathered",1,1,1,0.2,1,0.2)
    local zones={}
    for mapID,amount in pairs(item.zones or {}) do zones[#zones+1]={id=mapID,amount=amount} end
    table.sort(zones,function(a,b) return (a.amount or 0)>(b.amount or 0) end)
    for i=1,math.min(3,#zones) do
        local zone=ComfyData:GetGatherStore().zones[tostring(zones[i].id)]
        tooltip:AddDoubleLine(zone and zone.name or ("Map "..zones[i].id),tostring(zones[i].amount),0.8,0.8,0.8,1,1,1)
    end
end

function A:HookTooltips()
    if TooltipDataProcessor and type(TooltipDataProcessor.AddTooltipPostCall)=="function" and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item,function(t,data)
            A:AddItemTooltip(t,data and data.hyperlink)
        end)
    end
end

function A:GetDatabaseStats()
    if type(ComfyData)~="table" then return 0,0,0 end
    local store=ComfyData:GetGatherStore()
    local nodes,items,total=0,0,0
    for _ in pairs(store.nodes or {}) do nodes=nodes+1 end
    for _,item in pairs(store.items or {}) do items=items+1; total=total+(tonumber(item.total) or 0) end
    return nodes,items,total
end

function A:PrintStats()
    local n,i,t=self:GetDatabaseStats()
    self:Print(string.format(self:T("STATS_FORMAT"),n,i,t))
end

function A:RefreshFeatureOptions()
    if self.statsText then
        local n,i,t=self:GetDatabaseStats()
        self.statsText:SetText(string.format(self:T("STATS_FORMAT"),n,i,t))
    end
end

function A:RefreshFeature()
    self:RefreshMinimapPins()
    self:RefreshFeatureOptions()
end

function A:InitializeFeature()
    self:HookTooltips()
    local f=CreateFrame("Frame")
    self.eventFrame=f
    for _,ev in ipairs({"LOOT_OPENED","LOOT_SLOT_CLEARED","LOOT_CLOSED","PLAYER_ENTERING_WORLD","ZONE_CHANGED_NEW_AREA"}) do pcall(f.RegisterEvent,f,ev) end
    f:SetScript("OnEvent",function(_,ev,arg)
        if ev=="LOOT_OPENED" then
            A:CaptureLootWindow()
        elseif ev=="LOOT_SLOT_CLEARED" then
            A:RecordLootSlot(arg)
        elseif ev=="LOOT_CLOSED" then
            A.pendingLoot=nil
        else
            A:RefreshFeature()
        end
    end)
    f:SetScript("OnUpdate",function(self,elapsed)
        self.t=(self.t or 0)+(tonumber(elapsed) or 0)
        if self.t>=0.5 then self.t=0; A:RefreshMinimapPins() end
    end)
end

function A:BuildGeneralOptions(page,ui)
    ui.CreateCheck(page,self:T("TRACK_HERBS"),20,-95,function() return A.db.gather.trackHerbalism end,function(v) A.db.gather.trackHerbalism=v end)
    ui.CreateCheck(page,self:T("TRACK_MINING"),20,-130,function() return A.db.gather.trackMining end,function(v) A.db.gather.trackMining=v end)
    ui.CreateCheck(page,self:T("TRACK_SKINNING"),20,-165,function() return A.db.gather.trackSkinning end,function(v) A.db.gather.trackSkinning=v end)
    ui.CreateCheck(page,self:T("TRACK_OTHER"),20,-200,function() return A.db.gather.trackOther end,function(v) A.db.gather.trackOther=v end)
    ui.CreateCheck(page,self:T("SHOW_MINIMAP"),360,-95,function() return A.db.gather.showMinimapPins end,function(v) A.db.gather.showMinimapPins=v end)
    ui.CreateCheck(page,self:T("SHOW_TOOLTIP"),360,-130,function() return A.db.gather.showItemTooltip end,function(v) A.db.gather.showItemTooltip=v end)
    ui.CreateSlider(page,self:T("PIN_SIZE"),8,28,1,35,-285,function() return A.db.gather.pinSize end,function(v) A.db.gather.pinSize=math.floor(v+0.5) end,function(v) return math.floor(v+0.5).." px" end)
    ui.CreateSlider(page,self:T("MAX_PINS"),10,100,5,365,-285,function() return A.db.gather.maxPins end,function(v) A.db.gather.maxPins=math.floor(v+0.5) end,function(v) return tostring(math.floor(v+0.5)) end)
    local h=page:CreateFontString(nil,"ARTWORK","GameFontNormal"); h:SetPoint("TOPLEFT",20,-365); h:SetText(self:T("DATABASE"))
    self.statsText=page:CreateFontString(nil,"ARTWORK","GameFontHighlight"); self.statsText:SetPoint("TOPLEFT",20,-395); self.statsText:SetWidth(650); self.statsText:SetJustifyH("LEFT")
    local n=page:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall"); n:SetPoint("TOPLEFT",20,-440); n:SetWidth(680); n:SetJustifyH("LEFT"); n:SetText(self:T("FOREVER_NOTE"))
end
