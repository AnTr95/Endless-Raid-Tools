local f = CreateFrame("Frame");

local inEncounter = false;
local master = "";
local cursed = {};
local player = GetUnitName("player");
local curseID = GetSpellInfo(314396);
local marks = {};
local healers = 0;

local RED = "\124cFFFF0000";
local YELLOW = "\124cFFFFFF00";
local GREEN = "\124cFF00FF00";

local colorIndex = {
	[1] = GREEN,
	[2] = GREEN,
	[3] = GREEN,
	[4] = YELLOW,
	[5] = YELLOW,
	[6] = YELLOW,
	[7] = RED,
	[8] = RED,
	[9] = RED,
	[10] = RED,
};

local arrowIndex = {
	["down"] = "\124TInterface\\Buttons\\UI-SortArrow:10:12:6:-13:5:5:0:4:0:4:0:255:0\124t",
	["up"] = "\124TInterface\\Buttons\\UI-SortArrow:10:12:6:-13:5:5:0:4:4:0:255:0:0\124t",
};

local markIndex = {
	[1] = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:10:12:0:-13\124t",
	[2] = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:10:12:0:-13\124t",
	[3] = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:10:12:0:-13\124t",
	[4] = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:10:12:0:-13\124t",
	[5] = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:10:12:0:-13\124t",
	[6] = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:10:12:0:-13\124t",
	[7] = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:10:12:0:-13\124t",
	[8] = "\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:10:12:0:-13\124t",
};

--/run EnRT_InfoBoxShow("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:10:12:0:-13\124t\124cFF00FF00Ant - 1 \124TInterface\\Buttons\\UI-SortArrow:10:12:6:-13:5:5:0:4:4:0:255:0:0\124t")
--/run EnRT_InfoBoxShow("\124cFF00FF00Ant - 1 \124TInterface\\Buttons\\UI-SortArrow:10:12:6:-13:5:5:0:4:0:4:0:255:0\124t")
--/run EnRT_InfoBoxShow("\124cFF00FF00Ant - 1 \124TInterface\\Buttons\\UI-SortArrow:10:12:6:-13:5:5:0:4:4:0:255:0:0\124t\n\124cFFFF0000Alatariel - 10 \124TInterface\\Buttons\\UI-SortArrow:10:12:6:-13:5:5:0:4:0:4:0:255:0\124t")
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("RAID_TARGET_UPDATE");
--f:RegisterEvent("CHAT_MSG_ADDON");
--C_ChatInfo.RegisterAddonMessagePrefix("EnRT_Ilgynoth");

local function compare (a, b)
	return a.Stacks < b.Stacks;
end

local function initMarks()
	healers = 0;
	for i = 1, GetNumGroupMembers() do
		local raider = "raid"..i;
		if (UnitIsConnected(raider) and UnitIsVisible(raider)) then
			if (UnitGroupRolesAssigned(raider) == "HEALER") then
				healers = healers + 1;
			end
		end
	end
	local t = {};
	for i = 1, healers do
		if (i == 1) then
			t.mark = "star";
			t.unused = true;
		elseif (i == 2) then
			t.mark = "circle";
			t.unused = true;
		elseif (i == 3) then
			t.mark = "diamond";
			t.unused = true;
		elseif (i == 4) then 
			t.mark = "triangle";
			t.unused = true;
		elseif (i == 5) then 
			t.mark = "moon";
			t.unused = true;
		elseif(i == 6) then
			t.mark = "square";
			t.unused = true;
		elseif (i == 7) then
			t.mark =  "cross";
			t.unused = true;
		elseif (i == 8)then
			t.mark = "skull";
			t.unused = true;
		end
	end
	for i = healers + 1, 8 do
		if (i == 1) then
			t.mark = "star";
			t.unused = false;
		elseif (i == 2) then
			t.mark = "circle";
			t.unused = false;
		elseif (i == 3) then
			t.mark = "diamond";
			t.unused = false;
		elseif (i == 4) then 
			t.mark = "triangle";
			t.unused = false;
		elseif (i == 5) then 
			t.mark = "moon";
			t.unused = false;
		elseif(i == 6) then
			t.mark = "square";
			t.unused = false;
		elseif (i == 7) then
			t.mark =  "cross";
			t.unused = false;
		elseif (i == 8)then
			t.mark = "skull";
			t.unused = false;
		end
	end
	table.insert(marks, t);
