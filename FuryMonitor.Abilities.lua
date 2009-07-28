--[[
This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public Liscence, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtpl/COPYING for more details.
]]--

function FuryMonitor.Abilities(character)
	return {	

		FuryMonitor.Ability:new({ name = "Whirlwind",
			cooldown = 10,
			character = character,
			damageFunction = function(character)

					local mh_damage = character:GetMainHandWeaponDamage()
						+ character:GetAttackPower() * character:GetMainHandNormalizedSpeed() / 14
						+ character:GetDamageBuff();

					local oh_damage = character:GetOffHandWeaponDamage()
						+ character:GetAttackPower() * character:GetOffHandNormalizedSpeed() / 14
						+ character:GetDamageBuff();
					oh_damage = oh_damage
						* 0.5
						* (1 + 0.05 * character:GetTalent("Dual Wield Specialization"):GetRank());

					local damage = (mh_damage + oh_damage)
						* (1 + 0.02 * character:GetTalent("Two-Handed Weapon Specialization"):GetRank())
						* (1 + 0.1 * character:GetTalent("Improved Whirlwind"):GetRank())
						* (1 + 0.02 * character:GetTalent("Unending Fury"):GetRank())
						;

					return math.floor(damage);
				end,
			fake = false,
			reactive = false
		}),

		FuryMonitor.Ability:new({ name = "Bloodthirst",
			cooldown = 5,
			character = character,
			damageFunction = function(character)
					local damage = character:GetAttackPower() * 0.5
						+ character:GetDamageBuff()
						;
					
					damage = damage
						* (1 + 0.02 * character:GetTalent("Unending Fury"):GetRank())
						* (1 + 0.02 * character:GetTalent("Two-Handed Weapon Specialization"):GetRank())
						;
	
					return math.floor(damage);
				end,
			fake = false,
			reactive = false
		}),

		FuryMonitor.Ability:new({ name = "Empty",
			cooldown = 1.5,
			character = character,
			damageFunction = function(character) return 0; end,
			fake = true, -- THIS IS THE "GCD" ability
			reactive = false
		}),

		FuryMonitor.Ability:new({ name = "Victory Rush",
			cooldown = 1.5,
			character = character,
			damageFunction = function(character)
					local damage = character:GetAttackPower() * 0.45
						+ character:GetDamageBuff();

					return math.floor(damage);	
				end,
			fake = false,
			reactive = true, reactiveUses = 1, reactionDuration = 20
		}),

		FuryMonitor.Ability:new({ name = "Mortal Strike",
			cooldown = 6,
			character = character,
			damageFunction = function(character)
					local damage = character:GetMainHandWeaponDamage()
						+ character:GetAttackPower() * character:GetMainHandNormalizedSpeed() / 14
						+ 380
						+ character:GetDamageBuff()
						;
					
					damage = damage
						* (1 + 0.02 * character:GetTalent("Two-Handed Weapon Specialization"):GetRank())
						* (1 + 0.03 * character:GetTalent("Improved Mortal Strike"):GetRank())
						;

					return math.floor(damage);
				end,
			fake = false
		}),

		FuryMonitor.Ability:new({ name = "Devastate",
			cooldown = 1.5,
			character = character,
			damageFunction = function(character)
					local damage = (
						character:GetMainHandWeaponDamage()
						+ character:GetAttackPower() + character:GetMainHandNormalizedSpeed() / 14
						+ character:GetDamageBuff()
						+ 24 * 5
					) * 0.5;

					damage = damage
						* (1 + 0.02 * character:GetTalent("One-Handed Weapon Specialization"):GetRank())
						;
					
					return math.floor(damage);
				end,
			fake = false
		}),

		FuryMonitor.Ability:new({ name = "Heroic Throw",
			cooldown = 60,
			character = character,
			damageFunction = function(character)
					local damage = character:GetAttackPower() * 0.5
						+ character:GetDamageBuff();

					damage = damage
						* (1 + 0.02 * character:GetTalent("Two-Handed Weapon Specialization"):GetRank())
						;

					return math.floor(damage);	
				end,
			fake = false
		}),

		FuryMonitor.Ability:new({ name = "Slam",
			cooldown = 1.5,
			character = character,
			damageFunction = function(character)
					local damage = character:GetMainHandWeaponDamage()
						+ character:GetAttackPower() * character:GetMainHandWeaponSpeed() / 14
						+ 250
						+ character:GetDamageBuff();
	
					damage = damage
						* (1 + 0.02 * character:GetTalent("Two-Handed Weapon Specialization"):GetRank())
						* (1 + 0.02 * character:GetTalent("Unending Fury"):GetRank())
						;
	
					return math.floor(damage);
				end,
			fake = false,
			reactive = true, reactiveUses = 1, reactionDuration = 5,
			functions = {
				-- Slam should only be shown as available if the "Slam!" buff is active.
				IsAvailable = function(character)
						local buffName;
						for buffSlot = 1, 16 do
							buffName = UnitBuff("PLAYER", buffSlot);
							if buffName == "Slam!" then
								return true;
							end
						end
						return false;
					end
			}
		})

	};	
end
