# ComfyGatherer

**Version 0.2 – Beta**  
**Target: World of Warcraft: Forever 1.60.1 / Interface 16001**

Personal gathering database and minimap tracker for professions and farming on WoW Forever.

ComfyGatherer stores its observations through **ComfyData**, so the history survives replacing/updating the ComfyGatherer addon folder.

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
