local f2 = CreateFrame("Frame")--, nil, nil, BackdropTemplateMixin and "BackdropTemplate");
f2:SetMovable(false);
f2:EnableMouse(false);
f2:SetFrameLevel(3);
f2:SetFrameStrata("FULLSCREEN");
f2:SetHeight(25);
f2:SetWidth(265);
f2:Hide();
--[[
f2:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", --Set the background and border textures
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
});
f2:SetBackdropColor(0.3,0.3,0.3,0.6);
f2:Hide();

local texture = f2:CreateTexture();
texture:SetTexture(0.5, 0.5, 0.5, 0.5);
texture:SetAllPoints();

local point, relativeTo, relativePoint, xOfs, yOfs = ReadyCheckFrameText:GetPoint();
ReadyCheckFrameText:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs+13);
point, relativeTo, relativePoint, xOfs, yOfs = ReadyCheckFrameYesButton:GetPoint();
ReadyCheckFrameYesButton:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs-10);
point, relativeTo, relativePoint, xOfs, yOfs = ReadyCheckFrameNoButton:GetPoint();
ReadyCheckFrameNoButton:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs-10);
]]
local buffBackgroundTextureTop1 = f2:CreateTexture(nil, "ARTWORK");
buffBackgroundTextureTop1:SetTexture("Interface\\RAIDFRAME\\UI-ReadyCheckFrame");
buffBackgroundTextureTop1:SetWidth(265);
buffBackgroundTextureTop1:SetHeight(5);
buffBackgroundTextureTop1:SetTexCoord(0.12,0.59,0.07,0.12);
buffBackgroundTextureTop1:SetPoint("TOPLEFT", 0,-5);
local buffBackgroundTextureCenter = f2:CreateTexture(nil, "BACKGROUND");
buffBackgroundTextureCenter:SetTexture("Interface\\RAIDFRAME\\UI-ReadyCheckFrame");
buffBackgroundTextureCenter:SetSize(265, 20);
buffBackgroundTextureCenter:SetTexCoord(0.2,0.5,0.1,0.7);
buffBackgroundTextureCenter:SetPoint("TOPLEFT", 0, -10);
local buffBackgroundTextureBottom1 = f2:CreateTexture(nil, "ARTWORK");
buffBackgroundTextureBottom1:SetTexture("Interface\\RAIDFRAME\\UI-ReadyCheckFrame");
buffBackgroundTextureBottom1:SetWidth(265);
buffBackgroundTextureBottom1:SetHeight(5);
buffBackgroundTextureBottom1:SetTexCoord(0.05,0.6,0.66,0.71);
buffBackgroundTextureBottom1:SetPoint("BOTTOMLEFT", 0, -5);
local buffBackgroundTextureLeft = f2:CreateTexture(nil, "ARTWORK");
buffBackgroundTextureLeft:SetTexture("Interface\\RAIDFRAME\\UI-ReadyCheckFrame");
buffBackgroundTextureLeft:SetWidth(3);
buffBackgroundTextureLeft:SetHeight(22);
buffBackgroundTextureLeft:SetTexCoord(0.61,0.62,0.15,0.64);
buffBackgroundTextureLeft:SetPoint("TOPLEFT", -1, -8);
local buffBackgroundTextureRight = f2:CreateTexture(nil, "ARTWORK");
buffBackgroundTextureRight:SetTexture("Interface\\RAIDFRAME\\UI-ReadyCheckFrame");
buffBackgroundTextureRight:SetWidth(3);
buffBackgroundTextureRight:SetHeight(22);
buffBackgroundTextureRight:SetTexCoord(0.61,0.62,0.15,0.64);
buffBackgroundTextureRight:SetPoint("TOPRIGHT", 0, -8);

local rcText = f2:CreateFontString(nil, "ARTWORK", "GameFontNormal");
rcText:SetPoint("TOPLEFT", 0, -15);
rcText:SetJustifyV("TOP");
rcText:SetJustifyH("CENTER");
rcText:SetFont("Fonts\\FRIZQT__.TTF", 8.5);
rcText:SetText("");
rcText:SetSize(f2:GetWidth(), f2:GetHeight());

