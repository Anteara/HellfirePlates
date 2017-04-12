local backdrop = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32,
  insets = {left = 0, right = 0, top = 0, bottom = 0},
}

local checkbox = {
  ["blueshaman"]    = "Enable Blue Shaman Class Color",
  ["showdebuffs"]   = "Show Debuffs on Target Nameplate",
  ["showcastbar"]   = "Show Castbar",
  ["spellname"]     = "Show Spellname On Castbar",
  ["showhp"]        = "Display HP",
  ["enemyclassc"]   = "Enable Enemy Class Colors",
  ["friendclassc"]  = "Enable Friend Class Colors",
}

local text = {
  ["vpos"]           = "Vertical Offset",
  ["raidiconsize"]   = "Raid Icon Size",
}

-- config
pfConfigCreate = CreateFrame("Frame", nil, UIParent)
pfConfigCreate:RegisterEvent("VARIABLES_LOADED")

function pfConfigCreate:ResetConfig()
  pfNameplates_config = { }
  pfNameplates_config["blueshaman"] = "1"
  pfNameplates_config["raidiconsize"] = "16"
  pfNameplates_config["showdebuffs"] = "1"
  pfNameplates_config["showcastbar"] = "1"
  pfNameplates_config["spellname"] = "1"
  pfNameplates_config["showhp"] = "0"
  pfNameplates_config["vpos"] = "0"
  pfNameplates_config["clickthreshold"] = ".5"
  pfNameplates_config["enemyclassc"] = "1"
  pfNameplates_config["friendclassc"] = "1"
end

pfConfigCreate:SetScript("OnEvent", function()
  if not pfNameplates_config then
    pfConfigCreate:ResetConfig()
  end

  HellfirePlatesConfig:Initialize()

  if pfNameplates_config.blueshaman == "1" then
    RAID_CLASS_COLORS["SHAMAN"] = { r = 0.14, g = 0.35, b = 1.0, colorStr = "ff0070de" }
  end
end)

HellfirePlatesConfig = HellfirePlatesConfig or CreateFrame("Frame", "HellfirePlatesConfig", UIParent)
function HellfirePlatesConfig:Initialize()
  HellfirePlatesConfig:Hide()
  HellfirePlatesConfig:SetBackdrop(backdrop)
  HellfirePlatesConfig:SetBackdropColor(0,0,0,1)
  HellfirePlatesConfig:SetWidth(400)
  HellfirePlatesConfig:SetHeight(500)
  HellfirePlatesConfig:SetPoint("CENTER", 0, 0)
  HellfirePlatesConfig:SetMovable(true)
  HellfirePlatesConfig:EnableMouse(true)
  HellfirePlatesConfig:SetScript("OnMouseDown",function()
    HellfirePlatesConfig:StartMoving()
  end)

  HellfirePlatesConfig:SetScript("OnMouseUp",function()
    HellfirePlatesConfig:StopMovingOrSizing()
  end)

  HellfirePlatesConfig.vpos = 60

  HellfirePlatesConfig.title = CreateFrame("Frame", nil, HellfirePlatesConfig)
  HellfirePlatesConfig.title:SetPoint("TOP", 0, -2);
  HellfirePlatesConfig.title:SetWidth(396);
  HellfirePlatesConfig.title:SetHeight(40);
  HellfirePlatesConfig.title.tex = HellfirePlatesConfig.title:CreateTexture("LOW");
  HellfirePlatesConfig.title.tex:SetAllPoints();
  HellfirePlatesConfig.title.tex:SetTexture(0,0,0,.5);

  HellfirePlatesConfig.caption = HellfirePlatesConfig.caption or HellfirePlatesConfig.title:CreateFontString("Status", "LOW", "GameFontWhite")
  HellfirePlatesConfig.caption:SetPoint("TOP", 0, -10)
  HellfirePlatesConfig.caption:SetJustifyH("CENTER")
  HellfirePlatesConfig.caption:SetText("HellfirePlates")
  HellfirePlatesConfig.caption:SetFont("Interface\\AddOns\\HellfirePlates\\fonts\\arial.ttf", 24)
  HellfirePlatesConfig.caption:SetTextColor(.2,1,.8,1)

  for config, description in pairs(checkbox) do
    HellfirePlatesConfig:CreateEntry(config, description, "checkbox")
  end

  for config, description in pairs(text) do
    HellfirePlatesConfig:CreateEntry(config, description, "text")
  end

  HellfirePlatesConfig.reload = CreateFrame("Button", nil, HellfirePlatesConfig, "UIPanelButtonTemplate")
  HellfirePlatesConfig.reload:SetWidth(150)
  HellfirePlatesConfig.reload:SetHeight(30)
  HellfirePlatesConfig.reload:SetNormalTexture(nil)
  HellfirePlatesConfig.reload:SetHighlightTexture(nil)
  HellfirePlatesConfig.reload:SetPushedTexture(nil)
  HellfirePlatesConfig.reload:SetDisabledTexture(nil)
  HellfirePlatesConfig.reload:SetBackdrop(backdrop)
  HellfirePlatesConfig.reload:SetBackdropColor(0,0,0,1)
  HellfirePlatesConfig.reload:SetPoint("BOTTOMRIGHT", -20, 20)
  HellfirePlatesConfig.reload:SetText("Save")
  HellfirePlatesConfig.reload:SetScript("OnClick", function()
    ReloadUI()
  end)

  HellfirePlatesConfig.reset = CreateFrame("Button", nil, HellfirePlatesConfig, "UIPanelButtonTemplate")
  HellfirePlatesConfig.reset:SetWidth(150)
  HellfirePlatesConfig.reset:SetHeight(30)
  HellfirePlatesConfig.reset:SetNormalTexture(nil)
  HellfirePlatesConfig.reset:SetHighlightTexture(nil)
  HellfirePlatesConfig.reset:SetPushedTexture(nil)
  HellfirePlatesConfig.reset:SetDisabledTexture(nil)
  HellfirePlatesConfig.reset:SetBackdrop(backdrop)
  HellfirePlatesConfig.reset:SetBackdropColor(0,0,0,1)
  HellfirePlatesConfig.reset:SetPoint("BOTTOMLEFT", 20, 20)
  HellfirePlatesConfig.reset:SetText("Reset")
  HellfirePlatesConfig.reset:SetScript("OnClick", function()
    pfNameplates_config = nil
    ReloadUI()
  end)
