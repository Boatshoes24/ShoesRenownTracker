local SRT = unpack(ShoesRenownTracker)
local addon = ...

local _G = _G
local COVENANT_COLORS = _G.COVENANT_COLORS
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitName = UnitName
local GetRealmName = GetRealmName
local  C_MythicPlus_GetSeasonBestAffixScoreInfoForMap =  C_MythicPlus.GetSeasonBestAffixScoreInfoForMap
local C_Covenants_GetActiveCovenantID = C_Covenants.GetActiveCovenantID
local C_Covenants_GetCovenantData = C_Covenants.GetCovenantData
local C_CovenantSanctumUI_GetRenownLevel = C_CovenantSanctumUI.GetRenownLevel

local dungeonData = SRT.dungeonData

function SRT:GetCharName()
    local name = UnitName("player")
    local realm = GetRealmName("player")

    return name, realm
end

function SRT:GetCovenantInfo()
    local covenantID = C_Covenants_GetActiveCovenantID()
    if covenantID then
        local covenantData = C_Covenants_GetCovenantData(covenantID)
        local renownLevel = C_CovenantSanctumUI_GetRenownLevel()
        return covenantData, renownLevel
    end
end

function SRT:GetCovenantColorCode(id)
    local r, g, b = COVENANT_COLORS[id]:GetRGB()
    return r, g, b
end

function SRT:GetClassColor(class)
    local r, g, b = RAID_CLASS_COLORS[class]:GetRGB()
    return r, g, b
end

function SRT:AddData(charName, charRealm)   
    local covenantData, renownLevel = self:GetCovenantInfo()         
    self.db.global.chars[charRealm][charName].covenants[covenantData.ID] = {
        name = covenantData.name,
        renown = renownLevel,
    }

    for k, v in ipairs(dungeonData) do
        local mapData = C_MythicPlus_GetSeasonBestAffixScoreInfoForMap(v.id)     
        if mapData then
            for i, j in ipairs(mapData) do
                if mapData[i].name == "Fortified" then
                    self.db.global.chars[charRealm][charName].mplus[v.id].fortified = mapData[i].level
                end
                if mapData[i].name == "Tyrannical" then
                    self.db.global.chars[charRealm][charName].mplus[v.id].tyrannical = mapData[i].level
                end
            end
        end
    end
end

function SRT:RefreshMPlusData(charName, charRealm)
    for k, v in ipairs(dungeonData) do
        local mapData = C_MythicPlus_GetSeasonBestAffixScoreInfoForMap(v.id)     
        if mapData then
            for i, j in ipairs(mapData) do
                if mapData[i].name == "Fortified" then
                    self.db.global.chars[charRealm][charName].mplus[v.id].fortified = mapData[i].level
                end
                if mapData[i].name == "Tyrannical" then
                    self.db.global.chars[charRealm][charName].mplus[v.id].tyrannical = mapData[i].level
                end
            end
        end
    end
end

function SRT:GetDropdownData()
    local dropdownList = {}
    for realm, _ in pairs(self.db.global.chars) do
        table.insert(dropdownList, realm)
    end
    return dropdownList
end