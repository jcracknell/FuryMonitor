--[[
This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public Liscence, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtpl/COPYING for more details.
]]--

FuryMonitor.AbilityFrame = {};
FuryMonitor.AbilityFrame.__index = FuryMonitor.AbilityFrame;
FuryMonitor.AbilityFrame.Active = {};
FuryMonitor.AbilityFrame.Inactive = {};

function FuryMonitor.AbilityFrame:new(ability, useId, time, parentFrame, rageStatus)
	local instance = nil;
	if #FuryMonitor.AbilityFrame.Inactive > 0 then
		-- We have an old frame that is not in use, so we'll use that
		instance = FuryMonitor.AbilityFrame.Inactive[#FuryMonitor.AbilityFrame.Inactive];
		table.remove(FuryMonitor.AbilityFrame.Inactive, #FuryMonitor.AbilityFrame.Inactive);
	else
		-- We've run out of frames, so create a new one
		local rageIndicatorFrame = CreateFrame("Frame", nil, UIParent);
		local iconFrame = CreateFrame("Frame", nil, UIParent);
		local text = iconFrame:CreateFontString(nil);

		local members = {
			_ability = nil,
			_time = nil,
			_iconFrame = iconFrame,
			_damageText = text,
			_rageIndicatorFrame = rageIndicatorFrame,
			_rageStatus = nil,
			_parent = nil,
			_useId = nil,
			_x = 0,
			_y = 0,
			_active = nil
		};
		instance = setmetatable(members, FuryMonitor.AbilityFrame);
	end

	instance:SetAbility(ability);
	instance:SetUseId(useId);
	instance._time = time;
	instance._parent = parentFrame;
	instance._active = true;
	instance._rageStatus = rageStatus;

	instance:LoadFrameConfiguration();

	-- Add the instance to the table of active instances
	if not FuryMonitor.AbilityFrame.Active[instance:GetAbility():GetSpellNumber()] then
		FuryMonitor.AbilityFrame.Active[instance:GetAbility():GetSpellNumber()] = {};
	end
	FuryMonitor.AbilityFrame.Active[instance:GetAbility():GetSpellNumber()][instance:GetUseId()]
		= instance;

	-- Set up event subscriptions
	FuryMonitor.Main:GetInstance():SubscribeToConfigurationChanges(instance);	
	FuryMonitor.Main:GetInstance():SubscribeToStatChanges(instance);

	return instance;
end

function FuryMonitor.AbilityFrame:recycle()
	-- Cancel event subscriptions
	FuryMonitor.Main:GetInstance():UnSubscribeToConfigurationChanges(self);
	FuryMonitor.Main:GetInstance():UnSubscribeToStatChanges(self);

	self._active = false;

	-- Add this to the inactive list
	table.insert(FuryMonitor.AbilityFrame.Inactive, self);
	-- Remove this from the active list
	FuryMonitor.AbilityFrame.Active[self:GetAbility():GetSpellNumber()][self:GetUseId()] = nil;

	self:GetIconFrame():Hide();
	self:GetDamageText():Hide();
end

function FuryMonitor.AbilityFrame:LoadFrameConfiguration()
	-- Set up the icon frame
	self:GetIconFrame():SetWidth(FuryMonitor.Configuration.AbilityFrame.Width);
	self:GetIconFrame():SetHeight(FuryMonitor.Configuration.AbilityFrame.Height);
	self:GetIconFrame():SetBackdrop({
		bgFile = self:GetAbility():GetTexture(),
		edgeFile = FuryMonitor.Configuration.AbilityFrame.EdgeFile,
		edgeSize = FuryMonitor.Configuration.AbilityFrame.EdgeSize,
		tile = 0,
		tileSize = math.max(
			FuryMonitor.Configuration.AbilityFrame.Width,
			FuryMonitor.Configuration.AbilityFrame.Height
		),
		insets = {
			top = FuryMonitor.Configuration.AbilityFrame.BackgroundInset,
			bottom = FuryMonitor.Configuration.AbilityFrame.BackgroundInset,
			left = FuryMonitor.Configuration.AbilityFrame.BackgroundInset,
			right = FuryMonitor.Configuration.AbilityFrame.BackgroundInset
		}
	});
	self:GetIconFrame():SetAlpha(
		FuryMonitor.Configuration.AbilityFrame.Alpha
		* FuryMonitor.Configuration.Display.Alpha
	);
	self:GetIconFrame():SetFrameStrata(FuryMonitor.Configuration.AbilityFrame.FrameStrata);
	if FuryMonitor.Configuration.Enabled then
		self:GetIconFrame():Show();
	else
		self:GetIconFrame():Hide();
	end

	-- Set up rage indicator
	self:GetRageIndicatorFrame():SetWidth(
		FuryMonitor.Configuration.AbilityFrame.RageIndicator.Width
	);
	self:GetRageIndicatorFrame():SetHeight(
		FuryMonitor.Configuration.AbilityFrame.RageIndicator.Height
	);
	self:GetRageIndicatorFrame():SetBackdrop({
		bgFile = FuryMonitor.Configuration.AbilityFrame.RageIndicator.BackgroundFile,
		tile = 0,
		insets = {
			top = FuryMonitor.Configuration.AbilityFrame.RageIndicator.BackgroundInset,
			bottom = FuryMonitor.Configuration.AbilityFrame.RageIndicator.BackgroundInset,
			left = FuryMonitor.Configuration.AbilityFrame.RageIndicator.BackgroundInset,
			right = FuryMonitor.Configuration.AbilityFrame.RageIndicator.BackgroundInset
		}
	});
	self:GetRageIndicatorFrame():SetPoint(
		FuryMonitor.Configuration.AbilityFrame.RageIndicator.Position,
		self:GetIconFrame(),
		FuryMonitor.Configuration.AbilityFrame.RageIndicator.Position
	);
	self:GetRageIndicatorFrame():SetFrameStrata(
		FuryMonitor.Configuration.AbilityFrame.FrameStrata
	);
	self:UpdateRageIndicator();
	self:GetRageIndicatorFrame():SetAlpha(
		FuryMonitor.Configuration.AbilityFrame.RageIndicator.Alpha
	);
	if FuryMonitor.Configuration.AbilityFrame.RageIndicator.Show
		and FuryMonitor.Configuration.Enabled and not self:GetAbility():IsFake() then
		self:GetRageIndicatorFrame():Show();
	else
		self:GetRageIndicatorFrame():Hide();
	end

	-- Set up damage text
	self:GetDamageText():SetFont(
		FuryMonitor.Configuration.AbilityFrame.FontFile,
		FuryMonitor.Configuration.AbilityFrame.FontSize,
		"OUTLINE"
	);
	self:GetDamageText():SetTextColor(
		FuryMonitor.Configuration.AbilityFrame.FontColor.R,
		FuryMonitor.Configuration.AbilityFrame.FontColor.G,
		FuryMonitor.Configuration.AbilityFrame.FontColor.B,
		FuryMonitor.Configuration.AbilityFrame.FontColor.A
		* FuryMonitor.Configuration.Display.Alpha
	);
	self:GetDamageText():SetPoint("TOP", self:GetIconFrame(), "CENTER", 0,
		- FuryMonitor.Util.round(FuryMonitor.Configuration.AbilityFrame.Height * 0.5)
		+ FuryMonitor.Configuration.AbilityFrame.FontSize
	);
	self:UpdateDamageText();
	if FuryMonitor.Configuration.Enabled then
		self:GetDamageText():Show();
	else
		self:GetDamageText():Hide();
	end
end

function FuryMonitor.AbilityFrame:OnConfigurationChanged()
	self:LoadFrameConfiguration();
end

function FuryMonitor.AbilityFrame:OnStatsChanged()
	self:UpdateDamageText();
	self:UpdateRageIndicator();
end

function FuryMonitor.AbilityFrame.RecycleOldAbilityFrames()
	-- Recycles AbilityFrames in the Active table whose UseIds are lower
	-- than the current (pending) usecount of the ability
	-- USE BEFORE DISABLING THEORETICAL USE
	for i, abilityTable in pairs(FuryMonitor.AbilityFrame.Active) do
		for k, af in pairs(abilityTable) do
			if af:GetUseId() < af:GetAbility():GetUseCount() then
				af:recycle();
			end
		end
	end
end

function FuryMonitor.AbilityFrame.RecycleUnusedAbilityFrames()
	-- Recycles AbilityFrames in the Active table whose UseIds are higher
	-- than or equal to the current (pending) usecount of their ability
	-- USE AFTER DISABLING THEORETICAL USE
	for i, abilityTable in pairs(FuryMonitor.AbilityFrame.Active) do
		for j, af in pairs(abilityTable) do
			if af:GetUseId() >= af:GetAbility():GetUseCount() then
				af:recycle();
			end
		end
	end
end

function FuryMonitor.AbilityFrame:UpdateDamageText()
	local damage = self:GetAbility():GetDamage();
	local text = damage;
	if damage <= 0 then
		text = "";
	end	
	self:GetDamageText():SetText(text);
end

function FuryMonitor.AbilityFrame:UpdateRageIndicator()
	local color = nil;
	if self._rageStatus then
		color = FuryMonitor.Configuration.AbilityFrame.RageIndicator.OnColor;
	else
		color = FuryMonitor.Configuration.AbilityFrame.RageIndicator.OffColor;
	end
	self:GetRageIndicatorFrame():SetBackdropColor(
		color.R, color.G, color.B,
		color.A * FuryMonitor.Configuration.Display.Alpha
	);
end

function FuryMonitor.AbilityFrame:GetAbilityFrame(spellNumber, useNumber)
	if (not FuryMonitor.AbilityFrame.Active[spellNumber])
		or (not FuryMonitor.AbilityFrame.Active[spellNumber][useNumber]) then
		return nil;
	end
	return FuryMonitor.AbilityFrame.Active[spellNumber][useNumber]
end

function FuryMonitor.AbilityFrame:GetAbility()
	return self._ability;
end

function FuryMonitor.AbilityFrame:SetAbility(ability)
	self._ability = ability;
end

function FuryMonitor.AbilityFrame:GetIconFrame()
	return self._iconFrame;
end

function FuryMonitor.AbilityFrame:GetRageIndicatorFrame()
	return self._rageIndicatorFrame;
end

function FuryMonitor.AbilityFrame:GetDamageText()
	return self._damageText;
end

function FuryMonitor.AbilityFrame:GetParentFrame()
	return self._parent;
end

function FuryMonitor.AbilityFrame:GetUseId()
	return self._useId;
end

function FuryMonitor.AbilityFrame:SetUseId(useId)
	self._useId = useId;
end

function FuryMonitor.AbilityFrame:SetRageAvailable(available)
	self._rageStatus = available;
	self:UpdateRageIndicator();
end

function FuryMonitor.AbilityFrame:GetX(value)
	return self._x;
end

function FuryMonitor.AbilityFrame:SetX(value)
	self._x = value;
	self:GetIconFrame():SetPoint("TOPLEFT", self:GetParentFrame(), "TOPLEFT", self:GetX(), self:GetY());
end

function FuryMonitor.AbilityFrame:GetY()
	return self._y;
end

function FuryMonitor.AbilityFrame:SetY(value)
	self._y = -value;
	self:GetIconFrame():SetPoint("TOPLEFT", self:GetParentFrame(), "TOPLEFT", self:GetX(), self:GetY());
end
