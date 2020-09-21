local L = EnRTLocals;
local f = CreateFrame("Frame");
local addon = ...; -- The name of the addon folder
local version = GetAddOnMetadata(addon, "Version");
SLASH_ENDLESSRAIDTOOLS1 = "/endlessraidtools";
SLASH_ENDLESSRAIDTOOLS2 = "/enrt";
SLASH_ENDLESSRAIDTOOLS3 = "/irt";
SLASH_ENDLESSRAIDTOOLS4 = "/infiniteraidtools";
local playersChecked = {};
local initCheck = false;
local recievedOutOfDateMessage = false;
local function handler(msg, editbox)
	local arg = string.lower(msg);
	if (arg ~= nil and arg == "vc") then
		C_ChatInfo.SendAddonMessage("EnRT_VC", "vc", "RAID");
	else
		InterfaceOptionsFrame_OpenToCategory(EnRT_GeneralOptions);
		if (not EnRT_GeneralOptions:IsVisible()) then
			InterfaceOptionsFrame_OpenToCategory(EnRT_GeneralOptions);
		end
	end
end
SlashCmdList["ENDLESSRAIDTOOLS"] = handler;
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("ADDON_LOADED");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("GROUP_ROSTER_UPDATE");
C_ChatInfo.RegisterAddonMessagePrefix("EnRT_VC");
C_ChatInfo.RegisterAddonMessagePrefix("EnRT_UPDATE");

