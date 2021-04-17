local f = CreateFrame("Frame");
local L = IRTLocals;
GUI = nil;
local mazePath = {};
local startLex = {
	[1] = "Most Left",
	[2] = "Left of Center",
	[3] = "Center",
	[4] = "Right of Center",
	[5] = "Most Right",
};
f:RegisterEvent("ENCOUNTER_START");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("ENCOUNTER_END");
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
f:RegisterEvent("CHAT_MSG_ADDON");

C_ChatInfo.RegisterAddonMessagePrefix("IRT_PR");

local function getPath()
	local text = "";
	for row, data in pairs(mazePath) do
		for column, highlighted in pairs(data) do
			if (highlighted) then
				text = text .. "t";
			else
				text = text .. "f";
			end
		end
	end
	return text;
end

local function initGUI()
	GUI = {};
	local frame = CreateFrame("Frame", nil, nil, BackdropTemplateMixin and "BackdropTemplate");
	frame:SetPoint("CENTER", -400, 0);
	frame:SetFrameStrata("TOOLTIP");
	frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", --Set the background and border textures
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 16, 
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	});
	frame:SetBackdropColor(0,0,0,1);
	frame:SetSize(250, 250);
	frame:SetMovable(false);
	frame:EnableMouse(true);
	local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
	title:SetPoint("TOP", 0, -16);
	title:SetText(L.PAINSMITHRAZNAL_GUI_TITLE);
	title:SetFont("Fonts\\FRIZQT__.TTF", 12);
	for row = 1, 5 do
		mazePath[row] = {};
		for column = 1, 5 do
			mazePath[row][column] = false;
			local tileTexture = frame:CreateTexture(nil,"BACKGROUND");
			tileTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\tile.tga");
			tileTexture:SetSize(64, 64);
			local borderTexture = frame:CreateTexture(nil,"BACKGROUND");
			borderTexture:SetTexture("Interface\\addons\\InfiniteRaidTools\\Res\\greenbordertile.tga");
			borderTexture:SetSize(64, 64);
			local button = CreateFrame("Button", "IRT_PainsmithRaznal"..row..column, frame);
			button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
			button:SetSize(30,30);
			button:SetPoint("BOTTOMLEFT", 40+((column-1)*35), 30+((row-1)*35));
			button:SetNormalTexture(tileTexture);
			button:SetScript("OnClick", function(self, buttonClicked)
				if (buttonClicked == "LeftButton") then
					--[[
					if (self:GetNormalTexture():GetTexture() == "Interface\\addons\\InfiniteRaidTools\\Res\\greenbordertile") then
						self:SetNormalTexture("Interface\\addons\\InfiniteRaidTools\\Res\\tile.tga");
					else
						self:SetNormalTexture("Interface\\addons\\InfiniteRaidTools\\Res\\greenbordertile.tga");
					end]]
					self:SetNormalTexture(borderTexture);
					mazePath[row][column] = true;
				elseif (buttonClicked == "RightButton") then
					self:SetNormalTexture(tileTexture);
					mazePath[row][column] = false;
				else
					print(self:GetNormalTexture())
					if (self:GetNormalTexture():GetTexture() == "Interface\\addons\\InfiniteRaidTools\\Res\\greenbordertile") then
						self:SetNormalTexture("Interface\\addons\\InfiniteRaidTools\\Res\\tile.tga");
					else
						self:SetNormalTexture("Interface\\addons\\InfiniteRaidTools\\Res\\greenbordertile.tga");
					end
				end
			end);
			GUI[tonumber(row..column)] = button;
		end
	end
	local printButton = CreateFrame("Button", "IRT_PainsmithRaznalPrintButton", frame , "UIMenuButtonStretchTemplate");
	printButton:SetSize(55,20);
	printButton:SetPoint("BOTTOM", -30, 10);
	printButton:SetText(L.PAINSMITHRAZNAL_GUI_PRINT);
	printButton:SetScript("OnClick", function(self)
		printPath();
	end);
	local sendButton = CreateFrame("Button", "IRT_PainsmithRaznalSendButton", frame , "UIMenuButtonStretchTemplate");
	sendButton:SetSize(55,20);
	sendButton:SetPoint("BOTTOM", -30, 10);
	sendButton:SetText(L.PAINSMITHRAZNAL_GUI_SEND);
	sendButton:SetScript("OnClick", function(self)
		C_ChatInfo.SendAddonMessage("IRT_PR", getPath(), "WHISPER", "Ant");
		printPath();
	end);
	local hideButton = CreateFrame("Button", "IRT_PainsmithRaznalHideButton", frame , "UIMenuButtonStretchTemplate");
	hideButton:SetSize(55,20);
	hideButton:SetPoint("BOTTOM", printButton, "BOTTOM", 60, 0);
	hideButton:SetText(L.PAINSMITHRAZNAL_GUI_HIDE);
	hideButton:SetScript("OnClick", function(self)
		frame:Hide();
	end);
	printButton:Hide();
	--sendButton:Hide();
	GUI.hideButton = hideButton;
	GUI.sendButton = sendButton;
	GUI.printButton = printButton;
	frame:SetScript("OnShow", function(self)
		if (UnitIsUnit(IRT_GetRaidLeader(), UnitGetName("player")) or UnitIsGroupAssistant("player")) then
			printButton:Hide();
			sendButton:Show();
		else
			printButton:Show();
			sendButton:Hide();
		end
	end);
	GUI.title = title;
	GUI.frame = frame;
