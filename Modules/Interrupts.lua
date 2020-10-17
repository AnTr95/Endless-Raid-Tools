local L = IRTLocals;
local spellIDs = {
	[2139] = "",
	[147362] = "",
	[47528] = "",
	[47476] = "", 
	[78675] = "", 
	[96231] = "", 
	[15487] = "", 
	[1766] = "", 
	[57994] = "", 
	[6552] = "", 
	[116705] = "", 
	[106839] = "", 
	[183752] = "", 
	[187707] = "", 
	[171138] = "", 
	[119910] = "",
};
local inEncounter = false;
local nextInterrupter = "Antv";
local interruptNext = false;
local playerName = UnitName("player");
local nameplateTrack = nil;
local nameplateID = nil;
local timer = nil;

local UnitIsUnit = UnitIsUnit;
local UnitGUID = UnitGUID;

local f = CreateFrame("Frame");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
f:RegisterEvent("NAME_PLATE_UNIT_REMOVED");

local nameplateText = f:CreateFontString(nil, "ARTWORK", "GameFontNormal");
nameplateText:SetText(L.INTERRUPT_NEXT);
nameplateText:SetFont("Fonts\\frizqt__.ttf", 16);

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IRT_InterruptEnabled == nil) then IRT_InterruptEnabled = true; end
		if (IRT_NextInterrupt == nil) then IRT_NextInterrupt = {[1] = {bossID = 1}}; end
		if (type(IRT_NextInterrupt)) == "string" then IRT_NextInterrupt = {[1] = {bossID = 1}}; end-- convert people from older version
	elseif (event == "NAME_PLATE_UNIT_REMOVED" and IRT_InterruptEnabled and nextInterrupter and inEncounter) then
		local unit = ...;
		if (nameplateID and UnitIsUnit(unit, nameplateID)) then
			if (timer) then
				timer:Cancel();
			end
			nameplateText:Hide();
			nameplateText:ClearAllPoints();
			nameplateTrack = nil;
		end
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED" and IRT_InterruptEnabled and nextInterrupter and inEncounter) then
		local _, logEvent, _, _, caster, _, _, targetGUID, target, _, _, spellID = CombatLogGetCurrentEventInfo();
		if (logEvent == "SPELL_CAST_SUCCESS") then
			if (UnitIsUnit(caster, nextInterrupter) and spellIDs[spellID]) then
				for i = 1, 40 do
					local npGUID = UnitGUID("nameplate"..i);
					if (npGUID and UnitIsUnit(npGUID, targetGUID)) then
						if (not nameplateTrack or not UnitIsUnit(nameplateTrack.UnitFrame.unit, targetGUID)) then
							if (timer) then
								timer:Cancel();
							end
							nameplateID = "nameplate"..i;
							IRT_PopupShow("NEXT INTERRUPT IS YOURS!", 8);
							nameplateTrack = C_NamePlate.GetNamePlateForUnit("nameplate"..i);
							nameplateText:ClearAllPoints();
							nameplateText:SetPoint("BOTTOM", nameplateTrack, "TOP", 0, 2);
							nameplateText:Show();
							timer = C_Timer.NewTimer(30, function() 
								nameplateText:Hide();
								nameplateText:ClearAllPoints();
							end);
							break;
						else
							IRT_PopupShow("NEXT INTERRUPT IS YOURS!", 8);
							nameplateText:Show();
						end
					end
				end
			elseif (UnitIsUnit(caster, playerName)) then
				if (spellIDs[spellID]) then
					if (IRT_PopupGetText() == "NEXT INTERRUPT IS YOURS!") then
						IRT_PopupHide();
					end
					if (timer) then
						timer:Cancel();
					end
					nameplateText:Hide();
					nameplateText:ClearAllPoints();
				end
			end
		elseif (logEvent == "UNIT_DEAD") then
			if (nameplateID and UnitIsUnit(target, nameplateID)) then
				if (timer) then
					timer:Cancel();
				end
				nameplateText:Hide();
				nameplateText:ClearAllPoints();
				nameplateTrack = nil;
				if (IRT_PopupGetText() == "NEXT INTERRUPT IS YOURS!") then
					IRT_PopupHide();
				end
			end
		end
	elseif (event == "ENCOUNTER_START" and IRT_InterruptEnabled) then
		inEncounter = true;
		local eID = ...;
		for i = 1, #IRT_NextInterrupt do
			if (eID == IRT_NextInterrupt[i].bossID) then
				nextInterrupter = IRT_NextInterrupt[i].NextInterrupter;
			end
		end
		if (nextInterrupter and (not UnitExists(nextInterrupter) or not UnitIsConnected(nextInterrupter))) then
			print(L.INTERRUPT_ERROR1 .. "|cFFFFFFFF" .. nextInterrupter .. "|r" .. L.INTERRUPT_ERROR2);
			nextInterrupter = nil;
		end
	elseif (event == "ENCOUNTER_END" and inEncounter and IRT_InterruptEnabled) then
		inEncounter = false;
		nextInterrupter = nil;
		IRT_PopupHide();
		if (timer) then
			timer:Cancel();
		end
		nameplateText:Hide();
	end
end)