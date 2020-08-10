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
C_ChatInfo.RegisterAddonMessagePrefix("EndlessInterrupt");
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
local interruptNext = false;

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (EnRT_InterruptEnabled == nil) then EnRT_InterruptEnabled = true; end
		if (EnRT_NextInterrupt == nil) then EnRT_NextInterrupt = {[1] = {bossID = 1}}; end
		if (type(EnRT_NextInterrupt)) == "string" then  EnRT_NextInterrupt = {[1] = {bossID = 1}}; end-- convert people from older version
	elseif (event == "ENCOUNTER_START" and EnRT_InterruptEnabled) then
		inEncounter = true;
		local eID = ...;
		for i = 1, #EnRT_NextInterrupt do
			if (eID == EnRT_NextInterrupt[i].bossID) then
				nextInterrupter = EnRT_NextInterrupt[i].NextInterrupter;
			end
		end
	elseif (event == "ENCOUNTER_END" and inEncounter and EnRT_InterruptEnabled) then
		inEncounter = false;
		nextInterrupter = nil;
	elseif (event == "CHAT_MSG_ADDON" and EnRT_InterruptEnabled) then
		local prefix, msg, channel, sender = ...;
		sender = Ambiguate(sender, "short");
		if (prefix == "EndlessInterrupt" and ((UnitInParty(sender) or UnitInRaid(sender)))) then
			EnRT_PopupShow("NEXT INTERRUPT IS YOURS!", 7);
			interruptNext = true;
		end
	elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and nextInterrupter and inEncounter and EnRT_InterruptEnabled) then
		local unit, _, spell = ...;
		if (unit == "player") then
			if (EnRT_Contains(spellNames, spell)) then
				if (interruptNext) then
					EnRT_PopupHide();
					interruptNext = false;
				end
				if (nextInterrupter and UnitIsConnected(nextInterrupter) and IsInGroup() and ((UnitInParty(nextInterrupter) or UnitInRaid(nextInterrupter)))) then
					C_ChatInfo.SendAddonMessage("EndlessInterrupt", UnitName("player"), "WHISPER", nextInterrupter);
				end
			end
		end
	end
end)