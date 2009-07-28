--[[
This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public Liscence, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.
]]--

FuryMonitor.Ability = {};
FuryMonitor.Ability.__index = FuryMonitor.Ability;
FuryMonitor.Ability.TheorizeUse = false;
FuryMonitor.Ability.Instances = {};

function FuryMonitor.Ability:new(params)
	if FuryMonitor.Ability.Instances[params.name] then
		return FuryMonitor.Ability.Instances[params.name];
	end
	local members = {
		_name = params.name,
		_character = params.character,
		_damageFunction = params.damageFunction,
		_cooldown = params.cooldown,
		_castTime = params.castTime or 0,
		_fake = params.fake or false,
		_reactive = params.reactive or false,
		_reactionDuration = params.reactionDuration or 1.5,
		_reactiveUses = params.reactiveUses or 1,
		_cooldownFixed = false,
		_cooldownTime = 0,
		_spellNumber = nil,
		_useCount = 0,
		_theoreticalUses = 0,
		_lastUsed = -1,
		_available = false,
		_availableTime = 0,
		_functions = {
			IsAvailable = nil
		}
	};
	if params.functions then
		members._functions.IsAvailable = params.functions.IsAvailable;
	end
	local instance = setmetatable(members, FuryMonitor.Ability);
	if instance:IsFake() then
		-- This MUST be an ability that:
		-- a) Is instant
		-- b) Has no cooldown
		-- c) Is on the global cooldown
		instance._name = FuryMonitor.Localization.Localize("Hamstring");
		instance._cooldown = instance:GetCharacter():GetGlobalCooldown();
	end
	FuryMonitor.Ability.Instances[instance:GetName()] = instance;

	return instance;
end

function FuryMonitor.Ability.EnableTheoreticalUse()
	for k, i in pairs(FuryMonitor.Ability.Instances) do
		i:SetTheoreticalUses(0);
	end
	FuryMonitor.Ability.TheorizeUse = true;
end

function FuryMonitor.Ability.DisableTheoreticalUse()
	FuryMonitor.Ability.TheorizeUse = false;
	for k, i in pairs(FuryMonitor.Ability.Instances) do
		i:SetUseCount(i:GetUseCount() - i:GetTheoreticalUses());
	end
end

function FuryMonitor.Ability:IsFake()
	return self._fake;
end

function FuryMonitor.Ability:IsReactive()
	return self._reactive;
end

function FuryMonitor.Ability:GetName()
	return self._name;
end

function FuryMonitor.Ability:GetCharacter()
	return self._character;
end

function FuryMonitor.Ability:GetCastTime()
	return self._castTime;
end

function FuryMonitor.Ability:GetCooldownDuration()
	if not self:Exists() then
		return 0;
	end
	if self:IsReactive() then
		-- This is an ugly hack to prevent the rotation build from listing
		-- reactive abilities beyond their use count
		if self:GetReactiveUsesRemaining() <= 0 then
			return 1000;
		end
	end
	if self:IsFake() then
		return self:GetGlobalCooldown();
	end	
	if not self._cooldownFixed then
		local startTime, duration, e = GetSpellCooldown(self:GetSpellNumber(), BOOKTYPE_SPELL);
		if duration > self:GetGlobalCooldown() then
			self._cooldownFixed = true;
			if duration ~= self._cooldown then
				self._cooldown = duration;
			end
		end
	end
	return self._cooldown;
end

function FuryMonitor.Ability:GetCooldownRemaining()
	if not self:Exists() then
		return 0;
	end
	if not self:IsAvailable() then
		return self._cooldown;
	end
	local startTime, duration, e = GetSpellCooldown(self:GetSpellNumber(), BOOKTYPE_SPELL);

	local cooldown = 0;
	if startTime ~= 0 then
		if duration == self:GetGlobalCooldown() then
			-- If this ability caused the GCD, then return the real cooldown of the ability
			if self:GetLastUsedTime() >= startTime and self:GetLastUsedTime() < startTime + self:GetGlobalCooldown() then
				cooldown = math.max(self:GetCooldownDuration() - (FuryMonitor.Util.GetTime() - startTime), 0);
			else
				cooldown = duration - (FuryMonitor.Util.GetTime() - startTime);
			end
		else
			cooldown = duration - (FuryMonitor.Util.GetTime() - startTime);
		end
	end
	return cooldown;
