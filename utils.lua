local name, addon = ...;

Utils = {
    yard_to_km = 0.0009144
}

local elementId = 1;

Utils.convertYardsToKilometres = function(yards)
    if yards == nil then
        return 0;
    end
    return yards * Utils.yard_to_km;
end

Utils.ingameSpeedToMinutesPerKilometers = function(speed)
    local minutes = 0
    local seconds = 0
    if speed > 0 then
        local kmPerHour = speed * 3600 * Utils.yard_to_km
        local kmPerMinute = kmPerHour / 60
        local minPerKm = 1 / kmPerMinute
        minutes = math.floor(minPerKm)
        seconds = math.floor((minPerKm - minutes) * 60)
    end
    return string.format("%02d:%02d/km", minutes, seconds)
end

Utils.createLabel = function(parent, text, size, position, x, y)
    elementId = elementId + 1;
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetFont(Settings.mainFont, size, "OUTLINE")
    label:SetPoint(position, parent, position, x, y)
    label:SetText(text)
    return label;
end

Utils.createButton = function(parent, label, width, height, position, x, y)
    elementId = elementId + 1;
    local button = CreateFrame("Button", label .. "Button", parent, "UIPanelButtonTemplate")
    button:SetSize(width, height)
    button:SetText(label)
    button:SetPoint(position, parent, position, x, y)
    return button;
end

Utils.createCheckbox = function(parent, x_loc, y_loc, displayname)
    elementId = elementId + 1;
    local checkbox = CreateFrame("CheckButton", "my_addon_checkbox_0" .. elementId, parent,
        "ChatConfigCheckButtonTemplate");
    checkbox:SetPoint("TOPLEFT", x_loc, y_loc);
    getglobal(checkbox:GetName() .. 'Text'):SetText("  " .. displayname);
    return checkbox;
end

addon.Utils = Utils;
