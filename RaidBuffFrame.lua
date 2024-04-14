---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by yuyou.
--- DateTime: 2024/4/10 22:18
---

RaidBuffFrame = {}
local L = AceLibrary("AceLocale-2.2"):new("RaidBuff")
--起手--
function RaidBuffFrame:OnInitialize()
    self.Buff  ={}
    self.Buff["PRIEST"]=RaidBuff.opt.PBuff
    self.Buff["PRIEST2"]=RaidBuff.opt.P2Buff
    self.Buff["MAGE"]=RaidBuff.opt.MBuff
    self.Buff["DRUID"]=RaidBuff.opt.DBuff
end
function RaidBuffFrame:OnEnable()
    self:ScanRaid()
    if not self.CMF then
        self.CMF = self:SetUpContextMenusFrame()
    end
    if not self.mainFrame then
        self.mainFrame = self:SetUpMainFrame()
    end

end
function RaidBuffFrame:ShowFrame()
    self.mainFrame:Show()
end
--下拉菜单/反复利用--
function RaidBuffFrame:SetUpContextMenusFrame()
    --ContextMenusFrame
    local CMF = CreateFrame("Frame", "BFContextMenu", UIParent)
    CMF:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
        insets = {left = 5, right = 5, top = 5, bottom = 5},
    })
    CMF.buttons = {}
    CMF:SetWidth(90)
    CMF:SetHeight(40)
    CMF:Hide()
    CMF:SetScript("OnLeave", function()
        CMF:Hide()
    end)

    return CMF
end
function RaidBuffFrame:UpdateContextMenusFrame(classFile, parent)
    local classFileReal = GetRealClassFile(classFile)
    local Height = 0
    if  self.ClassList[classFileReal][1] then
        for id, v in ipairs(self.ClassList[classFileReal]) do
            local targetName = v
            if self.CMF.buttons[id] then
                self:UpdateContextMenusButton(id, parent, classFile, targetName)
            else
                self.CMF.buttons[id] = self:CreateContextMenusButton(id, parent, classFile, targetName)
            end
            Height  = Height +  self.CMF.buttons[id]:GetHeight()
        end
        self.CMF:SetWidth(90)
        self.CMF:SetHeight(Height)
        self.CMF:SetPoint("LEFT", parent, "RIGHT")
        self.CMF:Show()
    else
        parent.text:SetText(L["没有"]..L[classFile])
    end
end
function RaidBuffFrame:CreateContextMenusButton(id, parent, classFile, targetName)

    local classFileReal = GetRealClassFile(classFile)
    local nameC = RaidBuff:GetClassHex(classFileReal, targetName)
    local button = CreateFrame("Button", "DewdropButton" .. id, self.CMF)
    button:SetPoint("TOP", self.CMF, "TOP",0, - 20 * (id - 1))
    button:SetFrameStrata("FULLSCREEN_DIALOG")
    button:SetWidth(self.CMF:GetWidth())
    button:SetHeight(40)
    local highlight = button:CreateTexture(nil, "BACKGROUND")
    highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    highlight:SetBlendMode("ADD")
    highlight:SetAllPoints(button)
    highlight:Hide()
    button.highlight = highlight

    local text = button:CreateFontString(nil, "ARTWORK")
    text:SetFontObject(GameFontHighlightSmall)
    text:SetFont(STANDARD_TEXT_FONT, UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT)
    text:SetPoint("center",button ,"center")
    text:SetText(nameC)
    button.text = text

    local colorSwatch = button:CreateTexture(nil, "OVERLAY")
    button.colorSwatch = colorSwatch
    colorSwatch:SetWidth(90)
    colorSwatch:SetHeight(40)
    colorSwatch:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
    local texture = button:CreateTexture(nil, "OVERLAY")
    colorSwatch.texture = texture
    texture:SetTexture(1, 1, 1)
    texture:Show()

    button:SetScript("OnEnter", function()
        this.highlight:Show()
    end)

    button:SetScript("OnLeave", function()
        this.highlight:Hide()
    end)
    button:RegisterForClicks("LeftButtonUp","RightButtonUp")
    button:SetScript("OnClick", function()
        if arg1 == "LeftButton" then
            --parent.text:SetText(nameC)
            RaidBuffFrame:UpdateManuel(classFile, parent.subgroup, targetName, false,true)
            self.CMF:Hide()
        elseif arg1 == "RightButton" then
            self.CMF:Hide()
        end



    end)
    return button
