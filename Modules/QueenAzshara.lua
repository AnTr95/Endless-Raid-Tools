local f = CreateFrame("Frame");
local inEncounter = false;
local master = "";

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");

C_ChatInfo.RegisterAddonMessagePrefix("IRT_Azshara");

local function initAssignments()
	local debuffs = {
		["soak"] = {},
		["notsoak"] = {},
		["alone"] = {},
		["stack"] = {},
		["move"] = {},
		["stay"] = {},
		["cansoak"] = {},
	};
	local assigned = {};
	local mainSoaker = nil;
	local mainRunner = nil;
	local mainStay = nil;
	local aloneSoakers = 0;

	for i = 1, GetNumGroupMembers() do
		local raider = "raid" .. i;
		if (UnitExists(raider) and UnitIsVisible(raider)) then
			if (IRT_UnitDebuff(raider, GetSpellInfo(299254))) then
				table.insert(debuffs.stack, raider);
			elseif (IRT_UnitDebuff(raider, GetSpellInfo(299255))) then
				table.insert(debuffs.alone, raider);
			else
				table.insert(debuffs.cansoak, raider);
			end
			if (IRT_UnitDebuff(raider, GetSpellInfo(299252))) then
				table.insert(debuffs.move, raider);
			elseif (IRT_UnitDebuff(raider, GetSpellInfo(299253))) then
				table.insert(debuffs.stay, raider);
			end
			if (IRT_UnitDebuff(raider, GetSpellInfo(299249))) then
				table.insert(debuffs.soak, raider);
			elseif (IRT_UnitDebuff(raider, GetSpellInfo(299251))) then
				table.insert(debuffs.notsoak, raider);
			end
		end
	end
	table.sort(debuffs.stack);
	for i, pl in pairs(debuffs.stack) do
		if (IRT_Contains(debuffs.soak, pl)) then
			if (not mainSoaker) then
				mainSoaker = pl;
				SetRaidMark(pl, 1);
				C_ChatInfo.SendAddonMessage("IRT_Azshara", "{Star} SOAK LEADER {Star}", "WHISPER", pl);
			else
				C_ChatInfo.SendAddonMessage("IRT_Azshara", "{Star} SOAK WITH {Star}", "WHISPER", pl);
			end
		elseif (IRT_Contains(debuffs.move, pl)) then
			if (not mainRunner) then
				mainRunner = pl;
				SetRaidMark(pl, 7);
				C_ChatInfo.SendAddonMessage("IRT_Azshara", "{Cross} MARCH LEADER {Cross}", "WHISPER", pl);
			else
				C_ChatInfo.SendAddonMessage("IRT_Azshara", "{Cross} FOLLOW {Cross}", "WHISPER", pl);
			end
		elseif (IRT_Contains(debuffs.stay, pl )) then
			if (not mainStay) then
				mainStay = pl;
				SetRaidMark(pl, 8);
				C_ChatInfo.SendAddonMessage("IRT_Azshara", "{Skull} STACK LEADER {Skull}", "WHISPER", pl);
			else
				C_ChatInfo.SendAddonMessage("IRT_Azshara", "{Skull} STACK ON {Skull}", "WHISPER", pl);
			end
		end
	end
	for i, pl in pairs(debuffs.alone) do
		if (IRT_Contains(debuffs.soak, pl)) then
			table.remove(debuffs.cansoak, pl);
			SetRaidMark(pl, aloneSoakers+2);
			C_ChatInfo.SendAddonMessage("IRT_Azshara", "{rt".. (aloneSoakers+2) .."} SOAKING ALONE {rt" .. (aloneSoakers+2) .. "}", "WHISPER", pl);
			aloneSoakers = aloneSoakers + 1;
			--Add yell soak alone
		end
	end
	---------------------------------
	-------ADDITIONAL SOAKERS--------
	---------------------------------

	----------PRIORITY ONE-----------
	---------ALONE AND STAY----------
	---------------------------------
	for i = aloneSoakers+1, 5 do
		for j, pl in pairs(deubffs.cansoak) do
			if (not IRT_Contains(deubffs.stack, pl) and not IRT_Contains(debuffs.move)) then
				table.remove(debuffs.cansoak, pl);
				SetRaidMark(pl, aloneSoakers+2);
				C_ChatInfo.SendAddonMessage("IRT_Azshara", "{rt".. (aloneSoakers+2) .."} SOAKING ALONE {rt" .. (aloneSoakers+2) .. "}", "WHISPER", pl);
				aloneSoakers = aloneSoakers + 1;
				break;
			end
		end
	end
	----------PRIORITY TWO-----------
	---------STACK AND STAY----------
	---------------------------------
	local memberOne = nil;
	local memberTwo = nil;
	for i = aloneSoakers+1, 5 do
		for j, pl in pairs(deubffs.cansoak) do
			if (not IRT_Contains(debuffs.move)) then
				if (memberOne) then
					memberTwo = pl;
					break;
				else
					memberOne = pl;
				end
			end
		end
		if (memberOne and memberTwo) then
			table.remove(debuffs.cansoak, memberOne);
			table.remove(debuffs.cansoak, memberTwo);
			SetRaidMark(memberOne, aloneSoakers+2);
			C_ChatInfo.SendAddonMessage("IRT_Azshara", "{rt".. (aloneSoakers+2) .."} STACK LEADER {rt" .. (aloneSoakers+2) .. "}", "WHISPER", memberOne);
			C_ChatInfo.SendAddonMessage("IRT_Azshara", "{rt".. (aloneSoakers+2) .."} SOAK WITH {rt" .. (aloneSoakers+2) .. "}", "WHISPER", memberTwo);
			aloneSoakers = aloneSoakers + 1;
		end
	end
	---------PRIORITY THREE----------
	---------ALONE AND MOVE----------
	---------------------------------
	for i = aloneSoakers+1, 5 do
		for j, pl in pairs(deubffs.cansoak) do
			if (not IRT_Contains(deubffs.stack, pl)) then
				table.remove(debuffs.cansoak, pl);
				SetRaidMark(pl, aloneSoakers+2);
				C_ChatInfo.SendAddonMessage("IRT_Azshara", "{rt".. (aloneSoakers+2) .."} SOAKING ALONE {rt" .. (aloneSoakers+2) .. "}", "WHISPER", pl);
				aloneSoakers = aloneSoakers + 1;
				break;
			end
		end
	end
	----------PRIORITY FOUR----------
	----------STACK AND MOVE---------
	---------------------------------
	local memberOne = nil;
	local memberTwo = nil;
	for i = aloneSoakers+1, 5 do
		for j, pl in pairs(deubffs.cansoak) do
			if (memberOne) then
				memberTwo = pl;
				break;
			else
				memberOne = pl;
			end
		end
		if (memberOne and memberTwo) then
			table.remove(debuffs.cansoak, memberOne);
			table.remove(debuffs.cansoak, memberTwo);
			SetRaidMark(memberOne, aloneSoakers+2);
			C_ChatInfo.SendAddonMessage("IRT_Azshara", "{rt".. (aloneSoakers+2) .."} STACK LEADER {rt" .. (aloneSoakers+2) .. "}", "WHISPER", memberOne);
			C_ChatInfo.SendAddonMessage("IRT_Azshara", "{rt".. (aloneSoakers+2) .."} SOAK WITH {rt" .. (aloneSoakers+2) .. "}", "WHISPER", memberTwo);
			aloneSoakers = aloneSoakers + 1;
		end
	end
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IRT_QueenAzsharaEnabled == nil) then IRT_QueenAzsharaEnabled = true; end
	elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and IRT_QueenAzsharaEnabled and inEncounter) then
		local target, guid, spellID = ...;
		if (GetUnitName("player", true) == master and spellID == 299250) then
			initAssignments();
		end
	elseif (event == "CHAT_MSG_ADDON" and IRT_QueenAzsharaEnabled and inEncounter) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "IRT_Azshara" and IRT_QueenAzsharaEnabled) then
			IRT_PopupShow(msg, 20); --change duration to debuff duration
		end
	elseif (event == "ENCOUNTER_START" and IRT_QueenAzsharaEnabled and inEncounter) then
		local eID = ...;
		if (eID == 2299) then
			master = IRT_GetRaidLeader();
			inEncounter = true;
		end
	elseif (event == "ENCOUNTER_END" and IRT_QueenAzsharaEnabled and inEncounter) then
		inEncounter = false;
	end
end);