local text2 = ReadyCheckListenerFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
text2:SetPoint("TOP", ReadyCheckFrameText, "TOP", 0, -40);
text2:SetFont("Fonts\\FRIZQT__.TTF", 12);
text2:SetJustifyH("CENTER");
local text3 = ReadyCheckListenerFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal");
text3:SetPoint("BOTTOM", text2, "BOTTOM", 0, -18);
text3:SetFont("Fonts\\FRIZQT__.TTF", 12);
text3:SetJustifyH("CENTER");

local f = CreateFrame("Frame");

SLASH_INFINITECONSUMABLE1 = "/irtc";

local flasks = {307185,307187, 307166};
local oilsIDs = {6188, 6190, 6200};
local oilIconIDs = {
	[6188] = 463543, 
	[6190] = 463544, 
	[6200] = 3528422,
	[6201] = 3528423,
};
local RED = "\124cFFFF0000";
local YELLOW = "\124cFFFFFF00";
local GREEN = "\124cFF00FF00";
local CROSS = "\124TInterface\\addons\\InfiniteRaidTools\\Res\\cross:16\124t";
local CHECK = "\124TInterface\\addons\\InfiniteRaidTools\\Res\\check:16\124t";
local rcSender = "";
local raiders = {};
local playerName = UnitName("player");

local armorKitTimer = 0;
local oilTimers = {
	["Main Hand"] = 0,
	["Off Hand"] = 0,
};

local oilBindings = {
	["Shadowcore Oil"] = "Shadowcore Oil: No modifier(MH Only)", 
	["Embalmer's Oil"] = "Embalmer's Oil: SHIFT(MH Only)", 
	["Shaded Sharpening Stone"] = "Shaded Sharpening Stone: CTRL",
	["Shaded Weightstone"] = "Shaded Weightstone: ALT",
};

local buffSpellIDs = {
	["MAGE"] = 1459, 
	["PRIEST"] = 21562, 
	["WARRIOR"] = 6673,
};

local buffIconIDs = {
	["MAGE"] = 135932, 
	["PRIEST"] = 135987, 
	["WARRIOR"] = 132333,
};

local IRT_UnitBuff = IRT_UnitBuff;
local UnitIsUnit = UnitIsUnit;
local UnitIsVisible = UnitIsVisible;
local GetWeaponEnchantInfo = GetWeaponEnchantInfo;
local GetInventoryItemID = GetInventoryItemID;
local GetInventorySlotInfo = GetInventorySlotInfo;
local GetItemInfo = GetItemInfo;

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("READY_CHECK");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("UNIT_INVENTORY_CHANGED");
f:RegisterEvent("ENCOUNTER_START");

local currentKitIndex = 1;
local autoKit = CreateFrame("Button", "IRT_AutoKitButton", nil, "SecureActionButtonTemplate");
autoKit:ClearAllPoints();
autoKit:RegisterForClicks("RightButtonUp", "LeftButtonUp", "MiddleButtonUp");
autoKit:SetNormalTexture("Interface\\Icons\\inv_leatherworking_armorpatch_heavy");

autoKit:SetAttribute("type1", "macro"); 
autoKit:SetAttribute("macrotext", "/Use Heavy Desolate Armor Kit\n/use 5\n/click StaticPopup1Button1");

autoKit:SetSize(25,25);
autoKit:SetPoint("RIGHT", ReadyCheckFrame, "RIGHT", 40, 15);
autoKit:SetFrameStrata("FULLSCREEN");
autoKit:SetClampedToScreen(true);
autoKit:SetMovable(true);
autoKit:RegisterForDrag("LeftButton");
local autoKitCooldown = CreateFrame("Cooldown", "IRT_AutoKitCooldown", autoKit, "CooldownFrameTemplate")
autoKitCooldown:SetAllPoints();
autoKit:SetUserPlaced(false);
autoKit:Hide();