end

function HellfirePlatesConfig:CreateEntry(config, description, type)
  -- sanity check
  if not pfNameplates_config[config] then
    pfConfigCreate:ResetConfig()
  end

  -- basic frame
  local frame = getglobal("SPC" .. config) or CreateFrame("Frame", "SPC" .. config, HellfirePlatesConfig)
  frame:SetWidth(400)
  frame:SetHeight(25)
  frame:SetPoint("TOP", 0, -HellfirePlatesConfig.vpos)

  -- caption
  frame.caption = frame.caption or frame:CreateFontString("Status", "LOW", "GameFontWhite")
  frame.caption:SetFont("Interface\\AddOns\\HellfirePlates\\fonts\\arial.ttf", 14)
  frame.caption:SetPoint("LEFT", 20, 0)
  frame.caption:SetJustifyH("LEFT")
  frame.caption:SetText(description)

  -- checkbox
  if type == "checkbox" then
    frame.input = frame.input or CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.input:SetWidth(24)
    frame.input:SetHeight(24)
    frame.input:SetPoint("RIGHT" , -20, 0)

    frame.input.config = config
    if pfNameplates_config[config] == "1" then
      frame.input:SetChecked()
    end

    frame.input:SetScript("OnClick", function ()
      if this:GetChecked() then
        pfNameplates_config[this.config] = "1"
      else
        pfNameplates_config[this.config] = "0"
      end
    end)

  elseif type == "text" then
    -- input field
    frame.input = frame.input or CreateFrame("EditBox", nil, frame)
    frame.input:SetTextColor(.2,1,.8,1)
    frame.input:SetJustifyH("RIGHT")

    frame.input:SetWidth(50)
    frame.input:SetHeight(20)
    frame.input:SetPoint("RIGHT" , -20, 0)
    frame.input:SetFontObject(GameFontNormal)
    frame.input:SetAutoFocus(false)
    frame.input:SetScript("OnEscapePressed", function(self)
      this:ClearFocus()
    end)

    frame.input.config = config
    frame.input:SetText(pfNameplates_config[config])

    frame.input:SetScript("OnTextChanged", function(self)
      pfNameplates_config[this.config] = this:GetText()
    end)
  end

  HellfirePlatesConfig.vpos = HellfirePlatesConfig.vpos + 30
end

SLASH_SHAGUPLATES1 = '/hellfireplates'
SLASH_SHAGUPLATES2 = '/hp'

function SlashCmdList.SHAGUPLATES(msg)
  if HellfirePlatesConfig:IsShown() then
    HellfirePlatesConfig:Hide()
  else
    HellfirePlatesConfig:Show()
  end
end
