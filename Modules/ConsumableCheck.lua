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

local armorKitSlots = {"ChestSlot", "LegsSlot", "HandsSlot", "FeetSlot"};
local armorKitTimers = {
	["ChestSlot"] = 0,
	["LegsSlot"] = 0,
	["HandsSlot"] = 0,
	["FeetSlot"] = 0,
};
local armorKitSlotSimple = {
	["ChestSlot"] = "Chest",
	["LegsSlot"] = "Legs",
	["HandsSlot"] = "Hands",
	["FeetSlot"] = "Feet",
};

local armorKitSlotBindings = {
	["ChestSlot"] = " SHIFT+Left Click to reapply",
	["LegsSlot"] = " SHIFT+Right Click to reapply",
	["HandsSlot"] = " CTRL+Left Click to reapply",
	["FeetSlot"] = " CTRL+Right Click to reapply",
};
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

local currentKitIndex = 1;
local autoKit = CreateFrame("Button", "IRT_AutoKitButton", nil, "SecureActionButtonTemplate");
autoKit:ClearAllPoints();
autoKit:RegisterForClicks("RightButtonUp", "LeftButtonUp");
autoKit:SetNormalTexture("Interface\\Icons\\inv_leatherworking_armorpatch_heavy");

autoKit:SetAttribute("type", "macro"); 
autoKit:SetAttribute("macrotext1", "/Use Heavy Desolate Armor Kit\n/use 5\n/click StaticPopup1Button1");
autoKit:SetAttribute("shift-macrotext1", "/Use Heavy Desolate Armor Kit\n/use 5\n/click StaticPopup1Button1"); 
autoKit:SetAttribute("ctrl-macrotext1", "/Use Heavy Desolate Armor Kit\n/use 10\n/click StaticPopup1Button1"); 
autoKit:SetAttribute("shift-macrotext2", "/Use Heavy Desolate Armor Kit\n/use 7\n/click StaticPopup1Button1"); 
autoKit:SetAttribute("ctrl-macrotext2", "/Use Heavy Desolate Armor Kit\n/use 8\n/click StaticPopup1Button1"); 

autoKit:SetSize(25,25);
autoKit:SetPoint("RIGHT", ReadyCheckFrame, "RIGHT", 40, 15);
autoKit:SetFrameStrata("FULLSCREEN");
local autoKitCooldown = CreateFrame("Cooldown", "IRT_AutoKitCooldown", autoKit, "CooldownFrameTemplate")
autoKitCooldown:SetAllPoints();
autoKit:Hide();

autoKit:HookScript("OnEnter", function(self)
	local tooltipText = "|cFF00FFFFIRT:|r\n|cFFFFFFFFLeft Click loops all slots.|r";
	for slot, duration in pairs (armorKitTimers) do
		tooltipText = tooltipText .. "\n" .. armorKitSlotSimple[slot] .. ": " .. duration .. "|cFFFFFFFF" .. armorKitSlotBindings[slot] .. "|r";
	end
	GameTooltip:SetOwner(self);
	GameTooltip:SetText(tooltipText);
	GameTooltip:Show();
end);
autoKit:SetScript("OnLeave", function(self)
	GameTooltip:Hide();
end);

