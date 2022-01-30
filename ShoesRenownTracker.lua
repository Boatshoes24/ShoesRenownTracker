local _, Engine = ...
local SRT = LibStub("AceAddon-3.0"):NewAddon("ShoesRenownTracker", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0")

local _G = _G
local GetAddOnMetadata = GetAddOnMetadata
local COVENANT_COLORS = _G.COVENANT_COLORS

Engine[1] = SRT
_G.ShoesRenownTracker = Engine

SRT.Title = GetAddOnMetadata(..., "Title")
SRT.Version = GetAddOnMetadata(..., "Version")
SRT.Author = GetAddOnMetadata(..., "Author")
SRT.IsOpen = false

local defaults = {
    global = {
        chars = {},
    }
}

function SRT:SlashCommands(input)
    if #input ~= 0 then
        self:Print("No addtional options available. Use only /srt.")
    else
        if not self.IsOpen then
            self:OpenWindow()
        else
            self.IsOpen = true
            self:Print("Window is already open.")
            return
        end
    end
end

function SRT:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ShoesRenownTrackerDB", defaults, true)   

    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("COVENANT_CHOSEN")
    self:RegisterEvent("COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED")
    self:RegisterEvent("GOSSIP_CONFIRM")
    self:RegisterEvent("PLAYER_CHOICE_UPDATE")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
    self:RegisterChatCommand("srt", "SlashCommands")
end

