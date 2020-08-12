local f = CreateFrame("Frame", nil, nil, BackdropTemplateMixin and "BackdropTemplate");
local timer = nil;
f:SetSize(185, 150);
f:SetPoint("TOPLEFT", 30, -150);
f:SetMovable(false);
f:EnableMouse(false);
f:RegisterForDrag("LeftButton");
f:SetFrameLevel(3);
f:SetScript("OnDragStart", f.StartMoving);
f:SetScript("OnDragStop", function(self)
	local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(1);
	EnRT_InfoBoxPosition = {};
	EnRT_InfoBoxPosition.point = point;
	EnRT_InfoBoxPosition.relativeTo = relativeTo;
	EnRT_InfoBoxPosition.relativePoint = relativePoint;
	EnRT_InfoBoxPosition.xOffset = xOffset;
	EnRT_InfoBoxPosition.yOffset = yOffset;
	self:StopMovingOrSizing();
end);
f:SetFrameStrata("TOOLTIP");
f:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", --Set the background and border textures
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
	tile = true, tileSize = 16, edgeSize = 16, 
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
});
f:SetBackdropColor(0.3,0.3,0.3,0.6);
f:Hide();

local texture = f:CreateTexture();
texture:SetTexture(0.5, 0.5, 0.5, 0.5);
texture:SetAllPoints();

local text = f:CreateFontString(nil, "ARTWORK", "GameFontNormal");
text:SetPoint("TOPLEFT", 7, -10);
text:SetJustifyV("TOP");
text:SetJustifyH("LEFT");
text:SetSpacing(8);
text:SetText("");

function EnRT_InfoBoxUpdateFontSize()
	text:SetFont("Fonts\\ARIALN.TTF", EnRT_InfoBoxTextFontSize, "OUTLINE");
end
--TO:DO Create instances of text so multiple texts can be shown at the same time (1 way would be to create an array and keep all visible texts there)
function EnRT_InfoBoxShow(message, sec)
	text:SetText(message);
	f:SetSize(15 + text:GetStringWidth(), 15 + text:GetStringHeight());
	f:Show();
	if (timer) then
		timer:Cancel();
	end
	if (sec) then
		timer = C_Timer.NewTimer(sec, function()
			f:Hide();
		end);
	end
	return timer;
end

function EnRT_InfoBoxUpdate(message)
	text:SetText(message);
	f:SetSize(15 + text:GetStringWidth(), 15 + text:GetStringHeight());
end

function EnRT_InfoBoxMove()
	text:SetText("MOVE ME");
	f:SetMovable(true);
	f:EnableMouse(true);
	f:Show();
	C_Timer.After(7, function() 
		f:Hide();
		f:SetMovable(false);
		f:EnableMouse(false);
	end)
end

function EnRT_InfoBoxHide()
	if (timer) then
		timer:Cancel();
	end
	f:Hide();
end

function EnRT_InfoBoxGetSize()
	return f:GetSize();
end

function EnRT_InfoBoxSetPosition(point, relativeTo, relativePoint, xOffset, yOffset)
	f:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
end

function EnRT_InfoBoxIsShown()
	if f:IsShown() then
		return true;
	else
		return false;
	end
end

function EnRT_InfoBoxGetText()
	return text:GetText();
end