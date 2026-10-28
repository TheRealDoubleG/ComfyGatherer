# ComfyGatherer Changelog

## 0.4 Beta – 28.09.2026
- Registered ComfyGatherer in Blizzard's native AddOns settings list with a button to open the full Comfy settings window.


## 0.3 Beta – 28.09.2026
- Switched from LOOT_OPENED counting to LOOT_SLOT_CLEARED confirmation.
- Prevents abandoned/unlooted items from polluting the gathering database.


## 0.2 Beta – 28.09.2026
- Fixed item-history output for non-GameTooltip item tooltips.
- Synced node-visit handling with ComfyData's per-gather-action deduplication.


## 0.1 Beta – 28.09.2026
- Initial ComfyData-backed gathering tracker.
- Added personal loot/location recording.
- Added Herbalism/Mining/Skinning classification and filters.
- Added guarded minimap pin engine.
- Added item-tooltip gathering history.
- Added Comfy Suite profile/settings/info framework.

## 0.6 (development)
- Corrected GetLootSourceInfo return positions (guid1, quantity1) when
  collecting loot-source metadata for ore/herb/skinning tracking.
- Kept the source API optional; unavailable GUIDs do not suppress loot.
- Added 18 mock loot-source and duplicate-cleared-slot checks (Lua 5.1/5.4).
