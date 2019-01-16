local f = CreateFrame("Frame");
local inEncounter = false;
local pendingAssignments = false;
shrunkPlayers = {};
intermissionPlayers = {};
local myTarget = "";
local master = "";
local count = 0;
sparkBots = 0;
local htmData = {
	[1] = {
		text = "RED",
		mark = 7,
		color = "|cFFe70d01",
	},
	[2] = {
		text = "PURPLE",
		mark = 3,
		color = "|cFFe575e7",
	},
	[3] = {
		text = "GREEN",
		mark = 4,
		color = "|cFF05e800"
	},
	[4] = {
		text = "YELLOW",
		mark = 1,
		color = "|cFFe1e15e",
	},
	[5] = {
		text = "BLUE",
		mark = 6,
		color = "|cFF01bbe7"
	}
};

f:SetSize(167,70);
f:SetPoint("CENTER");
f:SetMovable(false);
f:EnableMouse(false);
f:SetClampedToScreen(true);
f:RegisterForDrag("LeftButton");
f:SetFrameLevel(1);
f:SetFrameStrata("TOOLTIP");
f:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background", --Set the background and border textures
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
});
f:SetBackdropColor(0,0,0,1);
f:SetBackdropBorderColor(1,0,0,1);
f:SetScript("OnDragStart", f.StartMoving);
f:SetScript("OnDragStop", function(self)
	local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(1)
	EnRT_HTMUIPosition = {}
	EnRT_HTMUIPosition.point = point
	EnRT_HTMUIPosition.relativeTo = relativeTo
	EnRT_HTMUIPosition.relativePoint = relativePoint
	EnRT_HTMUIPosition.xOffset = xOffset
	EnRT_HTMUIPosition.yOffset = yOffset
	self:StopMovingOrSizing()
end);
f:Hide();

local targetText = f:CreateFontString(nil, "ARTWORK", "GameFontNormal");
targetText:SetFont("Fonts\\FRIZQT__.TTF", 15);
targetText:SetPoint("TOP",0,-10);
targetText:SetText("Target: Waiting");
targetText:SetJustifyH("CENTER");

for i = 1, 5 do
	local button = CreateFrame("Button", "EnRT_HTMButton"..i, f, "UIMenuButtonStretchTemplate");
	button:SetSize(28,28);
	button:SetPoint("TOPLEFT", f, "TOPLEFT", 10+((i-1)*30), -30);
	local buttonTexture = button:CreateTexture();
	buttonTexture:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. htmData[i].mark .. ".png");
	buttonTexture:SetSize(20,20);
	buttonTexture:SetPoint("CENTER");
	--[[button:SetBackdrop({
		bgFile = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. htmData[i].mark .. ".png", --Set the background and border textures
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = false, tileSize = 30, edgeSize = 11, 
		insets = { left = 3, right = 4, top = 4, bottom = 5 }
	});]]
	button:SetScript("OnClick", function()
		local target = UnitName("target");
		C_ChatInfo.SendAddonMessage("EnRT_HTM", i, "WHISPER", target);
	end);
end

local function compareAlphabetically(str1, str2)
	local strLetter1 = str1:sub(1,2);
	local strLetter2 = str2:sub(1,2);
	if (strLetter1 == strLetter2) then
		compareAlphabetically(str1:sub(2), str2:sub(2));
	end
	return strLetter1 < strLetter2;
end

local function setMainFramePosition(point, relativeTo, relativePoint, xOffset, yOffset)
	f:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
end

local function showGUI()
	f:SetMovable(true);
	f:EnableMouse(true);
	f:SetUserPlaced(true);
	f:Show();
end

local function hideGUI()
	f:SetMovable(false);
	f:EnableMouse(false);
	f:Hide();
end

f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("UNIT_ENTERED_VEHICLE");
f:RegisterEvent("UNIT_EXITED_VEHICLE");
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("UNIT_AURA");

