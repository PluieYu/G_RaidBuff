---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by yuyou.
--- DateTime: 2024/4/10 0:06
---

RaidBuff = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0","AceComm-2.0","AceDB-2.0","AceDebug-2.0","AceConsole-2.0","FuBarPlugin-2.0", "AceHook-2.1")
local L = AceLibrary("AceLocale-2.2"):new("RaidBuff")
RaidBuff.hasIcon = "Interface\\Icons\\INV_Misc_Candle_02"
--CreateFrame("GameTooltip", "MyScanningTooltip", nil, "GameTooltipTemplate")
--MyScanningTooltip:SetOwner(WorldFrame, "ANCHOR_NONE" )

function RaidBuff:OnInitialize()
    self:SetDebugLevel(3)
    self.Prefix =
    "|cffF5F54A["..base64:dec("5bCP55qu566x").."]|r|cff9482C9"..base64:dec("5Zui6ZifYnVmZuWKqeaJiw==").."|r"
    self.Prefix2 =
    "|cffF5F54A["..base64:dec("5bCP55qu566x").."]|r\n|cff9482C9"..base64:dec("YnVmZuWKqeaJiw==").."|r"
    --self:SetDebugging(true)
    self:RegisterDB("RaidBuffDB")
    self:RegisterDefaults("profile", {
        xOfs = {},
        yOfs = {},
        point = {},
        relativePoint = {},
        PBuff = {},
        MBuff = {},
        DBuff = {},
    })
    self:OnProfileEnable()
    RBMain:OnInitialize()
    self:SetCommPrefix(self.Prefix)
    self:OnInitializeOption()
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
                func = function() RBMain.mf:Show() end,
            },
        }
    }
end

function RaidBuff:OnProfileEnable()
    self.opt = self.db.profile
end

function RaidBuff:OnEnable()
    RBMain:OnEnable()
    self:RegisterComm(self.Prefix, "RAID")
    --self:RegisterEvent("UNIT_AURA", "test")
    self:RegisterEvent("RAID_ROSTER_UPDATE", "Flush")
    --self:RegisterEvent("CHAT_MSG_RAID", "CheckChatMessage")
    --self:RegisterEvent("CHAT_MSG_RAID_LEADER", "CheckChatMessage")

end
function RaidBuff:OnDisable()
    self:UnregisterAllEvents()
end


--function RaidBuff:CheckChatMessage(msg, name)
--    if not name ==  UnitName("player")  then
--        for _, word in pairs({L["耐力"], L["智力"], L["爪子"]}) do
--            index_stat, index_end = string.find(msg, word);
--            if index_stat then
--
--            end
--        end
--    end
--    --if strsub(msg,0, stringLen) ~= self.Prefix then
--    --    for _, word in pairs(L["关键词"]) do
--    --        index_stat, index_end = string.find(msg, word);
--    --        if index_stat then
--    --            self:OnCommReceive("", "", "RAID", "Add", name)
--    --            self:SendCommMessage("RAID","Add",name)
--    --        end
--    --    end
--    --end
--end

function RaidBuff:OnCommReceive(_, sender, _, method, fileName, subgroup, targetName)
    if method =="UpdateManuel" then

        if targetName then
            self:Print(format("<%s>分配了%s加%s队%sbuff",sender,targetName, subgroup, L[fileName]))
        else
            self:Print(format("<%s>清除了%s队%sbuff的分配",sender, subgroup, L[fileName]))
        end
        RBMain:UpdateResult(fileName, subgroup, targetName, false)
        RBMain:Flush()
    end
end

function RaidBuff:Flush()
    RBMain:Scan()
    RBMain:Flush()
end

function RaidBuff:GetClassHex(fileName,name)
    local ColorfulName
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

--
--function MyScanningTooltip:getText()
--         local text = {}
--         for i = 1, MyScanningTooltip:NumLines() do
--             local left, right = getglobal("MyScanningTooltipTextLeft"..i), getglobal("MyScanningTooltipTextRight"..i)
--             left = left and left:IsVisible() and left:GetText()
--             right = right and right:IsVisible() and right:GetText()
--             left = left and left ~= "" and left or nil
--             right = right and right ~= "" and right or nil
--             if left and right then
--                 text[i] = {tostring(left), tostring(right)}
--             elseif left then
--                 text[i] = {tostring(left), "无"}
--             elseif right then
--                 text[i] = {"无", tostring(right)}
--             end
--         end
--         return text
--end