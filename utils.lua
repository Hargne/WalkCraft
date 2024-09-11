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
    if speed > 0 then
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

addon.dataLabelWidth = 75
addon.createDataLabel = function(parent, heading, value, position, x, y)
    local dataFrame = CreateFrame("Frame", heading .. "DataFrame", parent)
    dataFrame:SetSize(75, 35)
    dataFrame:SetPoint(position, parent, position, x, y)
    local headingLabel = addon.createLabel(dataFrame, heading, 8, "TOPLEFT", 0, 0)
    local valueLabel = addon.createLabel(dataFrame, value, 12, "TOPLEFT", 0, -12)
    valueLabel:SetTextColor(1, 1, 1)

    return {
        dataFrame,
        headingLabel,
        valueLabel
    }
end