C_ChatInfo.RegisterAddonMessagePrefix("EnRT_HTM") --MEKKATORQUE too long?

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (EnRT_HTMEnabled == nil) then EnRT_HTMEnabled = true; end
		if (EnRT_HTMUIPosition) then setMainFramePosition(EnRT_HTMUIPosition.point, EnRT_HTMUIPosition.relativeTo, EnRT_HTMUIPosition.relativePoint, EnRT_HTMUIPosition.xOffset, EnRT_HTMUIPosition.yOffset); end
	elseif (event == "UNIT_AURA" and EnRT_HTMEnabled) then
		local unit = ...;
		local plName = GetUnitName(unit, true);
		if (GetUnitName("player", true) == master) then
			--284168
			if (EnRT_UnitDebuff(unit, GetSpellInfo(284168))) then
				if (not EnRT_Contains(shrunkPlayers, plName)) then
					shrunkPlayers[#shrunkPlayers+1] = plName;
					if (not pendingAssignments) then
						pendingAssignments = true;
						C_Timer.After(1, function()
							if (#shrunkPlayers <= 4) then
								table.sort(shrunkPlayers, compareAlphabetically);
								for i = 1, #shrunkPlayers do
									if (i == #shrunkPlayers) then
										C_ChatInfo.SendAddonMessage("EnRT_HTM", shrunkPlayers[1], "WHISPER", shrunkPlayers[i]);
									else
										C_ChatInfo.SendAddonMessage("EnRT_HTM", shrunkPlayers[i+1], "WHISPER", shrunkPlayers[i]);
									end
								end
							end
							pendingAssignments = false;
						end);
					end
				end
			else
				if (EnRT_Contains(shrunkPlayers, plName)) then
					shrunkPlayers[EnRT_Contains(shrunkPlayers, plName)] = nil;
					targetText:SetText("Target: Waiting");
				end
			end
		end
	elseif (event == "CHAT_MSG_ADDON" and EnRT_HTMEnabled) then
		local prefix, msg, channel, sender = ...;
		if (prefix == "EnRT_HTM") then
			if (tonumber(msg)) then
				if (EnRT_PopupIsShown()) then
					EnRT_PopupHide();
				end
				msg = tonumber(msg);
				count = count + 1;
				EnRT_PopupShow(htmData[msg].color .. count .. ". " .. htmData[msg].text, 30);
			else
				targetText:SetText("Target: " .. msg);
				showGUI();
			end
		end
	elseif (event == "UNIT_ENTERED_VEHICLE" and EnRT_HTMEnabled) then
		local unit, _, _, _, _, vID = ...;
		if (UnitName("player") == master and #shrunkPlayers > 4 and vID == 61447) then
			if (#intermissionPlayers == 0) then
				sparkBots = 0;
				for i = 1, 40 do
					local np = "nameplate" .. i;
					if (np) then
						local guid = UnitGUID(np);
						if (guid) then
							local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",guid);
						--145924
							if (tonumber(npcID) and tonumber(npcID) == 145924) then
								sparkBots = sparkBots + 1;
							end
						end
					end
				end
				intermissionPlayers[#intermissionPlayers+1] = UnitName(unit);
				sparkBots = sparkBots - 1;
			else
				local place = #intermissionPlayers;
				intermissionPlayers[#intermissionPlayers+1] = UnitName(unit);
				C_ChatInfo.SendAddonMessage("EnRT_HTM", UnitName(unit), "WHISPER", intermissionPlayers[place]);
				if (sparkBots == 1) then
					C_ChatInfo.SendAddonMessage("EnRT_HTM", UnitName(unit), "WHISPER", intermissionPlayers[1]);
				end
				sparkBots = sparkBots - 1;
			end
		end
		if (UnitName(unit) == UnitName("player")) then
			showGUI();
		end
	elseif (event == "UNIT_EXITED_VEHICLE" and EnRT_HTMEnabled) then
		local unit = ...;
		if (UnitName(unit) == UnitName("player")) then
			C_Timer.After(5, function() 
				hideGUI(); 
				targetText:SetText("Target: Waiting...");
			end);
			EnRT_PopupHide();
			count = 0;
		end
	elseif (event == "ENCOUNTER_START" and EnRT_HTMEnabled) then
		local eID = ...;
		if (eID == 2276) then
			master = EnRT_GetRaidLeader();
			inEncounter = true;
		end
	elseif (event == "ENCOUNTER_END" and EnRT_HTMEnabled) then
		inEncounter = false;
	end
end);


--[[
	Checking if a table PGF_Contains a given value and if it does, what index is the value located at
	param(arr) table
	param(value) T - value to check exists
	return boolean or integer / returns false if the table does not contain the value otherwise it returns the index of where the value is locatedd
]]
function EnRT_Contains(arr, value)
	if value == nil then
		return false
	end
	if arr == nil then
		return false
	end
	for k, v in pairs(arr) do
		if v == value then
			return k
		end
	end
	return false
end

function EnRT_GetRaidLeader()
	for i = 1, GetNumGroupMembers() do
		local raider = "raid"..i
		if select(2, GetRaidRosterInfo(i)) == 2 then
			return GetUnitName(raider, true)
		end
	end
	return ""
end

