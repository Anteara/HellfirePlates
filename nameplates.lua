-- create frame
pfNameplates = CreateFrame("Frame", nil, UIParent)
pfNameplates:RegisterEvent("PLAYER_TARGET_CHANGED")
pfNameplates:RegisterEvent("UNIT_AURA")

local STANDARD_TEXT_FONT = "Interface\\AddOns\\HellfirePlates\\fonts\\arial.ttf"

pfNameplates.mobs = {}
pfNameplates.targets = {}
pfNameplates.players = {}

-- catch all nameplates
pfNameplates.scanner = CreateFrame("Frame", "pfNameplateScanner", UIParent)
pfNameplates.scanner.objects = {}
pfNameplates.scanner:SetScript("OnUpdate", function()

--Loop through all children of the WorldFrame. We want to find some nameplates! called infinitely.
for _, nameplate in ipairs({WorldFrame:GetChildren()}) do
	
    --if nameplate.done == false (a key we made up, in order to determine if that nameplate has been deleted yet), then continue.
	if not nameplate.done then --can cause a bug if the .done doesn't exist.
		local regions = nameplate:GetRegions()

			--If we actually have a nameplate found, then continue (will only get to this point for each nameplate on the screen). i.e. 3 mobs = called 3 times
			if regions and regions:GetObjectType() == "Texture" and regions:GetTexture() == "Interface\\Tooltips\\Nameplate-Border" then
				nameplate:Hide()
				nameplate:SetScript("OnShow", function() pfNameplates:CreateNameplate() end)
				nameplate:SetScript("OnUpdate", function() pfNameplates:UpdateNameplate() end)
				nameplate:Show()
				table.insert(this.objects, nameplate)
				nameplate.done = true
			end
		end
	end
end)

function round(input, places)
  if not places then places = 0 end
  if type(input) == "number" and type(places) == "number" then
    local pow = 1
    for i = 1, places do pow = pow * 10 end
    return floor(input * pow + 0.5) / pow
  end
end

-- Create Nameplate
function pfNameplates:CreateNameplate()
  local healthbar = this:GetChildren()
  local _, levelicon

  --First return type: Interface\\Tooltips\\Nameplate-Border
  --Second return type: Interface\\Tooltips\\Nameplate-Border (also...?)
  --Third return type: ?????????
  --Fourth return type: Interface\\Tooltips\\Nameplate-Glow
  --Fifth return type: Name of the Mob/NPC
  --Sixth return type: Level of the Mob/NPC
  --Seventh return type: Interface\\TargetingFrame\\UI-TargetingFrame-Skull (The elite border???)
  --Eighth return type: Interface\\TargetingFrame\\UI-RaidTargetingIcons

  local border, _, _, glow, name, level, levelicon, raidicon = this:GetRegions()

  -- hide default plates
  border:Hide()

  -- remove glowing
  glow:Hide()
  glow:SetAlpha(0)
  glow.Show = function() return end

  if hellfirePlates_configSettings["players"] == "1" then
    if not pfNameplates.players[name:GetText()] or not pfNameplates.players[name:GetText()]["class"] then
      this:Hide()
    end
  end

  -- healthbar
  healthbar:SetStatusBarTexture("Interface\\AddOns\\HellfirePlates\\img\\bar")
  healthbar:ClearAllPoints()
  healthbar:SetPoint("TOP", this, "TOP", 0, tonumber(hellfirePlates_configSettings["vpos"]))
  healthbar:SetWidth(110)
  healthbar:SetHeight(7)

  if healthbar.bg == nil then
    healthbar.bg = healthbar:CreateTexture(nil, "BORDER")
    healthbar.bg:SetTexture(0,0,0,0.90)
    healthbar.bg:ClearAllPoints()
    healthbar.bg:SetPoint("CENTER", healthbar, "CENTER", 0, 0)
    healthbar.bg:SetWidth(healthbar:GetWidth() + 3)
    healthbar.bg:SetHeight(healthbar:GetHeight() + 3)
  end

  healthbar.reaction = nil

  -- raidtarget
  raidicon:ClearAllPoints()