end
function RaidBuffFrame:UpdateContextMenusButton(id, parent, classFile, targetName)
    --local classFileReal = GetRealClassFile(classFile)
    --local nameC = RaidBuff:GetClassHex(classFileReal, targetName)
    self.CMF.buttons[id]:SetPoint("TOP", self.CMF, "TOP",0, - 20 * (id - 1))
    self.CMF.buttons[id]:SetFrameStrata("FULLSCREEN_DIALOG")
    self.CMF.buttons[id]:SetWidth(self.CMF:GetWidth())
    self.CMF.buttons[id]:SetHeight(40)
    self.CMF.buttons[id]:SetScript("OnClick", function()
        --parent.text:SetText(nameC)
        RaidBuffFrame:UpdateManuel(classFile, parent.subgroup, targetName, false, true)
        self.CMF:Hide()
    end)
end
--主界面--
function RaidBuffFrame:SetUpMainFrame()
    local Width = 60
    if not self.SubGroupList then
        self:ScanRaid()
    end
    for _, _ in ipairs(self.SubGroupList ) do
        Width = Width + 90
    end
    if Width < 240 then
        Width = 240
    end
    local Height = 300
    local f = CreateFrame("Frame", "RaidBuffFrame", UIParent)
    f:SetWidth(Width)
    f:SetHeight(Height)

    f:SetBackdrop({
        bgFile = "Interface\\RaidFrame\\UI-RaidFrame-GroupBg",
        --bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
        insets = {left = 5, right = 5, top = 5, bottom = 5},
    })
    f:SetFrameStrata("LOW")

    -- position
    f:ClearAllPoints()
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

    -- drag and drop
    f:EnableMouse(true)
    f:SetClampedToScreen(true) -- can't move it outside of the screen
    f:RegisterForDrag("LeftButton")
    f:SetMovable(true)
    f:SetScript("OnDragStart", function() this:StartMoving() end)
    f:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
        self:SaveFramePosition()
    end)
    --<创建抬头>
    f.headFrame = self:CreateHeaderFrame(f)
    --</创建抬头>
    --<创建左边>
    f.leftFrame = self:CreateLeftFrame(f)
    --</创建左边>
    --<创建右边>
    f.rightFrame = self:CreateRightFrame(f)
    --</创建右边>
    --<创建下边>
    f.bottomFrame = self:CreateBottomFrame(f)
    --</创建下边>

    local x = RaidBuff.opt.xOfs
    local y = RaidBuff.opt.yOfs
    local point = RaidBuff.opt.point
    local relativePoint = RaidBuff.opt.relativePoint
    if x and y then
        f:ClearAllPoints()
        f:SetPoint(point, UIParent, relativePoint, x  , y )
    end
    f:Hide()
    return f
end
function RaidBuffFrame:UpdateMainFrame()
    local f = self.mainFrame
    local hf = f.headFrame
    local lf = f.leftFrame
    local rf = f.rightFrame
    local bf = f.bottomFrame
    local width = 20 + lf:GetWidth() + rf:GetWidth()
    if width < 240 then
        width = 240
    end
    f:SetWidth(width)
    hf:SetWidth(width - 10)
    hf:SetPoint("top", f, "top", 0, -5)
    lf:SetPoint("TOPLEFT", hf, "TOPLEFT", 0, -hf:GetHeight())
    rf:SetPoint("TOPLEFT", hf, "TOPLEFT", lf :GetWidth() + 10 ,  -hf:GetHeight())
    bf:SetWidth(width - 10)
    bf:SetPoint("BOTTOM",f, "BOTTOM", 0, 0)
end
--顶部界面--
function RaidBuffFrame:CreateHeaderFrame(parent)
    local h = CreateFrame("Frame", "headFrame", parent)
    h:SetBackdrop({
        bgFile = "Interface\\QuestFrame\\UI-HorizontalBreak",
        --    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
        ----    --insets = {left = 0, right = 0, top = 0, bottom = 5},
    })
    h:SetWidth(parent:GetWidth() - 10)
    h:SetHeight(40)
    h:SetPoint("top",parent, "top", 0, -5)
    local hs = h:CreateFontString(nil, "OVERLAY")
    hs:SetJustifyH("CENTER")
    hs:SetPoint("TOP",h ,"TOP",5,-5)
    hs:SetHeight(12)
    hs:SetFontObject("GameFontNormal")
    hs:SetText(RaidBuff.Prefix)
    hs:Show()
    h.FontString = hs
    local hb = CreateFrame("Button", "", h)
    hb:Show()
    hb:SetPoint("TOPRIGHT", h ,"TOPRIGHT", 4, 4)
    hb:SetWidth(26)
    hb:SetHeight(26)
    hb:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    hb:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    hb:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    hb:EnableMouse(true)
    hb:RegisterForClicks("LeftButtonUp")
    hb:SetScript("OnClick", function() parent:Hide()
    end)
    h.closeButton= hb
    h:Show()
    return h
