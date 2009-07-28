--[[
This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public Liscence, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtpl/COPYING for more details.
]]--

FuryMonitor.Commands = {};

-----------------------------------------
-- BEGIN SLASH COMMAND HANDLING
-----------------------------------------
function FuryMonitor.Commands.SlashCommandHandler(cmd)
	local fm = FuryMonitor.Main:GetInstance();
	local goodText = "";
	local s, e = 0, 0;
	local current = FuryMonitor.Commands.SlashCommandStructure;
	while true do
		s, e = string.find(cmd, "[%a%d]+", e + 1);
		if s then
			local word = string.sub(cmd, s, e);
			if current[word] then
				local parent = current;
				current = current[word];
				if current._f then
					-- Collect arguments
					local args = {};
					while true do
						s, e = string.find(cmd, "[%a%d.\\/-]+", e + 1);
						if not s then
							do break end;
						end
						args[#args + 1] = string.sub(cmd, s, e);
					end
					FuryMonitor.Commands.SlashCommandHandler_CallFunction(goodText, parent, current._f, args);
					return;
				else
					goodText = goodText .. " " .. word;
				end
			else
				FuryMonitor.Main:GetInstance():PrintMessage(
					"The command you specified could not be found."
				);	
				do break end;
			end
		else
			FuryMonitor.Commands.SlashCommandHandler_ShowUsage(goodText, current);
			do break end;
		end
	end
end

	function FuryMonitor.Commands.SlashCommandHandler_CallFunction(goodText, current, func, args)
		local result = false;
		while true do
			if #args == 0 then
				result = func();
				do break end;
			elseif #args == 1 then
				result = func(args[1]);
				do break end;
			elseif #args == 2 then
				result = func(args[1], args[2]);
				do break end;
			elseif #args == 3 then
				result = func(args[1], args[2], args[3]);
				do break end;
			elseif #args == 4 then
				result = func(args[1], args[2], args[3], args[4]);
				do break end;
			end	
			-- Add additional cases here to support more arguments
		end
		if not result then
			FuryMonitor.Main:GetInstance():PrintMessage(
				"|cB3FF3333Command execution failed. Did you specify the correct parameters?"
			);
		else
			-- Propagate configuration changes
			FuryMonitor.Main:GetInstance():PrintMessage(
				"|cB333FF33Command succeded."
			);
			FuryMonitor.Main:GetInstance():OnConfigurationChanged();
		end
	end
	function FuryMonitor.Commands.SlashCommandHandler_ShowUsage(goodText, current, dontAddText)
		FuryMonitor.Main:GetInstance():PrintMessage("FuryMonitor: Usage");
		for k, v in pairs(current) do
			if string.sub(k, 1, 1) ~= "_" then
				local t = goodText;
				if not dontAddText then
					t = t .. " " .. k;
				end
				if v._a then -- Print args
					-- Highlight type specifications
					local args = string.gsub(v._a, "(:[^%s]+)", "|cB37799FF%1|cB333FF33");
					t = t .. "|cB333FF33 " .. args;
				end
				if v._d then -- Print description
					t = t .. "|cB3FFFF66 - " .. v._d;
				end	
				FuryMonitor.Main:GetInstance():PrintMessage(t);
			end
		end
	end

-----------------------------------------
-- END SLASH COMMAND HANDLING
-----------------------------------------

function FuryMonitor.Commands.debug_ability_show()
	local fm = FuryMonitor.Main:GetInstance();
	fm:PrintMessage("Registered Abilities:");
	for k, ability in pairs(fm:GetAbilities()) do
		fm:PrintMessage(ability:GetName());
	end
end

function FuryMonitor.Commands.debug_rotationitem_active()
	local fm = FuryMonitor.Main:GetInstance();
	fm:PrintMessage("FuryMonitor.RotationItem.Active:");
	for k, v in pairs(FuryMonitor.RotationItem.Active) do
		fm:PrintMessage(
			"[" .. k .. "] " .. v:GetAbility():GetName() .. v:GetUseId() .. ":" .. v:GetTime()
		);	
	end
	return true;
end

function FuryMonitor.Commands.debug_rotationitem_inactive()
	local fm = FuryMonitor.Main:GetInstance();
	fm:PrintMessage("");
	fm:PrintMessage("FuryMonitor.RotationItem.Inactive:");
	for k, v in pairs(FuryMonitor.RotationItem.Inactive) do
		fm:PrintMessage(
			"[" .. k .. "] " .. v:GetAbility():GetName() .. v:GetUseId() .. ":" .. v:GetTime()
		);	
	end
	return true;
end

function FuryMonitor.Commands.debug_rotation()
	local fm = FuryMonitor.Main:GetInstance();
	fm:PrintMessage("");
	fm:PrintMessage("Currently proposed rotation:");
	local rs = fm:BuildRotation();
	local r = rs;
	while r do
		fm:PrintMessage(r:GetAbility():GetName()
		.. " (+"
		.. FuryMonitor.Util.round(r:GetTime() - FuryMonitor.Util.GetTime(), 2) 
		.. "s)");
		r = r:GetNextItem();
	end
	rs:recycle();
	return true;
end

function FuryMonitor.Commands.debug_abilityframe_active()
	local fm = FuryMonitor.Main:GetInstance();
	fm:PrintMessage("");
	fm:PrintMessage("FuryMonitor.AbilityFrame.Active");
	for k, v in pairs(FuryMonitor.AbilityFrame.Active) do
		fm:PrintMessage(k .. ":");
		for j, af in pairs(v) do
			fm:PrintMessage("k:" .. j .. " " .. af:GetAbility():GetName() .. af:GetUseId());
		end
	end
	return true;
end

function FuryMonitor.Commands.debug_abilityframe_inactive()
	local fm = FuryMonitor.Main:GetInstance();
	fm:PrintMessage("");
	fm:PrintMessage("FuryMonitor.AbilityFrame.Inactive");
	for i, af in pairs(FuryMonitor.AbilityFrame.Inactive) do
		fm:PrintMessage("k:" .. i .. " " .. af:GetAbility():GetName() .. af:GetUseId());
	end
	return true;
end

function FuryMonitor.Commands.debug_character_hit()
	local fm = FuryMonitor.Main:GetInstance();
	fm:PrintMessage("");
	fm:PrintMessage(fm:GetCharacter():GetHitChance());
	return true;
end

function FuryMonitor.Commands.debug_character_normalizedweaponspeed()
	local fm = FuryMonitor.Main:GetInstance();
	local character = fm:GetCharacter();
	fm:PrintMessage("");
	fm:PrintMessage(
		"MH: " .. character:GetMainHandNormalizedSpeed() .. " " ..
		"OH: " .. character:GetOffHandNormalizedSpeed()
	);
	return true;
end

function FuryMonitor.Commands.debug_character_weapondamage()
	local fm = FuryMonitor.Main:GetInstance();
	local character = fm:GetCharacter();
	fm:PrintMessage("");
	fm:PrintMessage(
		"MH: " .. character:GetMainHandWeaponDamage() .. " " ..
		"OH: " .. character:GetOffHandWeaponDamage()
	);
	return true;
end

function FuryMonitor.Commands.debug_character_weaponspeed()
	local fm = FuryMonitor.Main:GetInstance();
	local character = fm:GetCharacter();
	fm:PrintMessage("");
	fm:PrintMessage(
		"MH: " .. character:GetMainHandWeaponSpeed() .. " " ..
		"OH: " .. character:GetOffHandWeaponSpeed()
	);
	return true;
end

function FuryMonitor.Commands.debug_character_talents()
	local fm = FuryMonitor.Main:GetInstance();
	local character = fm:GetCharacter();

	fm:PrintMessage("Currently loaded talents:");
	for name, talent in pairs(character._talents) do
		fm:PrintMessage(name .. " (Rank " .. talent:GetRank() .. ")");
	end
	return true;
end

function FuryMonitor.Commands.debug_permutationcache()
	local fm = FuryMonitor.Main:GetInstance();
	fm:PrintMessage("");
	fm:PrintMessage("Permutation cache:");
	for abilityHash, permutations in pairs(fm._permutations) do
		fm:PrintMessage("Hash: " .. abilityHash);
		for k, permutation in pairs(permutations) do
			local list = "";
			for j, ability in pairs(permutation) do
				list = list .. ability:GetName() .. ", ";
			end
			fm:PrintMessage(list);
		end
	end
	return true;
end

function FuryMonitor.Commands.debug_subscriptions()
	local fm = FuryMonitor.Main:GetInstance();
	fm:PrintMessage("");
	fm:PrintMessage("Subscriptions:");
	for name, subscribers in pairs(fm._subscribers) do
		-- I have NO idea why #subscribers doesn't work here
		local count = 0;
		for _, _ in pairs(subscribers) do count = count + 1; end
		fm:PrintMessage(name .. ": " .. count);
	end
	return true;
end

function FuryMonitor.Commands.set_Display_AbilitySpacing(spacing)
	local v = false;
	v, spacing = FuryMonitor.Validation.ValidateDimension(spacing);
	if not v then return false; end

	FuryMonitor.Configuration.Display.AbilitySpacing = spacing;
	return true;
end

function FuryMonitor.Commands.set_Display_CombatAlpha(alpha)
	local v = false;
	v, alpha = FuryMonitor.Validation.ValidateAlpha(alpha);
	if not v then return false; end

	FuryMonitor.Configuration.Display.CombatAlpha = alpha;
	return true;
end

function FuryMonitor.Commands.set_Display_IdleAlpha(alpha)
	local v = false;
	v, alpha = FuryMonitor.Validation.ValidateAlpha(alpha);
	if not v then return false; end

	FuryMonitor.Configuration.Display.IdleAlpha = alpha;
	return true;
end

function FuryMonitor.Commands.set_Display_AlphaFadeDuration(duration)
	local v = false;
	v, duration = FuryMonitor.Validation.ValidateDuration(duration);
	if not v then return false; end

	FuryMonitor.Configuration.Display.AlphaFadeDuration = duration;
	return true;
end

function FuryMonitor.Commands.set_Display_Padding(padding)
	local v = false;
	v, padding = FuryMonitor.Validation.ValidateDimension(padding);
	if not v then return false; end

	FuryMonitor.Configuration.Display.Padding = padding;
	return true;
end

function FuryMonitor.Commands.set_Display_Position(x, y)
	local v = false;
	v, x = FuryMonitor.Validation.ValidateDimension(x);
	if not v then return false; end
	v, y = FuryMonitor.Validation.ValidateDimension(y);
	if not v then return false; end

	FuryMonitor.Configuration.Display.Position.X = x;
	FuryMonitor.Configuration.Display.Position.Y = y;
	return true;
end

function FuryMonitor.Commands.set_Display_FrameStrata(strata)
	if not strata then
		return false;
	end

	-- Check that the provided value is a valid frame strata
	local validStrata = {
		"PARENT", "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG",
		"FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP"
	};
	local found = false;
	local strataString = ""; 	-- Build a list of the strata for error messages
	for i = 1, #validStrata do	-- as we go
		if validStrata[i] == strata then
			strataString = strataString .. " " .. validStrata[i];
			found = true;
		end
	end
	if not found then
		FuryMonitor.Main:GetInstance():PrintMessage(
			strata .. " is not a valid frame strata, must be one of:"
			.. strataString .. "."
		);
		return false;
	end

	FuryMonitor.Configuration.Display.FrameStrata = strata;
	return true;
end	

function FuryMonitor.Commands.set_AbilityFrame_Alpha(alpha)
	local v = false;
	v, alpha = FuryMonitor.Validation.ValidateAlpha(alpha);
	if not v then return false; end

	FuryMonitor.Configuration.AbilityFrame.Alpha = alpha;
	return true;
end

function FuryMonitor.Commands.set_AbilityFrame_Size(size)
	local v = false;
	v, size = FuryMonitor.Validation.ValidateDimension(size);
	if not v then return false; end

	FuryMonitor.Configuration.AbilityFrame.Width = size;
	FuryMonitor.Configuration.AbilityFrame.Height = size;
	return true;
end

function FuryMonitor.Commands.set_AbilityFrame_FontSize(fontSize)
	local v = false;
	v, fontSize = FuryMonitor.Validation.ValidateFontSize(fontSize);
	if not v then return false; end

	FuryMonitor.Configuration.AbilityFrame.FontSize = fontSize;
	return true;
end

function FuryMonitor.Commands.set_AbilityFrame_FontColor(r, g, b, a)
	local v = false;
	v, r, g, b, a = FuryMonitor.Validation.ValidateColor(r, g, b, a);
	if not v then return false; end

	FuryMonitor.Configuration.AbilityFrame.FontColor.R = r;
	FuryMonitor.Configuration.AbilityFrame.FontColor.G = g;
	FuryMonitor.Configuration.AbilityFrame.FontColor.B = b;
	FuryMonitor.Configuration.AbilityFrame.FontColor.A = a;
	return true;
end

function FuryMonitor.Commands.set_PowerBar_AnimationTime(time)
	local v = false;
	v, time = FuryMonitor.Validation.ValidateDuration(time);
	if not v then return false; end

	FuryMonitor.Configuration.PowerBar.AnimationTime = time;
	return true;
end

function FuryMonitor.Commands.set_PowerBar_BackgroundFile(backgroundFile)
	if not backgroundFile then
		return false;
	end
	FuryMonitor.Configuration.PowerBar.BackgroundFile = backgroundFile;
	return true;
end

function FuryMonitor.Commands.set_PowerBar_Color(r, g, b, a)
	local v = false;
	v, r, g, b, a = FuryMonitor.Validation.ValidateColor(r, g, b, a);
	if not v then return false; end

	FuryMonitor.Configuration.PowerBar.Color.R = r;
	FuryMonitor.Configuration.PowerBar.Color.G = g;
	FuryMonitor.Configuration.PowerBar.Color.B = b;
	FuryMonitor.Configuration.PowerBar.Color.A = a;
	return true;
end

function FuryMonitor.Commands.set_PowerBar_FontColor(r, g, b, a)
	local v = false;
	v, r, g, b, a = FuryMonitor.Validation.ValidateColor(r, g, b, a);
	if not v then return false; end

	FuryMonitor.Configuration.PowerBar.FontColor.R = r;
	FuryMonitor.Configuration.PowerBar.FontColor.G = g;
	FuryMonitor.Configuration.PowerBar.FontColor.B = b;
	FuryMonitor.Configuration.PowerBar.FontColor.A = a;
	return true;
end

function FuryMonitor.Commands.set_PowerBar_FontSize(fontSize)
	local v = false;
	v, fontSize = FuryMonitor.Validation.ValidateFontSize(fontSize);
	if not v then return false; end

	FuryMonitor.Configuration.PowerBar.FontSize = fontSize;
	return true;
end

function FuryMonitor.Commands.set_PowerBar_Height(height)
	local v = false;
	v, height = FuryMonitor.Validation.ValidateDimension(height);
	if not v then return false; end

	FuryMonitor.Configuration.PowerBar.Height = height;
	return true;
end

function FuryMonitor.Commands.set_AbilityFrame_RageIndicator_Height(height)
	local v = false;
	v, height = FuryMonitor.Validation.ValidateDimension(height);
	if not v then return false; end

	FuryMonitor.Configuration.AbilityFrame.RageIndicator.Height = height;
	return true;
end

function FuryMonitor.Commands.set_AbilityFrame_RageIndicator_OnColor(r, g, b, a)
	local v = false;
	v, r, g, b, a = FuryMonitor.Validation.ValidateColor(r, g, b, a);
	if not v then return false; end

	local color = FuryMonitor.Configuration.AbilityFrame.RageIndicator.OnColor;
	color.R = r;
	color.G = g;
	color.B = b;
	color.A = a;
	return true;
end

function FuryMonitor.Commands.set_AbilityFrame_RageIndicator_OffColor(r, g, b, a)
	local v = false;
	v, r, g, b, a = FuryMonitor.Validation.ValidateColor(r, g, b, a);
	if not v then return false; end

	local color = FuryMonitor.Configuration.AbilityFrame.RageIndicator.OffColor;
	color.R = r;
	color.G = g;
	color.B = b;
	color.A = a;
	return true;
end

function FuryMonitor.Commands.set_AbilityFrame_RageIndicator_Show(show)
	local value = true;
	if not show or show == "false" or show == "0" then
		value = false;
	end
	FuryMonitor.Configuration.AbilityFrame.RageIndicator.Show = value;
	return true;
end

function FuryMonitor.Commands.set_AbilityFrame_RageIndicator_Width(width)
	if not width then
		return false;
	end
	FuryMonitor.Configuration.AbilityFrame.RageIndicator.Width = width;
	return true;
end

function FuryMonitor.Commands.set_Tray_Alpha(alpha)
	local v = false;
	v, alpha = FuryMonitor.Validation.ValidateAlpha(alpha);
	if not v then return false; end

	FuryMonitor.Configuration.Tray.Alpha = alpha;
	return true;
end

function FuryMonitor.Commands.set_Tray_Padding(padding)
	local v = false;
	v, padding = FuryMonitor.Validation.ValidateDimension(padding);
	if not v then return false; end

	FuryMonitor.Configuration.Tray.Padding = padding;
	return true;
end

function FuryMonitor.Commands.set_RotationDuration(duration)
	local v = false;
	v, duration = FuryMonitor.Validation.ValidateDuration(duration);
	if not v then return false; end

	if duration ~= FuryMonitor.Util.round(duration) then
		FuryMonitor.Main:GetInstance():PrintMessage(
			"duration must be a whole number."
		);
		return false;
	end
	FuryMonitor.Configuration.RotationDuration
		= duration * FuryMonitor.Main:GetInstance():GetCharacter():GetGlobalCooldown();
	return true;
end

function FuryMonitor.Commands.set_Enabled(enabled)
	local fm = FuryMonitor.Main:GetInstance();
	if enabled == nil then
		fm:PrintMessage((FuryMonitor.Configuration.Enabled
			and "FuryMonitor disabled.")
			or "FuryMonitor enabled."
			);
		FuryMonitor.Configuration.Enabled = not FuryMonitor.Configuration.Enabled;
		return true;
	end
	if (not enabled) or enabled == "0" or enabled == "false" then
		FuryMonitor.Configuration.Enabled = false;
		fm:PrintMessage("FuryMonitor disabled.");
	else
		FuryMonitor.Configuration.Enabled = true;
		fm:PrintMessage("FuryMonitor enabled.");
	end
	return true;
end

-- This has to come last so that the function definitions (above) can be referenced.
FuryMonitor.Commands.SlashCommandStructure = {
	debug = { _d = "Debugging functions.",
		ability = { _d = "Functions to show information regarding abilities.",
			show = { _d = "Show information about the registered abilities.",
				_f = FuryMonitor.Commands.debug_ability_show
			}
		},
		abilityframe = { _d = "Functions to show information regarding the pool of AbilityFrames.",
			active = { _d = "Show the current pool of active AbilityFrames.",
				_f = FuryMonitor.Commands.debug_abilityframe_active
			},
			inactive = { _d = "Show the current pool of inactive AbilityFrames.",
				_f = FuryMonitor.Commands.debug_abilityframe_inactive
			}	
		},
		character = { _d = "Character abstraction debugging functions.",
			hit = { _d = "Show character hit chance.",
				_f = FuryMonitor.Commands.debug_character_hit
			},
			normalizedweaponspeed = { _d = "Show normalized weapon speeds.",
				_f = FuryMonitor.Commands.debug_character_normalizedweaponspeed
			},	
			talents = { _d = "Show character talents",
				_f = FuryMonitor.Commands.debug_character_talents
			},	
			weapondamage = { _d = "Show weapon damage.",
				_f = FuryMonitor.Commands.debug_character_weapondamage
			},
			weaponspeed = { _d = "Show weapon speeds.",
				_f = FuryMonitor.Commands.debug_character_weaponspeed
			}
		},
		permutationcache = { _d = "Show the cached permutations table.",
			_f = FuryMonitor.Commands.debug_permutationcache
		},
		rotation = { _d = "Show the current proposed rotation.",
			_f = FuryMonitor.Commands.debug_rotation
		},
		rotationitem = { _d = "Functions to show information regarding the pool of RotationItems.",
			active = { _d = "Show the current pool of active RotationItems.",
				_f = FuryMonitor.Commands.debug_rotationitem_active
			},
			inactive = { _d = "Show the current pool of inactive RotationItems.",
				_f = FuryMonitor.Commands.debug_rotationitem_inactive
			}
		},
		subscriptions = { _d = "Show information about subscriptions.",
			_f = FuryMonitor.Commands.debug_subscriptions
		}	
	},
	abilityframe = { _d = "Change the settings for AbilityFrames.",
		alpha = { _d = "Change the transparency of AbilityFrames.",
			_f = FuryMonitor.Commands.set_AbilityFrame_Alpha,
			_a = "alpha:dec[0,1]"
		},	
		fontcolor = { _d = "Change the font color of AbilityFrames.",
			_f = FuryMonitor.Commands.set_AbilityFrame_FontColor,
			_a = "r:dec[0,1] g:dec[0,1] b:dec[0,1] a:dec[0,1]"
		},	
		fontsize = { _d = "Change the font size of AbilityFrames.",
			_f = FuryMonitor.Commands.set_AbilityFrame_FontSize,
			_a = "fontSize:int[8,]"
		},
		rageindicator = { _d ="Change the settings for rage indicators.",
			height = { _d = "Change the height of the rage indicator.",
				_f = FuryMonitor.Commands.set_AbilityFrame_RageIndicator_Height,
				_a = "height:int[1,]"
			},
			offcolor = { _d = "Change the OFF color of the rage indicators.",
				_f = FuryMonitor.Commands.set_AbilityFrame_RageIndicator_OffColor,
				_a = "r:dec[0,1] g:dec[0,1] b:dec[0,1] a:dec[0,1]"
			},
			oncolor = { _d = "Change the ON color of the rage indicators.",
				_f = FuryMonitor.Commands.set_AbilityFrame_RageIndicator_OnColor,
				_a = "r:dec[0,1] g:dec[0,1] b:dec[0,1] a:dec[0,1]"
			},
			show = { _d = "Toggle whether or not to show the rage indicators.",
				_f = FuryMonitor.Commands.set_AbilityFrame_RageIndicator_Show,
				_a = "show:bit"
			},
			width = { _d = "Change the width of the rage indicators.",
				_f = FuryMonitor.Commands.set_AbilityFrame_RageIndicator_Width,
				_a = "width:int[1,]"
			}
		},
		size = { _d = "Change the size of ability frames.",
			_f = FuryMonitor.Commands.set_AbilityFrame_Size,
			_a = "size:int[1,]"
		}
	},
	display = { _d = "Change the overall layout of the mod.",
		abilityspacing = { _d = "Change the spacing between abilities.",
			_f = FuryMonitor.Commands.set_Display_AbilitySpacing,
			_a = "spacing:int[0,]"
		},
		combatalpha = { _d = "Change the transparency of the mod in combat.",
			_f = FuryMonitor.Commands.set_Display_CombatAlpha,
			_a = "alpha:dec[0,1]"
		},
		idlealpha = { _d = "Change the transparency of the mod out of combat.",
			_f = FuryMonitor.Commands.set_Display_IdleAlpha,
			_a = "alpha:dec[0,1]"
		},	
		alphafadeduration = { _d = "Change the fade duration when transitioning combat state.",
			_f = FuryMonitor.Commands.set_Display_AlphaFadeDuration,
			_a = "duration:dec[0,]"
		},	
		framestrata = { _d = "Change the frame strata used by FuryMonitor.",
			_f = FuryMonitor.Commands.set_Display_FrameStrata,
			_a = "strata:string"
		},	
		padding = { _d = "Adjust the space between the PowerBar and the Tray.",
			_f = FuryMonitor.Commands.set_Display_Padding,
			_a = "padding:int[0,]"
		},	
		position = { _d = "Change the position of the monitor.",
			_f = FuryMonitor.Commands.set_Display_Position,
			_a = "x:int[0,] y:int[0,]"
		}
	},
	option = { _d = "Change mod options.",
		enabled = { _d = "Enable/disable FuryMonitor.",
			_f = FuryMonitor.Commands.set_Enabled,
			_a = "enabled:bit"
		},
		rotationduration = { _d = "Set the number of rotation slots to display.",
			_f = FuryMonitor.Commands.set_RotationDuration,
			_a = "duration:int[1,]"
		}	
	},
	powerbar = { _d = "Change the settings of the PowerBar.",
		animationtime = { _d = "Change the time it takes for the PowerBar to adjust to new values.",
			_f = FuryMonitor.Commands.set_PowerBar_AnimationTime,
			_a = "time:dec[0,]"
		},
		color = { _d = "Change the color of the PowerBar.",
			_f = FuryMonitor.Commands.set_PowerBar_Color,
			_a = "r:dec[0,1] g:dec[0,1] b:dec[0,1] a:dec[0,1]"
		},
		fontcolor = { _d = "Change the font color of the PowerBar.",
			_f = FuryMonitor.Commands.set_PowerBar_FontColor,
			_a = "r:dec[0,1] g:dec[0,1] b:dec[0,1] a:dec[0,1]"
		},	
		fontsize = { _d = "Change the font size of the PowerBar.",
			_f = FuryMonitor.Commands.set_PowerBar_FontSize,
			_a = "fontSize:int[8,]"
		},
		height = { _d = "Change the height of the PowerBar.",
			_f = FuryMonitor.Commands.set_PowerBar_Height,
			_a = "height:int[1,]"
		},
		texture = { _d = "(EXPERTS ONLY) Change the texture of the powerbar.",
			_f = FuryMonitor.Commands.set_PowerBar_BackgroundFile,
			_a = "texturePath"
		}
	},
	tray = { _d = "Change the settings of the Tray.",
		alpha = { _d = "Change the alpha transparency of the tray.",
			_f = FuryMonitor.Commands.set_Tray_Alpha,
			_a = "alpha:dec[0,1]"
		},
		padding = { _d = "Change the padding of the tray.",
			_f = FuryMonitor.Commands.set_Tray_Padding,
			_a = "padding:int[0,]"
		}
	}
};
