local f = CreateFrame("Frame", nil, nil, BackdropTemplateMixin and "BackdropTemplate");
f:RegisterEvent("READY_CHECK_CONFIRM")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("READY_CHECK_FINISHED")
f:RegisterEvent("READY_CHECK")
f:RegisterEvent("CHAT_MSG_RAID")
f:RegisterEvent("CHAT_MSG_RAID_LEADER")
f:RegisterEvent("UNIT_AURA");
f:SetPoint("CENTER")
f:SetSize(200,200)
f:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", --Set the background and border textures
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
f:SetBackdropColor(0,0,0,0)
f:SetBackdropBorderColor(169,169,169,0)

local rcStatus = false;
local rcSender = ""
local flasks = {307185,307187};
local RED = "\124cFFFF0000";
local YELLOW = "\124cFFFFFF00";
local GREEN = "\124cFF00FF00";
local raiders = {};
local buffSpellIDs = {
	["MAGE"] = 1459, 
	["PRIEST"] = 21562, 
	["WARRIOR"] = 6673,
};
local buffIconIDs = {
	["MAGE"] = 135932, 
	["PRIEST"] = 135987, 
	["WARRIOR"] = 132333,
};
local blizzFixFrame = CreateFrame("Frame", "$parentDetails"); -- UIGoldBorderButtonTemplate is using $parentDetails pointing to a frame called the parents name of the button followed by Details which is undefined in blizzcode.
blizzFixFrame:SetPoint("CENTER", f, "CENTER");

local rcButtonText = f:CreateFontString(nil, "ARTWORK", "GameFontNormal");
rcButtonText:SetText("I am ready now!");
rcButtonText:SetPoint("CENTER");
local font = select(1, rcButtonText:GetFont());
rcButtonText:SetFont(font, 13);

local rcButton = CreateFrame("Button", "EnRT_ReadyCheckButton", f, "UIGoldBorderButtonTemplate");
rcButton:SetPoint("CENTER");
rcButton:SetSize(180,45);
rcButton:SetText("I am ready now!");
rcButton:SetFontString(rcButtonText);

local ag = rcButton:CreateAnimationGroup();
ag:SetLooping("REPEAT");

local aniFade = ag:CreateAnimation("Alpha");
aniFade:SetDuration(2);
aniFade:SetToAlpha(0.5);
aniFade:SetFromAlpha(1);
aniFade:SetOrder(1);

local aniAppear = ag:CreateAnimation("Alpha");
aniAppear:SetDuration(1.5);
aniAppear:SetToAlpha(1);
aniAppear:SetFromAlpha(0.5);
aniAppear:SetOrder(2);

rcButton:SetScript("OnClick", function(self)
	SendChatMessage("EnRT: I am ready now!", "RAID")
	rcStatus = true
	f:Hide()
	ag:Stop();
	rcButton:Hide()
end)

rcButton:SetScript("OnShow", function (self)
	if(EnRT_ReadyCheckFlashing) then
		ag:Play();
	end
end)

local rcText = f:CreateFontString("nil", "ARTWORK", "GameFontHighlight")
rcText:SetWordWrap(true)
rcText:SetPoint("TOP", 0, -10)
rcText:SetJustifyV("TOP")
rcText:SetText("")

local rcCloseButton = CreateFrame("Button", "EnRT_ReadyCheckCloseButton", f, "UIPanelButtonTemplate")
rcCloseButton:SetPoint("BOTTOM", 0, 10)
rcCloseButton:SetSize(60,25)
rcCloseButton:SetText("Close")
rcCloseButton:SetScript("OnClick", function(self)
	rcCloseButton:Hide()
	rcText:SetText("")
	rcText:Hide()
	rcButton:Hide();
	f:Hide();
end)

rcCloseButton:Hide()
rcText:Hide()
rcButton:Hide()
f:Hide()