end
--左边界面--
function RaidBuffFrame:CreateLeftFrame(parent)
    local hf = parent.headFrame
    local lf = CreateFrame("Frame", "leftFrame", parent)
    lf:Show()
    --lf:SetBackdrop({
    --    --bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
    --    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
    --})
    lf:SetWidth(40)
    lf:SetHeight(45*5)
    lf:SetPoint("TOPLEFT", hf, "TOPLEFT", 0, -hf:GetHeight())
    local bts  = {}
    for i, v in ipairs({"Interface\\Icons\\Interface\\Icons\\Temp",
                        "Interface\\Icons\\spell_holy_prayeroffortitude",
                        "Interface\\Icons\\spell_holy_prayerofspirit",
                        "Interface\\Icons\\spell_holy_arcaneintellect",
                        "Interface\\Icons\\spell_nature_regeneration"}) do
        bts[i] = CreateFrame("Button", "lfButton"..i, lf)
        if i > 1 then
            bts[i]:SetBackdrop({
                --bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
                insets = {left = 5, right =5, top =  5, bottom =  5},
            })
        end
        bts[i]:SetPoint("TOP" ,lf,"TOP",0, - 45 * (i - 1))
        bts[i]:SetWidth(40)
        bts[i]:SetHeight(40)
        bts[i]:SetNormalTexture(v)
        bts[i]:Show()
    end
    lf.Buttons = bts
    return lf
end
--右边界面--
function RaidBuffFrame:CreateRightFrame(parent)
    local lf = parent.leftFrame
    local hf = parent.headFrame
    local rf = CreateFrame("Frame", "rightMainFrame", parent)
    local gps = {}
    local rfLength = 0
    local blsWidth = 90
    local blsHeight = 45
    for i, v in ipairs(self.SubGroupList) do
        local id = i
        local subgroup = v
        gps[v] = self:CreateGroupFrame(rf, id, subgroup, blsWidth, blsHeight)
        rfLength = rfLength + blsWidth
    end
    rf.groups = gps
    rf:SetWidth(rfLength)
    rf:SetHeight(blsHeight*5)
    rf:SetPoint("TOPLEFT", hf, "TOPLEFT", lf:GetWidth() + 10 ,  -hf:GetHeight())
    rf:Show()
    return rf
end
function RaidBuffFrame:UpdateRightFrame()
    local lf = self.mainFrame.leftFrame
    local hf = self.mainFrame.headFrame
    local rf =  self.mainFrame.rightFrame
    local gps = rf.groups
    local rfLength = 0
    local blsWidth = 90
    local blsHeight = 45
    local fid = 1
    for gid = 1, 8 do
        local subgroup = gid
        if tContains(self.SubGroupList, gid)then
            if gps[subgroup] then
                self:UpdateGroupFrame(rf, fid, subgroup, blsWidth, blsHeight)
            else
                gps[gid] = self:CreateGroupFrame(rf, fid, subgroup, blsWidth, blsHeight)
            end
            fid = fid + 1
            rfLength = rfLength + blsWidth
        elseif rf.groups[subgroup] then
            RaidBuff:LevelDebug(2, format("HideGroupFrame:subgroup%s", tostring(subgroup)))
            rf.groups[subgroup]:Hide()
        end
    end
    rf.groups = gps
    rf:SetWidth(rfLength)
    rf:SetHeight(blsHeight*5)
    rf:SetPoint("TOPLEFT", hf, "TOPLEFT", lf:GetWidth() + 10 ,  -hf:GetHeight())
    rf:Show()
    RaidBuffFrame:UpdateMainFrame()
