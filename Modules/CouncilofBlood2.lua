local f = CreateFrame("Frame");
local inEncounter = false;
local playerName = GetUnitName("player");
local isGlowing = false;

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("CHAT_MSG_SYSTEM");
f:RegisterEvent("UI_INFO_MESSAGE");
f:RegisterEvent("CHAT_MSG_RESTRICTED");
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");

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

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then 
		if (EnRT_CouncilofBloodEnabled == nil) then EnRT_CouncilofBloodEnabled = true; end
	elseif (event == "UNIT_AURA" and EnRT_CouncilofBloodEnabled and inEncounter) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
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
	elseif (event == "ENCOUNTER_START" and EnRT_CouncilofBloodEnabled) then
		local eID = ...;
		if (eID == 0000) then
			inEncounter = true;
			isGlowing = false;
		end
	elseif (event == "ENCOUNTER_END" and EnRT_CouncilofBloodEnabled and inEncounter) then
		inEncounter = false;
		isGlowing = false;
	else
		--print(event);
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