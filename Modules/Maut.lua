local f = CreateFrame("Frame");
local inEncounter = false;

f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("PLAYER_LOGIN");

f:SetScript("OnEvent" function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
	elseif (event == "UNIT_AURA") then
	elseif (event == "ENCOUNTER_START") then
		local eID = ...;
		if (eID == 2327 and EnRT_MautEnabled) then
			inEncounter = true;
		end
	elseif (event == "ENCOUNTER_END") then
		if (eID == 2327 and EnRT_MautEnabled) then
			inEncounter = false;
			--remove data + clear marks
		end
	end
end);