--   DEFAULT_CHAT_FRAME:AddMessage(hellfirePlates_configSettings["raidiconsize"])
  raidicon:SetWidth(hellfirePlates_configSettings["raidiconsize"])
  raidicon:SetHeight(hellfirePlates_configSettings["raidiconsize"])
  raidicon:SetPoint("CENTER", healthbar, "CENTER", 0, 0)

  -- adjust font
  name:SetFont(STANDARD_TEXT_FONT,12,"OUTLINE")
  name:SetPoint("BOTTOM", healthbar, "CENTER", 0, 7)
  level:SetFont(STANDARD_TEXT_FONT,12, "OUTLINE")
  level:ClearAllPoints()
  level:SetPoint("RIGHT", healthbar, "LEFT", -1, 0)
  levelicon:ClearAllPoints()
  levelicon:SetPoint("RIGHT", healthbar, "LEFT", -1, 0)

  -- show indicator for elite/rare mobs
  if level:GetText() ~= nil then
    if pfNameplates.mobs[name:GetText()] and pfNameplates.mobs[name:GetText()] == "elite" and not string.find(level:GetText(), "+", 1) then
      level:SetText(level:GetText() .. "+")
    elseif pfNameplates.mobs[name:GetText()] and pfNameplates.mobs[name:GetText()] == "rareelite" and not string.find(level:GetText(), "R+", 1) then
      level:SetText(level:GetText() .. "R+")
    elseif pfNameplates.mobs[name:GetText()] and pfNameplates.mobs[name:GetText()] == "rare" and not string.find(level:GetText(), "R", 1) then
      level:SetText(level:GetText() .. "R")
    end
  end

  pfNameplates:CreateDebuffs(this)
  pfNameplates:CreateCastbar(healthbar)
  pfNameplates:CreateHP(healthbar)

  this.setup = true
end

function pfNameplates:CreateDebuffs(frame)
  if hellfirePlates_configSettings["nameplateShowDebuffs"] ~= "1" then return end

  if frame.debuffs == nil then frame.debuffs = {} end
  for j=1, 16, 1 do
    if frame.debuffs[j] == nil then
      frame.debuffs[j] = this:CreateTexture(nil, "BORDER")
      frame.debuffs[j]:SetTexture(0,0,0,0)
      frame.debuffs[j]:ClearAllPoints()
      frame.debuffs[j]:SetWidth(12)
      frame.debuffs[j]:SetHeight(12)
      if j == 1 then
        frame.debuffs[j]:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -3)
      elseif j <= 8 then
        frame.debuffs[j]:SetPoint("LEFT", frame.debuffs[j-1], "RIGHT", 1, 0)
      elseif j > 8 then
        frame.debuffs[j]:SetPoint("TOPLEFT", frame.debuffs[1], "BOTTOMLEFT", (j-9) * 13, -1)
      end
    end
  end
end

