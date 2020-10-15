local f = CreateFrame("Frame")
local timer = nil;
f:SetPoint("TOP", 0, -30)
f:SetSize(1000, 300)
f:SetMovable(false)
f:EnableMouse(false)
f:RegisterForDrag("LeftButton")
f:SetFrameLevel(3)
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", function(self)
	local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(1)
	IRT_PopupTextPosition = {}
	IRT_PopupTextPosition.point = point
	IRT_PopupTextPosition.relativeTo = relativeTo
	IRT_PopupTextPosition.relativePoint = relativePoint
	IRT_PopupTextPosition.xOffset = xOffset
	IRT_PopupTextPosition.yOffset = yOffset
	self:StopMovingOrSizing()
end)
f:Hide()
local text = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
text:SetPoint("TOP")
text:SetJustifyH("CENTER");
text:SetJustifyV("CENTER");
--text:SetSize(1080,300);

function IRT_PopupUpdateFontSize()
	text:SetFont("Fonts\\FRIZQT__.TTF", IRT_PopupTextFontSize);
end
--TO:DO Create instances of text so multiple texts can be shown at the same time (1 way would be to create an array and keep all visible texts there)
function IRT_PopupShow(message, sec)
	if (timer) then
		timer:Cancel();
		timer = nil;
	end
	text:SetText(message)
	f:Show()
	timer = C_Timer.NewTimer(sec, function()
		f:Hide()
	end)
	return timer
end
function IRT_PopupUpdate(message)
	text:SetText(message)
end
function IRT_PopupMove()
	text:SetText("MOVE ME")
	f:SetMovable(true)
	f:EnableMouse(true)
	f:Show()
	C_Timer.After(7, function() 
		f:Hide()
		f:SetMovable(false)
		f:EnableMouse(false)
	end)
end
function IRT_PopupHide()
	if (timer) then
		timer:Cancel();
		timer = nil;
	end
	f:Hide()
end
function IRT_PopupSetPosition(point, relativeTo, relativePoint, xOffset, yOffset)
	f:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
end
function IRT_PopupIsShown()
	if f:IsShown() then
		return true
	else
		return false
	end
end
function IRT_PopupGetText()
	return text:GetText()
end