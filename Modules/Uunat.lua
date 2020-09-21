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
	if (hasRelic and IRT_UunatEnabled and inEncounter) then
		ticks = ticks + elapsed;
		if (ticks > 1.5 and resonanceActive > 0) then
			SendChatMessage(hasRelic, "YELL");
			resonanceActive = resonanceActive - ticks;
			ticks = 0;
		elseif (resonanceActive < 0) then
			resonanceActive = 0;
		end
	elseif (yellText and IRT_UunatEnabled and inEncounter) then
		ticks = ticks + elapsed;
		if (ticks > 1.5) then
			SendChatMessage(yellText, "YELL");
			ticks = 0;
		end
	end
end)

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "UNIT_AURA" and IRT_UunatEnabled and inEncounter) then
		local target = UnitName(...);
		if (target == player) then
			if (IRT_UnitBuff(player, GetSpellInfo(284569))) then
				hasRelic = IRT_UunatStormMark .. " STORM " .. IRT_UunatStormMark;
			elseif (IRT_UnitBuff(player, GetSpellInfo(284684))) then
				hasRelic = IRT_UunatVoidMark .. " VOID " .. IRT_UunatVoidMark;
			elseif (IRT_UnitBuff(player, GetSpellInfo(284768))) then
				hasRelic = IRT_UunatOceanMark .. " OCEAN " .. IRT_UunatOceanMark;
			elseif (hasRelic) then
				hasRelic = nil;
			end
			if (IRT_UnitDebuff(player, GetSpellInfo(293661))) then
				yellText = IRT_UunatStormMark;
			elseif (IRT_UnitDebuff(player, GetSpellInfo(293663))) then
				yellText = IRT_UunatVoidMark;
			elseif (IRT_UnitDebuff(player, GetSpellInfo(293662))) then
				yellText = IRT_UunatOceanMark;
			elseif (yellText) then
				yellText = nil;
			end
		end
		if (IRT_UnitDebuff(target, GetSpellInfo(293661)) and resonanceActive == 0) then
			resonanceActive = 16;
		end
	elseif (event == "ENCOUNTER_START" and IRT_UunatEnabled) then
		local eID = ...;
		if (eID == 2273) then
			inEncounter = true;
			hasRelic = nil;
			yellText = nil;
			tikcs = 0;
			resonanceActive = 0;
		end
	elseif (event == "ENCOUNTER_END" and IRT_UunatEnabled) then
		local eID = ...;
		if (eID == 2273) then
			inEncounter = false;
			hasRelic = nil;
			yellText = nil;
			tikcs = 0;
			resonanceActive = 0;
		end
	elseif (event == "PLAYER_LOGIN") then
		if (IRT_UunatEnabled == nil) then IRT_UunatEnabled = true; end
		if (IRT_UunatStormMark == nil) then IRT_UunatStormMark = "{rt6}"; end
		if (IRT_UunatVoidMark == nil) then IRT_UunatVoidMark = "{rt3}"; end
		if (IRT_UunatOceanMark == nil) then IRT_UunatOceanMark = "{rt4}"; end
	end
end);