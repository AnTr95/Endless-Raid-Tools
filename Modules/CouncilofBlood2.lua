local f = CreateFrame("Frame");
local inEncounter = false;
local playerName = GetUnitName("player");
local isGlowing = false;
local timer = nil;
local text = nil;
local ticks = 0;
local debuffed = false;
local safe = true;
local leader = "";
local nearby = {};

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("CHAT_MSG_SYSTEM");
f:RegisterEvent("UI_INFO_MESSAGE");
f:RegisterEvent("CHAT_MSG_RESTRICTED");
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
f:RegisterEvent("CHAT_MSG_RAID_BOSS_WHISPER");

C_ChatInfo.RegisterAddonMessagePrefix("EnRT_TCOB");

local function glowButton(button)
	if (IsAddOnLoaded("Bartender4") and _G["BT4Button"..isGlowing]) then
		ActionButton_HideOverlayGlow(_G["BT4Button"..isGlowing]);
	elseif (IsAddOnLoaded("ElvUI_SLE") and _G["ElvUISLEEnhancedVehicleBarButton"..isGlowing]) then
		ActionButton_HideOverlayGlow(_G["ElvUISLEEnhancedVehicleBarButton"..isGlowing]);
	elseif (IsAddOnLoaded("ElvUI") and _G["ElvUI_Bar1Button"..isGlowing]) then
		ActionButton_HideOverlayGlow(_G["ElvUI_Bar1Button"..isGlowing]);
	else
		ActionButton_HideOverlayGlow(_G["OverrideActionBarButton"..isGlowing]);
	end
	if (IsAddOnLoaded("Bartender4") and _G["BT4Button"..button]) then
		ActionButton_ShowOverlayGlow(_G["BT4Button"..button]);
	elseif (IsAddOnLoaded("ElvUI_SLE") and _G["ElvUISLEEnhancedVehicleBarButton"..button]) then
		ActionButton_ShowOverlayGlow(_G["ElvUISLEEnhancedVehicleBarButton"..button]);
	elseif (IsAddOnLoaded("ElvUI") and _G["ElvUI_Bar1Button"..button]) then
		ActionButton_ShowOverlayGlow(_G["ElvUI_Bar1Button"..button]);
	else
		ActionButton_ShowOverlayGlow(_G["OverrideActionBarButton"..button]);
	end
	isGlowing = button;
end