autoKit:SetScript("OnLeave", function(self)
	GameTooltip:Hide();
end);

autoKit:SetScript("OnDragStart", function(self)
	if (IsAltKeyDown() and IsControlKeyDown()) then
		self:StartMoving();
	end
end);
autoKit:SetScript("OnDragStop", function(self)
	local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(1);
	IRT_AutoKitPosition = {};
	IRT_AutoKitPosition.point = point;
	IRT_AutoKitPosition.relativeTo = relativeTo;
	IRT_AutoKitPosition.relativePoint = relativePoint;
	IRT_AutoKitPosition.xOffset = xOffset;
	IRT_AutoKitPosition.yOffset = yOffset;
	self:StopMovingOrSizing();
end);

local offhand = GetInventoryItemID("player", GetInventorySlotInfo("SecondaryHandSlot"));
local isOffhandWeapon = false;
if (offhand and select(6, GetItemInfo(offhand)) == "Weapon") then
	isOffhandWeapon = true;
else
	isOffhandWeapon = false;
end

local autoOil = CreateFrame("Button", "IRT_AutoOilButton", nil, "SecureActionButtonTemplate");
autoOil:ClearAllPoints();
autoOil:RegisterForClicks("RightButtonUp", "LeftButtonUp", "MiddleButtonUp");
autoOil:SetNormalTexture("Interface\\Icons\\inv_misc_potionseta");

autoOil:SetAttribute("type", "macro"); 
autoOil:SetAttribute("macrotext1", "/Use Shadowcore Oil\n/use 16\n/click StaticPopup1Button1");
autoOil:SetAttribute("shift-macrotext1", "/Use Embalmer's Oil\n/use 16\n/click StaticPopup1Button1"); 
autoOil:SetAttribute("ctrl-macrotext1", "/Use Shaded Sharpening Stone\n/use 16\n/click StaticPopup1Button1"); 
autoOil:SetAttribute("alt-macrotext1", "/Use Shaded Weightstone\n/use 16\n/click StaticPopup1Button1"); 
autoOil:SetAttribute("macrotext2", "/Use Shadowcore Oil\n/use 17\n/click StaticPopup1Button1");
autoOil:SetAttribute("shift-macrotext2", "/Use Embalmer's Oil\n/use 17\n/click StaticPopup1Button1"); 
autoOil:SetAttribute("ctrl-macrotext2", "/Use Shaded Sharpening Stone\n/use 17\n/click StaticPopup1Button1"); 
autoOil:SetAttribute("alt-macrotext2", "/Use Shaded Weightstone\n/use 17\n/click StaticPopup1Button1"); 
autoOil:SetAttribute("alt-ctrl-shiftmacrotext", "/run autoOil:Hide(); autoKit:Hide();");

autoOil:SetSize(25,25);
autoOil:SetPoint("RIGHT", ReadyCheckFrame, "RIGHT", 40, -15);
autoOil:SetFrameStrata("FULLSCREEN");
autoOil:SetClampedToScreen(true);
autoOil:SetMovable(true);
autoOil:RegisterForDrag("LeftButton");
autoOil:SetScript("OnDragStart", function(self)
	if (IsAltKeyDown() and IsControlKeyDown()) then
		self:StartMoving();
	end
end);
autoOil:SetScript("OnDragStop", function(self)
	local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(1);
	IRT_AutoOilPosition = {};
	IRT_AutoOilPosition.point = point;
	IRT_AutoOilPosition.relativeTo = relativeTo;
	IRT_AutoOilPosition.relativePoint = relativePoint;
	IRT_AutoOilPosition.xOffset = xOffset;
	IRT_AutoOilPosition.yOffset = yOffset;
	self:StopMovingOrSizing();
end);

autoOil:Hide();
autoOil:SetScript("OnLeave", function(self)
	GameTooltip:Hide();
end);