autoKit:HookScript("OnClick", function()
	autoKit:SetAttribute("shift-macrotext1", "/Use Heavy Desolate Armor Kit\n/use 5\n/click StaticPopup1Button1"); 
	autoKit:SetAttribute("ctrl-macrotext1", "/Use Heavy Desolate Armor Kit\n/use 10\n/click StaticPopup1Button1"); 
	autoKit:SetAttribute("shift-macrotext2", "/Use Heavy Desolate Armor Kit\n/use 7\n/click StaticPopup1Button1"); 
	autoKit:SetAttribute("ctrl-macrotext2", "/Use Heavy Desolate Armor Kit\n/use 8\n/click StaticPopup1Button1"); 
	if (not UnitCastingInfo("player") and select(1, GetItemCooldown(172347) == 0)) then
		autoKitCooldown:SetCooldown(GetTime()+1.5, 1);
		currentKitIndex = currentKitIndex + 1;
		if (currentKitIndex == 1 or currentKitIndex == 5) then
			autoKit:SetAttribute("macrotext1", "/Use Heavy Desolate Armor Kit\n/use 5\n/click StaticPopup1Button1"); 
			currentKitIndex = 1;
		elseif (currentKitIndex == 2) then
			autoKit:SetAttribute("macrotext1", "/Use Heavy Desolate Armor Kit\n/use 10\n/click StaticPopup1Button1"); 
		elseif (currentKitIndex == 3) then
			autoKit:SetAttribute("macrotext1", "/Use Heavy Desolate Armor Kit\n/use 7\n/click StaticPopup1Button1"); 
		elseif (currentKitIndex == 4) then 
			autoKit:SetAttribute("macrotext1", "/Use Heavy Desolate Armor Kit\n/use 8\n/click StaticPopup1Button1"); 
		end
	end
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
autoOil:RegisterForClicks("RightButtonUp", "LeftButtonUp");
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

autoOil:SetSize(25,25);
autoOil:SetPoint("TOPLEFT", autoKit, "TOPLEFT", 0, -30);
autoOil:SetFrameStrata("FULLSCREEN");
local autoKitCooldown = CreateFrame("Cooldown", "IRT_AutoOilCooldown", autoOil, "CooldownFrameTemplate")
autoKitCooldown:SetAllPoints();
autoOil:Hide();

autoOil:HookScript("OnEnter", function(self)
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
	GameTooltip:SetOwner(autoOil);
	GameTooltip:SetText(tooltipText);
	GameTooltip:Show();
end);
autoOil:SetScript("OnLeave", function(self)
	GameTooltip:Hide();
end);

local scanTooltip = CreateFrame("GameToolTip", "IRT_TempToolTip", nil, "GameTooltipTemplate");
scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE");
scanTooltip:AddFontStrings(
    scanTooltip:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
    scanTooltip:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
);

function armorKit()
	local count = 0;
	local shortest = nil;
	for i = 1, #armorKitSlots do
		local slotID = select(1, GetInventorySlotInfo(armorKitSlots[i]));
		scanTooltip:ClearLines();
		local hasItem = scanTooltip:SetInventoryItem("player", slotID);
		armorKitTimers[armorKitSlots[i]] = RED .. "0min|r";
		if (hasItem) then
			local lines = {scanTooltip:GetRegions()};
			for index, region in pairs(lines) do
				if (region and region:GetObjectType() == "FontString") then
					local text = region:GetText() or "";
					if (text:match("Reinforced %(%+48 Stamina%)")) then
						count = count + 1;
						local timeUnit = text:reverse():match(".*%)"):reverse();
						local duration = tonumber(text:reverse():match("%d+"):reverse());
						if (timeUnit:match("hours")) then
							armorKitTimers[armorKitSlots[i]] = GREEN .. "2hrs|r";
							if (shortest == nil) then
								shortest = 61;
							end
						elseif(timeUnit:match("hour")) then
							armorKitTimers[armorKitSlots[i]] = GREEN .. "60min|r";
							if (shortest == nil) then
								shortest = 60;
							elseif (shortest > 60) then
								shortest = 60;
							end
						elseif(timeUnit:match("min")) then
							armorKitTimers[armorKitSlots[i]] = GREEN .. duration .."min|r";
							if (shortest == nil) then
								shortest = duration;
							elseif (shortest > duration) then
								shortest = duration;
							end
						else
							armorKitTimers[armorKitSlots[i]] = GREEN .. "2hrs|r";
							if (shortest == nil) then
								shortest = 61;
							end
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
	end
	if (count < 4) then
		count = RED .. count .. "/4|r ";
	elseif (count == 4) then
		count = GREEN .. count .. "/4|r ";
	end
	if (shortest == nil) then
		shortest = "";
		count = CROSS;
	else
		if (shortest == 61) then
			shortest = GREEN .. "2hrs|r";
		elseif (shortest > 15) then
			shortest = GREEN .. shortest .. "min|r";
		elseif (shortest <= 15 and shortest > 8) then
			shortest = YELLOW .. shortest .. "min|r";
		elseif (shortest <= 8) then
			shortest = RED .. shortest .. "min|r";
		end
	end
	if(autoOil:IsMouseOver()) then
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
		GameTooltip:SetOwner(autoOil);
		GameTooltip:SetText(tooltipText);
		GameTooltip:Show();
	end
	if(autoKit:IsMouseOver()) then
		GameTooltip:Hide();
		local tooltipText = "|cFF00FFFFIRT:|r\n|cFFFFFFFFLeft Click loops all slots.|r";
		for slot, duration in pairs (armorKitTimers) do
			tooltipText = tooltipText .. "\n" .. armorKitSlotSimple[slot] .. ": " .. duration .. "|cFFFFFFFF" .. armorKitSlotBindings[slot] .. "|r";
		end
		GameTooltip:SetOwner(autoKit);
		GameTooltip:SetText(tooltipText);
		GameTooltip:Show();
	end
	return count, shortest;
	--3528447
	--Reinforced (+48 Stamina)
end

f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("READY_CHECK");
f:RegisterEvent("UNIT_AURA");
f:RegisterEvent("UNIT_INVENTORY_CHANGED");

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
		oilTimers["Main Hand"] = GREEN .. oilTime .. "m|r";
		oilTimers["Off Hand"] = GREEN .. offhandOilTime .. "m|r";
		oilCount = 2;
		if (oilTime > offhandOilTime) then
			oilTime = offhandOilTime;
		end
	elseif (oilTime) then
		oilTime = math.floor(tonumber(oilTime)/1000/60);
		oilTimers["Main Hand"] = GREEN .. oilTime .. "m|r";
		oilTimers["Off Hand"] = RED .. "0m|r";
		oilCount = 1;
	elseif (offhandOilTime) then
		oilTime = math.floor(tonumber(offhandOilTime)/1000/60);
		oilTimers["Main Hand"] = RED .. "0m|r"
		oilTimers["Off Hand"] = GREEN .. oilTime .. "m|r";
		oilCount = 1;
	else
		oilTimers["Main Hand"] = RED .. "0m|r";
		oilTimers["Off Hand"] = RED .. "0m|r";
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
	local rune, runeIcon, _, _, _, runeTime = IRT_UnitBuff("player", GetSpellInfo(270058));
	local armorKitCount, armorKitTime = armorKit();
	local armorKitIcon = 3528447;
	flaskIcon = flaskIcon and flaskIcon or 2057568;
	oilIcon = oilIcon and oilIcon or 463543;
	foodIcon = foodIcon and foodIcon or 136000;
	runeIcon = runeIcon and runeIcon or 519379;

	local blizzText = ReadyCheckFrameText:GetText();
	if (blizzText:find("%-")) then
		local head, tail, name = blizzText:find("([^-]*)");
		blizzText = name .. " initiated a ready check";
	else
		local head, tail, name = blizzText:find("([^%s]*)");
		blizzText = name .. " initiated a ready check";
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
		if (ReadyCheckFrame.backdrop and ReadyCheckFrame.backdrop.backdropInfo and ReadyCheckFrame.backdrop.backdropInfo.bgFile and ReadyCheckFrame.backdrop.backdropInfo.bgFile:match("ElvUI")) then
			ReadyCheckFrameText:SetSize(320, 40);
			ReadyCheckFrameText:SetText(blizzText .. "\n\n\124T".. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilCount .. oilTime .. " \124T" .. armorKitIcon .. ":16\124t" .. armorKitCount .. armorKitTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS) .. " \124T" .. buffIconIDs[class] .. ":16\124t" .. (count == total and (GREEN .. count .. "/" .. total) or (RED .. count .. "/" .. total)));
		else
			f2:SetPoint("BOTTOM", ReadyCheckFrame, "BOTTOM", 0, -17);
			f2:Show();
			rcText:SetText("\124T" .. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilCount .. oilTime .. " \124T" .. armorKitIcon .. ":16\124t" .. armorKitCount .. armorKitTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS) .. " \124T" .. buffIconIDs[class] .. ":16\124t" .. (count == total and (GREEN .. count .. "/" .. total) or (RED .. count .. "/" .. total)));
		end
		--ReadyCheckFrameText:SetText(blizzText);
		--text2:SetText("\124T" .. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilTime .. "  \124T" .. armorKitIcon .. ":16\124t" .. armorKitCount .. armorKitTime);
		--text3:SetText("\124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS) .. " \124T" .. buffIconIDs[class] .. ":16\124t" .. (count == total and (GREEN .. count .. "/" .. total) or (RED .. count .. "/" .. total)));
		--rcText:SetText("\124T" .. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilTime .. " \124T" .. armorKitIcon .. ":16\124t" .. armorKitCount .. armorKitTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS) .. " \124T" .. buffIconIDs[class] .. ":16\124t" .. (count == total and (GREEN .. count .. "/" .. total) or (RED .. count .. "/" .. total)));
	else
		if (ReadyCheckFrame.backdrop and ReadyCheckFrame.backdrop.backdropInfo and ReadyCheckFrame.backdrop.backdropInfo.bgFile and ReadyCheckFrame.backdrop.backdropInfo.bgFile:match("ElvUI")) then
			ReadyCheckFrameText:SetSize(320, 40);
			ReadyCheckFrameText:SetText(blizzText .. "\n\n\124T".. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilCount .. oilTime .. " \124T" .. armorKitIcon .. ":16\124t" .. armorKitCount .. armorKitTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS));
		else
			f2:SetPoint("BOTTOM", ReadyCheckFrame, "BOTTOM", 0, -17);
			f2:Show();
			rcText:SetText("\124T" .. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilCount .. oilTime .. " \124T" .. armorKitIcon .. ":16\124t" .. armorKitCount .. armorKitTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS));
		end
		--ReadyCheckFrameText:SetText(blizzText .. "\n\n\124T".. flaskIcon .. ":16\124t" .. flaskTime .. " \124T" .. oilIcon .. ":16\124t" .. oilTime .. " \124T" .. foodIcon .. ":16\124t" .. (food and CHECK or CROSS) .. " \124T" .. runeIcon .. ":16\124t" .. (rune and CHECK or CROSS)); 
	end
