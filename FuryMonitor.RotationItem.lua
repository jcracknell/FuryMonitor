--[[
This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public Liscence, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtpl/COPYING for more details.
]]--

FuryMonitor.RotationItem = {};
FuryMonitor.RotationItem.__index = FuryMonitor.RotationItem;
FuryMonitor.RotationItem.Active = {};
FuryMonitor.RotationItem.Inactive = {};
FuryMonitor.RotationItem.Id = 0;

function FuryMonitor.RotationItem:new(ability, time, rageAvailable)
	local ri = nil;
	if #FuryMonitor.RotationItem.Inactive > 0 then
		-- Get the last instance on the Inactive list to serve as the instance
		ri = FuryMonitor.RotationItem.Inactive[#FuryMonitor.RotationItem.Inactive];
		table.remove(FuryMonitor.RotationItem.Inactive, #FuryMonitor.RotationItem.Inactive);
	else
		-- Create a new instance, as we have run out of existing ones
		local members = {
			_id = FuryMonitor.RotationItem.Id,
			_ability = nil,
			_useId = nil,
			_time = nil,
			_nextItem = nil,
			_rageAvailable = nil
		};
		FuryMonitor.RotationItem.Id = FuryMonitor.RotationItem.Id + 1;
		if FuryMonitor.RotationItem.Id > 10000 then
			FuryMonitor.RotationItem.Id = 0;
		end
		ri = setmetatable(members, FuryMonitor.RotationItem);
	end
	ri._ability = ability;
	ri._useId = ability:GetUseCount();
	ri._time = time;
	ri._rageAvailable = rageAvailable;
	ri._nextItem = nil;
	FuryMonitor.RotationItem.Active[ri:GetId()] = ri;
	return ri;
end

function FuryMonitor.RotationItem:recycle()
	-- Recycle children
	if self:GetNextItem() then
		self:GetNextItem():recycle();
	end
	-- Nuke the relationship to the next item...
	self:SetNextItem(nil);
	table.insert(FuryMonitor.RotationItem.Inactive, self);
	FuryMonitor.RotationItem.Active[self:GetId()] = nil;
end

function FuryMonitor.RotationItem:GetAbility()
	return self._ability;
end

function FuryMonitor.RotationItem:GetId()
	return self._id;
end

function FuryMonitor.RotationItem:GetTime()
	return self._time;
end

function FuryMonitor.RotationItem:SetTime(time)
	self._time = time;
end

function FuryMonitor.RotationItem:GetUseId()
	return self._useId;
end

function FuryMonitor.RotationItem:GetRageAvailable()
	return self._rageAvailable;
end

function FuryMonitor.RotationItem:Append(rotationItem)
	if self:GetNextItem() then
		self:GetNextItem():Append(rotationItem);
		return;
	end
	self:SetNextItem(rotationItem);
end

------------------------------------------
-- NEXT/PREVIOUS FUNCTIONS
------------------------------------------
function FuryMonitor.RotationItem:GetNextItem()
	return self._nextItem;
end

function FuryMonitor.RotationItem:SetNextItem(item)
	self._nextItem = item;
end

function FuryMonitor.RotationItem:GetNextAbility(ability)
	local nItem = self:GetNextItem();
	-- Base case (return this)
	if (not nItem ) or (nItem:GetAbility():GetSpellNumber() == ability:GetSpellNumber()) then
		return nItem;
	end
	-- Recursive case
	return nItem:GetNextAbility(ability);
end
