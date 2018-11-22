local f = CreateFrame("Frame")
SLASH_ENDLESSINNERVATE1 = "/endlessinnervate"
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("PLAYER_LOGIN")
C_ChatInfo.RegisterAddonMessagePrefix("ENDLESS_INN")
local function handler(msg, editbox)
	local arg = string.lower(msg)
	if arg ~= nil and arg ~= "" and UnitIsConnected(arg) and EnRT_InnervateEnabled then
		C_ChatInfo.SendAddonMessage("ENDLESS_INN", UnitName("player"), "WHISPER", arg)
	end
end
SlashCmdList["ENDLESSINNERVATE"] = handler
f:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		if EnRT_InnervateEnabled == nil then EnRT_InnervateEnabled = true end
	end
	if EnRT_InnervateEnabled then
		if event == "CHAT_MSG_ADDON" then
			local prefix, msg, channel, sender = ...
			sender = Ambiguate(sender, "short")
			if prefix == "ENDLESS_INN" then
				EnRT_PopupShow("INNERVATE ON "..sender, 5)
			end
		end
	end
end)