local function handler(msg, editbox)
	if (autoKit:IsShown()) then
		autoKit:Hide();
		autoOil:Hide();
	else
		autoKit:Show();
		autoOil:Show();
	end
end
SlashCmdList["INFINITECONSUMABLE"] = handler;

local scanTooltip = CreateFrame("GameToolTip", "IRT_TempToolTip", nil, "GameTooltipTemplate");
scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
scanTooltip:AddFontStrings(
    scanTooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
    scanTooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
);

local function armorKit()
	local duration = nil;
	local slotID = select(1, GetInventorySlotInfo("ChestSlot"))
	scanTooltip:ClearLines();
	local hasItem = scanTooltip:SetInventoryItem("player", slotID);
	armorKitTimer = RED .. "0min|r";
	if (hasItem) then
		local lines = {scanTooltip:GetRegions()};
		for index, region in pairs(lines) do
			if (region and region:GetObjectType() == "FontString") then
				local text = region:GetText() or "";
				if (text:match("Reinforced %(%+32 Stamina%)")) then
					local timeUnit = text:reverse():match(".*%)"):reverse();
					duration = tonumber(text:reverse():match("%d+"):reverse());
					if (timeUnit:match("hours")) then
						armorKitTimer = GREEN .. "2hrs|r";
						duration = 61;
					elseif(timeUnit:match("hour")) then
						armorKitTimer = GREEN .. "60min|r";
						duration = 60;
					elseif(timeUnit:match("min")) then
						armorKitTimer = GREEN .. duration .."min|r";
					else
						armorKitTimer = GREEN .. "2hrs|r";
						duration = 61;
					end
					--[[
					for number in text:gmatch("(%d+)") do
						if (tonumber(number) ~= 48) then
							if (shortest == nil) then
								shortest = tonumber(number);
							else
								if (shortest > tonumber(number)) then
									shortest = tonumber(number);
								end
							end
						end
					end
					if (shortest == nil) then
						shortest = 48;
					end
					]]
				end
			end
		end
	end
	if (duration == nil) then
		duration = CROSS;
	else
		if (duration == 61) then
			duration = GREEN .. "2hrs|r";
		elseif (duration > 15) then
			duration = GREEN .. duration .. "min|r";
		elseif (duration <= 15 and duration > 8) then
			duration = YELLOW .. duration .. "min|r";
		elseif (duration <= 8) then
			duration = RED .. duration .. "min|r";
		end
	end
	if(autoOil:IsMouseOver() and autoOil:IsShown()) then
		GameTooltip:Hide();
		local tooltipText = "|cFF00FFFFIRT:|r\n|cFFFFFFFFLeft+Modifier for main hand\nRight+Modifier for off hand|r\nModifiers:";
		for id, modifierInfo in pairs (oilBindings) do
			tooltipText = tooltipText .. "\n|cFFFFFFFF" .. modifierInfo .. "|r";
		end
		if (isOffhandWeapon) then
			tooltipText = tooltipText .. "\n" .. "Main Hand" .. ": " .. oilTimers["Main Hand"];
			tooltipText = tooltipText .. "\n" .. "Off Hand" .. ": " .. oilTimers["Off Hand"];
		else
			tooltipText = tooltipText .. "\n" .. "Main Hand" .. ": " .. oilTimers["Main Hand"];
		end
		tooltipText = tooltipText .. "\n|cFFFFFFFFCTRL+ALT+Drag to move\nToggle: /irtc or Middle Click to close.|r";
		GameTooltip:SetOwner(autoOil);
		GameTooltip:SetText(tooltipText);
		GameTooltip:Show();
	end
	if(autoKit:IsMouseOver() and autoKit:IsShown()) then
		GameTooltip:Hide();
		local tooltipText = "|cFF00FFFFIRT:|r\n|cFFFFFFFFClick to reapply.|r\nChest: " .. armorKitTimer .. "\n|cFFFFFFFFCTRL+ALT+Drag to move\nToggle: /irtc or Middle Click to close.|r";
		GameTooltip:SetOwner(autoKit);
		GameTooltip:SetText(tooltipText);
		GameTooltip:Show();
	end
	return duration;
	--3528447
	--Reinforced (+48 Stamina)
