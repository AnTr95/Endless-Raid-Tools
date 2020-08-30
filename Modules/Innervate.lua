local f = CreateFrame("Frame");
SLASH_ENDLESSINNERVATE1 = "/endlessinnervate";
f:RegisterEvent("CHAT_MSG_ADDON");
f:RegisterEvent("PLAYER_LOGIN");
local timer = nil;
C_ChatInfo.RegisterAddonMessagePrefix("ENDLESS_INN");
local function handler(msg, editbox)
	local arg = string.lower(msg)
	if (arg ~= nil and arg ~= "" and UnitIsConnected(arg) and EnRT_InnervateEnabled) then
		C_ChatInfo.SendAddonMessage("ENDLESS_INN", UnitName("player"), "WHISPER", arg);
	end
end
SlashCmdList["ENDLESSINNERVATE"] = handler;
f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (EnRT_InnervateEnabled == nil) then EnRT_InnervateEnabled = true; end
	elseif (event == "CHAT_MSG_ADDON" and EnRT_InnervateEnabled) then
		local prefix, msg, channel, sender = ...;
		sender = Ambiguate(sender, "short");
		if (prefix == "ENDLESS_INN") then
			sender = string.format("\124c%s%s\124r", RAID_CLASS_COLORS[select(2, UnitClass(sender))].colorStr, sender);
			timer = EnRT_PopupShow("\124TInterface\\Icons\\spell_nature_lightning:30\124t INNERVATE ON " .. sender .. " \124TInterface\\Icons\\spell_nature_lightning:30\124t" , 5);
			f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
			C_Timer.After(5, function()
				f:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
			end);
		end
	elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and EnRT_InnervateEnabled and timer) then
		local unit, _, spellID = ...;
		if (UnitIsUnit(unit, UnitName("player")) and spellID == 29166) then
			if (timer) then
				EnRT_PopupHide();
				timer = nil;
				f:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
			end
		end
	end
end);