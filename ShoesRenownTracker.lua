local addonName, scope = ...

local SRT = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0")

local AceGUI = LibStub("AceGUI-3.0")
local iconSize = 40
local isOpen = false

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
    local covColorTable = _G.COVENANT_COLORS
    local r, g, b = covColorTable[id]:GetRGB()
    return r, g, b
end

local function GetClassColor(class)
    local classColorTable = _G.RAID_CLASS_COLORS
    local r, g, b = classColorTable[class]:GetRGB()
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

AceGUI:RegisterLayout("RenownHeaderFrameRows", function(content, children)
    if children[1] then
        children[1]:SetWidth(120)
        children[1].frame:ClearAllPoints()
        children[1].frame:SetPoint("LEFT", content, "LEFT", 3, -5)
        children[1].frame:Show()
    end
    if children[2] then
        children[2]:SetWidth(60)
        children[2].frame:ClearAllPoints()
        children[2].frame:SetPoint("CENTER", content, "LEFT", 240, -5)
        children[2].frame:Show()
    end
    if children[3] then
        children[3]:SetWidth(60)
        children[3].frame:ClearAllPoints()
        children[3].frame:SetPoint("CENTER", content, "LEFT", 380, -5)
        children[3].frame:Show()
    end
    if children[4] then
        children[4]:SetWidth(60)
        children[4].frame:ClearAllPoints()
        children[4].frame:SetPoint("CENTER", content, "LEFT", 520, -5)
        children[4].frame:Show()
    end
    if children[5] then
        children[5]:SetWidth(60)
        children[5].frame:ClearAllPoints()
        children[5].frame:SetPoint("CENTER", content, "LEFT", 660, -5)
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
        children[2].frame:SetPoint("CENTER", content, "LEFT", 232, -2)
        children[2].frame:Show()
    end
    if children[3] then
        children[3]:SetWidth(60)
        children[3].frame:ClearAllPoints()
        children[3].frame:SetPoint("CENTER", content, "LEFT", 372, -2)
        children[3].frame:Show()
    end
    if children[4] then
        children[4]:SetWidth(60)
        children[4].frame:ClearAllPoints()
        children[4].frame:SetPoint("CENTER", content, "LEFT", 512, -2)
        children[4].frame:Show()
    end
    if children[5] then
        children[5]:SetWidth(60)
        children[5].frame:ClearAllPoints()
        children[5].frame:SetPoint("CENTER", content, "LEFT", 653, -2)
        children[5].frame:Show()
    end
end)

function SRT:GetScrollData()
    local scrollFrame = AceGUI:Create("ScrollFrame")
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
        charFrame.highlight:Hide()
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
            covBtn:SetJustifyH("MIDDLE")
            covBtn:SetJustifyV("CENTER")
            covBtn:SetFont(_G.STANDARD_TEXT_FONT, 14)
            if charTable.data.covenants[i].renown ~= "N/A" then
                covBtn:SetColor(cr, cg, cb)
            else
                covBtn:SetColor(0.3, 0.3, 0.3)
            end
            charFrame:AddChild(covBtn)
        end
        charFrame:SetLayout("RenownScrollFrameRows")
        charFrame:SetFullWidth(true)
        charFrame:SetHeight(26)  
        scrollFrame:AddChild(charFrame)
    end
    scrollFrame:SetFullWidth(true)
    scrollFrame:SetLayout("Flow")
    return scrollFrame
end

local function DrawRenownGroup(container)
    container:PauseLayout()
    local renownGroup = AceGUI:Create("SimpleGroup")
    
    local blankLabel = AceGUI:Create("Label")
    blankLabel:SetText(" ")

    local kyrianIcon = AceGUI:Create("Icon")
    kyrianIcon:SetImage(3257748)
    kyrianIcon:SetImageSize(iconSize, iconSize)
    kyrianIcon:SetLabel("Kyrian")

    local venthyrIcon = AceGUI:Create("Icon")
    venthyrIcon:SetImage(3257751)
    venthyrIcon:SetImageSize(iconSize, iconSize)
    venthyrIcon:SetLabel("Venthyr")

    local faeIcon = AceGUI:Create("Icon")
    faeIcon:SetImage(3257750)
    faeIcon:SetImageSize(iconSize, iconSize)
    faeIcon:SetLabel("Night Fae")

    local necroIcon = AceGUI:Create("Icon")
    necroIcon:SetImage(3257749)
    necroIcon:SetImageSize(iconSize, iconSize)
    necroIcon:SetLabel("Necrolord")

    

    
    local scrollContainer = AceGUI:Create("InlineGroup")
    scrollContainer:SetFullWidth(true)
    scrollContainer:SetFullHeight(true)
    scrollContainer:SetLayout("Fill")

    local scroll = SRT:GetScrollData()
    scrollContainer:AddChild(scroll)

    renownGroup:AddChild(blankLabel)
    renownGroup:AddChild(kyrianIcon)
    renownGroup:AddChild(venthyrIcon)
    renownGroup:AddChild(faeIcon)
    renownGroup:AddChild(necroIcon)
    renownGroup:SetFullWidth(true)
    renownGroup:SetHeight(iconSize)
    renownGroup.frame:ClearBackdrop()
    renownGroup:SetLayout("RenownHeaderFrameRows")

    container:AddChild(renownGroup)
    container:AddChild(scrollContainer)
    container:ResumeLayout()
    container:DoLayout()
    
end

local function SelectGroup(container, event, group)
    container:ReleaseChildren()
    if group == "renownTab" then
        DrawRenownGroup(container)
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
    self.nameRow:SetList(self:GetDropdownData())
    self.nameRow:SetCallback("OnValueChanged", function(valueTable) 
        self.currRealm = valueTable.text:GetText()
        SelectGroup(self.tabGroup, nil, self.currTab)
    end)

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