end


local function updateConsumables()
	local flask, flaskIcon, _, _, _, flaskTime = IRT_UnitBuff("player", GetSpellInfo(307185));
	for i = 1, #flasks do
		flask, flaskIcon, _, _, _, flaskTime = IRT_UnitBuff("player", GetSpellInfo(flasks[i]));
		if (flask) then
			break;
		end
	end
	local oil, oilTime, _, oilID, offhandOil, offhandOilTime, _, offhandOilID = GetWeaponEnchantInfo();
	offhand = GetInventoryItemID("player", GetInventorySlotInfo("SecondaryHandSlot"));
	if (offhand and select(6, GetItemInfo(offhand)) == "Weapon") then
		isOffhandWeapon = true;
	else
		isOffhandWeapon = false;
	end
	local oilCount = 0;
	local oilIcon = nil;
	if (oil) then
		oilIcon = oilIconIDs[oilID];
	elseif (offhandOil) then
		oilIcon = oilIconIDs[offhandOilID];
	end
	if (oilTime and offhandOilTime) then
		oilTime = math.floor(tonumber(oilTime)/1000/60);
		offhandOilTime = math.floor(tonumber(offhandOilTime)/1000/60);
		oilTimers["Main Hand"] = GREEN .. oilTime .. "min|r";
		oilTimers["Off Hand"] = GREEN .. offhandOilTime .. "min|r";
		oilCount = 2;
		if (oilTime > offhandOilTime) then
			oilTime = offhandOilTime;
		end
	elseif (oilTime) then
		oilTime = math.floor(tonumber(oilTime)/1000/60);
		oilTimers["Main Hand"] = GREEN .. oilTime .. "min|r";
		oilTimers["Off Hand"] = RED .. "0min|r";
		oilCount = 1;
	elseif (offhandOilTime) then
		oilTime = math.floor(tonumber(offhandOilTime)/1000/60);
		oilTimers["Main Hand"] = RED .. "0min|r"
		oilTimers["Off Hand"] = GREEN .. oilTime .. "min|r";
		oilCount = 1;
	else
		oilTimers["Main Hand"] = RED .. "0min|r";
		oilTimers["Off Hand"] = RED .. "0min|r";
		oilTime = nil;
	end
	if (oilTime) then
		if (oilCount == 2) then
			oilCount = GREEN .. "2/2 ";
		elseif (isOffhandWeapon) then
			oilCount = RED .. "1/2 ";
		else
			oilCount = "";
		end
		if (oilTime > 15) then
			oilTime = GREEN .. oilTime .. "min|r";
		elseif (oilTime <= 15 and oilTime > 8) then
			oilTime = YELLOW .. oilTime .. "min|r";
		elseif (oilTime <= 8) then
			oilTime = RED .. oilTime .. "min|r";
		end
	else
		oilCount = "";
		oilTime = CROSS;
	end
	local food, foodIcon, _, _, _, foodTime = IRT_UnitBuff("player", GetSpellInfo(297039)); -- Random Well Fed Buff
	local rune, runeIcon, _, _, _, runeTime = IRT_UnitBuff("player", GetSpellInfo(347901));
	local armorKitTime = armorKit();
	local armorKitIcon = 3528447;
	flaskIcon = flaskIcon and flaskIcon or 2057568;
	oilIcon = oilIcon and oilIcon or 463543;
	foodIcon = foodIcon and foodIcon or 136000;
	runeIcon = runeIcon and runeIcon or 134078;
	if (ReadyCheckFrame:IsShown() and ReadyCheckFrameText:GetText() and (not UnitIsUnit(rcSender, playerName) or IRT_SenderReadyCheck)) then
		local blizzText = ReadyCheckFrameText:GetText();
		if (UnitIsUnit(playerName.."(Consumable Check)", ReadyCheckFrame.initiator)) then --this is a bug without elvui
			blizzText = playerName .. "(Consumable Check) initiated a ready check";
		else
			if (blizzText:find("%-")) then
				local head, tail, name = blizzText:find("([^-]*)");
				blizzText = name .. " initiated a ready check";
			else
				local head, tail, name = blizzText:find("([^%s]*)");
				blizzText = name .. " initiated a ready check";
			end
		end
		local currTime = GetTime();
		flaskTime = flaskTime and math.floor((tonumber(flaskTime)-currTime)/60) or nil;
		if (flaskTime) then
			if (flaskTime > 15) then
				flaskTime = GREEN .. flaskTime .. "min|r";
			elseif (flaskTime <= 15 and flaskTime > 8) then
				flaskTime = YELLOW .. flaskTime .. "min|r";
			elseif (flaskTime <= 8) then
				flaskTime = RED .. flaskTime .. "min|r";
			end
		else
			flaskTime = CROSS;
		end
		local class = select(2, UnitClass("player"));
		if (class == "MAGE" or class == "PRIEST" or class == "WARRIOR") then
			local count = 0;
			local total = 0;
			local unit = nil;
			if (IsInRaid()) then
				for i = 1, GetNumGroupMembers() do
					unit = "raid"..i;
					if (UnitIsVisible(unit)) then
						total = total + 1;
						if (IRT_UnitBuff(unit, GetSpellInfo(buffSpellIDs[class]))) then
							count = count + 1;
						end
					end
				end
			elseif (IsInGroup()) then
				for i = 1, GetNumGroupMembers()-1 do
					unit = "party"..i;
					if (UnitIsVisible(unit)) then
						total = total + 1;
						if (IRT_UnitBuff(unit, GetSpellInfo(buffSpellIDs[class]))) then
							count = count + 1;
						end
					end
				end
				total = total + 1;
				if (IRT_UnitBuff("player", GetSpellInfo(buffSpellIDs[class]))) then
					count = count + 1;
				end
			end
			if (ReadyCheckFrame.backdropInfo and ReadyCheckFrame.backdropInfo.bgFile and ReadyCheckFrame.backdropInfo.bgFile:match("ElvUI")) then
				ReadyCheckFrameText:SetSize(320, 40);
				ReadyCheckFrameText:SetText(blizzText .. "\n\n\124T".. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilCount .. oilTime .. " \124T" .. armorKitIcon .. ":16\124t" .. armorKitTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS) .. " \124T" .. buffIconIDs[class] .. ":16\124t" .. (count == total and (GREEN .. count .. "/" .. total) or (RED .. count .. "/" .. total)));
			else
				f2:SetPoint("BOTTOM", ReadyCheckFrame, "BOTTOM", 0, -17);
				f2:Show();
				rcText:SetText("\124T" .. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilCount .. oilTime .. " \124T" .. armorKitIcon .. ":16\124t" .. armorKitTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS) .. " \124T" .. buffIconIDs[class] .. ":16\124t" .. (count == total and (GREEN .. count .. "/" .. total) or (RED .. count .. "/" .. total)));
			end
			--ReadyCheckFrameText:SetText(blizzText);
			--text2:SetText("\124T" .. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilTime .. "  \124T" .. armorKitIcon .. ":16\124t" .. armorKitCount .. armorKitTime);
			--text3:SetText("\124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS) .. " \124T" .. buffIconIDs[class] .. ":16\124t" .. (count == total and (GREEN .. count .. "/" .. total) or (RED .. count .. "/" .. total)));
			--rcText:SetText("\124T" .. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilTime .. " \124T" .. armorKitIcon .. ":16\124t" .. armorKitCount .. armorKitTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS) .. " \124T" .. buffIconIDs[class] .. ":16\124t" .. (count == total and (GREEN .. count .. "/" .. total) or (RED .. count .. "/" .. total)));
		else
			if (ReadyCheckFrame.backdropInfo and ReadyCheckFrame.backdropInfo.bgFile and ReadyCheckFrame.backdropInfo.bgFile:match("ElvUI")) then
				ReadyCheckFrameText:SetSize(320, 40);
				ReadyCheckFrameText:SetText(blizzText .. "\n\n\124T".. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilCount .. oilTime .. " \124T" .. armorKitIcon .. ":16\124t" .. armorKitTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS));
			else
				f2:SetPoint("BOTTOM", ReadyCheckFrame, "BOTTOM", 0, -17);
				f2:Show();
				rcText:SetText("\124T" .. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilCount .. oilTime .. " \124T" .. armorKitIcon .. ":16\124t" .. armorKitTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS));
			end
			--ReadyCheckFrameText:SetText(blizzText .. "\n\n\124T".. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS)); 
		end
	end