local function renameWarning()
	local warningFrame = CreateFrame("Frame", nil, nil, BackdropTemplateMixin and "BackdropTemplate");
	warningFrame:SetSize(1000, 150);
	warningFrame:SetPoint("CENTER");
	warningFrame:SetMovable(false);
	warningFrame:EnableMouse(false);
	warningFrame:SetFrameLevel(3);
	warningFrame:SetFrameStrata("TOOLTIP");
	warningFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", --Set the background and border textures
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 16, 
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	});
	warningFrame:SetBackdropColor(0.27,0.5,1,1);
	--warningFrame:SetBackdropColor(0.2,0.4,0.92,1);
	--warningFrame:SetBackdropColor(0.27,0.56,0.92,1);
	--warningFrame:SetBackdropColor(0.13,0.29,0.60,1);

	local warningText = warningFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
	warningText:SetPoint("TOP", 0, -10);
	warningText:SetJustifyV("TOP");
	warningText:SetJustifyH("CENTER");
	warningText:SetSpacing(8);
	warningText:SetText(L.WARNING_DELETE_OLD_FOLDER);

	local closeButton = CreateFrame("Button", nil, warningFrame, "UIPanelButtonTemplate");
	closeButton:SetPoint("BOTTOM", 0, 10);
	closeButton:SetSize(60,25);
	closeButton:SetText("Okay!");
	closeButton:SetScript("OnClick", function(self)
		closeButton:Hide();
		warningText:Hide();
		warningFrame:Hide();
	end);
	warningFrame:Show();
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "CHAT_MSG_ADDON") then
		local prefix, msg, channel, sender = ...;
		if (prefix == "EnRT_VC" and UnitName("player") ~= Ambiguate(sender, "short")) then
			if (msg == "vc") then
				C_ChatInfo.SendAddonMessage("EnRT_VC", version, "WHISPER", sender);
			--[[
			elseif (msg:find("vco") and not recievedOutOfDateMessage) then
			local head, tail, ver = msg:find("([^vco-].*)");
			if (tonumber(ver) ~= nil) then
				if (tonumber(ver) > tonumber(version)) then
					DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00" .. L.WARNING_OUTOFDATEMESSAGE);
					recievedOutOfDateMessage = true;
				end
			end]]
			else
				if (not initCheck) then
					initCheck = true;
					C_Timer.After(2, function() 
						EnRT_FindMissingPlayers();
						playersChecked = {};
						initCheck = false;
					end);
				end
				sender = Ambiguate(sender, "short");
				playersChecked[#playersChecked+1] = sender;
				print(sender .. "-" .. msg);
			end
		elseif (prefix == "EnRT_UPDATE" and UnitName("player") ~= Ambiguate(sender, "short") and not recievedOutOfDateMessage) then
			if (tonumber(msg) ~= nil) then
				if (tonumber(msg) > tonumber(version)) then
					DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000" .. L.WARNING_OUTOFDATEMESSAGE .. "|r");
					recievedOutOfDateMessage = true;
				end
			end
		end
	elseif (event == "GROUP_ROSTER_UPDATE") then
		if (IsInRaid(LE_PARTY_CATEGORY_INSTANCE) or IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) then
			C_ChatInfo.SendAddonMessage("EnRT_UPDATE", version, "INSTANCE_CHAT");
		elseif (IsInRaid(LE_PARTY_CATEGORY_HOME)) then
			C_ChatInfo.SendAddonMessage("EnRT_UPDATE", version, "RAID");
		elseif (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
			C_ChatInfo.SendAddonMessage("EnRT_UPDATE", version, "PARTY");
		end
	elseif (event == "ADDON_LOADED") then
		local loadedAddon = ...;
		if (loadedAddon == "EndlessRaidTools") then
			renameWarning();
		elseif (loadedAddon == addon) then
			if (IsAddOnLoaded("EndlessRaidTools")) then
				renameWarning();
			end
			if (EnRT_PopupTextPosition ~= nil) then
				EnRT_PopupSetPosition(EnRT_PopupTextPosition.point, EnRT_PopupTextPosition.relativeTo, EnRT_PopupTextPosition.relativePoint, EnRT_PopupTextPosition.xOffset, EnRT_PopupTextPosition.yOffset);
			end
			if (EnRT_PopupTextFontSize == nil) then
				EnRT_PopupTextFontSize = 28;
			end
			if (EnRT_InfoBoxTextPosition ~= nil) then
				EnRT_InfoBoxSetPosition(EnRT_InfoBoxTextPosition.point, EnRT_InfoBoxTextPosition.relativeTo, EnRT_InfoBoxTextPosition.relativePoint, EnRT_InfoBoxTextPosition.xOffset, EnRT_InfoBoxTextPosition.yOffset);
			end
			if (EnRT_InfoBoxTextFontSize == nil) then
				EnRT_InfoBoxTextFontSize = 14;
			end
			if (EnRT_MinimapDegree) then EnRT_SetMinimapPoint(EnRT_MinimapDegree); end
			if (EnRT_MinimapMode == nil) then EnRT_MinimapMode = "Always"; end
			EnRT_PopupUpdateFontSize();
			EnRT_InfoBoxUpdateFontSize();
			if (IsInGuild()) then
				C_ChatInfo.SendAddonMessage("EnRT_UPDATE", version, "GUILD");
			end
		end
	elseif (event == "PLAYER_LOGIN") then
		if (EnRT_MinimapMode == "Always") then
			EnRT_MinimapButton:Show();
		else
			EnRT_MinimapButton:Hide();
		end
	end
end);
function EnRT_FindMissingPlayers()
	for i = 1, GetNumGroupMembers() do
		if (not EnRT_Contains(playersChecked, UnitName("raid"..i)) and UnitName("raid"..i) ~= UnitName("player")) then
			print(GetUnitName("raid"..i, true) .. "-not installed");
		end
	end
end
--[[
	Checking if a table contains a given value and if it does, what index is the value located at
	param(arr) table
	param(value) T - value to check exists
	return boolean or integer / returns false if the table does not contain the value otherwise it returns the index of where the value is locatedd
]]
function EnRT_Contains(arr, value)
	if (value == nil) then
		return false;
	end
	if (arr == nil) then
		return false;
	end
	for k, v in pairs(arr) do
		if (v == value) then
			return k;
		end
	end
	return false;
end

--[[
	Checking if a table contains a given value and if it does, what index is the value located at
	param(arr) table
	param(value) T - value to check exists
	return boolean or integer / returns false if the table does not contain the value otherwise it returns the index of where the value is locatedd
]]
function EnRT_ContainsKey(arr, value)
	if (value == nil or arr == nil) then
		return false;
	end
	for k, v in pairs(arr) do
		if (k == value) then
			return true;
		end
	end
	return false;
end

function EnRT_UnitBuff(unit, spellName)
	if (unit and spellName) then
		for i = 1, 100 do
			local name, rank, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff(unit, i);
			if (not name) then
				return
			end
			if (name == spellName) then
				return name, rank, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3;
			end
		end
	end
	return
end

function EnRT_UnitDebuff(unit, spellName)
	if unit and spellName then
		for i = 1, 100 do
			local name, rank, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitDebuff(unit, i);
			if (not name) then
				return
			end
			if (name == spellName) then
				return name, rank, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3
			end
		end
	end
	return
end

function EnRT_GetRaidLeader()
	for i = 1, GetNumGroupMembers() do
		local raider = "raid"..i;
		if select(2, GetRaidRosterInfo(i)) == 2 then
			return GetUnitName(raider, true);
		end
	end
	return "";
end

function sortTableByValue(tbl)
end

function EnRT_SetFlagIcon(texture, index)
	local iconSize = 32;
	local columns = 256/iconSize;
	local rows = 64/iconSize;
	local l = mod(index, columns) / columns;
	local r = l + (1/columns);
	local t = floor(index/columns) / rows;
	local b = t + (1/rows);
	texture:SetTexCoord(l,r,t,b);
end