--[[
This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public Liscence, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtfpl/COPYING for more details.
]]--

FuryMonitor.Localization = {};

FuryMonitor.Localization.Locales = {
	enUS = {
		["Warrior"] =							"Warrior",
		["WarriorF"] =							"Warrior",
	
		-- Weapon types
		["Two-Handed"] =						"Two-Handed",
		["One-Handed"] =						"One-Handed",
		["Dagger"] =							"Dagger",
	
		-- Talents
		["Two-Handed Weapon Specialization"] =	"Two-Handed Weapon Specialization",
		["One-Handed Weapon Specialization"] =	"One-Handed Weapon Specialization",
		["Dual Wield Specialization"] =			"Dual Wield Specialization",
		["Hamstring"] =							"Hamstring",
		["Improved Whirlwind"] =				"Improved Whirwind",
		["Unending Fury"] =						"Unending Fury",
		["Improved Mortal Strike"] =			"Improved Mortal Strike",

		-- Buffs
		["Slam!"] =								"Slam!",
	
		-- Abilities
		["Slam"] =								"Slam",
		["Heroic Throw"] =						"Heroic Throw",
		["Devastate"] =							"Devastate",
		["Mortal Strike"] =						"Mortal Strike",
		["Victory Rush"] =						"Victory Rush",
		["Bloodthirst"] =						"Bloodthirst",
		["Whirlwind"] =							"Whirlwind"
	},
	deDE = {
		["Warrior"] =							"Krieger", 
		["WarriorF"] =							"Kriegerin",
	
		-- Weapon types
		["Two-Handed"] =						"Zweihand",
		["One-Handed"] =						"Einhand",
		["Dagger"] =							"Dolch",
		
		-- Talents
		["Two-Handed Weapon Specialization"] =	"Zweihandwaffen-Spezialisierung",
		["One-Handed Weapon Specialization"] =	"Einhandwaffen-Spezialisierung",
		["Dual Wield Specialization"] =			"Beidh\195\164ndigkeits-Spezialisierung",
		["Hamstring"] =							"Kniesehne",
		["Improved Whirlwind"] =				"Verbesserter Wirbelwind",
		["Unending Fury"] =						"Unendlicher Furor",
		["Improved Mortal Strike"] =			"Verbesserter t\195\182dlicher Sto\195\159",
	
		-- Buffs
		["Slam!"] =					       		"Zerschmettern!",
	
		-- Abilities
		["Slam"] =								"Zerschmettern",
		["Heroic Throw"] =						"Heldenhafter Wurf",
		["Devastate"] =							"Verw\195\188sten",
		["Mortal Strike"] =						"T\195\182dlicher Sto\195\159",
		["Victory Rush"] =						"Siegesrausch",
		["Bloodthirst"] =						"Blutdurst",
		["Whirlwind"] =							"Wirbelwind"
	},
	ruRU = {
		["Warrior"] =							"Воин",
		["WarriorF"] =							"Воин",
	
		-- Weapon types
		["Two-Handed"] =						"Двуручное",
		["One-Handed"] =						"Одноручное",
		["Dagger"] =							"Кинжалы",
	
		-- Talents
		["Two-Handed Weapon Specialization"] =	"Специализация на двуручном оружии",
		["One-Handed Weapon Specialization"] =	"Специализация на одноручном оружии",
		["Dual Wield Specialization"] =			"Специализация на бое двумя оружиями",
		["Hamstring"] =							"Подрезать сухожилия",
		["Improved Whirlwind"] =				"Улучшенный вихрь",
		["Unending Fury"] =						"Бесконечное неистовство",
		["Improved Mortal Strike"] =			"Улучшенный смертельный удар",

		-- Buffs
		["Slam!"] =								"Сокрушить!",
	
		-- Abilities
		["Slam"] =								"Мощный удар",
		["Heroic Throw"] =						"Героический бросок",
		["Devastate"] =							"Сокрушение",
		["Mortal Strike"] =						"Смертельный удар",
		["Victory Rush"] =						"Победный раж",
		["Bloodthirst"] =						"Кровожадность",
		["Whirlwind"] =							"Вихрь"
	}
};

FuryMonitor.Localization.Locale = nil;

function FuryMonitor.Localization.Localize(string)
	while true do
		-- Cache the localization table so we only have to look it up once
		if not FuryMonitor.Localization.Locale then
			local loc = GetLocale();
			if FuryMonitor.Localization.Locales[loc] then
				FuryMonitor.Localization.Locale
					= FuryMonitor.Localization.Locales[loc];
			else
				FuryMonitor.Main:GetInstance():PrintMessage(
					'Locale ' .. loc .. ' has not been localized yet.'
				);
				break;
			end
		end
	
		if not FuryMonitor.Localization.Locale[string] then
			FuryMonitor.Main:GetInstance():PrintMessage(
				'Localization of string "' .. string .. '" failed.'
			);
			break;
		end

		-- Return localized string
		return FuryMonitor.Localization.Locale[string];
	end
	-- Return empty string on failure
	return '';
end
