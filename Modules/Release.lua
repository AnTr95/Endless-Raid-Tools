local L = IRTLocals;
local f = CreateFrame("Frame");
f:RegisterEvent("PLAYER_DEAD");
f:RegisterEvent("PLAYER_LOGIN");
f:RegisterEvent("MODIFIER_STATE_CHANGED");

local text = nil;

f:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		if (IRT_ReleaseEnabled == nil) then IRT_ReleaseEnabled = true; end
	elseif (event == "PLAYER_DEAD" and IRT_ReleaseEnabled) then
		if (GetZoneText() == "Sanctum of Domination" or GetZoneText() == "Castle Nathria") then
			StaticPopup1Text:SetPoint("TOP", 0, -10);
			if (text == nil) then
				local font, size, flag = StaticPopup1Text:GetFont();
				text = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
				text:SetText(L.RELEASE_STATICPOPUP);
				text:SetWordWrap(true)
				text:SetJustifyV("TOP");
				text:SetPoint("TOP", StaticPopup1Text, "TOP", 0, -8);
				f:SetFrameStrata("TOOLTIP");
				text:SetFont(font, 8, "");
			end
			text:Show();
			StaticPopup1Button1:Hide();
		end
	elseif (event == "MODIFIER_STATE_CHANGED" and IRT_ReleaseEnabled and (GetZoneText() == "Sanctum of Domination" or GetZoneText() == "Castle Nathria") and StaticPopup1:IsShown() and StaticPopup1Text:GetText():match("elease")) then
		local button, pressed = ...;
		if (button == "LSHIFT") then
			if (pressed == 1) then
				StaticPopup1Button1:Show();
			else
				StaticPopup1Button1:Hide();
			end
		end
	end
end);

StaticPopup1Button1:HookScript("OnClick", function(self)
	if (text and text:IsShown()) then
		text:Hide();
		StaticPopup1Text:SetPoint("TOP", 0, -16);
	end
end);

StaticPopup1:HookScript("OnHide", function(self)
	if (text and text:IsShown()) then
		text:Hide();
		StaticPopup1Text:SetPoint("TOP", 0, -16);
	end
end);