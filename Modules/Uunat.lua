local f = CreateFrame("Frame");

f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
local player = UnitName("player");

local hasRelic = nil;
local yellText = nil;
local resonanceActive = false;
local ticks = 0;
local inEncounter = false;

f:SetScript("OnUpdate", function(self, elapsed)
	if (hasRelic and EnRT_UunatEnabled and inEncounter) then
		ticks = ticks + elapsed;
		if (ticks > 1.5 and resonanceActive > 0) then
			SendChatMessage(hasRelic, "YELL");
			resonanceActive = resonanceActive - ticks;
			ticks = 0;
		elseif (resonanceActive < 0) then
			resonanceActive = 0;
		end
	elseif (yellText and EnRT_UunatEnabled and inEncounter) then
		ticks = ticks + elapsed;
		if (ticks > 1.5) then
			SendChatMessage(yellText, "YELL");
			ticks = 0;
		end
	end
end)

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "UNIT_AURA" and EnRT_UunatEnabled and inEncounter) then
		local target = UnitName(...);
		if (target == player) then
			if (EnRT_UnitBuff(player, GetSpellInfo(284569))) then
				hasRelic = EnRT_UunatStormMark .. " STORM " .. EnRT_UunatStormMark;
			elseif (EnRT_UnitBuff(player, GetSpellInfo(284684))) then
				hasRelic = EnRT_UunatVoidMark .. " VOID " .. EnRT_UunatVoidMark;
			elseif (EnRT_UnitBuff(player, GetSpellInfo(284768))) then
				hasRelic = EnRT_UunatOceanMark .. " OCEAN " .. EnRT_UunatOceanMark;
			elseif (hasRelic) then
				hasRelic = nil;
			end
			if (EnRT_UnitDebuff(player, GetSpellInfo(293661))) then
				yellText = EnRT_UunatStormMark;
			elseif (EnRT_UnitDebuff(player, GetSpellInfo(293663))) then
				yellText = EnRT_UunatVoidMark;
			elseif (EnRT_UnitDebuff(player, GetSpellInfo(293662))) then
				yellText = EnRT_UunatOceanMark;
			elseif (yellText) then
				yellText = nil;
			end
		end
		if (EnRT_UnitDebuff(target, GetSpellInfo(293661)) and resonanceActive == 0) then
			resonanceActive = 16;
		end
	elseif (event == "ENCOUNTER_START" and EnRT_UunatEnabled) then
		local eID = ...;
		if (eID == 2273) then
			inEncounter = true;
			hasRelic = nil;
			yellText = nil;
			tikcs = 0;
			resonanceActive = 0;
		end
	elseif (event == "ENCOUNTER_END" and EnRT_UunatEnabled) then
		local eID = ...;
		if (eID == 2273) then
			inEncounter = false;
			hasRelic = nil;
			yellText = nil;
			tikcs = 0;
			resonanceActive = 0;
		end
	elseif (event == "PLAYER_LOGIN") then
		if (EnRT_UunatEnabled == nil) then EnRT_UunatEnabled = true; end
		if (EnRT_UunatStormMark == nil) then EnRT_UunatStormMark = "{rt6}"; end
		if (EnRT_UunatVoidMark == nil) then EnRT_UunatVoidMark = "{rt3}"; end
		if (EnRT_UunatOceanMark == nil) then EnRT_UunatOceanMark = "{rt4}"; end
	end
end);