local function updateConsumables()
	local flask, flaskIcon, _, _, _, flaskTime = EnRT_UnitBuff("player", GetSpellInfo(307185));
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
	if (blizzText:find("%-")) then
		local head, tail, name = blizzText:find("([^-]*)");
		blizzText = name .. " initiated a ready check";
	else
		local head, tail, name = blizzText:find("([^%s]*)");
		blizzText = name .. " initiated a ready check";
	end
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
	local class = select(2, UnitClass("player"));
	if (class == "MAGE" or class == "PRIEST" or class == "WARRIOR") then
		ReadyCheckFrameText:SetSize(280, 40);
		local count = 0;
		local total = 0;
		local unit = nil;
		if (IsInRaid()) then
			for i = 1, GetNumGroupMembers() do
				unit = "raid"..i;
				if (UnitIsVisible(unit)) then
					total = total + 1;
					if (EnRT_UnitBuff(unit, GetSpellInfo(buffSpellIDs[class]))) then
						count = count + 1;
					end
				end
			end
		elseif (IsInGroup()) then
			for i = 1, GetNumGroupMembers()-1 do
				unit = "party"..i;
				if (UnitIsVisible(unit)) then
					total = total + 1;
					if (EnRT_UnitBuff(unit, GetSpellInfo(buffSpellIDs[class]))) then
						count = count + 1;
					end
				end
			end
			total = total + 1;
			if (EnRT_UnitBuff("player", GetSpellInfo(buffSpellIDs[class]))) then
				count = count + 1;
			end
		end
		ReadyCheckFrameText:SetText(blizzText .. "\n\n\124T"..flaskIcon .. ":16\124t" .. flaskTime .. "\124T" .. foodIcon .. ":16\124t" .. (food and (GREEN .. "Check ") or (RED .. "Missing ")) .. "\124T" .. runeIcon .. ":16\124t" .. (rune and (GREEN .. "Check ") or (RED .."Missing ")) .. "\124T" .. buffIconIDs[class] .. ":16\124t" .. (count == total and (GREEN .. count .. "/" ..total) or (RED .. count .. "/" .. total)));
	else
		ReadyCheckFrameText:SetText(blizzText .. "\n\n\124T"..flaskIcon .. ":16\124t " .. flaskTime .. "\124T" .. foodIcon .. ":16\124t " .. (food and (GREEN .. "Check ") or (RED .. "Missing ")) .. "\124T" .. runeIcon .. ":16\124t " .. (rune and (GREEN .. "Check ") or (RED .."Missing "))); 
	end
end

f:SetScript("OnEvent", function(self, event, ...)
	if event == "READY_CHECK_CONFIRM" and EnRT_ReadyCheckEnabled then
		local id, response = ...
		local player = UnitName("player")
		local playerIndex = EnRT_GetRaidMemberIndex(player)
		--Sender part
		if rcSender == UnitName("player") and select(2,GetInstanceInfo()) == "raid" and UnitIsVisible(id) then
			local playerTargeted = GetUnitName(id, true);
			raiders[playerTargeted] = response;
			if (not response) then
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

				local playerText = string.format("|c%s%s", RAID_CLASS_COLORS[select(2, UnitClass(playerTargeted))].colorStr, UnitName(playerTargeted))
				if (rcText:GetText() == nil) then
					rcText:SetText("Players not ready or afk: \n" .. playerText .. '\n');
				elseif (not rcText:GetText():match(playerText)) then
					rcText:SetText(rcText:GetText() .. playerText .. '\n');
				end
			end
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
	elseif (event == "UNIT_AURA" and EnRT_ReadyCheckEnabled and ReadyCheckFrame:IsShown()) then
		local unit = ...;
		if (UnitInRaid(unit) or UnitInParty(unit)) then
			updateConsumables();
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
				if currentText == "Players not ready or afk: \n" then
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
		if (sender ~= UnitName("player") and EnRT_ConsumableCheckEnabled) then
			updateConsumables();
		end
		if sender == UnitName("player") then
			raiders = {};
			for i = 1, GetNumGroupMembers() do
				local raiderName = GetUnitName("raid"..i, true);
				if (UnitIsVisible(raiderName)) then
					raiders[raiderName] = 0;
				end
			end
			raiders[rcSender] = true;
			rcStatus = true
		end
	elseif event == "READY_CHECK_FINISHED" and EnRT_ReadyCheckEnabled then
		if not rcStatus and not f:IsShown() and select(2,GetInstanceInfo()) == "raid" then
			f:Show()
			rcButton:Show()
			f:SetBackdropColor(0,0,0,0)
			f:SetBackdropBorderColor(169,169,169,0)
		end
		if (rcSender == UnitName("player") and select(2, GetInstanceInfo()) == "raid") then
			for raider, response in pairs(raiders) do
				if (UnitInRaid(raider)) then
					if (response == 0) then
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

						local playerText = string.format("|c%s%s", RAID_CLASS_COLORS[select(2, UnitClass(raider))].colorStr, Ambiguate(raider, "short"));
						if (rcText:GetText() == nil) then
							rcText:SetText("Players not ready or afk: \n" .. playerText .. '\n');
						elseif (not rcText:GetText():match(playerText)) then
							rcText:SetText(rcText:GetText() .. playerText .. '\n');
						end
					end
				end
			end
		end
	elseif event == "PLAYER_LOGIN" then
		if EnRT_ReadyCheckEnabled == nil then EnRT_ReadyCheckEnabled = true end
		if EnRT_ReadyCheckFlashing == nil then EnRT_ReadyCheckFlashing = false end
		if EnRT_ConsumableCheckEnabled == nil then EnRT_ConsumableCheckEnabled = true end
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