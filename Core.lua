local f = CreateFrame("Frame")
local addon = ...
SLASH_ENDLESSRAIDTOOLS1 = "/endlessraidtools"
SLASH_ENDLESSRAIDTOOLS2 = "/enrt"
local playersChecked = {}
local initCheck = false
local function handler(msg, editbox)
	local arg = string.lower(msg)
	if arg ~= nil and arg == "vc" then
		C_ChatInfo.SendAddonMessage("EnRT_VC", "vc", "RAID")
	else
		InterfaceOptionsFrame_OpenToCategory(EnRT_GeneralModules)
		if not EnRT_GeneralModules:IsVisible() then
			InterfaceOptionsFrame_OpenToCategory(EnRT_GeneralModules)
		end
	end
end
SlashCmdList["ENDLESSRAIDTOOLS"] = handler
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN");
C_ChatInfo.RegisterAddonMessagePrefix("EnRT_VC")
f:SetScript("OnEvent", function(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
		local prefix, msg, channel, sender = ...
		if prefix == "EnRT_VC" then
			if msg == "vc" then
				C_ChatInfo.SendAddonMessage("EnRT_VC", GetAddOnMetadata(addon, "Version"), "WHISPER", sender)
			else
				if not initCheck then
					initCheck = true
					C_Timer.After(2, function() 
						EnRT_FindMissingPlayers()
						playersChecked = {}
						initCheck = false
					end)
				end
				sender = Ambiguate(sender, "short")
				playersChecked[#playersChecked+1] = sender
				print(sender .. "-" .. msg)
			end
		end
	elseif event == "ADDON_LOADED" and addon == ... then
		if EnRT_PopupTextPosition ~= nil then
			EnRT_PopupSetPosition(EnRT_PopupTextPosition.point, EnRT_PopupTextPosition.relativeTo, EnRT_PopupTextPosition.relativePoint, EnRT_PopupTextPosition.xOffset, EnRT_PopupTextPosition.yOffset)
		end
		if EnRT_PopupTextFontSize == nil then
			EnRT_PopupTextFontSize = 28
		end
		if EnRT_InfoBoxTextPosition ~= nil then
			EnRT_InfoBoxSetPosition(EnRT_InfoBoxTextPosition.point, EnRT_InfoBoxTextPosition.relativeTo, EnRT_InfoBoxTextPosition.relativePoint, EnRT_InfoBoxTextPosition.xOffset, EnRT_InfoBoxTextPosition.yOffset)
		end
		if EnRT_InfoBoxTextFontSize == nil then
			EnRT_InfoBoxTextFontSize = 22
		end
		if (EnRT_MinimapDegree) then EnRT_SetMinimapPoint(EnRT_MinimapDegree); end
		if (EnRT_MinimapMode == nil) then EnRT_MinimapMode = "Always"; end
		EnRT_PopupUpdateFontSize()
		EnRT_InfoBoxUpdateFontSize()
	elseif (event == "PLAYER_LOGIN") then
		if (EnRT_MinimapMode == "Always") then
			EnRT_MinimapButton:Show();
		else
			EnRT_MinimapButton:Hide();
		end
	end
end)
function EnRT_FindMissingPlayers()
	for i = 1, GetNumGroupMembers() do
		if not Endless_Contains(playersChecked, UnitName("raid"..i)) and UnitName("raid"..i) ~= UnitName("player") then
			print(GetUnitName("raid"..i, true) .. "-not installed")
		end
	end
end
--[[
	Checking if a table contains a given value and if it does, what index is the value located at
	param(arr) table
	param(value) T - value to check exists
	return boolean or integer / returns false if the table does not contain the value otherwise it returns the index of where the value is locatedd
]]
function Endless_Contains(arr, value)
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
	if unit and spellName then
		for i = 1, 100 do
			local name, rank, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitBuff(unit, i);
			if not name then
				return
			end
			if name == spellName then
				return name, rank, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3
			end
		end
	end
	return
end

function EnRT_UnitDebuff(unit, spellName)
	if unit and spellName then
		for i = 1, 100 do
			local name, rank, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3 = UnitDebuff(unit, i);
			if not name then
				return
			end
			if name == spellName then
				return name, rank, count, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, nameplateShowAll, timeMod, value1, value2, value3
			end
		end
	end
	return
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