end
function RaidBuffFrame:CreateGroupFrame(parent, id, subgroup, blsWidth, blsHeight)
    local bl = CreateFrame("Frame", "groupFrame"..subgroup, parent)
    bl:SetWidth(blsWidth)
    bl:SetHeight(blsHeight * 5)
    bl:SetPoint("TOPLEFT", parent, "TOPLEFT", blsWidth * (id - 1)  , 0)
    local text = bl:CreateFontString(nil, "OVERLAY")
    text:SetJustifyH("CENTER")
    text:SetPoint("TOP",bl ,"TOP",0,-20)
    text:SetHeight(12)
    text:SetFontObject("GameFontNormal")
    text:SetText(L["队伍"]..subgroup)
    text:Show()
    bl.text = text
    local bs = {}
    for j, v in ipairs({"PRIEST", "PRIEST2", "MAGE", "DRUID"}) do
        bs[j] = CreateFrame("Button", "groupFrame"..subgroup.."Button"..id, bl)

        local classFile =  v
        local classFileReal = GetRealClassFile(classFile)
        bs[j].subgroup = subgroup
        bs[j].classFile = classFile
        bs[j]:SetPoint("TOP" ,bl, "TOP", 0, - 45 * j)
        bs[j]:SetWidth(blsWidth)
        bs[j]:SetHeight(blsHeight - 5 )
        bs[j]:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\UI-ChatInputBorder",
        })
        local bstext = bs[j]:CreateFontString(nil, "OVERLAY")
        bstext:SetPoint("center", bs[j] ,"center")
        bstext:SetFontObject("GameFontNormal")
        local nameC = "N/A"
        if self.Buff[classFile][subgroup] then
            local textString = self.Buff[classFile][subgroup]
            nameC = RaidBuff:GetClassHex(classFileReal, textString)
        end
        bstext:SetText(nameC)
        bs[j].text = bstext
        bs[j]:RegisterForClicks("LeftButtonUp","RightButtonUp")
        bs[j]:SetScript("OnClick", function()
            if arg1 == "LeftButton" then
                self:UpdateContextMenusFrame(this.classFile, this)
            elseif arg1 == "RightButton" then
                self:UpdateManuel(classFile,subgroup,nil,false,true)
                if self.CMF:IsVisible() then
                    self.CMF:Hide()
                end
            end
        end)
        bs[j]:Show()
    end
    bl.Buttons = bs
    return bl
end
function RaidBuffFrame:UpdateGroupFrame(parent,  id, subgroup, blsWidth)
    parent.groups[subgroup]:SetPoint("TOPLEFT", parent, "TOPLEFT", blsWidth * (id - 1)  , 0)
    local classFs = {"PRIEST", "PRIEST2", "MAGE", "DRUID"}
    for j = 1, 4 do
        local className = classFs[j]
        local targetName = self.Buff[className][subgroup]
        local classNameReal = GetRealClassFile(className)
        local nameC = "N/A"
        if targetName then nameC = RaidBuff:GetClassHex(classNameReal, targetName) end
        --RaidBuff:LevelDebug(3,
        --        format("UpdateGroupFrame  :subgroup%s for the <%s>%s ",
        --                tostring(subgroup), tostring(className), tostring(nameC)))
        parent.groups[subgroup].Buttons[j].text:SetText(nameC)

    end
    parent.groups[subgroup]:Show()
end
--下面界面--
function RaidBuffFrame:CreateBottomFrame(parent)
    local b = CreateFrame("Frame", "bottomFrame", parent)
    b:SetWidth(parent:GetWidth())
    b:SetHeight(30)
    b:SetPoint("BOTTOM",parent, "BOTTOM", 0, 0)
    if not b.aotob then
        b.aotob = self:CreateBottomButton(b, 0 ,L["自动分配"],function() self:AutoSet() end)
    end
    if not b.rb then
        b.rb =  self:CreateBottomButton(b, 1 ,L["发送报告"],function() self:Report() end)
    end
    if  not  b.cb then
        b.cb =  self:CreateBottomButton(b, 2 ,L["清除所有"],function() self:CleanBuff() end)
    end
    b:Show()
    return b
end
function RaidBuffFrame:CreateBottomButton(parent, id, text , func)
    local b = CreateFrame("Button", "", parent)
    b:Show()
    b:SetPoint("CENTER", parent, "RIGHT", -20 - 70 * id, 0)
    b:SetWidth(110)
    b:SetHeight(30)
    b:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
    b:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
    b:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
    b:EnableMouse(true)
    local bt = b:CreateFontString(nil, "OVERLAY")
    --bt:SetJustifyH("RIGHT")
    bt:SetJustifyH("CENTER")
    bt:SetWidth(80)
    bt:SetHeight(20)
    bt:SetPoint("TOP", b, "TOP", -20, 0)
    bt:SetFontObject("GameFontNormal")
    bt:SetText(text)
    bt.text = bt
    b:RegisterForClicks("LeftButtonUp")
    b:SetScript("OnClick", func)
    return b
end
--frame 用到的 func--
function RaidBuffFrame:ResetList()
    self.ClassList  = {}
    self.ClassList["PRIEST"] = {}
    self.ClassList["MAGE"] = {}
    self.ClassList["DRUID"] = {}
    self.SubGroupList  = {}
