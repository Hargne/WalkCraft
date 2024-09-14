local name, addon = ...;

local yardToKm = 0.0009144
local _elementId = 1;

addon.convertYardsToKilometres = function(yards)
    if yards == nil then
        return 0;
    end
    return yards * yardToKm;
end

addon.ingameSpeedToMinutesPerKilometers = function(speed)
    local minutes = 0
    local seconds = 0
    if speed ~= nil and speed > 0 then
        local kmPerHour = speed * 3600 * yardToKm
        local kmPerMinute = kmPerHour / 60
        local minPerKm = 1 / kmPerMinute
        minutes = math.floor(minPerKm)
        seconds = math.floor((minPerKm - minutes) * 60)
    end
    return string.format("%02d:%02d/km", minutes, seconds)
end

addon.createLabel = function(parent, text, size, position, x, y)
    _elementId = _elementId + 1;
    local label = parent:CreateFontString("label" .. _elementId, "OVERLAY", "GameFontNormal")
    label:SetFont(addon.config.mainFont, size, "OUTLINE")
    label:SetPoint(position, parent, position, x, y)
    label:SetText(text)
    return label;
end

addon.createButton = function(parent, label, width, height, position, x, y, texture)
    _elementId = _elementId + 1;
    local button = CreateFrame("Button", label .. "Button" .. _elementId, parent, texture or "UIPanelButtonTemplate")
    button:SetSize(width, height)
    button:SetText(label)
    button:SetPoint(position, parent, position, x, y)
    return button;
end

addon.createCloseButton = function(parent, position, x, y)
    return addon.createButton(parent, "Close", 32, 32, position, x, y, "UIPanelCloseButton")
end

addon.createCheckbox = function(parent, x_loc, y_loc, displayname)
    _elementId = _elementId + 1;
    local checkbox = CreateFrame("CheckButton", "my_addon_checkbox_0" .. _elementId, parent,
        "ChatConfigCheckButtonTemplate");
    checkbox:SetPoint("TOPLEFT", x_loc, y_loc);
    getglobal(checkbox:GetName() .. 'Text'):SetText("  " .. displayname);
    return checkbox;
end

addon.dataLabelWidth = 128
addon.dataLabelHeight = 42
addon.createDataLabel = function(parent, heading, value, position, x, y)
    local dataFrame = CreateFrame("Frame", heading .. "DataFrame", parent)
    dataFrame:SetSize(addon.dataLabelWidth, 32)
    dataFrame:SetPoint(position, parent, position, x, y)
    dataFrame.texture = dataFrame:CreateTexture()
    dataFrame.texture:SetAllPoints(dataFrame)
    dataFrame.texture:SetTexture("Interface/PaperDollInfoFrame/UI-CHARACTER-INACTIVETAB")

    local headerFrame = CreateFrame("Frame", heading .. "HeadingFrame", dataFrame)
    headerFrame:SetSize(addon.dataLabelWidth * 1.7, 36)
    headerFrame:SetPoint("TOP", dataFrame, "TOP", 0, 17)
    headerFrame.texture = headerFrame:CreateTexture()
    headerFrame.texture:SetAllPoints(headerFrame)
    headerFrame.texture:SetTexture("Interface/DialogFrame/UI-DialogBox-Header")
    local headingLabel = addon.createLabel(headerFrame, heading, 9, "CENTER", 0, 6)

    local valueLabel = addon.createLabel(dataFrame, value, 12, "CENTER", 0, 4)
    valueLabel:SetTextColor(1, 1, 1)

    return {
        dataFrame,
        headingLabel,
        valueLabel
    }
end

