--[[
This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public Liscence, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.
]]--

FuryMonitor.RageDumpFrame = {};
FuryMonitor.RageDumpFrame.__index = FuryMonitor.RageDumpFrame;

function FuryMonitor.RageDumpFrame:new(ability, parentFrame)
	local members = {
		_ability = ability,
		_iconFrame = CreateFrame("Frame"),
		_parentFrame = parentFrame,
		_status = false
	};
	local instance = setmetatable(members, FuryMonitor.RageDumpFrame);

	FuryMonitor.Main:GetInstance():SubscribeToConfigurationChanges(
		"RageDumpFrame", instance
	);

	return instance;
end

function FuryMonitor.RageDumpFrame:LoadFrameConfiguration()
	self:GetIconFrame():SetWidth(
		FuryMonitor.Configuration.RageDumpFrame.Width
	);
	self:GetIconFrame():SetHeight(
		FuryMonitor.Configuration.RageDumpFrame.Height
	);
	self:GetIconFrame():SetBackdrop({
		bgFile = self:GetAbility():GetTexture(),
		edgeFile = FuryMonitor.Configuration.RageDumpFrame.EdgeFile,
		edgeSize = FuryMonitor.Configuration.RageDumpFrame.EdgeSize,
		tile = 0,
		tileSize = math.max(
			FuryMonitor.Configuration.RageDumpFrame.Width,
			FuryMonitor.Configuration.RageDumpFrame.Height
		),
		insets = {
			top = FuryMonitor.Configuration.RageDumpFrame.BackgroundInset,
			bottom = FuryMonitor.Configuration.RageDumpFrame.BackgroundInset,
			left = FuryMonitor.Configuration.RageDumpFrame.BackgroundInset,
			right = FuryMonitor.Configuration.RageDumpFrame.BackgroundInset,
		}
	});
	self:GetIconFrame():SetPoint("BOTTOMRIGHT", self:GetParentFrame(), "BOTTOMLEFT",
		- FuryMonitor.Configuration.Display.Padding,
		- FuryMonitor.Configuration.RageDumpFrame.VerticalOffset
	);
	self:GetIconFrame():SetAlpha(
		FuryMonitor.Configuration.RageDumpFrame.Alpha
		* FuryMonitor.Configuration.Display.Alpha
	);
	self:UpdateStatus();
	if FuryMonitor.Configuration.RageDumpFrame.Show
		and FuryMonitor.Configuration.Enabled then
		self:GetIconFrame():Show();
	else
		self:GetIconFrame():Hide();
	end
end

function FuryMonitor.RageDumpFrame:GetStatus()
	return self._status;
end

function FuryMonitor.RageDumpFrame:SetStatus(time)
	self._status = time >= FuryMonitor.Configuration.RageDumpFrame.RotationTime;
	self:UpdateStatus();
end

function FuryMonitor.RageDumpFrame:UpdateStatus()
	if self:GetStatus() then
		self:GetIconFrame():SetBackdropColor(1, 1, 1);
	else
		self:GetIconFrame():SetBackdropColor(0, 0, 0);
	end
end

function FuryMonitor.RageDumpFrame:OnConfigurationChanged()
	self:LoadFrameConfiguration();
end

function FuryMonitor.RageDumpFrame:GetAbility()
	return self._ability;
end

function FuryMonitor.RageDumpFrame:GetIconFrame()
	return self._iconFrame;
end

function FuryMonitor.RageDumpFrame:GetParentFrame()
	return self._parentFrame;
end
