local name, addon = ...;

Settings = {
    mainFont = "Fonts\\FRIZQT__.TTF"
}

local padding = 24

local frame = CreateFrame("FRAME", "WalkCraftSettingsFrame", UIParent);
frame:SetSize(300 + padding, 150 + padding)
frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
frame:SetFrameStrata("HIGH")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame.texture = frame:CreateTexture()
frame.texture:SetAllPoints(frame)
frame.texture:SetTexture("Interface/BUTTONS/WHITE8X8")
frame.texture:SetColorTexture(0, 0, 0, 0.75)
frame:Hide()

local title = Utils.createLabel(frame, "WalkCraft", 24, "TOPLEFT", padding, -padding)

local showTrackSessionCheckbox = Utils.createCheckbox(frame, padding, -padding - 24 - padding,
    "Show current session tracker");
showTrackSessionCheckbox.tooltip = "Toggle visibility of the section where you can start/stop and track sessions.";
showTrackSessionCheckbox:SetScript("OnClick", function()
    if showTrackSessionCheckbox:GetChecked() then
        addon.showSessionFrame();
    else
        addon.hideSessionFrame();
    end
end);

local resetTotalDistanceButton = Utils.createButton(frame, "Reset total distance", 150, 22, "BOTTOMLEFT", padding,
    padding)
resetTotalDistanceButton:SetScript("OnClick", function()
    addon.setTotalDistanceTravelled(0)
end)

local versionLabel = Utils.createLabel(frame, "WalkCraft v0.0.1", 10, "BOTTOMRIGHT", -padding, padding)

addon.openSettings = function()
    if ShowTrackSession == nil or ShowTrackSession == true then
        showTrackSessionCheckbox:SetChecked(ShowTrackSession or true);
    end
    frame:Show();
end
addon.closeSettings = function()
    frame:Hide();
end

local closeSettingsButton = Utils.createButton(frame, "Close", 80, 22, "TOPRIGHT", -padding, -padding)
closeSettingsButton:SetScript("OnClick", function()
    addon.closeSettings();
end)
