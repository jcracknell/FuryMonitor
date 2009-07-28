--[[
This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public Liscence, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtpl/COPYING for more details.
]]--

FuryMonitor.PowerBar = { _instance = nil }
FuryMonitor.PowerBar.__index = FuryMonitor.PowerBar;

function FuryMonitor.PowerBar:GetInstance(character, parentFrame)
	if not self._instance then
		local members = {
			_character = nil,
			_targetLevel = 1,
			_currentLevel = 0,
			_time = 0,
			_currentAttackPower = 0,
			_backgroundFrame = nil,
			_statusFrame = nil,
			_text = nil,
			_parent = nil,
			_X = 0,
			_Y = 0
		};
		self._instance = setmetatable(members, FuryMonitor.PowerBar);
	end
	self._instance._character = character;
	self._instance._parent = parentFrame;

	self._instance:CreateFrames();
	self._instance:LoadFrameConfiguration();

	FuryMonitor.Main:GetInstance():SubscribeToConfigurationChanges(self._instance);
	FuryMonitor.Main:GetInstance():SubscribeToStatChanges(self._instance);
	FuryMonitor.Main:GetInstance():SubscribeToUpdates(self._instance);

	return self._instance;
end

	function FuryMonitor.PowerBar:CreateFrames()
		-- Create background frame
		self:SetBackgroundFrame(CreateFrame("Frame", nil, self:GetParentFrame()));
		
		-- Create status frame
		self:SetStatusFrame(CreateFrame("FRAME", nil, self:GetParentFrame()));

		-- Create status text
		self._text = self:GetStatusFrame():CreateFontString(nil);
	end

function FuryMonitor.PowerBar:OnUpdate(force)
	if force or self:GetCurrentLevel() ~= self:GetTargetLevel() then
		local difference = self:GetTargetLevel() - self:GetCurrentLevel();
		local timeLeft = math.max(self:GetTime() - FuryMonitor.Util.GetTime(), 0);
		local percent = 1 - timeLeft / FuryMonitor.Configuration.PowerBar.AnimationTime;
		local value = self:GetCurrentLevel() + difference * percent;

		if difference > 0 then
			value = math.min(value, self:GetTargetLevel());
		else
			value = math.max(value, self:GetTargetLevel());
		end

		self:SetCurrentLevel(value);
		self:GetStatusFrame():SetWidth(value * self:GetWidth());

		local c = self:GetCharacter();
		local modAp = math.floor(value * c:GetMaxAttackPower());
		self:SetText(
			modAp
			.. " / "
			.. c:GetMaxAttackPower()
			.. " ("
			.. FuryMonitor.Util.round(100 * modAp / c:GetMaxAttackPower(), 0)
			.. "%)"
		);	
			
	end
end

function FuryMonitor.PowerBar:OnConfigurationChanged()
	-- Clear cached values dependant on configuration values
	self._width = nil;

	self:LoadFrameConfiguration();
end

