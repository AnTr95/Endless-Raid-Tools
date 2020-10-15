local f = CreateFrame("Frame");
local inEncounter = false;
local playerName = GetUnitName("player");
local isGlowing = false;
--local timer = nil;
local text = nil;
local ticks = 0;
local debuffed = false;
local safe = true;
local nearby = {};

local dfID = GetSpellInfo(342859);

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");
--f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
f:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE");

C_ChatInfo.RegisterAddonMessagePrefix("IRT_TCOB");

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
	C_Timer.After(2, function() 
		removeGlow();
	end);]]
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
	if (debuffed and IRT_TCOBDFEnabled and inEncounter) then
		ticks = ticks + elapsed;
		if (ticks > 0.05) then
			safe = true;
			for i = 1, GetNumGroupMembers() do
				local raider = "raid"..i;
				local name = GetUnitName(raider, true);
				if (UnitIsVisible(raider) and not UnitIsUnit(playerName, name) and not UnitIsDead(raider)) then
					if (IsItemInRange(63427, raider) and not IRT_Contains(nearby, name)) then --Duel range 10y
						safe = false;
						nearby[#nearby+1] = name;
					elseif (IsItemInRange(63427, raider)) then
						safe = false;
					elseif (not IsItemInRange(63427, raider) and IRT_Contains(nearby, name)) then
						nearby[IRT_Contains(nearby, name)] = nil;
					end
				end
			end
			if (safe and IRT_UnitDebuff(playerName, dfID)) then
				if (text == nil) then
					text = "SAFE - " .. math.ceil(debuffed-GetTime()) .. "s";
					SendChatMessage(text, "YELL");
				elseif (text:match("NOT")) then
					text = "SAFE - " .. math.ceil(debuffed-GetTime()) .. "s";
					SendChatMessage(text, "YELL");
				end
				C_ChatInfo.SendAddonMessage("IRT_TCOB", "SHOW", "RAID");
			elseif (not safe and IRT_UnitDebuff(playerName, dfID)) then
				if (text == nil) then
					text = "NOT SAFE - " .. math.ceil(debuffed-GetTime()) .. "s";
					SendChatMessage(text, "YELL");
				elseif (not text:match("NOT")) then
					text = "NOT SAFE - " .. math.ceil(debuffed-GetTime()) .. "s";
					SendChatMessage(text, "YELL");
				end
				C_ChatInfo.SendAddonMessage("IRT_TCOB", "HIDE", "RAID");
			end
			--[[
			if (timer == nil) then
				timer = C_Timer.NewTicker(2, function()
					if(safe) then
						text = "SAFE - " .. math.ceil(debuffed-GetTime());
					else
						text = "NOT SAFE - " .. math.ceil(debuffed-GetTime());
					end
					SendChatMessage(text, "YELL");
				end, 2);
			end]]
			ticks = 0;
		end
	end
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then 
		if (IRT_TCOBDMEnabled == nil) then IRT_TCOBDMEnabled = true; end
		if (IRT_TCOBDFEnabled == nil) then IRT_TCOBDFEnabled = true; end
	elseif (event == "UNIT_AURA" and inEncounter) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (UnitIsUnit(unitName, playerName)) then
			if (IRT_TCOBDMEnabled) then
				if ((not IRT_UnitDebuff(unit, GetSpellInfo(328495)) or IRT_UnitDebuff(unit, GetSpellInfo(330848))) and isGlowing) then
					C_Timer.After(1, function() 
						removeGlow();
					end);
				end
			end
			if (IRT_TCOBDFEnabled) then
				if (IRT_UnitDebuff(unit, dfID) and not debuffed) then -- unknown spellid Dancing Fever
					debuffed = math.floor(GetTime())+5;
					nearby = {};
					f:SetScript("OnUpdate", onUpdate);
				elseif (not IRT_UnitDebuff(unit, dfID) and debuffed) then
					debuffed = false;
					nearby = {};
					if (timer) then
						timer:Cancel();
					end
					--timer = nil;
					text = nil;
					f:SetScript("OnUpdate", nil);
					C_ChatInfo.SendAddonMessage("IRT_TCOB", "HIDE", "RAID");
				end
			end
		end
	--[[
	elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and IRT_TCOBDMEnabled and inEncounter) then
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
	elseif (event == "CHAT_MSG_ADDON" and IRT_TCOBDFEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		sender = Ambiguate(sender, "short");
		if (prefix == "IRT_TCOB") then
			local class = select(2, UnitClass(sender));
			if (class == "MONK" or class == "PALADIN" or class == "PRIEST") then
				local name = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(sender))].colorStr, sender);
				if (msg == "SHOW" and not UnitIsUnit(playerName, sender)) then
					if (not IRT_PopupIsShown()) then
						IRT_PopupShow("|cFF00FF00DISPEL|r " .. name, 500);
					elseif (IRT_PopupIsShown() and IRT_PopupGetText():match("DISPEL") and not IRT_PopupGetText():match(sender)) then
						local getText = IRT_PopupGetText();
						IRT_PopupHide();
						IRT_PopupShow(getText .. " AND " .. name, 500);
					end
				elseif (msg == "HIDE" and IRT_PopupIsShown() and IRT_PopupGetText():match(sender)) then
					if (IRT_PopupIsShown() and IRT_PopupGetText():match("DISPEL")) then
						IRT_PopupHide();
					end
				end
			end
		end
	elseif (event == "ENCOUNTER_START" and (IRT_TCOBDMEnabled or IRT_TCOBDFEnabled)) then
		local eID = ...;
		if (eID == 2412) then
			inEncounter = true;
			isGlowing = false;
			--timer = nil;
			debuffed = false;
			nearby = {};
			ticks = 0;
			text = nil;
			f:SetScript("OnUpdate", nil);
		end
	elseif (event == "ENCOUNTER_END" and inEncounter and (IRT_TCOBDFEnabled or IRT_TCOBDMEnabled)) then
		inEncounter = false;
		isGlowing = false;
		--timer = nil;
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