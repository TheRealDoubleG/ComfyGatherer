ComfyGatherer = ComfyGatherer or {}
local A = ComfyGatherer

A.version = "0.6"
A.buildDate = "04.10.2026"

local function Epoch() return type(time)=="function" and time() or 0 end
local function RelativeTime(epoch)
    local delta=math.max(0,Epoch()-(tonumber(epoch) or Epoch()))
    if delta<60 then return tostring(delta).."s" end
    if delta<3600 then return tostring(math.floor(delta/60)).."m" end
    if delta<86400 then return tostring(math.floor(delta/3600)).."h" end
    return tostring(math.floor(delta/86400)).."d"
end

local function RichPinTooltip(pin)
    if not pin or not pin.node or not GameTooltip then return end
    local node=pin.node
    GameTooltip:SetOwner(pin,"ANCHOR_LEFT")
    GameTooltip:AddLine("ComfyGatherer",1,.82,0)
    GameTooltip:AddDoubleLine("Typ",tostring(node.profession or node.category or "Gathering"),1,1,1,.45,1,.55)
    GameTooltip:AddDoubleLine("Koordinaten",string.format("%.1f, %.1f",(tonumber(node.x) or 0)*100,(tonumber(node.y) or 0)*100),1,1,1,.45,1,.55)
    GameTooltip:AddDoubleLine("Gesammelt",tostring(tonumber(node.visits) or 0).."x",1,1,1,1,1,1)
    if node.lastSeen then GameTooltip:AddDoubleLine("Zuletzt",RelativeTime(node.lastSeen),1,1,1,1,1,1) end
    for itemID,amount in pairs(node.items or {}) do
        local item=type(ComfyData)=="table" and type(ComfyData.GetGatherItem)=="function" and ComfyData:GetGatherItem(itemID)
        GameTooltip:AddDoubleLine(item and item.name or ("Item "..tostring(itemID)),tostring(amount),1,1,1,.2,1,.2)
    end
    GameTooltip:Show()
end

local originalGetPin=A.GetPin
function A:GetPin(index)
    local pin=originalGetPin and originalGetPin(self,index)
    if pin and not pin.__comfyRichTooltip then
        pin.__comfyRichTooltip=true
        pin:SetScript("OnEnter",function(self) RichPinTooltip(self) end)
        pin:SetScript("OnLeave",function() if GameTooltip then GameTooltip:Hide() end end)
    end
    return pin
end

local originalRecordLootSlot=A.RecordLootSlot
function A:RecordLootSlot(slot)
    local result
    if originalRecordLootSlot then result=originalRecordLootSlot(self,slot) end
    if type(ComfyMaps)=="table" and type(ComfyMaps.RefreshGathererPins)=="function" then pcall(ComfyMaps.RefreshGathererPins,ComfyMaps) end
    return result
end

local originalBuildGeneralOptions=A.BuildGeneralOptions
function A:BuildGeneralOptions(page,ui)
    if originalBuildGeneralOptions then originalBuildGeneralOptions(self,page,ui) end
    if not page then return end
    local sync=page:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
    sync:SetPoint("TOPLEFT",360,-365); sync:SetWidth(330); sync:SetJustifyH("LEFT")
    sync:SetText("ComfyGatherer und ComfyMaps verwenden dieselben accountweiten Punkte aus ComfyData. Nahe Fundorte werden automatisch zusammengeführt.")
    if ui and ui.CreateButton then
        ui.CreateButton(page,"ComfyMap aktualisieren",360,-430,190,function() if type(ComfyMaps)=="table" and ComfyMaps.RefreshGathererPins then ComfyMaps:RefreshGathererPins() end end)
    end
end
