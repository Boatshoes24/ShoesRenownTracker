local addonName, scope = ...

local SRT = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local iconSize = 40
local isOpen = false

local COVENANT_COLORS = _G.COVENANT_COLORS
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS

local dungeonData = {
    {id = 381, name = "SOA", color = {COVENANT_COLORS[1]:GetRGB()}},
    {id = 376, name = "NW", color = {COVENANT_COLORS[1]:GetRGB()}},
    {id = 378, name = "HOA", color = {COVENANT_COLORS[2]:GetRGB()}},
    {id = 380, name = "SD", color = {COVENANT_COLORS[2]:GetRGB()}},
    {id = 375, name = "MOTS", color = {COVENANT_COLORS[3]:GetRGB()}},    
    {id = 377, name = "DOS", color = {COVENANT_COLORS[3]:GetRGB()}},    
    {id = 379, name = "PF", color = {COVENANT_COLORS[4]:GetRGB()}},    
    {id = 382, name = "TOP", color = {COVENANT_COLORS[4]:GetRGB()}},
    {id = 391, name = "TAZ1", color = {1, 1, 0}},
    {id = 392, name = "TAZ2", color = {1, 1, 0}}
}

local defaults = {
    global = {
        chars = {},
    }
}

local characterDefaults = {
    ["covenants"] = {
        [1] = {
            ["name"] = "Kyrian",
            ["renown"] = "N/A"
        },
        [2] = {
            ["name"] = "Venthyr",
            ["renown"] = "N/A"
        },
        [3] = {
            ["name"] = "Night Fae",
            ["renown"] = "N/A"
        },
        [4] = {
            ["name"] = "Necrolord",
            ["renown"] = "N/A"
        }
    },
    ["mplus"] = {
        [377] = {
            ["fortified"] = "N/A",
            ["tyrannical"] = "N/A",
            ["name"] = "DOS"
        },
        [378] = {
            ["fortified"] = "N/A",
            ["tyrannical"] = "N/A",
            ["name"] = "HOA"
        },
        [375] = {
            ["fortified"] = "N/A",
            ["tyrannical"] = "N/A",
            ["name"] = "MOTS"
        },
        [379] = {
            ["fortified"] = "N/A",
            ["tyrannical"] = "N/A",
            ["name"] = "PF"
        },
        [380] = {
            ["fortified"] = "N/A",
            ["tyrannical"] = "N/A",
            ["name"] = "SD"
        },
        [381] = {
            ["fortified"] = "N/A",
            ["tyrannical"] = "N/A",
            ["name"] = "SOA"
        },
        [376] = {
            ["fortified"] = "N/A",
            ["tyrannical"] = "N/A",
            ["name"] = "NW"
        },
        [382] = {
            ["fortified"] = "N/A",
            ["tyrannical"] = "N/A",
            ["name"] = "TOP"
        },
        [391] = {
            ["fortified"] = "N/A",
            ["tyrannical"] = "N/A",
            ["name"] = "TAZ1"
        },
        [392] = {
            ["fortified"] = "N/A",
            ["tyrannical"] = "N/A",
            ["name"] = "TAZ2"
        },
    },
    ["class"] = "N/A"    
}

local function GetCharName()
    local name = UnitName("player")
    local realm = GetRealmName("player")
    -- local charName = ("%s-%s"):format(
    --     UnitName("player"), 
    --     GetRealmName("player")
    -- )
    return name, realm
end

local function GetCovenantInfo()
    local covenantID = C_Covenants.GetActiveCovenantID()
    if covenantID then
        local covenantData = C_Covenants.GetCovenantData(covenantID)
        local renownLevel = C_CovenantSanctumUI.GetRenownLevel()
        return covenantData, renownLevel
    end
end

local function GetCovenantColorCode(id)
    local r, g, b = COVENANT_COLORS[id]:GetRGB()
    return r, g, b
end

local function GetClassColor(class)
    local r, g, b = RAID_CLASS_COLORS[class]:GetRGB()
    return r, g, b
