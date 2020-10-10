local spellNames = {
	2139,
	147362,
	47528,
	47476, 
	78675, 
	96231, 
	15487, 
	1766, 
	57994, 
	6552, 
	116705, 
	106839, 
	183752, 
	187707, 
	171138, 
	119910,
};
local inEncounter = false;
local nextInterrupter = nil;
local f = CreateFrame("Frame");
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
C_ChatInfo.RegisterAddonMessagePrefix("IRT_INTERRUPT");
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
local interruptNext = false;

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IRT_InterruptEnabled == nil) then IRT_InterruptEnabled = true; end
		if (IRT_NextInterrupt == nil) then IRT_NextInterrupt = {[1] = {bossID = 1}}; end
		if (type(IRT_NextInterrupt)) == "string" then  IRT_NextInterrupt = {[1] = {bossID = 1}}; end-- convert people from older version
	elseif (event == "ENCOUNTER_START" and IRT_InterruptEnabled) then
		inEncounter = true;
		local eID = ...;
		for i = 1, #IRT_NextInterrupt do
			if (eID == IRT_NextInterrupt[i].bossID) then
				nextInterrupter = IRT_NextInterrupt[i].NextInterrupter;
			end
		end
	elseif (event == "ENCOUNTER_END" and inEncounter and IRT_InterruptEnabled) then
		inEncounter = false;
		nextInterrupter = nil;
	elseif (event == "CHAT_MSG_ADDON" and IRT_InterruptEnabled) then
		local prefix, msg, channel, sender = ...;
		sender = Ambiguate(sender, "short");
		if (prefix == "IRT_INTERRUPT" and ((UnitInParty(sender) or UnitInRaid(sender)))) then
			IRT_PopupShow("NEXT INTERRUPT IS YOURS!", 7);
			interruptNext = true;
		end
	elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and nextInterrupter and inEncounter and IRT_InterruptEnabled) then
		local unit, _, spell = ...;
		if (unit == "player") then
			if (IRT_Contains(spellNames, spell)) then
				if (interruptNext) then
					IRT_PopupHide();
					interruptNext = false;
				end
				if (nextInterrupter and UnitIsConnected(nextInterrupter) and IsInGroup() and ((UnitInParty(nextInterrupter) or UnitInRaid(nextInterrupter)))) then
					C_ChatInfo.SendAddonMessage("IRT_INTERRUPT", UnitName("player"), "WHISPER", nextInterrupter);
				end
			end
		end
	end
end)
--[[
	Checking if a table contains a given value and if it does, what index is the value located at
	param(arr) table
	param(value) T - value to check exists
	return boolean or integer / returns false if the table does not contain the value otherwise it returns the index of where the value is locatedd
]]
function Endless_Contains(arr, value)
	if (value == nil) then
		return false;
	end
	if (arr == nil) then
		return false;
	end
	for k, v in pairs(arr) do
		if (v == value) then
			return k;
		end
	end
	return false;
end