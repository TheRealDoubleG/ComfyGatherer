local ADDON_NAME = ...

ComfyGatherer = ComfyGatherer or {}
local A = ComfyGatherer

A.name = ADDON_NAME or "ComfyGatherer"
A.version = "0.4"
A.buildDate = "28.09.2026"
A.status = "Beta"
A.gameVersion = "WoW Forever 1.60.1"
A.targetBuild = "70009"
A.interface = 16001
A.author = "TheRealDoubleG"
A.discord = "the.real.double.g"
A.github = "https://github.com/TheRealDoubleG/ComfyGatherer"

local defaults = {
    enabled = true,
    gather = {
        trackHerbalism = true,
        trackMining = true,
        trackSkinning = true,
        trackOther = false,
        showMinimapPins = true,
        showItemTooltip = true,
        pinSize = 14,
        maxPins = 50,
    },
    optionsWindow = {point="CENTER",relativePoint="CENTER",x=0,y=20},
    ui = {windowLocked=false,windowOpacity=100,showWindowBorder=true,backgroundAlpha=92},
}

function A:Print(msg)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cffffd200ComfyGatherer:|r "..tostring(msg)) end
end

function A:GetClientBuildInfo()
    if type(GetBuildInfo)~="function" then return "?","?","?",nil end
    local v,b,d,i=GetBuildInfo()
    return tostring(v or "?"),tostring(b or "?"),tostring(d or "?"),tonumber(i)
end

function A:GetCompatibilityStatus()
    local _,_,_,i=self:GetClientBuildInfo()
    if i and tonumber(i)==tonumber(self.interface) then return true,self:T("COMPAT_MATCH") end
    return false,self:T("COMPAT_UPDATE_REQUIRED")
end

function A:InitializeDB()
    self:InitializeProfileStorage(defaults,"ComfyGathererDB")
end

function A:SetEnabled(v)
    if not self.db then return false end
    self.db.enabled=v and true or false
    if self.RefreshFeature then self:RefreshFeature() end
    if self.RefreshOptions then self:RefreshOptions() end
    return true
end

function A:GetComfyProfileProvider() return self end
function A:OpenOptions() if self.ShowOptions then self:ShowOptions() end end

SLASH_COMFYGATHERER1="/comfygatherer"
SLASH_COMFYGATHERER2="/cgather"
SlashCmdList.COMFYGATHERER=function(msg)
    msg=tostring(msg or ""):lower():match("^%s*(.-)%s*$")
    if msg=="stats" and A.PrintStats then A:PrintStats(); return end
    A:OpenOptions()
end

local e=CreateFrame("Frame")
e:RegisterEvent("ADDON_LOADED")
e:RegisterEvent("PLAYER_LOGIN")
e:SetScript("OnEvent",function(_,ev,arg1)
    if ev=="ADDON_LOADED" and arg1==A.name then
        A:InitializeDB()
        if A.InitializeFeature then A:InitializeFeature() end
        if A.InitializeOptions then A:InitializeOptions() end
    elseif ev=="PLAYER_LOGIN" and A.RefreshFeature then
        A:RefreshFeature()
    end
end)