end

local function updateCurses()
	local array = {}
	for name, data in pairs(tbl) do
  		array[#array+1] = {Name = name, Stacks = data.Stacks};
	end
	table.sort(array, compare);


	local text = "";
	for i = 1, #array do
		local pl = array[i].Name;
		local stacks = cursed[pl].Stacks;
		local arrow = cursed[pl].Arrow;
		if (player == master) then
			for j = 1, #marks do
				if (marks[j].unused) then
					marks[j].unused = false;
					cursed[pl].Mark = j;
					SetRaidTarget(pl, j)
					break
				end
			end
			if (i <= healers and cursed[pl].Mark == "") then
				local hStacks = 0;
				local hName = "";
				for name, data in pairs(cursed) do
					local iStacks = data.Stacks;
					local iMark = data.Mark;
					if (stacks < iStacks and iMark ~= "" and highestStacks < iStacks) then
						hStacks = iStacks;
						hName = name;
					end
				end
				if (hName ~= "") then
					local mark = GetRaidTargetIndex(hName);
					cursed[hName].Mark = "";
					SetRaidTarget(hName, 0);
					SetRaidTarget(pl, mark);
					cursed[pl].Mark = mark;
				end
			end 
		end
		local mark = GetRaidTargetIndex(pl);
		if (mark) then
			text = text .. markIndex[mark] .. colorIndex[stacks] .. pl .. " - " .. stacks .. " " .. arrowIndex[arrow] .. "\n";
		else
			text = text .. colorIndex[stacks] .. pl .. " - " .. stacks .. " " .. arrowIndex[arrow] .. "\n";
		end
	end
	EnRT_InfoBoxShow(text);
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (EnRT_IlgynothEnabled == nil) then EnRT_IlgynothEnabled = true; end
	elseif (event == "UNIT_AURA" and inEncounter and EnRT_IlgynothEnabled) then
		local unit = ...;
		local unitName = GetUnitName(unit, true);
		if (EnRT_UnitDebuff(unit, curseID)) then
			if (not EnRT_ContainsKey(cursed, unitName)) then
				local _, _, stacks = EnRT_UnitDebuff(unit, curseID);
				cursed[unitName] = {};
				cursed[unitName].Stacks = stacks;
				cursed[unitName].Arrow = "up";
				cursed[unitName].Mark = "";
				updateCurses();
			else
				local _, _, stacks = EnRT_UnitDebuff(unit, curseID);
				local cStacks = cursed[unitName].Stacks;
				if (cStacks ~= stacks) then
					if (stacks > cStacks) then
						cursed[unitName].Arrow = "up";
					else
						cursed[unitName].Arrow = "down";
					end
					cursed[unitName].Stacks = stacks;
					updateCurses();
				end
			end
		elseif (EnRT_ContainsKey(cursed, unitName)) then
			if (player == master and cursed[unitName].Mark ~= "") then
				SetRaidTarget(unitName, 0);
				marks[cursed[unitName].Mark] = true;
				cursed[unitName].Mark = "";
			end
			cursed[unitName] = nil;
			updateCurses();
			if (#cursed == 0) then
				EnRT_InfoBoxHide();
			end
		end
	elseif (event == "RAID_TARGET_UPDATE" and inEncounter and EnRT_IlgynothEnabled) then
		updateCurses();
	elseif (event == "ENCOUNTER_START"and EnRT_IlgynothEnabled) then
		local eID = ...;
		local difficulty = select(3, GetInstanceInfo());
		if (eID == 2345 and difficulty == 16) then
			cursed = {};
			master = EnRT_GetRaidLeader();
			initMarks();
			inEncounter = true;
		end
	elseif (event == "ENCOUNTER_END" and EnRT_IlgynothEnabled) then
		if (inEncounter) then
			cursed = {};
			master = "";
			inEncounter = false;
		end
	end
end);