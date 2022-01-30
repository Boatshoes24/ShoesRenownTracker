local SRT = unpack(ShoesRenownTracker)
local addon = ...

SRT.dungeonData = {
    {
        id = 381, 
        name = "SOA", 
        color = {COVENANT_COLORS[1]:GetRGB()},
        icon = 3759933
    },
    {
        id = 376, 
        name = "NW", 
        color = {COVENANT_COLORS[1]:GetRGB()}, 
        icon = 3759930
    },
    {
        id = 378, 
        name = "HOA", 
        color = {COVENANT_COLORS[2]:GetRGB()},
        icon = 3759928
    },
    {
        id = 380, 
        name = "SD", 
        color = {COVENANT_COLORS[2]:GetRGB()},
        icon = 3759932
    },
    {
        id = 375, 
        name = "MOTS", 
        color = {COVENANT_COLORS[3]:GetRGB()},
        icon = 3759929
    },    
    {
        id = 377, 
        name = "DOS", 
        color = {COVENANT_COLORS[3]:GetRGB()},
        icon = 3759935
    },    
    {
        id = 379, 
        name = "PF", 
        color = {COVENANT_COLORS[4]:GetRGB()},
        icon = 3759931
    },    
    {
        id = 382, 
        name = "TOP", 
        color = {COVENANT_COLORS[4]:GetRGB()},
        icon = 3759934
    },
    {
        id = 391, 
        name = "TAZ1", 
        color = {1, 1, 0},
        icon = 4181531 
    },
    {
        id = 392, 
        name = "TAZ2", 
        color = {1, 1, 0},
        icon = 4181531 
    }
}

SRT.characterDefaults = {
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