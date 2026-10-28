-- Regressions for same-second loot windows and GetItemInfo fallback subtype.
local root=arg[1] or "."
local tick=600
time=function() return tick end
local slots=2
C_Map={GetBestMapForUnit=function() return 42 end,
  GetPlayerMapPosition=function() return {GetXY=function() return 0.45,0.67 end} end}
GetNumLootItems=function() return slots end
GetLootSlotLink=function(slot) return "|Hitem:"..(1000+slot)..":0|h[Copper Ore]|h" end
GetLootSlotInfo=function() return "icon","Copper Ore",1 end
GetItemInfoInstant=function() return 1001,"Trade Goods","Metal & Stone" end
GetZoneText=function() return "Same Place" end
GetLootSourceInfo=nil
ComfyData={RecordGather=function() return true end}
ComfyGatherer={db={enabled=true,gather={trackMining=true,trackHerbalism=true,trackSkinning=true,trackOther=false,showMinimapPins=false}}}
assert(loadfile(root.."/Gatherer.lua"))()
local A=ComfyGatherer
local checks=0
local function expect(cond,label)
 checks=checks+1
 assert(cond,"Check "..checks.." "..label)
end
A:CaptureLootWindow()
local first=A.pendingLoot[1]
expect(first and A.pendingLoot[2],"two items captured")
expect(first.visitID==A.pendingLoot[2].visitID,"two items same loot window -> same node visit")
A:CaptureLootWindow()
local second=A.pendingLoot[1]
expect(second and second.visitID~=first.visitID,"separate loot windows same second same place -> different visits")
expect(second.mapID==first.mapID,"same map")
-- Fallback path when GetItemInfoInstant isn't available.
GetItemInfoInstant=nil
GetItemInfo=function() return "Copper Ore","|Hitem:1001:0|h[Copper Ore]|h",2,10,1,"Trade Goods","Metal & Stone" end
slots=1
A:CaptureLootWindow()
expect(A.pendingLoot[1] and A.pendingLoot[1].profession=="Mining","GetItemInfo 7th return subtype classifies mining")
local savedProfile=A.db
expect(savedProfile.gather.captureSequence==3,"capture counter stored in profile")
ComfyGatherer={db=savedProfile}
assert(loadfile(root.."/Gatherer.lua"))()
local reloaded=ComfyGatherer
reloaded:CaptureLootWindow()
local afterReload=reloaded.pendingLoot[1]
expect(afterReload and afterReload.visitID~=second.visitID,"visit ID remains unique after reload with saved profile")
expect(savedProfile.gather.captureSequence==4,"capture counter persists through reload")
print("PASS: "..checks.." same-second loot windows / item subtype fallback checks")
