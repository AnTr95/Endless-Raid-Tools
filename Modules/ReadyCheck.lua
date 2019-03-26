local f = CreateFrame("Frame")
f:RegisterEvent("READY_CHECK_CONFIRM")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("READY_CHECK_FINISHED")
f:RegisterEvent("READY_CHECK")
f:RegisterEvent("CHAT_MSG_RAID")
f:RegisterEvent("CHAT_MSG_RAID_LEADER")
f:RegisterEvent("CHAT_MSG_ADDON")
C_ChatInfo.RegisterAddonMessagePrefix("EnRT_RC")
f:SetPoint("CENTER")
f:SetSize(200,200)
f:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", --Set the background and border textures
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
f:SetBackdropColor(0,0,0,0)
f:SetBackdropBorderColor(169,169,169,0)
local rcStatus = false
local rcSender = ""
local rcButton = CreateFrame("Button", "EnRT_ReadyCheckButton", f, "UIPanelButtonTemplate")
rcButton:SetPoint("CENTER")
rcButton:SetSize(200,80)
rcButton:SetText("I AM READY!")
rcButton:SetScript("OnClick", function(self)
	SendChatMessage("EnRT: I am ready now!", "RAID")
	rcStatus = true
	f:Hide()
	rcButton:Hide()
end)

local rcCloseButton = CreateFrame("Button", "EnRT_ReadyCheckCloseButton", f, "UIPanelButtonTemplate")
rcCloseButton:SetPoint("BOTTOM", 0, 10)
rcCloseButton:SetSize(35,20)
rcCloseButton:SetText("Close")
rcCloseButton:SetScript("OnClick", function(self)
	rcCloseButton:Hide()
	rcText:SetText("")
	rcText:Hide()
	rcButton:Hide()
	f:Hide()
end)
rcCloseButton:Hide()


rcText = f:CreateFontString("nil", "ARTWORK", "GameFontHighlight")
rcText:SetWordWrap(true)
rcText:SetPoint("TOP", 0, -10)
rcText:SetJustifyV("TOP")
rcText:SetText("")
rcText:Hide()
rcButton:Hide()
f:Hide()
f:SetScript("OnEvent", function(self, event, ...)
	if event == "READY_CHECK_CONFIRM" and EnRT_ReadyCheckEnabled then
		local id, response = ...
		local player = UnitName("player")
		local playerIndex = EnRT_GetRaidMemberIndex(player)
		--Sender part
		if rcSender ~= UnitName(id) and rcSender == UnitName("player") and not response and select(2,GetInstanceInfo()) == "raid" and UnitIsVisible(id) then
			if not rcText:IsShown() then 
				rcText:Show()
			end
			if not rcCloseButton:IsShown() then
				rcCloseButton:Show()
			end
			if not f:IsShown() then
				f:Show()
				f:SetBackdropColor(0,0,0,1)
				f:SetBackdropBorderColor(169,169,169,1)
			end
			local playerTargeted = UnitName(id)
			local players = {}
			if rcText:GetText() then
				for s in rcText:GetText():gmatch("[^\r\n]+") do
	    			table.insert(players, s)
				end
			end
			local playerText = string.format("|c%s%s", RAID_CLASS_COLORS[select(2, UnitClass(playerTargeted))].colorStr, UnitName(playerTargeted))
			for k, v in pairs(players) do 
				if playerText == v then
					playerText = ""
					break --return??
				end
			end
			local currentText = rcText:GetText() and rcText:GetText() .. playerText .. '\n' or playerText .. '\n'
			rcText:SetText(currentText)
		end
		--Reciever part
		if select(2,GetInstanceInfo()) == "raid" and playerIndex == id and not response then --Inside a raid instance, the player answered the invites is the player and response was not ready
			f:Show()
			rcButton:Show()
			f:SetBackdropColor(0,0,0,0)
			f:SetBackdropBorderColor(169,169,169,0)
		elseif playerIndex == id and response then
			rcStatus = true
		end
	elseif (event == "CHAT_MSG_RAID" or event == "CHAT_MSG_RAID_LEADER") and EnRT_ReadyCheckEnabled and rcText:IsShown() then
		if rcSender == UnitName("player") then
			local msg, sender = ...
			sender = Ambiguate(sender, "short")
			if msg == "EnRT: I am ready now!" and rcText:GetText():match(sender) then
				local playerText = string.format("|c%s%s", RAID_CLASS_COLORS[select(2, UnitClass(sender))].colorStr, UnitName(sender))
				local currentText = ""
				local players = {}
				if rcText:GetText() then
					for s in rcText:GetText():gmatch("[^\r\n]+") do
	    				table.insert(players, s)
					end
				end
				for k, v in pairs(players) do
					if playerText ~= v then
						currentText = currentText .. v .. '\n'
					end
				end
				if currentText == "" then
					rcText:SetText("")
					rcText:Hide()
					f:Hide()
					rcCloseButton:Hide()
				else
					rcText:SetText(currentText)
				end
			end
		end
	elseif event == "READY_CHECK" and EnRT_ReadyCheckEnabled then
		local sender = ...
		rcStatus = false
		rcSender = sender
		if sender == UnitName("player") then
			rcStatus = true
		end
	elseif event == "CHAT_MSG_ADDON" and EnRT_ReadyCheckEnabled and rcSender == UnitName("player") then
		local prefix, msg, channel, sender = ...;
		if prefix == "EnRT_RC" and msg == "afk" then
			local players = {}
			if rcText:GetText() then
				for s in rcText:GetText():gmatch("[^\r\n]+") do
	    			table.insert(players, s)
				end
			end
			local playerText = string.format("|c%s%s", RAID_CLASS_COLORS[select(2, UnitClass(sender))].colorStr, UnitName(sender))
			for k, v in pairs(players) do 
				if playerText == v then
					playerText = ""
					break
				end
			end
			local currentText = rcText:GetText() and rcText:GetText() .. playerText .. '\n' or playerText .. '\n'
			rcText:SetText(currentText)
		end
	elseif event == "READY_CHECK_FINISHED" and EnRT_ReadyCheckEnabled then
		if not rcStatus and not f:IsShown() and select(2,GetInstanceInfo()) == "raid" then
			f:Show()
			rcButton:Show()
			f:SetBackdropColor(0,0,0,0)
			f:SetBackdropBorderColor(169,169,169,0)
			C_ChatInfo.SendAddonMessage("EnRT_RC", "afk", "RAID")
		end
	elseif event == "PLAYER_LOGIN" then
		if EnRT_ReadyCheckEnabled == nil then EnRT_ReadyCheckEnabled = true end
	end
end)

function EnRT_GetRaidMemberIndex(name)
	for i = 1, GetNumGroupMembers() do
		local raider = "raid"..i
		if UnitName(raider) == name then
			return raider
		end
	end
	return -1
end