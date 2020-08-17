local f = CreateFrame("Frame");
local inEncounter = false;
local leader = "";
local debuffed = {};
local playerName = GetUnitName("player");
local groupIcons = {
	["1"] = "STAR",
	["2"] = "CIRCLE",
	["3"] = "DIAMOND",
};


f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");

C_ChatInfo.RegisterAddonMessagePrefix("EnRT_LID");

local function assignMarks()
	local count = 1;
	for i = 1, GetNumGroupMembers() do
		local raider = "raid" ..i;
		local raiderName = GetUnitName(raider, true);
		--assign by group order
		if (EnRT_Contains(debuffed, raiderName)) then
			SetRaidTarget(raiderName, count);
			C_ChatInfo.SendAddonMessage("EnRT_LID", count, "WHISPER", raiderName);
			count = count + 1;
		end
	end
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then 
		if (EnRT_LadyInervaDarkveinEnabled == nil) then EnRT_LadyInervaDarkveinEnabled = true; end
	elseif (event == "UNIT_AURA" and EnRT_LadyInervaDarkveinEnabled and inEncounter) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (UnitIsUnit(leader, playerName)) then
			if (EnRT_UnitDebuff(unit, GetSpellInfo(325064))) then
				if (not EnRT_Contains(debuffed, unitName)) then
					debuffed[#debuffed+1] = unitName;
					if (#debuffed == 3) then
						assignMarks();
					end
				end
			else
				if (EnRT_Contains(debuffed, unitName)) then
					debuffed[EnRT_Contains(debuffed, unitName)] = nil;
					SetRaidTarget(unitName, 0);
					EnRT_PopupHide();
				end
			end
		end
	elseif (event == "CHAT_MSG_ADDON" and EnRT_LadyInervaDarkveinEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "EnRT_LID") then
			EnRT_PopupShow("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t".." MOVE TO " .. groupIcons[mark] .. " NOW " .. "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..mark..":30\124t", 60);
			PlaySoundFile("Interface\\AddOns\\EndlessRaidTools\\Sound\\"..groupIcons[mark]..".ogg", "Master");
		end
	elseif (event == "ENCOUNTER_START" and EnRT_LadyInervaDarkveinEnabled) then
		local eID = ...;
		if (eID == 2406) then
			inEncounter = true;
			leader = EnRT_GetRaidLeader();
			debuffed = {};
		end
	elseif (event == "ENCOUNTER_END" and EnRT_LadyInervaDarkveinEnabled) then
		inEncounter = false;
		debuffed = {};
	end
end);