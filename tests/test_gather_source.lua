-- ComfyGatherer: source GUID and loot slot dedupe checks for Lua 5.1/5.4.
local root=arg[1] or "."
local calls={}
local sources={}
local data
local now=123
time=function() return now end
C_Map={
  GetBestMapForUnit=function(unit) return 12 end,
  GetPlayerMapPosition=function(mapID,unit) return {GetXY=function() return 0.25,0.75 end} end,
}
GetZoneText=function() return "Test Zone" end
GetNumLootItems=function() return 1 end
GetLootSlotLink=function(slot) return "|Hitem:2770:0|h[Kupfererz]|h" end
GetLootSlotInfo=function(slot) return "icon","Kupfererz",3 end
GetItemInfoInstant=function(link) return 2770,"Trade Goods","Metal & Stone" end
GetLootSourceInfo=function(slot) return "GameObject-0-11-22-33-9988-0000001",3 end
ComfyData={
  RecordGather=function(self,info)
    calls[#calls+1]=info
    return true
  end,
}
ComfyGatherer={db={enabled=true,gather={
  trackMining=true,trackHerbalism=true,trackOther=false,
  trackSkinning=false,showMinimapPins=false,
}}}
assert(loadfile(root.."/Gatherer.lua"))()
local A=ComfyGatherer
local checks=0
local function expect(ok,msg)
  checks=checks+1;assert(ok,"Check "..checks..": "..msg)
end
expect(A:ShouldTrack("Mining"),"mining active")
A:CaptureLootWindow()
data=A.pendingLoot[1]
expect(type(data)=="table","ore slot staged")
expect(data.itemID==2770,"ore ID")
expect(data.itemName=="Kupfererz","localized ore name")
expect(data.quantity==3,"three ore pieces")
expect(data.profession=="Mining","metal classified as mining")
expect(data.mapID==12,"map captured")
expect(data.x==0.25 and data.y==0.75,"coordinates captured")
expect(data.visitID~=nil,"visit ID")
expect(data.sourceGUID=="GameObject-0-11-22-33-9988-0000001","source GUID from API's first return value")
A:RecordLootSlot(1)
expect(#calls==1,"ore saved once")
expect(calls[1].sourceGUID=="GameObject-0-11-22-33-9988-0000001","source GUID propagated")
expect(A.pendingLoot[1]==nil,"pending slot removed")
A:RecordLootSlot(1)
expect(#calls==1,"duplicate cleared event suppressed")
GetLootSourceInfo=function() return "Creature-0-11-22-33-4455-0000002",1 end
A:CaptureLootWindow()
expect(A.pendingLoot[1].sourceGUID=="Creature-0-11-22-33-4455-0000002","source can also be a creature")
A.pendingLoot=nil
A:RecordLootSlot(1)
expect(#calls==1,"closed loot window not recorded")
GetLootSourceInfo=nil
A:CaptureLootWindow()
expect(A.pendingLoot[1] and A.pendingLoot[1].sourceGUID==nil,"missing optional source API does not lose loot")
GetItemInfoInstant=function(link) return 2770,"Trade Goods","Other" end
A:CaptureLootWindow()
expect(A.pendingLoot[1]==nil,"untracked subtype excluded")
print("PASS: "..checks.." ComfyGatherer source/loot checks")
