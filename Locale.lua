ComfyGatherer = ComfyGatherer or {}
local A=ComfyGatherer
local de=GetLocale and GetLocale()=="deDE"

local EN={
    TAB_GENERAL="Gathering", TAB_INFO="Info", ADDON_ENABLED="Enable ComfyGatherer",
    INFO_VERSION="Version",INFO_BUILD_DATE="Build date",INFO_STATUS="Status",INFO_CLIENT="Current client",
    INFO_TESTED_TARGET="Tested target",INFO_COMPAT_STATUS="Compatibility",INFO_AUTHOR="Author",
    INFO_DISCORD="Discord",INFO_GITHUB="GitHub",INFO_COMMANDS="Slash commands",
    COMPAT_MATCH="Compatible",COMPAT_UPDATE_REQUIRED="Interface differs from the tested target",
    INFO_NOTICE="ComfyGatherer stores personal gathering observations in ComfyData. It does not automate movement, gathering or routes.",
    INFO_THANKS="Thanks for using ComfyGatherer! Feedback and bug reports are welcome via Discord.",
    TRACK_HERBS="Track Herbalism",TRACK_MINING="Track Mining",TRACK_SKINNING="Track Skinning",
    TRACK_OTHER="Track other trade goods",SHOW_MINIMAP="Show minimap pins",SHOW_TOOLTIP="Add gathering history to item tooltips",
    PIN_SIZE="Minimap pin size",MAX_PINS="Maximum nearby pins",DATABASE="Database",
    STATS_FORMAT="%d nodes · %d items · %d total gathered",
    FOREVER_NOTE="0.1 learns only from your own loot. Minimap pins use stored map coordinates when Forever exposes the required map/world-position APIs.",
}
local DE={
    TAB_GENERAL="Sammeln", TAB_INFO="Info", ADDON_ENABLED="ComfyGatherer aktivieren",
    INFO_VERSION="Version",INFO_BUILD_DATE="Build-Datum",INFO_STATUS="Status",INFO_CLIENT="Aktueller Client",
    INFO_TESTED_TARGET="Getestetes Ziel",INFO_COMPAT_STATUS="Kompatibilität",INFO_AUTHOR="Autor",
    INFO_DISCORD="Discord",INFO_GITHUB="GitHub",INFO_COMMANDS="Slash-Befehle",
    COMPAT_MATCH="Kompatibel",COMPAT_UPDATE_REQUIRED="Interface weicht vom getesteten Ziel ab",
    INFO_NOTICE="ComfyGatherer speichert deine eigenen Sammelfunde in ComfyData. Bewegung, Sammeln oder Routen werden nicht automatisiert.",
    INFO_THANKS="Danke, dass du ComfyGatherer nutzt! Feedback und Fehlermeldungen sind über Discord willkommen.",
    TRACK_HERBS="Kräuterkunde tracken",TRACK_MINING="Bergbau tracken",TRACK_SKINNING="Kürschnerei tracken",
    TRACK_OTHER="Andere Handwerkswaren tracken",SHOW_MINIMAP="Minimap-Punkte anzeigen",SHOW_TOOLTIP="Sammelhistorie im Item-Tooltip anzeigen",
    PIN_SIZE="Größe der Minimap-Punkte",MAX_PINS="Maximale nahe Punkte",DATABASE="Datenbank",
    STATS_FORMAT="%d Sammelstellen · %d Items · %d insgesamt gesammelt",
    FOREVER_NOTE="0.1 lernt nur aus deinen eigenen Funden. Minimap-Punkte nutzen gespeicherte Kartenkoordinaten, wenn Forever die benötigten Karten-/Weltpositions-APIs bereitstellt.",
}
local S=de and DE or EN
function A:T(k) return S[k] or EN[k] or k end