function pfNameplates:CreateCastbar(healthbar)
  -- create frames
  if healthbar.castbar == nil then
    healthbar.castbar = CreateFrame("StatusBar", nil, healthbar)
    healthbar.castbar:Hide()
    healthbar.castbar:SetWidth(110)
    healthbar.castbar:SetHeight(7)
    healthbar.castbar:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -5)
    healthbar.castbar:SetBackdrop({  bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
                                     insets = {left = -1, right = -1, top = -1, bottom = -1} })
    healthbar.castbar:SetBackdropColor(0,0,0,1)
    healthbar.castbar:SetStatusBarTexture("Interface\\AddOns\\HellfirePlates\\img\\bar")
    healthbar.castbar:SetStatusBarColor(.9,.8,0,1)

    if healthbar.castbar.bg == nil then
      healthbar.castbar.bg = healthbar.castbar:CreateTexture(nil, "BACKGROUND")
      healthbar.castbar.bg:SetTexture(0,0,0,0.90)
      healthbar.castbar.bg:ClearAllPoints()
      healthbar.castbar.bg:SetPoint("CENTER", healthbar.castbar, "CENTER", 0, 0)
      healthbar.castbar.bg:SetWidth(healthbar.castbar:GetWidth() + 3)
      healthbar.castbar.bg:SetHeight(healthbar.castbar:GetHeight() + 3)
    end

    if healthbar.castbar.text == nil then
      healthbar.castbar.text = healthbar.castbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
      healthbar.castbar.text:SetPoint("RIGHT", healthbar.castbar, "LEFT")
      healthbar.castbar.text:SetNonSpaceWrap(false)
      healthbar.castbar.text:SetFontObject(GameFontWhite)
      healthbar.castbar.text:SetTextColor(1,1,1,.5)
      healthbar.castbar.text:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    end

    if healthbar.castbar.spell == nil then
      healthbar.castbar.spell = healthbar.castbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
      healthbar.castbar.spell:SetPoint("CENTER", healthbar.castbar, "CENTER")
      healthbar.castbar.spell:SetNonSpaceWrap(false)
      healthbar.castbar.spell:SetFontObject(GameFontWhite)
      healthbar.castbar.spell:SetTextColor(1,1,1,1)
      healthbar.castbar.spell:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
    end

    if healthbar.castbar.icon == nil then
      healthbar.castbar.icon = healthbar.castbar:CreateTexture(nil, "BORDER")
      healthbar.castbar.icon:ClearAllPoints()
      healthbar.castbar.icon:SetPoint("BOTTOMLEFT", healthbar.castbar, "BOTTOMRIGHT", 5, 0)
      healthbar.castbar.icon:SetWidth(18)
      healthbar.castbar.icon:SetHeight(18)
    end

    if healthbar.castbar.icon.bg == nil then
      healthbar.castbar.icon.bg = healthbar.castbar:CreateTexture(nil, "BACKGROUND")
      healthbar.castbar.icon.bg:SetTexture(0,0,0,0.90)
      healthbar.castbar.icon.bg:ClearAllPoints()
      healthbar.castbar.icon.bg:SetPoint("CENTER", healthbar.castbar.icon, "CENTER", 0, 0)
      healthbar.castbar.icon.bg:SetWidth(healthbar.castbar.icon:GetWidth() + 3)
      healthbar.castbar.icon.bg:SetHeight(healthbar.castbar.icon:GetHeight() + 3)
    end
  end
end

function pfNameplates:CreateHP(healthbar)
	if hellfirePlates_configSettings["nameplateShowHP"] == 1 and not healthbar.hptext then
		healthbar.hptext = healthbar:CreateFontString("Status", "DIALOG", "GameFontNormal")
		healthbar.hptext:SetPoint("RIGHT", healthbar, "RIGHT")
		healthbar.hptext:SetNonSpaceWrap(false)
		healthbar.hptext:SetFontObject(GameFontWhite)
		healthbar.hptext:SetTextColor(1,1,1,1)
		healthbar.hptext:SetFont(STANDARD_TEXT_FONT, 10)
	end
end

-- Update Nameplate
function pfNameplates:UpdateNameplate()
  if not this.setup then pfNameplates:CreateNameplate() return end

  local healthbar = this:GetChildren()

  local border, _, _, glow, name, level, levelicon, raidicon = this:GetRegions()


  if hellfirePlates_configSettings["players"] == "1" then
    if not pfNameplates.players[name:GetText()] or not pfNameplates.players[name:GetText()]["class"] then
      this:Hide()
    end
  end

  pfNameplates:UpdatePlayer(name)
  pfNameplates:UpdateColors(name, level, healthbar)
  pfNameplates:UpdateCastbar(this, name, healthbar)
  pfNameplates:UpdateDebuffs(this, healthbar)
  pfNameplates:UpdateHP(healthbar)