end

autoKit:HookScript("OnClick", function(self, button, down)
	autoKit:SetAttribute("macrotext", "/Use Heavy Desolate Armor Kit\n/use 5\n/click StaticPopup1Button1"); 
	if (button == "MiddleButton") then
		autoKit:Hide();
		autoOil:Hide();
	end
end);

autoOil:HookScript("OnClick", function(self, button, down)
	autoOil:SetAttribute("macrotext1", "/Use Shadowcore Oil\n/use 16\n/click StaticPopup1Button1");
	autoOil:SetAttribute("shift-macrotext1", "/Use Embalmer's Oil\n/use 16\n/click StaticPopup1Button1"); 
	autoOil:SetAttribute("ctrl-macrotext1", "/Use Shaded Sharpening Stone\n/use 16\n/click StaticPopup1Button1"); 
	autoOil:SetAttribute("alt-macrotext1", "/Use Shaded Weightstone\n/use 16\n/click StaticPopup1Button1"); 
	autoOil:SetAttribute("macrotext2", "/Use Shadowcore Oil\n/use 17\n/click StaticPopup1Button1");
	autoOil:SetAttribute("shift-macrotext2", "/Use Embalmer's Oil\n/use 17\n/click StaticPopup1Button1"); 
	autoOil:SetAttribute("ctrl-macrotext2", "/Use Shaded Sharpening Stone\n/use 17\n/click StaticPopup1Button1"); 
	autoOil:SetAttribute("alt-macrotext2", "/Use Shaded Weightstone\n/use 17\n/click StaticPopup1Button1"); 
	autoOil:SetAttribute("alt-ctrl-shiftmacrotext", "/run autoOil:Hide(); autoKit:Hide();");
	if (button == "MiddleButton") then
		autoKit:Hide();
		autoOil:Hide();
	end
end);