end

function FuryMonitor.Ability:GetDamage()
	if self:IsFake() then
		return 0;
	end
	return math.floor(self._damageFunction(self:GetCharacter())
		* self:GetCharacter():GetDamageModifier());
end

function FuryMonitor.Ability:GetGlobalCooldown()
	return self:GetCharacter():GetGlobalCooldown();
end

function FuryMonitor.Ability:GetValue()
	return self:GetDamage() / self:GetCooldownDuration();
end

function FuryMonitor.Ability:GetSpellNumber()
	if ( not self._spellNumber ) then
		local foundNum = nil;
		local num = 1;
		while true do
			local name, _ = GetSpellName(num, BOOKTYPE_SPELL);
			if not name then do break end end

			if name == self:GetName() then
				foundNum = num;
			end	
	
			num = num + 1
		end
		if not foundNum then
			return nil;
		end	

		self._spellNumber = foundNum;
	end
	
	return self._spellNumber;
end

function FuryMonitor.Ability:GetTexture()
	if self:IsFake() or not self:Exists() then
		return "Interface\\DialogFrame\\UI-DialogBox-Background";
	end
	return GetSpellTexture(self:GetSpellNumber(), BOOKTYPE_SPELL);
end

function FuryMonitor.Ability:Used()
	self:SetUseCount(self:GetUseCount() + 1);
	if FuryMonitor.Ability.TheorizeUse then
		self:SetTheoreticalUses(self:GetTheoreticalUses() + 1);
	else
		self:SetLastUsedTime(FuryMonitor.Util.GetTime());
	end
end

function FuryMonitor.Ability:GetUseCount()
	return self._useCount;
end

function FuryMonitor.Ability:SetUseCount(value)
	self._useCount = value;
end	

function FuryMonitor.Ability:GetLastUsedTime()
	return self._lastUsed;
end

function FuryMonitor.Ability:SetLastUsedTime(time)
	self._lastUsed = time;
end

function FuryMonitor.Ability:GetRageCost()
	if self:IsFake() then
		return 0;
	end
	_, _, _, cost = GetSpellInfo(self:GetName());
	return cost;
end

function FuryMonitor.Ability:IsAvailable()
	if self:IsFake() then
		-- This is important, otherwise when dead you get an empty rotation
		return true;
	end
	if not self:Exists() then
		return false;
	end
	local usable, nomana = IsUsableSpell(self:GetName());
	while usable or nomana do
		-- If there is a defined IsAvailable function, call it and check the result
		if self._functions.IsAvailable and not self._functions.IsAvailable(self) then
			break;
		end
		if not self._available then
			self._available = true;
			self:SetAvailableTime(FuryMonitor.Util.GetTime());
		end
		return true;
	end

	self._available = false;
	return false;
end

function FuryMonitor.Ability:Exists()
	-- GetSpellNumber returns nil if the spell number is not found
	return self:GetSpellNumber() ~= nil;
end

function FuryMonitor.Ability:GetAvailableUntil()
	return self:GetAvailableTime() + self:GetReactionDuration();
end

function FuryMonitor.Ability:GetAvailableTime()
	return self._availableTime;
end	

function FuryMonitor.Ability:SetAvailableTime(time)
	self._availableTime = time;
end	

function FuryMonitor.Ability:GetReactionDuration()
	return self._reactionDuration;
end	

function FuryMonitor.Ability:GetReactionDurationRemaining()
	return math.max(0, self:GetAvailableUntil() - FuryMonitor.Util.GetTime());
end	

function FuryMonitor.Ability:GetReactiveUsesRemaining()
	return math.max(0, self:GetReactiveUses() - self:GetTheoreticalUses());
end 

function FuryMonitor.Ability:GetReactiveUses()
	return self._reactiveUses;
end

function FuryMonitor.Ability:GetTheoreticalUses()
	return self._theoreticalUses;
end

function FuryMonitor.Ability:SetTheoreticalUses(value)
	self._theoreticalUses = value;
end

function FuryMonitor.Ability:OnTalentsChanged()
	-- Clear the cached spell number, as the spell numbers change during
	-- talent changes
	self._spellNumber = nil;
end