end

function SRT:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ShoesRenownTrackerDB", defaults, true)   

    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("COVENANT_CHOSEN")
    self:RegisterEvent("COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED")
    self:RegisterEvent("GOSSIP_CONFIRM")
    self:RegisterEvent("PLAYER_CHOICE_UPDATE")
    self:RegisterChatCommand("srt", "SlashCommands")
end

function SRT:SlashCommands(input)
    if #input ~= 0 then
        self:Print("No addtional options available. Use only /srt.")
    else
        if not isOpen then
            self:OpenWindow()
        else
            isOpen = true
            self:Print("Window is already open.")
            return
        end
    end
end

function SRT:PLAYER_LOGIN()

    local covID = C_Covenants.GetActiveCovenantID()
    if covID == 0 then
        self:Print("No active covenant detected. Character skipped.")
    else
        self.currTab = "renownTab"
        local charName, charRealm = GetCharName()

        self.currRealm = charRealm

        if not self.db.global.chars[charRealm] then
            self.db.global.chars[charRealm] = {}
        end

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
        local charName, charRealm = GetCharName()

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

function SRT:AddData(charName, charRealm)   
    local covenantData, renownLevel = GetCovenantInfo()         
    self.db.global.chars[charRealm][charName].covenants[covenantData.ID] = {
        name = covenantData.name,
        renown = renownLevel,
    }

    for k, v in ipairs(dungeonData) do
        local mapData = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(v.id)     
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

function SRT:GOSSIP_CONFIRM(event, _, gossipText)
    if gossipText:find("This path will lead to you leaving your current covenant") then
        local charName, charRealm = GetCharName()
        local covenantData, renownLevel = GetCovenantInfo()
        self.db.global.chars[charRealm][charName].covenants[covenantData.ID].renown = renownLevel
    end
end

function SRT:COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED(event, new, prev)
    C_Timer.After(1.5, function() 
        local charName, charRealm = GetCharName()
        local covenantData, renownLevel = GetCovenantInfo()
        self.db.global.chars[charRealm][charName].covenants[covenantData.ID].renown = new
    end)
end

function SRT:COVENANT_CHOSEN(event, cov)
    local charName, charRealm = GetCharName()
    self:AddData(charName, charRealm)
end

function SRT:GetDropdownData()
    local dropdownList = {}
    for realm, _ in pairs(self.db.global.chars) do
        table.insert(dropdownList, realm)
    end
    return dropdownList
end

AceGUI:RegisterLayout("MPlusHeaderFrameRows", function(content, children)
    if children[1] then
        children[1]:SetWidth(120)
        children[1].frame:ClearAllPoints()
        children[1].frame:SetPoint("LEFT", content, "LEFT", 3, -2)
        children[1].frame:Show()
    end
    if children[2] then
        children[2]:SetWidth(50)
        children[2].frame:ClearAllPoints()
        children[2].frame:SetPoint("LEFT", content, "LEFT", 135, -2)
        children[2].frame:Show()
    end
    if children[3] then
        children[3]:SetWidth(50)
        children[3].frame:ClearAllPoints()
        children[3].frame:SetPoint("LEFT", content, "LEFT", 194, -2)
        children[3].frame:Show()
    end
    if children[4] then
        children[4]:SetWidth(50)
        children[4].frame:ClearAllPoints()
        children[4].frame:SetPoint("LEFT", content, "LEFT", 253, -2)
        children[4].frame:Show()
    end
    if children[5] then
        children[5]:SetWidth(50)
        children[5].frame:ClearAllPoints()
        children[5].frame:SetPoint("LEFT", content, "LEFT", 312, -2)
        children[5].frame:Show()
    end
    if children[6] then
        children[6]:SetWidth(50)
        children[6].frame:ClearAllPoints()
        children[6].frame:SetPoint("LEFT", content, "LEFT", 371, -2)
        children[6].frame:Show()
    end
    if children[7] then
        children[7]:SetWidth(50)
        children[7].frame:ClearAllPoints()
        children[7].frame:SetPoint("LEFT", content, "LEFT", 430, -2)
        children[7].frame:Show()
    end
    if children[8] then
        children[8]:SetWidth(50)
        children[8].frame:ClearAllPoints()
        children[8].frame:SetPoint("LEFT", content, "LEFT", 489, -2)
        children[8].frame:Show()
    end
    if children[9] then
        children[9]:SetWidth(50)
        children[9].frame:ClearAllPoints()
        children[9].frame:SetPoint("LEFT", content, "LEFT", 548, -2)
        children[9].frame:Show()
    end
    if children[10] then
        children[10]:SetWidth(50)
        children[10].frame:ClearAllPoints()
        children[10].frame:SetPoint("LEFT", content, "LEFT", 607, -2)
        children[10].frame:Show()
    end
    if children[11] then
        children[11]:SetWidth(50)
        children[11].frame:ClearAllPoints()
        children[11].frame:SetPoint("LEFT", content, "LEFT", 666, -2)
        children[11].frame:Show()
    end
end)

