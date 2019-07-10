local f = CreateFrame("Frame");
local inEncounter = false;
local madeAssignments = false;
local debuffs = {
	[296942] = {
		["msg"] = "{cross} RED {cross}",
		["name"] = "";
	},
	[296939] = {
		["msg"] = "{diamond} PURPLE {diamond}",
		["name"] = "",
	},
	[296940] = {
		["msg"] = "{square} BLUE {square}",
		["name"] = "",
	},
	[296943] = {
		["msg"] = "{triangle} GREEN {triangle}",
		["name"] = "",
	},
	[296938] = {
		["msg"] = "{star} YELLOW {star}",
		["name"] = "",
	},
	[296941] = {
		["msg"] = "{circle} ORANGE {circle}",
		["name"] = "",
	},
};
local master = "";

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");

C_ChatInfo.RegisterAddonMessagePrefix("EnRT_LA");

local function checkDebuffs(pl)
	for spellID, data in pairs(debuffs) do
		if (EnRT_UnitDebuff(pl, GetSpellInfo(spellID))) then
			data.name = pl;
			if (madeAssignments == false) then
				madeAssignments = true;
				C_Timer.After(0.5, function() sortAssignments(); end);
			end
			break;
		end
	end
end

local function sortAssignments()
	if (UnitInRaid(debuffs[296942].name) < UnitInRaid(debuffs[296939].name)) then
		local temp = debuffs[296942].name;
		debuffs[296942].name = debuffs[296939].name;
		debuffs[296939].name = temp;
	end
	if (UnitInRaid(debuffs[296940]) < UnitInRaid(debuffs[296943])) then
		local temp = debuffs[296940].name;
		debuffs[296940].name = debuffs[296943].name;
		debuffs[296943].name = temp;
	end
	if (UnitInRaid(debuffs[296938]) < UnitInRaid(debuffs[296941])) then
		local temp = debuffs[296938].name;
		debuffs[296938].name = debuffs[296941].name;
		debuffs[296941].name = temp;
	end
	for spellID, data in pairs(debuffs) do
		C_ChatInfo.SendChatMessage("EnRT_LA", data.msg, "WHISPER", data.name);
		data.name = "";
	end
	C_Timer.After(10, function() madeAssignments = false; end);
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then 
		if (EnRT_LadyAshvaneEnabled == nil) then EnRT_LadyAshvaneEnabled = true; end
	elseif (event == "UNIT_AURA" and EnRT_LadyAshvaneEnabled and inEncounter) then
		local unit = ...;
		unit = Ambiguate(unit, "all");
		if (GetUnitName("player", true) == master) then
			checkDebuffs(unit);
		end
	elseif (event == "CHAT_MSG_ADDON" and EnRT_LadyAshvaneEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "EnRT_LA") then
			EnRT_ShowPopup(8, msg);
		end
	elseif (event == "ENCOUNTER_START" and EnRT_LadyAshvaneEnabled) then
		local eID = ...;
		if (eID == 2304) then
			inEncounter = true;
			master = EnRT_GetRaidLeader();
		end
	elseif (event == "ENCOUNTER_END" and EnRT_LadyAshvaneEnabled) then
		inEncounter = false;
	end
end);
