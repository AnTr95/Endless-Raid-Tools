local f = CreateFrame("Frame");
local inEncounter = false;
local leader = "";
local playerName = GetUnitName("player");
local traceKey = false;
local hooked = false;

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");

C_ChatInfo.RegisterAddonMessagePrefix("EnRT_TCOB");

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then 
		if (EnRT_CouncilofBloodEnabled == nil) then EnRT_CouncilofBloodEnabled = true; end
	elseif (event == "UNIT_AURA" and EnRT_CouncilofBloodEnabled and inEncounter) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (UnitIsUnit(unitName, playerName)) then
			if (EnRT_UnitDebuff(unit, GetSpellInfo(328495)) and not traceKey and not EnRT_UnitDebuff(unit, GetSpellInfo(330848))) then
				traceKey = true;
			elseif ((not EnRT_UnitDebuff(unit, GetSpellInfo(328495)) and traceKey) or (EnRT_UnitDebuff(unit, GetSpellInfo(330848)) and traceKey)) then
				if (traceKey) then
					traceKey = false;
					if (IsAddOnLoaded("Bartender4") and _G["BT4Button1"]) then
						for i = 1, 4 do
							ActionButton_HideOverlayGlow(_G["BT4Button"..i]);
						end
					elseif (IsAddOnLoaded("ElvUI_SLE") and _G["ElvUISLEEnhancedVehicleBarButton1"]) then
						for i = 1, 4 do
							ActionButton_HideOverlayGlow(_G["ElvUISLEEnhancedVehicleBarButton"..i]);
						end
					elseif (IsAddOnLoaded("ElvUI") and _G["ElvUI_Bar1Button1"]) then
						for i = 1, 4 do
							ActionButton_HideOverlayGlow(_G["ElvUI_Bar1Button"..i]);
						end
					else
						for i = 1, 4 do
							ActionButton_HideOverlayGlow(_G["OverrideActionBarButton"..i]);
						end
					end
				end
			end
		end
	elseif (event == "CHAT_MSG_ADDON" and EnRT_CouncilofBloodEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "EnRT_TCOB" and traceKey) then
			msg = msg:sub(strlen(msg));
			if (tonumber(msg)) then
				msg = tonumber(msg);
				if (IsAddOnLoaded("Bartender4") and _G["BT4Button"..msg]) then
					for i = 1, 4 do
						ActionButton_HideOverlayGlow(_G["BT4Button"..i]);
					end
				elseif (IsAddOnLoaded("ElvUI_SLE") and _G["ElvUISLEEnhancedVehicleBarButton"..msg]) then
					for i = 1, 4 do
						ActionButton_HideOverlayGlow(_G["ElvUISLEEnhancedVehicleBarButton"..i]);
					end
				elseif (IsAddOnLoaded("ElvUI") and _G["ElvUI_Bar1Button"..msg]) then
					for i = 1, 4 do
						ActionButton_HideOverlayGlow(_G["ElvUI_Bar1Button"..i]);
					end
				else
					for i = 1, 4 do
						ActionButton_HideOverlayGlow(_G["OverrideActionBarButton"..i]);
					end
				end
				if (IsAddOnLoaded("Bartender4") and _G["BT4Button"..msg]) then
					ActionButton_ShowOverlayGlow(_G["BT4Button"..msg]);
				elseif (IsAddOnLoaded("ElvUI_SLE") and _G["ElvUISLEEnhancedVehicleBarButton"..msg]) then
					ActionButton_ShowOverlayGlow(_G["ElvUISLEEnhancedVehicleBarButton"..msg]);
				elseif (IsAddOnLoaded("ElvUI") and _G["ElvUI_Bar1Button"..msg]) then
					ActionButton_ShowOverlayGlow(_G["ElvUI_Bar1Button"..msg]);
				else
					ActionButton_ShowOverlayGlow(_G["OverrideActionBarButton"..msg]);
				end
			end
		end
	elseif (event == "ENCOUNTER_START" and EnRT_CouncilofBloodEnabled) then
		local eID = ...;
		if (eID == 0000) then
			inEncounter = true;
			traceKey = false;
			leader = EnRT_GetRaidLeader();
			if (UnitIsUnit(leader, playerName) and hooked == false) then
				hooked = true;
				if (IsAddOnLoaded("Bartender4") and _G["BT4Button1"]) then
					for i = 1, 4 do
						_G["BT4Button"..i]:HookScript("OnClick", function(self)
							if (traceKey) then
								C_ChatInfo.SendAddonMessage("EnRT_TCOB", self:GetName(), "RAID");
							end
						end);
					end
				elseif (IsAddOnLoaded("ElvUI_SLE") and _G["ElvUISLEEnhancedVehicleBarButton1"]) then
					for i = 1, 4 do
						_G["ElvUISLEEnhancedVehicleBarButton"..i]:HookScript("OnClick", function(self)
							if (traceKey) then
								C_ChatInfo.SendAddonMessage("EnRT_TCOB", self:GetName(), "RAID");
							end
						end);
					end
				elseif (IsAddOnLoaded("ElvUI") and _G["ElvUI_Bar1Button1"]) then
					for i = 1, 4 do
						_G["ElvUI_Bar1Button"..i]:HookScript("OnClick", function(self)
							if (traceKey) then
								C_ChatInfo.SendAddonMessage("EnRT_TCOB", self:GetName(), "RAID");
							end
						end);
					end
				else
					for i = 1, 4 do
						_G["OverrideActionBarButton"..i]:HookScript("OnClick", function(self)
							if (traceKey) then
								C_ChatInfo.SendAddonMessage("EnRT_TCOB", self:GetName(), "RAID");
							end
						end);
					end
				end
			elseif (hooked == false) then
				hooked = true;
				if (IsAddOnLoaded("Bartender4") and _G["BT4Button1"]) then
					for i = 1, 4 do
						_G["BT4Button"..i]:HookScript("OnClick", function(self)
							if (traceKey) then
								ActionButton_HideOverlayGlow(_G["BT4Button"..i]);
							end
						end);
					end
				elseif (IsAddOnLoaded("ElvUI_SLE") and _G["ElvUISLEEnhancedVehicleBarButton1"]) then
					for i = 1, 4 do
						_G["ElvUISLEEnhancedVehicleBarButton"..i]:HookScript("OnClick", function(self)
							if (traceKey) then
								ActionButton_HideOverlayGlow(_G["ElvUISLEEnhancedVehicleBarButton"..i]);
							end
						end);
					end
				elseif (IsAddOnLoaded("ElvUI") and _G["ElvUI_Bar1Button1"]) then
					for i = 1, 4 do
						_G["ElvUI_Bar1Button"..i]:HookScript("OnClick", function(self)
							if (traceKey) then
								ActionButton_HideOverlayGlow(_G["ElvUI_Bar1Button"..i]);
							end
						end);
					end
				else
					for i = 1, 4 do
						_G["OverrideActionBarButton"..i]:HookScript("OnClick", function(self)
							if (traceKey) then
								ActionButton_HideOverlayGlow(_G["OverrideActionBarButton"..i]);
							end
						end);
					end
				end
			end
		end
	elseif (event == "ENCOUNTER_END" and EnRT_CouncilofBloodEnabled and inEncounter) then
		inEncounter = false;
		traceKey = false;
	end
end);