AceGUI:RegisterLayout("MPlusScrollFrameRows", function(content, children)
    if children[1] then
        children[1]:SetWidth(120)
        children[1].frame:ClearAllPoints()
        children[1].frame:SetPoint("LEFT", content, "LEFT", 3, -2)
        children[1].frame:Show()
    end
    if children[2] then
        children[2]:SetWidth(50)
        children[2].frame:ClearAllPoints()
        children[2].frame:SetPoint("LEFT", content, "LEFT", 130, -2)
        children[2].frame:Show()
    end
    if children[3] then
        children[3]:SetWidth(50)
        children[3].frame:ClearAllPoints()
        children[3].frame:SetPoint("LEFT", content, "LEFT", 189, -2)
        children[3].frame:Show()
    end
    if children[4] then
        children[4]:SetWidth(50)
        children[4].frame:ClearAllPoints()
        children[4].frame:SetPoint("LEFT", content, "LEFT", 248, -2)
        children[4].frame:Show()
    end
    if children[5] then
        children[5]:SetWidth(50)
        children[5].frame:ClearAllPoints()
        children[5].frame:SetPoint("LEFT", content, "LEFT", 307, -2)
        children[5].frame:Show()
    end
    if children[6] then
        children[6]:SetWidth(50)
        children[6].frame:ClearAllPoints()
        children[6].frame:SetPoint("LEFT", content, "LEFT", 366, -2)
        children[6].frame:Show()
    end
    if children[7] then
        children[7]:SetWidth(50)
        children[7].frame:ClearAllPoints()
        children[7].frame:SetPoint("LEFT", content, "LEFT", 425, -2)
        children[7].frame:Show()
    end
    if children[8] then
        children[8]:SetWidth(50)
        children[8].frame:ClearAllPoints()
        children[8].frame:SetPoint("LEFT", content, "LEFT", 484, -2)
        children[8].frame:Show()
    end
    if children[9] then
        children[9]:SetWidth(50)
        children[9].frame:ClearAllPoints()
        children[9].frame:SetPoint("LEFT", content, "LEFT", 543, -2)
        children[9].frame:Show()
    end
    if children[10] then
        children[10]:SetWidth(50)
        children[10].frame:ClearAllPoints()
        children[10].frame:SetPoint("LEFT", content, "LEFT", 602, -2)
        children[10].frame:Show()
    end
    if children[11] then
        children[11]:SetWidth(50)
        children[11].frame:ClearAllPoints()
        children[11].frame:SetPoint("LEFT", content, "LEFT", 661, -2)
        children[11].frame:Show()
    end
end)

