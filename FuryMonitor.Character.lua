FuryMonitor.Character = {};
FuryMonitor.Character.__index = FuryMonitor.Character;
FuryMonitor.Character.PrecisionSpellIds = { [0.01] = 29590, [0.02] = 29591, [0.03] = 29592 };

function FuryMonitor.Character:new()
	local members = {
		_maxAttackPower = nil,
		_maxArmorPenetration = -1,
		_slowestMainHandSpeed = 1,
		_slowestOffHandSpeed = 1,
		_offHandWeaponDamage = 5000,
		_mainHandWeaponDamage = 5000,
		_talents = {}
	};
	return setmetatable(members, FuryMonitor.Character);
end

function FuryMonitor.Character:GetAttackPower()
	base, buff, debuff = UnitAttackPower("player");
	ap = base + buff + debuff;
	if ( self._maxAttackPower == nil or ap > self._maxAttackPower ) then
		self._maxAttackPower = ap;
	end
	return ap;
end

function FuryMonitor.Character:GetDamageModifier()
	local mh_low, mh_hi, oh_low, oh_hi, buff, debuff, pct
		= UnitDamage("player");
	
	return pct;
end

function FuryMonitor.Character:GetGlobalCooldown()
	return 1.5;
end

function FuryMonitor.Character:GetDamageBuff()
	local _, _, _, _, buff, debuff, _ = UnitDamage("player");
	return buff + debuff;
end

function FuryMonitor.Character:GetMainHandDamage()
	local mh_low, mh_hi, oh_low, oh_hi, buff, debuff, pct
		= UnitDamage("player");
	
	return ((mh_low + mh_hi) / 2 + buff + debuff) / pct;
end

function FuryMonitor.Character:GetMainHandWeaponDamage()
	local damage = self:GetMainHandDamage()
		- (self:GetAttackPower() * self:GetMainHandWeaponSpeed() / 14);
	self._mainHandWeaponDamage = math.min(
		self._mainHandWeaponDamage,
		self:GetMainHandDamage()
			- (self:GetAttackPower()
			* self:GetMainHandWeaponSpeed() / 14)
	);
	return self._mainHandWeaponDamage;
end

function FuryMonitor.Character:GetMainHandNormalizedSpeed()
	local weaponLink = GetInventoryItemLink("PLAYER", 16);
	if not weaponLink then
		return 2.4;
	end

	local _, _, _, _, _, _, weaponType = GetItemInfo(weaponLink);
	
	if FuryMonitor.Util.str_contains(weaponType, "Two-Handed") then
		return 3.3;
	end
	if FuryMonitor.Util.str_contains(weaponType, "One-handed") then
		return 2.4;
	end
	if FuryMonitor.Util.str_contains(weaponType, "Dagger") then
		return 1.8;
	end
	return 2.4;
end

function FuryMonitor.Character:GetOffHandDamage()
	local mh_low, mh_hi, oh_low, oh_hi, buff, debuff, pct
		= UnitDamage("player");

	if not oh_low then
		return 0;
	end	
	return ((oh_low + oh_hi) / 2 + buff + debuff) / pct;	
end

function FuryMonitor.Character:GetOffHandWeaponDamage()
	if self:GetOffHandDamage() == 0 then
		return 0;
	end
	self._offHandWeaponDamage = math.min(
		self._offHandWeaponDamage,
		self:GetOffHandDamage()
		- (self:GetAttackPower()
			* self:GetOffHandWeaponSpeed() / 14
			* 0.625)
	);
	return self._offHandWeaponDamage;
end

function FuryMonitor.Character:GetOffHandNormalizedSpeed()
	local weaponLink = GetInventoryItemLink("PLAYER", 17);
	if not weaponLink then
		return 2.4;
	end

	local _, _, _, _, _, _, weaponType = GetItemInfo(weaponLink);
	
	if FuryMonitor.Util.str_contains(weaponType, "Two-Handed") then
		return 3.3;
	end
	if FuryMonitor.Util.str_contains(weaponType, "One-Handed") then
		return 2.4;
	end
	if FuryMonitor.Util.str_contains(weaponType, "Dagger") then
		return 1.8;
	end
	return 2.4;
end

function FuryMonitor.Character:GetMaxAttackPower()
	-- Call GetAttackPower to refresh the maximum
	self:GetAttackPower();
	return self._maxAttackPower;
end

function FuryMonitor.Character:GetPowerLevel()
	return math.floor(100 * self:GetAttackPower() / self:GetMaxAttackPower());
end

function FuryMonitor.Character:OnEquipmentChanged()
	-- We may have changed weapons, so the cached speed values are no
	-- longer valid
	self._slowestMainHandSpeed = 1;
	self._slowestOffHandSpeed = 1;
	self._offHandWeaponDamage = 5000;
	self._mainHandWeaponDamage = 5000;
end

function FuryMonitor.Character:UpdateWeaponSpeeds()
	local mh, oh = UnitAttackSpeed("player");
	-- These values are affected by haste, so we need to re-adjust them
	local haste = (100 + GetCombatRatingBonus(CR_HASTE_MELEE))
					/ 100;
	if mh then
		mh = FuryMonitor.Util.round(mh * haste, 1);
		if mh > self._slowestMainHandSpeed then
			self._slowestMainHandSpeed = mh;
		end
	end
	if oh then
		oh = FuryMonitor.Util.round(oh * haste, 1);
		if oh > self._slowestOffHandSpeed then
			self._slowestOffHandSpeed = oh;
		end
	end
end

function FuryMonitor.Character:GetMainHandWeaponSpeed()
	self:UpdateWeaponSpeeds();
	return self._slowestMainHandSpeed;
end

function FuryMonitor.Character:GetOffHandWeaponSpeed()
	self:UpdateWeaponSpeeds();
	return self._slowestOffHandSpeed;
end

function FuryMonitor.Character:GetRage()
	return UnitMana("player");
end

function FuryMonitor.Character:GetHitChance()
	local bonusHitChance = GetCombatRatingBonus(CR_HIT_MELEE) / 100;
	local baseMiss = 0.09;
	if self:GetOffHandWeaponDamage() > 0 then
		baseMiss = baseMiss + 0.19;
	end
	return math.min(1, 1 - baseMiss + bonusHitChance);
end

function FuryMonitor.Character:GetTalent(name)
	if self._talents[name] == nil then
		self._talents[name] = FuryMonitor.Talent:new(name);
		FuryMonitor.Main:GetInstance():SubscribeToTalentChanges(self._talents[name]);
	end
	return self._talents[name];
end