autoOil:HookScript("OnEnter", function(self)
	updateConsumables();
	local tooltipText = "|cFF00FFFFIRT:|r\n|cFFFFFFFFLeft+Modifier for main hand\nRight+Modifier for off hand|r\nModifiers:";
	for id, modifierInfo in pairs (oilBindings) do
		tooltipText = tooltipText .. "\n|cFFFFFFFF" .. modifierInfo .. "|r";
	end
	if (isOffhandWeapon) then
		tooltipText = tooltipText .. "\n" .. "Main Hand" .. ": " .. oilTimers["Main Hand"];
		tooltipText = tooltipText .. "\n" .. "Off Hand" .. ": " .. oilTimers["Off Hand"];
	else
		tooltipText = tooltipText .. "\n" .. "Main Hand" .. ": " .. oilTimers["Main Hand"];
	end
	tooltipText = tooltipText .. "\n|cFFFFFFFFCTRL+ALT+Drag to move\nToggle: /irtc or Middle Click to close.|r";
	GameTooltip:SetOwner(autoOil);
	GameTooltip:SetText(tooltipText);
	GameTooltip:Show();
end);

autoKit:HookScript("OnEnter", function(self)
	updateConsumables();
	local tooltipText = "|cFF00FFFFIRT:|r\n|cFFFFFFFFClick to reapply.|r\nChest: " .. armorKitTimer .. "\n|cFFFFFFFFCTRL+ALT+Drag to move\nToggle: /irtc or Middle Click to close.|r";
	GameTooltip:SetOwner(self);
	GameTooltip:SetText(tooltipText);
	GameTooltip:Show();
end);