function SRT:GetMPlusData(flag)
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:PauseLayout()

    local sorted = {}
    for k, v in pairs(self.db.global.chars[self.currRealm]) do
        local temp = {char = k, data = v}
        table.insert(sorted, temp)
    end
    table.sort(sorted, function(a, b) 
        return a.char < b.char
    end)
  
    for idx, charTable in ipairs(sorted) do
        local charFrame = AceGUI:Create("SimpleGroup")
        local r, g, b = GetClassColor(charTable.data.class)

        charFrame.highlight = charFrame.frame:CreateTexture()
        charFrame.highlight:SetTexture([[Interface\Buttons\WHITE8X8]])
        charFrame.highlight:SetVertexColor(r, g, b, 0.1)
        charFrame.highlight:SetAllPoints(true)
        --charFrame.highlight:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_White")        
        charFrame.frame:SetScript("OnEnter", function() charFrame.highlight:Show() end)
        charFrame.frame:SetScript("OnLeave", function() charFrame.highlight:Hide() end)

        local charHeading = AceGUI:Create("Label")
        charHeading:SetText(charTable.char)        
        charHeading:SetColor(r, g, b)
        charHeading:SetJustifyH("LEFT")
        charHeading:SetJustifyV("MIDDLE")
        charHeading:SetFont(_G.STANDARD_TEXT_FONT, 14)
        
        charFrame:AddChild(charHeading)
        for k, v in ipairs(dungeonData) do
            --local cr, cg, cb = GetCovenantColorCode(i)
            local keyLevelLabel = AceGUI:Create("Label")
            if flag == "fortified" then
                keyLevelLabel:SetText(charTable.data.mplus[v.id].fortified)
                keyLevelLabel:SetJustifyH("CENTER")
                keyLevelLabel:SetJustifyV("MIDDLE")
                keyLevelLabel:SetFont(_G.STANDARD_TEXT_FONT, 14)
                if charTable.data.mplus[v.id].fortified ~= "N/A" then
                    if charTable.data.mplus[v.id].fortified < 20 then
                        keyLevelLabel:SetColor(0.76, 0.09, 1)
                    elseif charTable.data.mplus[v.id].fortified < 15 then
                        keyLevelLabel:SetColor(0.09, 0.51, 1)
                    elseif charTable.data.mplus[v.id].fortified < 10 then
                        keyLevelLabel:SetColor(0.09, 1, 0.44)
                    elseif charTable.data.mplus[v.id].fortified < 5 then
                        keyLevelLabel:SetColor(0.47, 0.47, 0.47)
                    else
                        keyLevelLabel:SetColor(1, 0.59, 0.09)
                    end
                else
                    keyLevelLabel:SetColor(0.29, 0.29, 0.29)
                end
            elseif flag == "tyrannical" then
                keyLevelLabel:SetText(charTable.data.mplus[v.id].tyrannical)
                keyLevelLabel:SetJustifyH("CENTER")
                keyLevelLabel:SetJustifyV("MIDDLE")
                keyLevelLabel:SetFont(_G.STANDARD_TEXT_FONT, 14)
                if charTable.data.mplus[v.id].tyrannical ~= "N/A" then
                    if charTable.data.mplus[v.id].tyrannical < 20 then
                        keyLevelLabel:SetColor(0.76, 0.09, 1)
                    elseif charTable.data.mplus[v.id].tyrannical < 15 then
                        keyLevelLabel:SetColor(0.09, 0.51, 1)
                    elseif charTable.data.mplus[v.id].tyrannical < 10 then
                        keyLevelLabel:SetColor(0.09, 1, 0.44)
                    elseif charTable.data.mplus[v.id].tyrannical < 5 then
                        keyLevelLabel:SetColor(0.47, 0.47, 0.47)
                    else
                        keyLevelLabel:SetColor(1, 0.59, 0.09)
                    end
                else
                    keyLevelLabel:SetColor(0.29, 0.29, 0.29)
                end
            end
            charFrame:AddChild(keyLevelLabel)
        end
        charFrame.highlight:Hide()
        charFrame:SetLayout("MPlusScrollFrameRows")
        charFrame:SetFullWidth(true)
        charFrame:SetHeight(26)  
        scrollFrame:AddChild(charFrame)
    end
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetLayout("Flow")
    scrollFrame:ResumeLayout()
    scrollFrame:DoLayout()
    return scrollFrame
