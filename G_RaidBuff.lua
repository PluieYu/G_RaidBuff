---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by yuyou.
--- DateTime: 2024/4/10 0:06
---

RaidBuff = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0","AceComm-2.0","AceDB-2.0","AceDebug-2.0","AceConsole-2.0","FuBarPlugin-2.0", "AceHook-2.1")
local L = AceLibrary("AceLocale-2.2"):new("RaidBuff")
RaidBuff.hasIcon = "Interface\\Icons\\INV_Misc_Candle_02"

function RaidBuff:OnInitialize()
    self:SetDebugLevel(3)
    self.Prefix =
    "|cffF5F54A["..base64:dec("5bCP55qu566x").."]|r|cff9482C9"..base64:dec("5Zui6ZifYnVmZuWKqeaJiw==").."|r"
    --self:SetDebugging(true)
    self:RegisterDB("RaidBuffDB")
    self:RegisterDefaults("profile", {
        xOfs = nil,
        yOfs = nil,
        point = nil,
        relativePoint = nil,
        PBuff = {},
        P2Buff = {},
        MBuff = {},
        DBuff = {},
    })
    self:OnProfileEnable()
    self.RBF=RaidBuffFrame
    self.RBF:OnInitialize()
    self:OnInitializeOption()
    self:SetCommPrefix(self.Prefix)
    self.OnMenuRequest = self.options
    self:RegisterChatCommand({"/RaidBuff", "/RB"}, self.options)
    DEFAULT_CHAT_FRAME:AddMessage(self.Prefix ..L["已加载"])
end
function RaidBuff:OnInitializeOption()
    self.options = {
        type = "group",
        args = {
            openFrame = {
                type = "execute",
                name = L["打开界面"],
                desc = L["打开界面描述"],
                order =1,
                func = function() self.RBF:ShowFrame() end,
            },
        }
    }


end

function RaidBuff:OnProfileEnable()
    self.opt = self.db.profile
end

function RaidBuff:OnEnable()
    self.RBF:OnEnable()
    self:RegisterComm(self.Prefix, "RAID")

    self:RegisterEvent("PARTY_MEMBERS_CHANGED", "Reflash")
    --self:RegisterEvent("PARTY_INVITE_CANCEL", "canceljoinParty")
end
function RaidBuff:OnDisable()
    self:UnregisterAllEvents()
end

function RaidBuff:OnCommReceive(prefix, sender, distribution, method, fileName,subgroup,targetName)
    if method =="UpdateManuel" then
        self.RBF:UpdateManuel(fileName,subgroup,targetName, true,true)
        if targetName then
            self:Print(format("<%s>分配《%s》加《%s》队%sbuff",sender,targetName,subgroup,L[fileName]))
        else
            self:Print(format("<%s>清除了《%s》队%sbuff的分配",sender,subgroup,L[fileName]))
        end
    elseif  method =="CleanBuff" then
        self:Print(format("<%s>清除了所有buff分配",sender))
        self.RBF:CleanBuff(true)
    elseif method =="Reflash" then
        self.RBF:Reflash()
    end
end
function RaidBuff:Reflash(msg, name)
    self.RBF:Reflash()
end

function RaidBuff:GetClassHex(fileName,name)
    local ColorfulName, ColorfulClassName = nil, nil
    local c = RAID_CLASS_COLORS[fileName]
    local classHex = string.format("%2x%2x%2x", c.r*255, c.g*255, c.b*255)
    if name then ColorfulName = string.format("|cff%s%s|r", classHex,  name) end
    return ColorfulName
end
function tContains(table, item)
    local index = 1;
    while table[index] do
        if ( item == table[index] ) then
            return index
        end
        index = index + 1;
    end
    return nil;
end
function tContainsKey(table, item)
    for k, _ in pairs(table) do
        if  k == item then
            return true
        end
    end
    return false
end
function tLength(table)
    local size = 0
    for _, _ in pairs(table) do
        size = size + 1
    end
    return size;
end
