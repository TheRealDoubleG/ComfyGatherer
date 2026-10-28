# ComfyGatherer

**Version 0.4 – Beta**  
**Target: World of Warcraft: Forever 1.60.1 / Interface 16001**

Personal gathering database and minimap tracker for professions and farming on WoW Forever.

ComfyGatherer stores its observations through **ComfyData**, so the history survives replacing/updating the ComfyGatherer addon folder.

## 0.3 Beta

- Gathering data is now committed only when a loot slot is actually cleared/taken.
- Closing a loot window without taking an item no longer falsely counts that item as gathered.

## 0.2 Beta

- Fixed gathering-history lines so they are added to the actual tooltip being processed.
- Works with the ComfyData node-visit deduplication used for multi-item loot from one gathering action.

## 0.1 Beta

- Learns gathering history from your own loot.
- Classifies Herbalism, Mining, Skinning and optional other trade goods.
- Stores item amounts, map IDs, coordinates, zones, characters and sessions in ComfyData.
- Shows nearby stored gathering points on the minimap when Forever exposes the required coordinate APIs.
- Adds personal gathered totals and common zones to item tooltips.
- Configurable profession filters, pin size and maximum visible nearby pins.
- /cgather stats prints database totals.

World-map pins and a full searchable farming browser are planned after the minimap/loot path has been validated in the Forever client.

## Source GUID fix (development)

GetLootSourceInfo(slot) returns alternating GUID/quantity pairs; the
previous code inspected the GUID as a number and often lost the source.
The new code passes the first nonempty GUID to ComfyData if a positive
source quantity exists. The API is optional. Together with the current
ComfyData development version, the last loot-source kind can be inspected
after /reload and compared to ore node gathers. Run:

    lua5.1 tests/test_gather_source.lua .
    lua5.4 tests/test_gather_source.lua .

Live Forever-client verification remains necessary for event availability
and genuine mining versus mob loot. No changes to release main branches.