end

local function DrawMPlusGroup(container, flag)    
    local mplusHeader = AceGUI:Create("InlineGroup")
    container:PauseLayout()   
    
    local blankLabel = AceGUI:Create("Label")
    blankLabel:SetText(" ")
    blankLabel:SetJustifyH("CENTER")
    blankLabel:SetJustifyV("MIDDLE")
    mplusHeader:AddChild(blankLabel)

    for k, v in ipairs(dungeonData) do
        local mplusLabel = AceGUI:Create("Label")
        mplusLabel:SetText(v.name)        
        mplusLabel:SetColor(unpack(v.color))
        mplusLabel:SetJustifyH("CENTER")
        mplusLabel:SetJustifyV("MIDDLE")
        mplusLabel:SetFont(_G.STANDARD_TEXT_FONT, 14)
        mplusHeader:AddChild(mplusLabel)
    end
    
    local scrollContainer = AceGUI:Create("InlineGroup")
    scrollContainer:SetFullWidth(true)
    scrollContainer:SetFullHeight(true)
    scrollContainer:SetLayout("Fill")

    local scroll = SRT:GetMPlusData(flag)
    scrollContainer:AddChild(scroll)

    mplusHeader:SetFullWidth(true)
    mplusHeader:SetHeight(10) 
    mplusHeader:SetLayout("MPlusHeaderFrameRows")

    for i = 1, mplusHeader.frame:GetNumChildren() do
        local child = select(i, mplusHeader.frame:GetChildren())
        child:ClearBackdrop()
    end

    container:AddChild(mplusHeader)
    container:AddChild(scrollContainer)
    container:ResumeLayout()
    container:DoLayout()    
end

AceGUI:RegisterLayout("RenownHeaderFrameRows", function(content, children)
    if children[1] then
        children[1]:SetWidth(120)
        children[1].frame:ClearAllPoints()
        children[1].frame:SetPoint("LEFT", content, "LEFT", 3, 3)
        children[1].frame:Show()
    end
    if children[2] then
        children[2]:SetWidth(60)
        children[2].frame:ClearAllPoints()
        children[2].frame:SetPoint("LEFT", content, "LEFT", 237, 3)
        children[2].frame:Show()
    end
    if children[3] then
        children[3]:SetWidth(60)
        children[3].frame:ClearAllPoints()
        children[3].frame:SetPoint("LEFT", content, "LEFT", 377, 3)
        children[3].frame:Show()
    end
    if children[4] then
        children[4]:SetWidth(60)
        children[4].frame:ClearAllPoints()
        children[4].frame:SetPoint("LEFT", content, "LEFT", 517, 3)
        children[4].frame:Show()
    end
    if children[5] then
        children[5]:SetWidth(60)
        children[5].frame:ClearAllPoints()
        children[5].frame:SetPoint("LEFT", content, "LEFT", 658, 3)
        children[5].frame:Show()
    end
end)

AceGUI:RegisterLayout("RenownScrollFrameRows", function(content, children)
    if children[1] then
        children[1]:SetWidth(120)
        children[1].frame:ClearAllPoints()
        children[1].frame:SetPoint("LEFT", content, "LEFT", 3, -2)
        children[1].frame:Show()
    end
    if children[2] then
        children[2]:SetWidth(60)
        children[2].frame:ClearAllPoints()
        children[2].frame:SetPoint("LEFT", content, "LEFT", 232, -2)
        children[2].frame:Show()
    end
    if children[3] then
        children[3]:SetWidth(60)
        children[3].frame:ClearAllPoints()
        children[3].frame:SetPoint("LEFT", content, "LEFT", 372, -2)
        children[3].frame:Show()
    end
    if children[4] then
        children[4]:SetWidth(60)
        children[4].frame:ClearAllPoints()
        children[4].frame:SetPoint("LEFT", content, "LEFT", 512, -2)
        children[4].frame:Show()
    end
    if children[5] then
        children[5]:SetWidth(60)
        children[5].frame:ClearAllPoints()
        children[5].frame:SetPoint("LEFT", content, "LEFT", 653, -2)
        children[5].frame:Show()
    end
end)