local function onUpdate(self, elapsed)
	if (debuffed and EnRT_CouncilofBloodEnabled and inEncounter) then
		ticks = ticks + elapsed;
		if (ticks > 0.05) then
			safe = true;
			for i = 1, GetNumGroupMembers() do
				local raider = "raid"..i;
				local name = GetUnitName(raider, true);
				if (UnitIsVisible(raider) and not UnitIsUnit(playerName, name) and not UnitIsDead(raider)) then
					if (CheckInteractDistance(raider, 3) and not EnRT_Contains(nearby, name)) then --Duel range 10y
						safe = false;
						nearby[#nearby+1] = name;
						if (UnitIsConnected(name)) then
							C_ChatInfo.SendAddonMessage("EnRT_TCOB", "NEARBY", "WHISPER", name);
						end
					elseif (CheckInteractDistance(raider, 3)) then
						safe = false;
					elseif (not CheckInteractDistance(raider, 3) and EnRT_Contains(nearby, name)) then
						nearby[EnRT_Contains(nearby, name)] = nil;
						if (UnitIsConnected(name)) then
							C_ChatInfo.SendAddonMessage("EnRT_TCOB", "AWAY", "WHISPER", name);
						end
					end
				end
			end
			if (safe and EnRT_UnitDebuff(player, GetSpellInfo(00000))) then
				text = "SAFE - " .. debuffed;
				C_ChatInfo.SendAddonMessage("EnRT_TCOB", "SHOW", "RAID");
			elseif (not safe and EnRT_UnitDebuff(player, GetSpellInfo(00000))) then
				text = "NOT SAFE - " .. debuffed;
				C_ChatInfo.SendAddonMessage("EnRT_TCOB", "HIDE", "RAID");
			end
			if (timer == nil) then
				SendChatMessage(text, "YELL");
				timer = C_Timer.NewTicker(1, function()
					SendChatMessage(text, "YELL");
				end, 4);
			end
			ticks = 0;
		end
	end
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then 
		if (EnRT_CouncilofBloodEnabled == nil) then EnRT_CouncilofBloodEnabled = true; end
	elseif (event == "UNIT_AURA" and EnRT_CouncilofBloodEnabled and inEncounter) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (UnitIsUnit(leader, unitName)) then
			if (EnRT_UnitDebuff(unit, GetSpellInfo(00000)) and not EnRT_Contains(debuffedPlayers, unitName)) then
				debuffedPlayers[#debuffedPlayers+1] = unitName;
				SetRaidTarget(unitName, #debuffedPlayers);
			elseif (EnRT_Contains(debuffedPlayers, unitName)) then
				SetRaidTarget(unitName, 0);
				debuffedPlayers[EnRT_Contains(debuffedPlayers, unitName)] = nil;
			end
		end
		if (UnitIsUnit(unitName, playerName)) then
			if ((not EnRT_UnitDebuff(unit, GetSpellInfo(328495)) or EnRT_UnitDebuff(unit, GetSpellInfo(330848))) and isGlowing) then
				isGlowing = false;
				if (IsAddOnLoaded("Bartender4") and _G["BT4Button"..isGlowing]) then
					ActionButton_HideOverlayGlow(_G["BT4Button"..isGlowing]);
				elseif (IsAddOnLoaded("ElvUI_SLE") and _G["ElvUISLEEnhancedVehicleBarButton"..isGlowing]) then
					ActionButton_HideOverlayGlow(_G["ElvUISLEEnhancedVehicleBarButton"..isGlowing]);
				elseif (IsAddOnLoaded("ElvUI") and _G["ElvUI_Bar1Button"..isGlowing]) then
					ActionButton_HideOverlayGlow(_G["ElvUI_Bar1Button"..isGlowing]);
				else
					ActionButton_HideOverlayGlow(_G["OverrideActionBarButton"..isGlowing]);
				end
			end
			if (EnRT_UnitDebuff(unit, GetSpellInfo(00000)) and not debuffed) then -- unknown spellid Dancing Fever
				debuffed = select(7, EnRT_UnitDebuff(unit, GetSpellInfo(00000)));
				nearby = {};
				f:SetScript("OnUpdate", onUpdate);
			elseif (debuffed) then
				debuffed = false;
				nearby = {};
				timer = nil;
				f:SetScript("OnUpdate", nil);
				C_ChatInfo.SendAddonMessage("EnRT_TCOB", "HIDE", "RAID");
				C_ChatInfo.SendAddonMessage("EnRT_TCOB", "AWAY", "RAID");
			end
		end
	elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and EnRT_CouncilofBloodEnabled and inEncounter) then
		local unit, _, spellID = ...;
		if (UnitIsUnit(unit, playerName) and (spellID == 333837 or spellID == 328595 or spellID == 333835 or spellID == 333836 or spellID == 328593 or spellID == 333838 or spellID == 328596)) then
			if (IsAddOnLoaded("Bartender4") and _G["BT4Button"..isGlowing]) then
				ActionButton_HideOverlayGlow(_G["BT4Button"..isGlowing]);
			elseif (IsAddOnLoaded("ElvUI_SLE") and _G["ElvUISLEEnhancedVehicleBarButton"..isGlowing]) then
				ActionButton_HideOverlayGlow(_G["ElvUISLEEnhancedVehicleBarButton"..isGlowing]);
			elseif (IsAddOnLoaded("ElvUI") and _G["ElvUI_Bar1Button"..isGlowing]) then
				ActionButton_HideOverlayGlow(_G["ElvUI_Bar1Button"..isGlowing]);
			else
				ActionButton_HideOverlayGlow(_G["OverrideActionBarButton"..isGlowing]);
			end
		elseif (not UnitInRaid(unit) and (spellID == 333837 or spellID == 328595 or spellID == 333835 or spellID == 328591 or spellID == 333836 or spellID == 328592 or spellID == 333838 or spellID == 328596)) then
			if (spellID == 333837 or spellID == 328595) then
				glowButton(1);
			elseif (spellID == 333835 or spellID == 328591) then
				glowButton(2);
			elseif (spellID == 333836 or spellID == 328592) then
				glowButton(3);
			elseif (spellID == 333838 or spellID == 328596) then
				glowButton(4);
			end
		end
	elseif (event == "CHAT_MSG_ADDON" and EnRT_CouncilofBloodEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		sender = Ambiguate(sender, "short");
		if (prefix == "EnRT_TCOB") then
			local class = select(2, UnitClass(sender));
			if (class == "MONK" or class == "PALADIN" or class == "PRIEST") then
				local name = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(sender))].colorStr, sender);
				if (msg == "SHOW") then --and not UnitIsUnit(playerName, sender)) then
					if (not EnRT_PopupIsShown()) then
						EnRT_PopupShow("|cFF00FF00DISPEL|r " .. name, 500);
					elseif (EnRT_PopupIsShown() and EnRT_PopupGetText():match("DISPEL") and not EnRT_PopupGetText():match(sender)) then
						local getText = EnRT_PopupGetText();
						EnRT_PopupHide();
						EnRT_PopupShow(getText .. " AND " .. name, 500);
					end
				elseif (msg == "HIDE" and EnRT_PopupIsShown() and EnRT_PopupGetText():match(sender)) then
					if (EnRT_PopupIsShown() and EnRT_PopupGetText():match("DISPEL")) then
						EnRT_PopupHide();
					end
				end
			end
			if (msg == "NEARBY" and not debuffed) then
				local name = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(sender))].colorStr, sender);
				if (not EnRT_PopupIsShown() or not EnRT_PopupGetText():match("Close to")) then
					EnRT_PopupShow("|cFFFF0000Close to:|r \124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. GetRaidTargetIndex(sender) .. ":20\124t" .. name, 5);
				elseif (EnRT_PopupIsShown() and not EnRT_PopupGetText():match(sender)) then 
					local getText = EnRT_PopupGetText();
					EnRT_PopupShow(getText .. " AND \124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. GetRaidTargetIndex(sender) .. ":20\124t" .. name, 5);
				end
			elseif (msg:match("AWAY") and EnRT_PopupIsShown() and not debuffed and EnRT_PopupGetText():match(sender)) then
				if (EnRT_PopupGetText():match(" AND ")) then
					local getText = EnRT_PopupGetText();
					getText = getText:sub(23);
					local tempText = "";
					local test = {strsplit(" ", getText)};
					for k, v in pairs(test) do
						if (not v:match(sender) and tempText == "" and v ~= "AND") then
							tempText = "|cFFFF0000Close to:|r " .. v;
						elseif(not v:match(sender) and v ~= "AND") then
							tempText = tempText .. " AND " .. v;
						end
					end
					EnRT_PopupShow(tempText, 5);
				else
					EnRT_PopupHide();
				end
			end
		end
	elseif (event == "ENCOUNTER_START" and EnRT_CouncilofBloodEnabled) then
		local eID = ...;
		if (eID == 2412) then
			inEncounter = true;
			isGlowing = false;
			timer = nil;
			debuffed = false;
			nearby = {};
			ticks = 0;
			text = nil;
			leader = EnRT_GetRaidLeader();
			f:SetScript("OnUpdate", nil);
		end
	elseif (event == "ENCOUNTER_END" and EnRT_CouncilofBloodEnabled and inEncounter) then
		inEncounter = false;
		isGlowing = false;
		timer = nil;
		debuffed = false;
		nearby = {};
		ticks = 0;
		text = nil;
		f:SetScript("OnUpdate", nil);
	elseif (event ~= "ENCOUNTER_END" and event ~= "ENCOUNTER_START" and event ~= "UNIT_AURA" and event ~= "UNIT_SPELLCAST_SUCCEEDED" and event ~= "PLAYER_LOGIN" and event ~= "CHAT_MSG_ADDON") then
		print(event);
		local msg = ...;
		if (msg:match("Sashy Left")) then
			glowButton(1);
		elseif (msg:match("Boogie Down")) then
			glowButton(2);
		elseif (msg:match("Prance Forward")) then
			glowButton(3);
		elseif (msg:match("Shimmy Right")) then
			glowButton(4);
		end
	end
end);