ReadyCheckFrame:HookScript("OnHide", function()
	if (IRT_ConsumableCheckEnabled) then
		f2:Hide();
		autoKit:Hide();
		autoOil:Hide();
	end
end);
ReadyCheckFrame:HookScript("OnShow", function() 
	if (IRT_ConsumableCheckEnabled) then
		if (UnitIsUnit(ReadyCheckFrame.initiator, playerName) and IRT_SenderReadyCheck) then
			C_Timer.After(0.5, function()
				ShowReadyCheck(playerName.."(Consumable Check)", 38); --fool the game its not the player
				SetPortraitTexture(ReadyCheckPortrait, playerName);
				updateConsumables();
				if (IRT_ConsumableAutoButtonsEnabled) then
					autoKit:Show(); 
					autoOil:Show();
				end
				f2:Show();
			end);
		elseif (not UnitIsUnit(ReadyCheckFrame.initiator, playerName)) then
			f2:Show();
			if (IRT_ConsumableAutoButtonsEnabled) then
				autoKit:Show(); 
				autoOil:Show();
			end
		elseif (not IRT_SenderReadyCheck) then
			--updateConsumables();
			if (IRT_ConsumableAutoButtonsEnabled) then
				autoKit:Show(); 
				autoOil:Show();
			end
		end
		--ReadyCheckFrame:Show();
		--ReadyCheckListenerFrame:Show();
	end
end);
f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IRT_ConsumableCheckEnabled == nil) then IRT_ConsumableCheckEnabled = true; end
		if (IRT_SenderReadyCheck == nil) then IRT_SenderReadyCheck = true; end
		if (IRT_ConsumableAutoButtonsEnabled == nil) then IRT_ConsumableAutoButtonsEnabled = true; end
	elseif (event == "ENCOUNTER_START" and (autoOil:IsShown() or autoKit:IsShown())) then
		autoKit:Hide();
		autoOil:Hide();
	elseif (event == "READY_CHECK" and IRT_ConsumableCheckEnabled) then
		local sender = ...;
		rcSender = sender;
		if (not UnitIsUnit(sender, playerName)) then
			updateConsumables();
		end
	elseif (event == "UNIT_AURA" and IRT_ConsumableCheckEnabled and (ReadyCheckFrame:IsShown() or ((autoOil:IsMouseOver() and autoOil:IsShown()) or (autoKit:IsMouseOver() and autoKit:IsShown())))) then
		--local unit = ...;
		--if ((UnitInRaid(unit) or UnitInParty(unit)) and not UnitIsUnit(rcSender, UnitName("player"))) then
			updateConsumables();
		--end
	elseif (event == "UNIT_INVENTORY_CHANGED" and IRT_ConsumableCheckEnabled and (ReadyCheckFrame:IsShown() or ((autoOil:IsMouseOver() and autoOil:IsShown()) or (autoKit:IsMouseOver() and autoKit:IsShown())))) then
		--local unit = ...;
		--if ((UnitInRaid(unit) or UnitInParty(unit)) and not UnitIsUnit(rcSender, UnitName("player"))) then
			C_Timer.After(0.1, updateConsumables);
			--updateConsumables();
		--end
	end
end);

function IRT_AutoKitSetPosition(point, relativeTo, relativePoint, xOffset, yOffset)
	autoKit:ClearAllPoints();
	autoKit:SetPoint(point, ReadyCheckFrame, relativePoint, xOffset, yOffset);
end
function IRT_AutoOilSetPosition(point, relativeTo, relativePoint, xOffset, yOffset)
	autoOil:ClearAllPoints();
	autoOil:SetPoint(point, ReadyCheckFrame, relativePoint, xOffset, yOffset);
end