function SRT:GetRenownData()
    local scrollFrame = AceGUI:Create("ScrollFrame")
    scrollFrame:PauseLayout()
    --[[
        covenant ids
        1 - Kyrian
        2 - Venthyr
        3 - Night Fae
        4 - Necrolord
    ]]--
    local sorted = {}
    for k, v in pairs(self.db.global.chars[self.currRealm]) do
        local temp = {char = k, data = v}
        table.insert(sorted, temp)
    end
    table.sort(sorted, function(a, b) 
        return a.char < b.char
    end)
  
    for idx, charTable in ipairs(sorted) do
        local charFrame = AceGUI:Create("SimpleGroup")
        local r, g, b = GetClassColor(charTable.data.class)

        charFrame.highlight = charFrame.frame:CreateTexture(nil, "BACKGROUND")
        charFrame.highlight:SetAllPoints(true)
        --charFrame.highlight:SetTexture("Interface\\AddOns\\WeakAuras\\Media\\Textures\\Square_White")
        charFrame.highlight:SetTexture([[Interface\Buttons\WHITE8X8]])
        charFrame.highlight:SetVertexColor(r, g, b, 0.1)
        charFrame.frame:SetScript("OnEnter", function() charFrame.highlight:Show() end)
        charFrame.frame:SetScript("OnLeave", function() charFrame.highlight:Hide() end)

        local charHeading = AceGUI:Create("Label")
        charHeading:SetText(charTable.char)        
        charHeading:SetColor(r, g, b)
        charHeading:SetJustifyH("LEFT")
        charHeading:SetJustifyV("CENTER")
        charHeading:SetFont(_G.STANDARD_TEXT_FONT, 14)
        
        charFrame:AddChild(charHeading)
        for i = 1, 4 do
            local cr, cg, cb = GetCovenantColorCode(i)
            local covBtn = AceGUI:Create("Label")
            covBtn:SetText(charTable.data.covenants[i].renown)
            covBtn:SetJustifyH("CENTER")
            covBtn:SetJustifyV("MIDDLE")
            covBtn:SetFont(_G.STANDARD_TEXT_FONT, 14)
            if charTable.data.covenants[i].renown ~= "N/A" then
                covBtn:SetColor(cr, cg, cb)
            else
                covBtn:SetColor(0.29, 0.29, 0.29)
            end
            charFrame:AddChild(covBtn)
        end
        charFrame.highlight:Hide()
        charFrame:SetLayout("RenownScrollFrameRows")
        charFrame:SetFullWidth(true)
        charFrame:SetHeight(26)  
        scrollFrame:AddChild(charFrame)
    end
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetLayout("Flow")
    scrollFrame:ResumeLayout()
    scrollFrame:DoLayout()
    return scrollFrame
end

