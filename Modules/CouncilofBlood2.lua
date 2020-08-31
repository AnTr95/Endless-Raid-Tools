local f = CreateFrame("Frame");
local inEncounter = false;
local playerName = GetUnitName("player");
local isGlowing = false;
local timer = nil;
local text = nil;
local ticks = 0;
local debuffed = false;
local safe = true;
local nearby = {};

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("CHAT_MSG_SYSTEM");
f:RegisterEvent("CHAT_MSG_RESTRICTED");
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
f:RegisterEvent("CHAT_MSG_RAID_BOSS_WHISPER");
f:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE");

C_ChatInfo.RegisterAddonMessagePrefix("EnRT_TCOB");

local function glowButton(button)
	if (isGlowing) then
		if (IsAddOnLoaded("Bartender4") and _G["BT4Button"..isGlowing]) then
			ActionButton_HideOverlayGlow(_G["BT4Button"..isGlowing]);
		elseif (IsAddOnLoaded("ElvUI_SLE") and _G["ElvUISLEEnhancedVehicleBarButton"..isGlowing]) then
			ActionButton_HideOverlayGlow(_G["ElvUISLEEnhancedVehicleBarButton"..isGlowing]);
		elseif (IsAddOnLoaded("ElvUI") and _G["ElvUI_Bar1Button"..isGlowing]) then
			ActionButton_HideOverlayGlow(_G["ElvUI_Bar1Button"..isGlowing]);
		elseif (ActionButton_HideOverlayGlow(_G["OverrideActionBarButton"..isGlowing])) then
			ActionButton_HideOverlayGlow(_G["OverrideActionBarButton"..isGlowing]);
		end
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
	--[[
	C_Timer.After(2.5, function()
		if (isGlowing) then
			print("timer removing glow " .. isGlowing)
			if (IsAddOnLoaded("Bartender4") and _G["BT4Button"..isGlowing]) then
				ActionButton_HideOverlayGlow(_G["BT4Button"..isGlowing]);
			elseif (IsAddOnLoaded("ElvUI_SLE") and _G["ElvUISLEEnhancedVehicleBarButton"..isGlowing]) then
				ActionButton_HideOverlayGlow(_G["ElvUISLEEnhancedVehicleBarButton"..isGlowing]);
			elseif (IsAddOnLoaded("ElvUI") and _G["ElvUI_Bar1Button"..isGlowing]) then
				ActionButton_HideOverlayGlow(_G["ElvUI_Bar1Button"..isGlowing]);
			elseif (ActionButton_HideOverlayGlow(_G["OverrideActionBarButton"..isGlowing])) then
				ActionButton_HideOverlayGlow(_G["OverrideActionBarButton"..isGlowing]);
			end
		end
		isGlowing = false;
	end);]]
	isGlowing = button;
end

local function removeGlow()
	if (isGlowing) then
		if (IsAddOnLoaded("Bartender4") and _G["BT4Button"..isGlowing]) then
			ActionButton_HideOverlayGlow(_G["BT4Button"..isGlowing]);
		elseif (IsAddOnLoaded("ElvUI_SLE") and _G["ElvUISLEEnhancedVehicleBarButton"..isGlowing]) then
			ActionButton_HideOverlayGlow(_G["ElvUISLEEnhancedVehicleBarButton"..isGlowing]);
		elseif (IsAddOnLoaded("ElvUI") and _G["ElvUI_Bar1Button"..isGlowing]) then
			ActionButton_HideOverlayGlow(_G["ElvUI_Bar1Button"..isGlowing]);
		else
			ActionButton_HideOverlayGlow(_G["OverrideActionBarButton"..isGlowing]);
		end
		isGlowing = false;
	end
end