end

ReadyCheckFrame:HookScript("OnHide", function() f2:Hide(); autoKit:Hide(); autoOil:Hide(); end);
ReadyCheckFrame:HookScript("OnShow", function() 
	if (not UnitIsUnit(ReadyCheckFrame.initiator, "player")) then
		autoKit:Show(); 
		autoOil:Show();
	end
end);
f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IRT_ConsumableCheckEnabled == nil) then IRT_ConsumableCheckEnabled = true; end
	elseif (event == "READY_CHECK" and IRT_ConsumableCheckEnabled) then
		local sender = ...
		rcSender = sender;
		if (not UnitIsUnit(sender, UnitName("player"))) then
			updateConsumables();
		end
	elseif (event == "UNIT_AURA" and IRT_ConsumableCheckEnabled and ReadyCheckFrame:IsShown()) then
		local unit = ...;
		if ((UnitInRaid(unit) or UnitInParty(unit)) and not UnitIsUnit(rcSender, UnitName("player"))) then
			updateConsumables();
		end
	elseif (event == "UNIT_INVENTORY_CHANGED" and IRT_ConsumableCheckEnabled and ReadyCheckFrame:IsShown()) then
		local unit = ...;
		if ((UnitInRaid(unit) or UnitInParty(unit)) and not UnitIsUnit(rcSender, UnitName("player"))) then
			updateConsumables();
		end
	end
end);