end

function pfNameplates:UpdatePlayer(name)
  local name = name:GetText()

  -- target
  if not pfNameplates.players[name] and pfNameplates.targets[name] == nil and UnitName("target") == nil then
    if UnitIsPlayer("target") then
      local _, class = UnitClass("target")
      pfNameplates.players[name] = {}
      pfNameplates.players[name]["class"] = class
    elseif UnitClassification("target") ~= "normal" then
      local elite = UnitClassification("target")
      pfNameplates.mobs[name] = elite
    end
    pfNameplates.targets[name] = "OK"
  end

  -- mouseover
  if not pfNameplates.players[name] and pfNameplates.targets[name] == nil and UnitName("mouseover") == name then
    if UnitIsPlayer("mouseover") then
      local _, class = UnitClass("mouseover")
      pfNameplates.players[name] = {}
      pfNameplates.players[name]["class"] = class
    elseif UnitClassification("mouseover") ~= "normal" then
      local elite = UnitClassification("mouseover")
      pfNameplates.mobs[name] = elite
    end
    pfNameplates.targets[name] = "OK"
  end
end

function pfNameplates:UpdateColors(name, level, healthbar)
  -- name color
  local red, green, blue, _ = name:GetTextColor()
  if red > 0.99 and green == 0 and blue == 0 then
    name:SetTextColor(1,0.4,0.2,0.85)
  elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
    name:SetTextColor(1,1,1,0.85)
  end

  -- level colors
  local red, green, blue, _ = level:GetTextColor()
  if red > 0.99 and green == 0 and blue == 0 then
    level:SetTextColor(1,0.4,0.2,0.85)
  elseif red > 0.99 and green > 0.81 and green < 0.82 and blue == 0 then
    level:SetTextColor(1,1,1,0.85)
  end

  -- healthbar color
  -- reaction: 0 enemy ; 1 neutral ; 2 player ; 3 npc
  local red, green, blue, _ = healthbar:GetStatusBarColor()
  if red > 0.9 and green < 0.2 and blue < 0.2 then
    healthbar.reaction = 0
    healthbar:SetStatusBarColor(.9,.2,.3,0.8)
  elseif red > 0.9 and green > 0.9 and blue < 0.2 then
    healthbar.reaction = 1
    healthbar:SetStatusBarColor(1,1,.3,0.8)
  elseif ( blue > 0.9 and red == 0 and green == 0 ) then
    healthbar.reaction = 2
    healthbar:SetStatusBarColor(0.2,0.6,1,0.8)
  elseif red == 0 and green > 0.99 and blue == 0 then
    healthbar.reaction = 3
    healthbar:SetStatusBarColor(0.6,1,0,0.8)
  end

  local name = name:GetText()

  if healthbar.reaction == 0 then
    if hellfirePlates_configSettings["classColourEnemy"] == "1"
    and pfNameplates.players[name]
    and pfNameplates.players[name]["class"]
    and RAID_CLASS_COLORS[pfNameplates.players[name]["class"]]
    then
      healthbar:SetStatusBarColor(
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].r,
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].g,
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].b,
        0.9)
    end
  elseif healthbar.reaction == 2 then
    if hellfirePlates_configSettings["classColourFriendly"] == "1"
    and pfNameplates.players[name]
    and pfNameplates.players[name]["class"]
    and RAID_CLASS_COLORS[pfNameplates.players[name]["class"]]
    then
      healthbar:SetStatusBarColor(
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].r,
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].g,
        RAID_CLASS_COLORS[pfNameplates.players[name]["class"]].b,
        0.9)
    end
  end
end