local function DrawRenownGroup(container)    
    local renownHeader = AceGUI:Create("InlineGroup")
    container:PauseLayout()
    
    local blankLabel = AceGUI:Create("Label")
    blankLabel:SetText(" ")
    blankLabel:SetJustifyH("CENTER")
    blankLabel:SetJustifyV("MIDDLE")
    renownHeader:AddChild(blankLabel)

    local kyrianIcon = AceGUI:Create("Icon")
    kyrianIcon:SetImage(3257748)
    kyrianIcon:SetImageSize(iconSize, iconSize)
    kyrianIcon:SetLabel("Kyrian")
    kyrianIcon.label:SetTextColor(COVENANT_COLORS[1]:GetRGB())

    local venthyrIcon = AceGUI:Create("Icon")
    venthyrIcon:SetImage(3257751)
    venthyrIcon:SetImageSize(iconSize, iconSize)
    venthyrIcon:SetLabel("Venthyr")
    venthyrIcon.label:SetTextColor(COVENANT_COLORS[2]:GetRGB())

    local faeIcon = AceGUI:Create("Icon")
    faeIcon:SetImage(3257750)
    faeIcon:SetImageSize(iconSize, iconSize)
    faeIcon:SetLabel("Night Fae")
    faeIcon.label:SetTextColor(COVENANT_COLORS[3]:GetRGB())

    local necroIcon = AceGUI:Create("Icon")
    necroIcon:SetImage(3257749)
    necroIcon:SetImageSize(iconSize, iconSize)
    necroIcon:SetLabel("Necrolord")
    necroIcon.label:SetTextColor(COVENANT_COLORS[4]:GetRGB())
    
    local scrollContainer = AceGUI:Create("InlineGroup")
    scrollContainer:SetFullWidth(true)
    scrollContainer:SetFullHeight(true)
    scrollContainer:SetLayout("Fill")

    local scroll = SRT:GetRenownData()
    scrollContainer:AddChild(scroll)

  
    renownHeader:AddChild(kyrianIcon)
    renownHeader:AddChild(venthyrIcon)
    renownHeader:AddChild(faeIcon)
    renownHeader:AddChild(necroIcon)

    renownHeader:SetFullWidth(true)
    renownHeader:SetHeight(iconSize)
    renownHeader:SetLayout("RenownHeaderFrameRows")

    for i = 1, renownHeader.frame:GetNumChildren() do
        local child = select(i, renownHeader.frame:GetChildren())
        child:ClearBackdrop()
    end

    container:AddChild(renownHeader)
    container:AddChild(scrollContainer)
    container:ResumeLayout()
    container:DoLayout()    
end

local function SelectGroup(container, event, group)
    container:ReleaseChildren()
    if group == "renownTab" then
        DrawRenownGroup(container)
    elseif group == "fortifiedTab" then
        DrawMPlusGroup(container, "fortified")
    elseif group == "tyrannicalTab" then
        DrawMPlusGroup(container, "tyrannical")
    end
    SRT.currTab = group
end

function SRT:OpenWindow()
    self.container = AceGUI:Create("Frame")
    self.container:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        isOpen = false
        local charName, charRealm = GetCharName()
        self.currRealm = charRealm
    end)
    self.container:SetTitle("Shoes Renown Tracker - Dev")
    self.container:SetLayout("Flow") 
    self.container:SetHeight(600)
    self.container:SetWidth(800)
    self.container:EnableResize(false)  

    self.nameRow = AceGUI:Create("Dropdown")
    self.nameRow:SetLabel("Realm")
    self.nameRow:SetText(self.currRealm)  
    self.nameRow:SetMultiselect(false)
    self.nameRow.text:SetJustifyH("LEFT")
    self.nameRow:SetList(self:GetDropdownData())
    self.nameRow:SetCallback("OnValueChanged", function(valueTable, null, value)
        self.currRealm = valueTable.text:GetText()
        self.nameRow:SetValue(value)
        self.tabGroup:ReleaseChildren()
        SelectGroup(self.tabGroup, nil, self.currTab)
    end)
 
    local realmIdx = 1
    for k, v in ipairs(self.nameRow.list) do
         if v == self.currRealm then
            realmIdx = k
         end
    end
    self.nameRow:SetValue(realmIdx)

    self.container:AddChild(self.nameRow)    

    self.tabGroup = AceGUI:Create("TabGroup")
    self.tabGroup:SetLayout("Flow")
    self.tabGroup:SetFullWidth(true)
    self.tabGroup:SetAutoAdjustHeight(false)
    self.tabGroup:SetHeight(480)
    self.tabGroup:SetTabs({
        {text="Renown", value="renownTab"},
        {text="M+ Fort", value="fortifiedTab"},
        {text="M+ Tyr", value="tyrannicalTab"}
    })
    
    self.tabGroup:SetCallback("OnGroupSelected", SelectGroup)
    self.tabGroup:SelectTab("renownTab") 

    self.container:AddChild(self.tabGroup)

    isOpen = true
end