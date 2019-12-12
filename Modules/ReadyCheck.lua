local f = CreateFrame("Frame")
f:RegisterEvent("READY_CHECK_CONFIRM")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("READY_CHECK_FINISHED")
f:RegisterEvent("READY_CHECK")
f:RegisterEvent("CHAT_MSG_RAID")
f:RegisterEvent("CHAT_MSG_RAID_LEADER")
f:SetPoint("CENTER")
f:SetSize(200,200)
f:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", --Set the background and border textures
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
f:SetBackdropColor(0,0,0,0)
f:SetBackdropBorderColor(169,169,169,0)

local rcStatus = false
local rcSender = ""
local flasks = {298839,298836,298837,298841,251836, 251837, 251839, 251838};
local RED = "\124cFFFF0000";
local YELLOW = "\124cFFFFFF00";
local GREEN = "\124cFF00FF00";

local rcButton = CreateFrame("Button", "EnRT_ReadyCheckButton", f, "UIPanelButtonTemplate")
rcButton:SetPoint("CENTER")
rcButton:SetSize(200,80)
rcButton:SetText("I AM READY!")
rcButton:SetScript("OnClick", function(self)
	SendChatMessage("EnRT: I am ready now!", "RAID")
	rcStatus = true
	f:Hide()
	rcButton:Hide()
end)

local rcCloseButton = CreateFrame("Button", "EnRT_ReadyCheckCloseButton", f, "UIPanelButtonTemplate")
rcCloseButton:SetPoint("BOTTOM", 0, 10)
rcCloseButton:SetSize(35,20)
rcCloseButton:SetText("Close")
rcCloseButton:SetScript("OnClick", function(self)
	rcCloseButton:Hide()
	rcText:SetText("")
	rcText:Hide()
	rcButton:Hide()
	f:Hide()
end)
rcCloseButton:Hide()


rcText = f:CreateFontString("nil", "ARTWORK", "GameFontHighlight")
rcText:SetWordWrap(true)
rcText:SetPoint("TOP", 0, -10)
rcText:SetJustifyV("TOP")
rcText:SetText("")

rcText:Hide()
rcButton:Hide()
f:Hide()

local function updateConsumables()
	local flask, flaskIcon, _, _, _, flaskTime = EnRT_UnitBuff("player", GetSpellInfo(298839));
	for i = 1, #flasks do
		flask, flaskIcon, _, _, _, flaskTime = EnRT_UnitBuff("player", GetSpellInfo(flasks[i]));
		if (flask) then
			break;
		end
	end
	local food, foodIcon, _, _, _, foodTime = EnRT_UnitBuff("player", GetSpellInfo(297039)); -- Random Well Fed Buff
	local rune, runeIcon, _, _, _, runeTime = EnRT_UnitBuff("player", GetSpellInfo(270058));
	flaskIcon = flaskIcon and flaskIcon or 134877;
	foodIcon = foodIcon and foodIcon or 136000;
	runeIcon = runeIcon and runeIcon or 519379;

	local blizzText = ReadyCheckFrameText:GetText();
	local currTime = GetTime();
	flaskTime = flaskTime and math.floor((tonumber(flaskTime)-currTime)/60) or nil;
	if (flaskTime) then
		if (flaskTime > 15) then
			flaskTime = GREEN .. flaskTime .. " min ";
		elseif (flaskTime <= 15 and flaskTime > 8) then
			flaskTime = YELLOW .. flaskTime .. " min ";
		elseif (flaskTime <= 8) then
			flaskTime = RED .. flaskTime .. " min ";
		end
	else
		flaskTime = RED .. "Missing ";
	end
	ReadyCheckFrameText:SetText(blizzText .. "\n\n\124T"..flaskIcon .. ":16\124t " .. flaskTime .. "\124T" .. foodIcon .. ":16\124t " .. (food and (GREEN .. "Check ") or (RED .. "Missing ")) .. "\124T" .. runeIcon .. ":16\124t " .. (rune and (GREEN .. "Check ") or (RED .."Missing "))); 
	--print(("%d=%s, %s, %.2f minutes left."):format(i,name,icon,(etime-GetTime())/60))