function FuryMonitor.PowerBar:LoadFrameConfiguration()
	-- Set up background frame
	self:GetBackgroundFrame():SetBackdrop({
		edgeFile = FuryMonitor.Configuration.PowerBar.EdgeFile,
		edgeSize = FuryMonitor.Configuration.PowerBar.EdgeSize,
		insets = {
			top = FuryMonitor.Configuration.PowerBar.BackgroundInset,
			bottom = FuryMonitor.Configuration.PowerBar.BackgroundInset,
			left = FuryMonitor.Configuration.PowerBar.BackgroundInset,
			right = FuryMonitor.Configuration.PowerBar.BackgroundInset
		}
	});
	self:GetBackgroundFrame():SetFrameStrata(FuryMonitor.Configuration.Display.FrameStrata);
	self:GetBackgroundFrame():SetFrameLevel(
		FuryMonitor.Configuration.Display.FrameLevel
	);	
	self:GetBackgroundFrame():SetWidth(
		FuryMonitor.Configuration.PowerBar.BackgroundInset
		+ self:GetWidth()
		+ FuryMonitor.Configuration.PowerBar.BackgroundInset
	);
	self:GetBackgroundFrame():SetHeight(FuryMonitor.Configuration.PowerBar.Height);
	self:GetBackgroundFrame():SetPoint("TOPLEFT");
	self:GetBackgroundFrame():SetAlpha(FuryMonitor.Configuration.PowerBar.Color.A);
	if FuryMonitor.Configuration.Enabled then
		self:GetBackgroundFrame():Show();
	else
		self:GetBackgroundFrame():Hide();
	end

	-- Set up status frame
	self:GetStatusFrame():SetFrameStrata(FuryMonitor.Configuration.Display.FrameStrata);
	self:GetStatusFrame():SetFrameLevel(
		FuryMonitor.Configuration.Display.FrameLevel
	);	
	self:GetStatusFrame():SetBackdrop({
		bgFile = FuryMonitor.Configuration.PowerBar.BackgroundFile,
		tile = 0
	});
	self:GetStatusFrame():SetHeight(
		- FuryMonitor.Configuration.PowerBar.BackgroundInset
		+ FuryMonitor.Configuration.PowerBar.Height
		- FuryMonitor.Configuration.PowerBar.BackgroundInset
	);	
	self:GetStatusFrame():SetPoint("TOPLEFT", self:GetBackgroundFrame(), "TOPLEFT",
		FuryMonitor.Configuration.PowerBar.BackgroundInset,
		- FuryMonitor.Configuration.PowerBar.BackgroundInset
	);	
	self:GetStatusFrame():SetBackdropColor(
		FuryMonitor.Configuration.PowerBar.Color.R,
		FuryMonitor.Configuration.PowerBar.Color.G,
		FuryMonitor.Configuration.PowerBar.Color.B,
		FuryMonitor.Configuration.PowerBar.Color.A
	);	
	if FuryMonitor.Configuration.Enabled then
		self:GetStatusFrame():Show();
	else
		self:GetStatusFrame():Hide();
	end

	-- Set up text
	self._text:SetFont(
		FuryMonitor.Configuration.PowerBar.FontFile,
		FuryMonitor.Configuration.PowerBar.FontSize,
		"OUTLINE"
	);
	self._text:SetTextColor(
		FuryMonitor.Configuration.PowerBar.FontColor.R,
		FuryMonitor.Configuration.PowerBar.FontColor.G,
		FuryMonitor.Configuration.PowerBar.FontColor.B,
		FuryMonitor.Configuration.PowerBar.FontColor.A
	);	
	self._text:SetPoint("CENTER", self:GetBackgroundFrame(), "CENTER");
	if FuryMonitor.Configuration.Enabled then
		self._text:Show();
	else
		self._text:Hide();
	end

	-- Force a redraw
	self:OnUpdate(true);
end

function FuryMonitor.PowerBar:OnStatsChanged()
	local c = self:GetCharacter();
	if c:GetAttackPower() ~= self:GetCurrentAttackPower() then
		self:SetCurrentLevel(
			self:GetCurrentAttackPower()
			/ c:GetMaxAttackPower()
		);
		self:SetTargetLevel(
			c:GetAttackPower()
			/ c:GetMaxAttackPower()
		);	
		self:SetTime(
			FuryMonitor.Util.GetTime()
			+ FuryMonitor.Configuration.PowerBar.AnimationTime
		);
		self:SetCurrentAttackPower(c:GetAttackPower());
	end
end

function FuryMonitor.PowerBar:GetWidth()
	if self._width == nil then
		self._width =
			FuryMonitor.Configuration.Tray.Padding
			- FuryMonitor.Configuration.PowerBar.BackgroundInset
			+ (FuryMonitor.Configuration.RotationDuration
			/ self:GetCharacter():GetGlobalCooldown())
			*
			(FuryMonitor.Configuration.Display.AbilitySpacing
			+ FuryMonitor.Configuration.AbilityFrame.Width)
			+ FuryMonitor.Configuration.Display.AbilitySpacing
			+ FuryMonitor.Configuration.Tray.Padding;
	end
	return self._width;
end

function FuryMonitor.PowerBar:GetCharacter()
	return self._character;
end

function FuryMonitor.PowerBar:GetTime()
	return self._time;
end

function FuryMonitor.PowerBar:SetTime(value)
	self._time = value;
end

function FuryMonitor.PowerBar:GetTargetLevel()
	return self._targetLevel;
end

function FuryMonitor.PowerBar:SetTargetLevel(value)
	self._targetLevel = value;
end

function FuryMonitor.PowerBar:GetCurrentLevel()
	return self._currentLevel;
end

function FuryMonitor.PowerBar:SetCurrentLevel(value)
	self._currentLevel = value;
end

function FuryMonitor.PowerBar:GetCurrentAttackPower()
	return self._currentAttackPower;
end

function FuryMonitor.PowerBar:SetCurrentAttackPower(value)
	self._currentAttackPower = value;
end

function FuryMonitor.PowerBar:GetBackgroundFrame()
	return self._backgroundFrame;
end

function FuryMonitor.PowerBar:SetBackgroundFrame(frame)
	self._backgroundFrame = frame;
end

function FuryMonitor.PowerBar:GetStatusFrame()
	return self._statusFrame;
end

function FuryMonitor.PowerBar:SetStatusFrame(frame)
	self._statusFrame = frame;
end

function FuryMonitor.PowerBar:GetParentFrame()
	return self._parent;
end

function FuryMonitor.PowerBar:SetText(text)
	self._text:SetText(text);
end