local function onUpdate(self, elapsed)
	if (debuffed and EnRT_TCOBDFEnabled and inEncounter) then
		ticks = ticks + elapsed;
		if (ticks > 0.05) then
			safe = true;
			for i = 1, GetNumGroupMembers() do
				local raider = "raid"..i;
				local name = GetUnitName(raider, true);
				if (UnitIsVisible(raider) and not UnitIsUnit(playerName, name) and not UnitIsDead(raider)) then
					if (IsItemInRange(63427, raider) and not EnRT_Contains(nearby, name)) then --Duel range 10y
						safe = false;
						nearby[#nearby+1] = name;
					elseif (IsItemInRange(63427, raider)) then
						safe = false;
					elseif (not IsItemInRange(63427, raider) and EnRT_Contains(nearby, name)) then
						nearby[EnRT_Contains(nearby, name)] = nil;
					end
				end
			end
			if (safe and EnRT_UnitDebuff(player, GetSpellInfo(342859))) then
				text = "SAFE - " .. debuffed;
				C_ChatInfo.SendAddonMessage("EnRT_TCOB", "SHOW", "RAID");
			elseif (not safe and EnRT_UnitDebuff(player, GetSpellInfo(342859))) then
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
		if (EnRT_TCOBDMEnabled == nil) then EnRT_TCOBDMEnabled = true; end
		if (EnRT_TCOBDFEnabled == nil) then EnRT_TCOBDFEnabled = true; end
	elseif (event == "UNIT_AURA" and inEncounter) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (UnitIsUnit(unitName, playerName)) then
			if (EnRT_TCOBDMEnabled) then
				if ((not EnRT_UnitDebuff(unit, GetSpellInfo(328495)) or EnRT_UnitDebuff(unit, GetSpellInfo(330848))) and isGlowing) then
					C_Timer.After(1, function() 
						removeGlow();
					end);
				end
			end
			if (EnRT_TCOBDFEnabled) then
				if (EnRT_UnitDebuff(unit, GetSpellInfo(342859)) and not debuffed) then -- unknown spellid Dancing Fever
					debuffed = select(7, EnRT_UnitDebuff(unit, GetSpellInfo(342859)));
					nearby = {};
					f:SetScript("OnUpdate", onUpdate);
				elseif (debuffed) then
					debuffed = false;
					nearby = {};
					timer = nil;
					f:SetScript("OnUpdate", nil);
					C_ChatInfo.SendAddonMessage("EnRT_TCOB", "HIDE", "RAID");
				end
			end
		end
	--[[
	elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and EnRT_TCOBDMEnabled and inEncounter) then
		local unit, _, spellID = ...;
		if (not UnitInRaid(unit) and (spellID == 328595 or spellID == 328591 or spellID == 328592 or spellID == 328596)) then
			if (spellID == 328595 and not isGlowing) then
				glowButton(1);
			elseif (spellID == 328591 and not isGlowing) then
				glowButton(2);
			elseif (spellID == 328592 and not isGlowing) then
				glowButton(3);
			elseif (spellID == 328596 and not isGlowing) then
				glowButton(4);
			end
		end]]
	elseif (event == "CHAT_MSG_ADDON" and EnRT_TCOBDFEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		sender = Ambiguate(sender, "short");
		if (prefix == "EnRT_TCOB") then
			local class = select(2, UnitClass(sender));
			if (class == "MONK" or class == "PALADIN" or class == "PRIEST") then
				local name = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(sender))].colorStr, sender);
				if (msg == "SHOW" and not UnitIsUnit(playerName, sender)) then
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
		end
	elseif (event == "ENCOUNTER_START" and (EnRT_TCOBDMEnabled or EnRT_TCOBDFEnabled)) then
		local eID = ...;
		if (eID == 2412) then
			inEncounter = true;
			isGlowing = false;
			timer = nil;
			debuffed = false;
			nearby = {};
			ticks = 0;
			text = nil;
			f:SetScript("OnUpdate", nil);
		end
	elseif (event == "ENCOUNTER_END" and inEncounter and (EnRT_TCOBDFEnabled or EnRT_TCOBDMEnabled)) then
		inEncounter = false;
		isGlowing = false;
		timer = nil;
		debuffed = false;
		nearby = {};
		ticks = 0;
		text = nil;
		f:SetScript("OnUpdate", nil);
	elseif (inEncounter and event == "CHAT_MSG_RAID_BOSS_EMOTE") then
		local msg = ...;
		if (msg:match("Sashay Left")) then
			glowButton(1);
		elseif (msg:match("Prance Forward")) then
			glowButton(2);
		elseif (msg:match("Boogie Down")) then
			glowButton(3);
		elseif (msg:match("Shimmy Right")) then
			glowButton(4);
		end
	end
end);