function pfNameplates:UpdateCastbar(frame, name, healthbar)
  if not healthbar.castbar then return end

  -- show castbar
  if hellfirePlates_configSettings["nameplateShowCastbar"] == "1" and pfCastbar.casterDB[name:GetText()] ~= nil and pfCastbar.casterDB[name:GetText()]["cast"] ~= nil then
    if pfCastbar.casterDB[name:GetText()]["starttime"] + pfCastbar.casterDB[name:GetText()]["casttime"] <= GetTime() then
      pfCastbar.casterDB[name:GetText()] = nil
      healthbar.castbar:Hide()
    else
      healthbar.castbar:SetMinMaxValues(0,  pfCastbar.casterDB[name:GetText()]["casttime"])
      healthbar.castbar:SetValue(GetTime() -  pfCastbar.casterDB[name:GetText()]["starttime"])
      healthbar.castbar.text:SetText(round( pfCastbar.casterDB[name:GetText()]["starttime"] +  pfCastbar.casterDB[name:GetText()]["casttime"] - GetTime(),1))
      if hellfirePlates_configSettings["spellname"] == "1" and healthbar.castbar.spell then
        healthbar.castbar.spell:SetText(pfCastbar.casterDB[name:GetText()]["cast"])
      else
        healthbar.castbar.spell:SetText("")
      end
      healthbar.castbar:Show()
      if frame.debuffs then
        frame.debuffs[1]:SetPoint("TOPLEFT", healthbar.castbar, "BOTTOMLEFT", 0, -3)
      end

      if pfCastbar.casterDB[name:GetText()]["icon"] then
        healthbar.castbar.icon:SetTexture("Interface\\Icons\\" ..  pfCastbar.casterDB[name:GetText()]["icon"])
        healthbar.castbar.icon:SetTexCoord(.1,.9,.1,.9)
      end
    end
  else
    healthbar.castbar:Hide()
    if frame.debuffs then
      frame.debuffs[1]:SetPoint("TOPLEFT", healthbar, "BOTTOMLEFT", 0, -3)
    end
  end
end

function pfNameplates:UpdateDebuffs(frame, healthbar)
  if not frame.debuffs or hellfirePlates_configSettings["nameplateShowDebuffs"] ~= "1" then return end

  if UnitExists("target") and healthbar:GetAlpha() == 1 then
  local j = 1
    local k = 1
    for j, e in ipairs(pfNameplates.debuffs) do
      frame.debuffs[j]:SetTexture(pfNameplates.debuffs[j])
      frame.debuffs[j]:SetTexCoord(.078, .92, .079, .937)
      frame.debuffs[j]:SetAlpha(0.9)
      k = k + 1
    end
    for j = k, 16, 1 do
      frame.debuffs[j]:SetTexture(nil)
    end
  elseif frame.debuffs then
    for j = 1, 16, 1 do
      frame.debuffs[j]:SetTexture(nil)
    end
  end
end

function pfNameplates:UpdateHP(healthbar)
	if hellfirePlates_configSettings["nameplateShowHP"] == 1 and healthbar.hptext then
		local min, max = healthbar:GetMinMaxValues()
		local cur = healthbar:GetValue()
		healthbar.hptext:SetText(cur .. " / " .. max)
	end
end

-- debuff detection
pfNameplates:RegisterEvent("PLAYER_TARGET_CHANGED")
pfNameplates:RegisterEvent("UNIT_AURA")
pfNameplates:SetScript("OnEvent", function()
  pfNameplates.debuffs = {}
  local i = 1
  local debuff = UnitDebuff("target", i)
  while debuff do
    pfNameplates.debuffs[i] = debuff
    i = i + 1
    debuff = UnitDebuff("target", i)
  end
end)

-- combat tracker
pfNameplates.combat = CreateFrame("Frame")
pfNameplates.combat:RegisterEvent("PLAYER_ENTER_COMBAT")
pfNameplates.combat:RegisterEvent("PLAYER_LEAVE_COMBAT")
pfNameplates.combat:SetScript("OnEvent", function()
  if event == "PLAYER_ENTER_COMBAT" then
    this.inCombat = 1
  elseif event == "PLAYER_LEAVE_COMBAT" then
    this.inCombat = nil
  end
end)
