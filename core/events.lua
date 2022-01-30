local SRT = unpack(ShoesRenownTracker)
local addon = ...

local _G = _G
local UnitClass = UnitClass
local C_Covenants_GetActiveCovenantID = C_Covenants.GetActiveCovenantID

local characterDefaults = SRT.characterDefaults

function SRT:PLAYER_LOGIN()
    local charName, charRealm = self:GetCharName()
    self.currRealm = charRealm    

        if not self.db.global.chars[charRealm] then
            self.db.global.chars[charRealm] = {}
        end

    local covID = C_Covenants_GetActiveCovenantID()
    if covID == 0 then
        self:Print("No active covenant detected. Character skipped.")
    else
        self.currTab = "renownTab"

        if not self.db.global.chars[charRealm][charName] then
            self.db.global.chars[charRealm][charName] = characterDefaults
        end

        if self.db.global.chars[charRealm][charName].class == "N/A" then
            local _, class = UnitClass("player")
            self.db.global.chars[charRealm][charName].class = class    
        end

        self:AddData(charName, charRealm)
        self:Print("Covenant detected. Character updated.")
    end
end

function SRT:PLAYER_CHOICE_UPDATE()
    if _G.PlayerChoiceFrame:IsShown() then
        local charName, charRealm = self:GetCharName()

        self.currRealm = charRealm

        if not self.db.global.chars[charRealm] then
            self.db.global.chars[charRealm] = {}
        end

        if not self.db.global.chars[charRealm][charName] then
            self.db.global.chars[charRealm][charName] = characterDefaults
            self:Print("Adding player to db.")
        end

        if self.db.global.chars[charRealm][charName].class == "N/A" then
            local _, class = UnitClass("player")
            self.db.global.chars[charRealm][charName].class = class    
        end
    end
end

function SRT:CHALLENGE_MODE_COMPLETED(event)
    local charName, charRealm = self:GetCharName()
    self:RefreshMPlusData(charName, charRealm)
end

function SRT:CHALLENGE_MODE_MAPS_UPDATE(event)
    local charName, charRealm = self:GetCharName()
    self:RefreshMPlusData(charName, charRealm)
end

function SRT:GOSSIP_CONFIRM(event, _, gossipText)
    if gossipText:find("This path will lead to you leaving your current covenant") then
        local charName, charRealm = self:GetCharName()
        local covenantData, renownLevel = self:GetCovenantInfo()
        self.db.global.chars[charRealm][charName].covenants[covenantData.ID].renown = renownLevel
    end
end

function SRT:COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED(event, new, prev)
    C_Timer.After(1.5, function() 
        local charName, charRealm = self:GetCharName()
        local covenantData, renownLevel = self:GetCovenantInfo()
        self.db.global.chars[charRealm][charName].covenants[covenantData.ID].renown = new
    end)
end

function SRT:COVENANT_CHOSEN(event, cov)
    local charName, charRealm = self:GetCharName()
    self:AddData(charName, charRealm)
end