end

function printPath()
	local text = "IRT Path: ";
	local startColumn = nil;
	for column, highlighted in pairs(mazePath[1]) do
		if (highlighted) then
			startColumn = column;
			text = text .. startLex[startColumn];
			break;
		end
	end
	local currentColumn = startColumn;
	local a = 1;
	for row, data in pairs(mazePath) do
		if (next(mazePath, row)) then
			for i = currentColumn, 20, a do
				if (mazePath[row+1][currentColumn]) then
					text = text .. " UP";
					a = 1;
					break;
				end
				if (mazePath[row][currentColumn+a]) then
					if (a==1) then
						text = text .. " RIGHT";
						currentColumn = currentColumn + a;
					else
						text = text .. " LEFT";
						currentColumn = currentColumn + a;
					end
				end
				if (i==5) then
					a = -1;
				elseif (i == 1) then
					a = 1;
				end
			end
		end
	end
	print(text)
end

local function hideGUI()
	GUI.frame:Hide();
	GUI.frame:EnableMouse(false);
end
local function hideGUI()
	GUI.frame:Show();
	GUI.frame:EnableMouse(true);
end

local function IRT_PainsmithRaznalGUIUpdate()
	if (GUI == nil) then
		initGUI();
	end
	frame:SetMovable(true);
	frame:EnableMouse(true);
	frame:RegisterForDrag("LeftButton");
end

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then 
		if (IRT_PainsmithRaznalEnabled == nil) then IRT_PainsmithRaznalEnabled = true; end
		initGUI();
	elseif (event == "CHAT_MSG_ADDON") then
		local prefix, msg, channel, sender = ...;
		if (prefix == "IRT_PR") then -- and UnitIsUnit(sender, IRT_GetRaidLeader()) or UnitIsGroupAssistant(sender)) then
			print(msg)
			local mazeCode = {};
			local rowCount = 1;
			local columnCount = 1;
			for v in string.gmatch(msg,"%a") do
				if columnCount > 5 then
					columnCount = 1;
					rowCount = rowCount + 1;
				end
				if (v == "t") then
					mazePath[rowCount][columnCount] = true;
					print(GUI[tonumber(rowCount..columnCount)]:GetNormalTexture())
					if (GUI[tonumber(rowCount..columnCount)]:GetNormalTexture():GetTexture() == "Interface\\addons\\InfiniteRaidTools\\Res\\tile") then
						GUI[tonumber(rowCount..columnCount)]:Click();
					end
				else
					mazePath[rowCount][columnCount] = false;
					if (GUI[tonumber(rowCount..columnCount)]:GetNormalTexture():GetTexture() == "Interface\\addons\\InfiniteRaidTools\\Res\\greenbordertile") then
						GUI[tonumber(rowCount..columnCount)]:Click();
					end
				end
				columnCount = columnCount + 1;
			end
		end
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
	elseif (event == "ENCOUNTER_START") then
		if (GUI == nil) then
			initGUI();
		end
	elseif (event == "ENCOUNTER_END") then
	end
end);

local _, logEvent, _, _, _, _, _, _, target, _, _, spellID, _, _, _, stacks = CombatLogGetCurrentEventInfo();