end

f:SetScript("OnEvent", function(self, event, ...)
	if event == "READY_CHECK_CONFIRM" and EnRT_ReadyCheckEnabled then
		local id, response = ...
		local player = UnitName("player")
		local playerIndex = EnRT_GetRaidMemberIndex(player)
		--Sender part
		if rcSender ~= UnitName(id) and rcSender == UnitName("player") and not response and select(2,GetInstanceInfo()) == "raid" and UnitIsVisible(id) then
			if not rcText:IsShown() then 
				rcText:Show()
			end
			if not rcCloseButton:IsShown() then
				rcCloseButton:Show()
			end
			if not f:IsShown() then
				f:Show()
				f:SetBackdropColor(0,0,0,1)
				f:SetBackdropBorderColor(169,169,169,1)
			end
			local playerTargeted = UnitName(id)
			local players = {}
			if rcText:GetText() then
				for s in rcText:GetText():gmatch("[^\r\n]+") do
	    			table.insert(players, s)
				end
			end
			local playerText = string.format("|c%s%s", RAID_CLASS_COLORS[select(2, UnitClass(playerTargeted))].colorStr, UnitName(playerTargeted))
			for k, v in pairs(players) do 
				if playerText == v then
					playerText = ""
					return
				end
			end
			local currentText = rcText:GetText() and rcText:GetText() .. playerText .. '\n' or playerText .. '\n'
			rcText:SetText(currentText)
		end
		--Reciever part
		if select(2,GetInstanceInfo()) == "raid" and playerIndex == id and not response then --Inside a raid instance, the player answered the invites is the player and response was not ready
			f:Show()
			rcButton:Show()
			f:SetBackdropColor(0,0,0,0)
			f:SetBackdropBorderColor(169,169,169,0)
		elseif playerIndex == id and response then
			rcStatus = true
		end
	elseif (event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER") and EnRT_ReadyCheckEnabled and rcText:IsShown() then
		if rcSender == UnitName("player") then
			local msg, sender = ...
			sender = Ambiguate(sender, "short")
			if msg == "EnRT: I am ready now!" and rcText:GetText():match(sender) then
				local playerText = string.format("|c%s%s", RAID_CLASS_COLORS[select(2, UnitClass(sender))].colorStr, UnitName(sender))
				local currentText = ""
				local players = {}
				if rcText:GetText() then
					for s in rcText:GetText():gmatch("[^\r\n]+") do
	    				table.insert(players, s)
					end
				end
				for k, v in pairs(players) do
					if playerText ~= v then
						currentText = currentText .. v .. '\n'
					end
				end
				if currentText == "" then
					rcText:SetText("")
					rcText:Hide()
					f:Hide()
					rcCloseButton:Hide()
				else
					rcText:SetText(currentText)
				end
			end
		end
	elseif event == "READY_CHECK" and EnRT_ReadyCheckEnabled then
		local sender = ...
		rcStatus = false
		rcSender = sender
		if sender == UnitName("player") then
			rcStatus = true
		end
		updateConsumables();
	elseif event == "READY_CHECK_FINISHED" and EnRT_ReadyCheckEnabled then
		if not rcStatus and not f:IsShown() and select(2,GetInstanceInfo()) == "raid" then
			f:Show()
			rcButton:Show()
			f:SetBackdropColor(0,0,0,0)
			f:SetBackdropBorderColor(169,169,169,0)
		end
	elseif event == "PLAYER_LOGIN" then
		if EnRT_ReadyCheckEnabled == nil then EnRT_ReadyCheckEnabled = true end
	end
end)

function EnRT_GetRaidMemberIndex(name)
	for i = 1, GetNumGroupMembers() do
		local raider = "raid"..i
		if UnitName(raider) == name then
			return raider
		end
	end
	return -1
end