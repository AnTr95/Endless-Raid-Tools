local L = IRTLocals;
local f = CreateFrame("Frame");
local addon = ...; -- The name of the addon folder
local version = GetAddOnMetadata(addon, "Version");
SLASH_INFINITERAIDTOOLS1 = "/endlessraidtools";
SLASH_INFINITERAIDTOOLS2 = "/enrt";
SLASH_INFINITERAIDTOOLS3 = "/irt";
SLASH_INFINITERAIDTOOLS4 = "/infiniteraidtools";
local playersChecked = {};
local initCheck = false;
local recievedOutOfDateMessage = false;			

local UnitBuff = UnitBuff;
local UnitDebuff = UnitDebuff;

local function handler(msg, editbox)
	local arg = string.lower(msg);
	if (arg ~= nil and arg == "vc") then
		C_ChatInfo.SendAddonMessage("IRT_VC", "vc", "RAID");
	else
		InterfaceOptionsFrame_OpenToCategory(IRT_GeneralModules);
		InterfaceOptionsFrame_OpenToCategory(IRT_GeneralOptions);
		if (not IRT_GeneralOptions:IsVisible()) then
			InterfaceOptionsFrame_OpenToCategory(IRT_GeneralModules);
			InterfaceOptionsFrame_OpenToCategory(IRT_GeneralOptions);
		end
	end
end
SlashCmdList["INFINITERAIDTOOLS"] = handler;
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("ADDON_LOADED");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("GROUP_ROSTER_UPDATE");
C_ChatInfo.RegisterAddonMessagePrefix("IRT_VC");
C_ChatInfo.RegisterAddonMessagePrefix("IRT_UPDATE");

local function renameWarning()
	local warningFrame = CreateFrame("Frame", nil, nil, BackdropTemplateMixin and "BackdropTemplate");
	warningFrame:SetSize(1000, 170);
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
	DisableAddOn("EndlessRaidTools");

	local closeButton = CreateFrame("Button", nil, warningFrame, "UIPanelButtonTemplate");
	closeButton:SetPoint("BOTTOM", 0, 10);
	closeButton:SetSize(80,25);
	closeButton:SetText("Reload UI");
	closeButton:SetScript("OnClick", function(self)
		ReloadUI();
	end);
	warningFrame:Show();
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "CHAT_MSG_ADDON") then
		local prefix, msg, channel, sender = ...;
		if (prefix == "IRT_VC" and UnitName("player") ~= Ambiguate(sender, "short")) then
			if (msg == "vc") then
				C_ChatInfo.SendAddonMessage("IRT_VC", version, "WHISPER", sender);
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
						IRT_FindMissingPlayers();
						playersChecked = {};
						initCheck = false;
					end);
				end
				sender = Ambiguate(sender, "short");
				playersChecked[#playersChecked+1] = sender;
				print(sender .. "-" .. msg);
			end
		elseif (prefix == "IRT_UPDATE" and UnitName("player") ~= Ambiguate(sender, "short") and not recievedOutOfDateMessage) then
			if (tonumber(msg) ~= nil) then
				if (tonumber(msg) > tonumber(version)) then
					DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000" .. L.WARNING_OUTOFDATEMESSAGE .. "|r");
					recievedOutOfDateMessage = true;
				end
			end
		end
	elseif (event == "GROUP_ROSTER_UPDATE") then
		if (IsInRaid(LE_PARTY_CATEGORY_INSTANCE) or IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) then
			C_ChatInfo.SendAddonMessage("IRT_UPDATE", version, "INSTANCE_CHAT");
		elseif (IsInRaid(LE_PARTY_CATEGORY_HOME)) then
			C_ChatInfo.SendAddonMessage("IRT_UPDATE", version, "RAID");
		elseif (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
			C_ChatInfo.SendAddonMessage("IRT_UPDATE", version, "PARTY");
		end
	elseif (event == "ADDON_LOADED") then
		local loadedAddon = ...;
		if (loadedAddon == "EndlessRaidTools") then
			renameWarning();
		elseif (loadedAddon == addon) then
			if (IsAddOnLoaded("EndlessRaidTools")) then
				renameWarning();
			end
			if (IRT_PopupTextPosition ~= nil) then
				IRT_PopupSetPosition(IRT_PopupTextPosition.point, IRT_PopupTextPosition.relativeTo, IRT_PopupTextPosition.relativePoint, IRT_PopupTextPosition.xOffset, IRT_PopupTextPosition.yOffset);
			end
			if (IRT_PopupTextFontSize == nil) then
				IRT_PopupTextFontSize = 28;
			end
			if (IRT_InfoBoxTextPosition ~= nil) then
				IRT_InfoBoxSetPosition(IRT_InfoBoxTextPosition.point, IRT_InfoBoxTextPosition.relativeTo, IRT_InfoBoxTextPosition.relativePoint, IRT_InfoBoxTextPosition.xOffset, IRT_InfoBoxTextPosition.yOffset);
			end
			if (IRT_InfoBoxTextFontSize == nil) then
				IRT_InfoBoxTextFontSize = 14;
			end
			if (IRT_MinimapDegree) then IRT_SetMinimapPoint(IRT_MinimapDegree); end
			if (IRT_MinimapMode == nil) then IRT_MinimapMode = "Always"; end
			if (IRT_AutoKitPosition ~= nil) then
				IRT_AutoKitSetPosition(IRT_AutoKitPosition.point, IRT_AutoKitPosition.relativeTo, IRT_AutoKitPosition.relativePoint, IRT_AutoKitPosition.xOffset, IRT_AutoKitPosition.yOffset);
			end
			if (IRT_AutoOilPosition ~= nil) then
				IRT_AutoOilSetPosition(IRT_AutoOilPosition.point, IRT_AutoOilPosition.relativeTo, IRT_AutoOilPosition.relativePoint, IRT_AutoOilPosition.xOffset, IRT_AutoOilPosition.yOffset);
			end
			IRT_PopupUpdateFontSize();
			IRT_InfoBoxUpdateFontSize();
			if (IsInGuild()) then
				C_ChatInfo.SendAddonMessage("IRT_UPDATE", version, "GUILD");
			end
		end
	elseif (event == "PLAYER_LOGIN") then
		if (IRT_MinimapMode == "Always") then
			IRT_MinimapButton:Show();
		else
			IRT_MinimapButton:Hide();
		end
	end
end);
function IRT_FindMissingPlayers()
	for i = 1, GetNumGroupMembers() do
		if (not IRT_Contains(playersChecked, UnitName("raid"..i)) and UnitName("raid"..i) ~= UnitName("player")) then
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
function IRT_Contains(arr, value)
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
function IRT_ContainsKey(arr, value)
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

function IRT_UnitBuff(unit, spellName)
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

function IRT_UnitDebuff(unit, spellName)
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

function IRT_GetRaidLeader()
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

function IRT_SetFlagIcon(texture, index)
	local iconSize = 32;
	local columns = 256/iconSize;
	local rows = 64/iconSize;
	local l = mod(index, columns) / columns;
	local r = l + (1/columns);
	local t = floor(index/columns) / rows;
	local b = t + (1/rows);
	texture:SetTexCoord(l,r,t,b);
end