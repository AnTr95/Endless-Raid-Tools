local f = CreateFrame("Frame", nil, nil, BackdropTemplateMixin and "BackdropTemplate");
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

local rcStatus = false;
local rcSender = ""
local raiders = {};

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