local name, addon = ...;

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

local title = addon.createLabel(frame, "WalkCraft", 24, "TOPLEFT", padding, -padding)

local showTrackSessionCheckbox = addon.createCheckbox(frame, padding, -padding - 24 - padding,
    "Show current session tracker");
showTrackSessionCheckbox.tooltip = "Toggle visibility of the section where you can start/stop and track sessions.";
showTrackSessionCheckbox:SetScript("OnClick", function()
    if showTrackSessionCheckbox:GetChecked() then
        addon.showSessionWindow();
    else
        addon.hideSessionWindow();
    end
end);

StaticPopupDialogs["CONFIRM_RESET_TOTAL_DISTANCE"] = {
    text = "Are you sure that you want to reset your all time distance?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        addon.setTotalDistanceTravelled(0)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3
}

local resetTotalDistanceButton = addon.createButton(frame, "Reset total distance", 150, 22, "BOTTOMLEFT", padding,
    padding)
resetTotalDistanceButton:SetScript("OnClick", function()
    StaticPopup_Show("CONFIRM_RESET_TOTAL_DISTANCE")
end)

local versionLabel = addon.createLabel(frame, "WalkCraft v" .. addon.config.version, 10, "BOTTOMRIGHT", -padding,
    padding)

addon.openSettings = function()
    if ShowTrackSession == nil or ShowTrackSession == true then
        showTrackSessionCheckbox:SetChecked(ShowTrackSession or true);
    end
    frame:Show();
end

addon.closeSettings = function()
    frame:Hide();
end

local closeSettingsButton = addon.createCloseButton(frame, "TOPRIGHT", 0, 0)
closeSettingsButton:SetScript("OnClick", function()
    addon.closeSettings();
end)
