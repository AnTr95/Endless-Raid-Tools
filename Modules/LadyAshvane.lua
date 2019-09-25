local f = CreateFrame("Frame");
local inEncounter = false;
local madeAssignments = false;
local debuffs = {
	[296942] = {
		["msg"] = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:24\124t GO TO CROSS \124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:24\124t",
		["name"] = "",
		["mark"] = 7,
	},
	[296939] = {
		["msg"] = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:24\124t GO TO DIAMOND \124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:24\124t",
		["name"] = "",
		["mark"] = 3,
	},
	[296940] = {
		["msg"] = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:24\124t GO TO SQUARE \124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:24\124t",
		["name"] = "",
		["mark"] = 6,
	},
	[296943] = {
		["msg"] = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:24\124t GO TO TRIANGLE \124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:24\124t",
		["name"] = "",
		["mark"] = 4,
	},
	[296938] = {
		["msg"] = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:24\124t GO TO STAR \124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:24\124t",
		["name"] = "",
		["mark"] = 1,
	},
	[296941] = {
		["msg"] = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:24\124t GO TO CIRCLE \124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:24\124t",
		["name"] = "",
		["mark"] = 2,
	},
};
local master = "";

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");

C_ChatInfo.RegisterAddonMessagePrefix("EnRT_Ashvane");

local function sortAssignments()
	if (UnitInRaid(debuffs[296942].name) > UnitInRaid(debuffs[296939].name)) then
		if (debuffs[296939].name ~= "Ant") then
			local temp = debuffs[296942].name;
			debuffs[296942].name = debuffs[296939].name;
			debuffs[296939].name = temp;
		end
	end
	if (UnitInRaid(debuffs[296940].name) > UnitInRaid(debuffs[296943].name)) then
		if (debuffs[296943].name ~= "Ant") then
			local temp = debuffs[296940].name;
			debuffs[296940].name = debuffs[296943].name;
			debuffs[296943].name = temp;
		end
	end
	if (UnitInRaid(debuffs[296938].name) > UnitInRaid(debuffs[296941].name)) then
		if (debuffs[296941].name ~= "Ant") then
			local temp = debuffs[296938].name;
			debuffs[296938].name = debuffs[296941].name;
			debuffs[296941].name = temp;
		end
	end
	for spellID, data in pairs(debuffs) do
		C_ChatInfo.SendAddonMessage("EnRT_Ashvane", data.msg, "WHISPER", data.name);
		SetRaidTarget(data.name, data.mark);
		print(data.name .. " - \124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. data.mark .. ":14\124t");
	end
	C_Timer.After(10, function() 
		madeAssignments = false;
		for spellID, data in pairs(debuffs) do
			data.name = "";
		end
		for i = 1, GetNumGroupMembers() do
			local raider = "raid" .. i;
			SetRaidTarget(raider, 0);
		end 
	end);
end

local function checkDebuffs(pl)
	if (EnRT_UnitDebuff(pl, GetSpellInfo(296942))) then
		local spellID = select(10, EnRT_UnitDebuff(pl, GetSpellInfo(296942)));
		debuffs[spellID].name = pl;
		if (madeAssignments == false) then
			C_Timer.After(0.7, function() sortAssignments(); end);
			madeAssignments = true;
		end
	end
end


f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then 
		if (EnRT_LadyAshvaneEnabled == nil) then EnRT_LadyAshvaneEnabled = true; end
	elseif (event == "UNIT_AURA" and EnRT_LadyAshvaneEnabled and inEncounter) then
		local unit = ...;
		if (GetUnitName("player", true) == master) then
			checkDebuffs(GetUnitName(unit, true));
		end
	elseif (event == "CHAT_MSG_ADDON" and EnRT_LadyAshvaneEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "EnRT_Ashvane") then
			EnRT_PopupShow(msg, 10);
		end
	elseif (event == "ENCOUNTER_START" and EnRT_LadyAshvaneEnabled) then
		local eID = ...;
		if (eID == 2304) then
			inEncounter = true;
			madeAssignments = false;
			master = EnRT_GetRaidLeader();
		end
	elseif (event == "ENCOUNTER_END" and EnRT_LadyAshvaneEnabled) then
		inEncounter = false;
	end
end);