end
function RaidBuffFrame:ScanRaid()
    self:ResetList()
    local GroupList = {}
    if  GetNumRaidMembers() > 0  then
        for i = 1, GetNumRaidMembers() do
            local name, _, subgroup, level, _, fileName = GetRaidRosterInfo(i)
            if name then
                GroupList[subgroup] = true
            end
            if self.ClassList[fileName] and level==60 then
                tinsert(self.ClassList[fileName], name)
            end
        end
        for i = 1, 8 do
            if GroupList[i] then
                tinsert(self.SubGroupList, i)
            end
        end
    end
end

function RaidBuffFrame:UpdateManuel(fileName, subgroup, targetName, disableComm, reflash)
    self.Buff[fileName][subgroup] = targetName
    if not disableComm then
        RaidBuff:SendCommMessage("RAID","UpdateManuel", fileName,subgroup,targetName )
    end
    if reflash then
        self:Reflash()
    end
end
function RaidBuffFrame:SaveFramePosition()
    local point, _, relativePoint, xOfs, yOfs = self.mainFrame:GetPoint()
    RaidBuff.opt.point = point
    RaidBuff.opt.relativePoint = relativePoint
    RaidBuff.opt.xOfs = xOfs
    RaidBuff.opt.yOfs = yOfs
end
function GetRealClassFile(classFile)
    if classFile == "PRIEST2" then
        return "PRIEST"
    end
    return classFile
end
--下面的按钮的func--
function RaidBuffFrame:AutoSet()
    self:ScanRaid()
    local nbOfGroup = tLength(self.SubGroupList)
    for _, v in ipairs( {"PRIEST", "MAGE", "DRUID" }) do
        self.Buff[v] = {}
        self:SetForClass(nbOfGroup, v)
    end
    for i, v in pairs( self.Buff["PRIEST"]) do
        self.Buff["PRIEST2"][i] = v
    end
    RaidBuff:SendCommMessage("RAID","Reflash")
    self:Reflash()
end
function RaidBuffFrame:SetForClass(nbOfGroup, fileName)
    local nbOfCandidate = tLength(self.ClassList[fileName])
    --RaidBuff:LevelDebug(2,
    --        format("nbOfCandidate of %s are <%s> ",
    --                tostring(fileName), tostring(nbOfCandidate)))
    local nbOfG = nbOfGroup
    local indexOfSGL = 1
    local subgroup,nb,targetName
    if nbOfCandidate > 0 then
        for _, v in ipairs(self.ClassList[fileName]) do
            targetName = v
            nb = ceil(nbOfG/ nbOfCandidate)
            for _ = 1, nb do
                subgroup = self.SubGroupList[indexOfSGL]
                self:UpdateManuel(fileName,subgroup,targetName,false,false)
                --self.Buff[fileName][subgroup] = targetName
                indexOfSGL=indexOfSGL +  1
                nbOfG = nbOfG - 1
            end
            nbOfCandidate = nbOfCandidate - 1
        end
    end
end
function RaidBuffFrame:Report()
    SendChatMessage(format("%s%s%s", strrep("*", 10),RaidBuff.Prefix, strrep("*", 10) ),"RAID")
    local buffName = {L["耐力"], L["精神"], L["智力"], L["爪子"]}
    for i, c in ipairs({"PRIEST", "PRIEST2", "MAGE", "DRUID"}) do
        local buffByPlayer = {}
        for g, n in pairs(self.Buff[c]) do
            if not buffByPlayer[n] then
                buffByPlayer[n] =  {}
            end
            if tContains(self.SubGroupList, g) then
                tinsert(buffByPlayer[n],g)
            end
        end
        SendChatMessage(format("*%s :", buffName[i]),"RAID")
        for  name, group in pairs(buffByPlayer) do
            local gmsg =tostring(table.concat(group,","))
            local nameC = RaidBuff:GetClassHex(c, name)
            local msg = format(">%s<: %s%s%s", nameC, L["第"], gmsg , L["队"])
            SendChatMessage(msg,"RAID")
        end
    end
    SendChatMessage(strrep("*", 42),"RAID")
end
function RaidBuffFrame:CleanBuff(disableComm)
    for _, c in ipairs({ "PRIEST", "PRIEST2", "MAGE", "DRUID"}) do
        self.Buff[c] = {}
    end
    if not disableComm then
        RaidBuff:SendCommMessage("RAID","CleanBuff")
    end
    self:UpdateRightFrame()
end
function RaidBuffFrame:Reflash()
        self:ScanRaid()
        self:UpdateRightFrame()
end

