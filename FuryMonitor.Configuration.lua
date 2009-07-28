--[[
This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public Liscence, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtpl/COPYING for more details.
]]--

FuryMonitor.Configuration = {
	Version = 				000302,
	OldestCompatible =		000301,
	AbilityFrame = {
		Width = 			30,
		Height =			30,
		Alpha = 			0.5,
		BackgroundInset = 	1,
		EdgeFile =			"Interface\\Tooltips\\UI-Tooltip-Border",
		EdgeSize =			10,
		FontColor = 		{ R = 1, G = 1, B = 1, A = 1 },
		FontFile =			"Fonts\\FRIZQT__.ttf",
		FontSize =			11,
		RageIndicator = {
			Width =				30,
			Height =			10,
			BackgroundFile =	"Interface\\TargetingFrame\\UI-StatusBar",
			BackgroundInset =	3,
			OnColor = 			{ R = 1, G = 0.2, B = 0, A = 1 },
			OffColor = 			{ R = 0.4, G = 0.2, B = 0.2, A = 0.9 },
			Position =			"TOPRIGHT",
			Show =				true
		}
	},
	PowerBar = {
		AnimationTime = 	1,
		Color = 			{ R = 0.8, G = 0, B = 0.1, A = 0.6 },
		Height = 			22,
		BackgroundFile = 	"Interface\\TargetingFrame\\UI-StatusBar",
		BackgroundInset =	 3,
		EdgeFile = 			"Interface\\Tooltips\\UI-Tooltip-Border",
		EdgeSize = 			10,
		FontFile =			"Fonts\\FRIZQT__.TTF",
		FontSize = 			11,
		FontColor =			{ R = 1, G = 1, B = 1, A = 1 },
		StatusBarTexture =	"Interface\\TargetingFrame\\UI-StatusBar"
	},
	Tray = {
		Alpha = 				0.6,
		BackgroundFile = 		"Interface\\DialogFrame\\UI-DialogBox-Background",
		BackgroundTileSize =	10,
		BackgroundInset = 		2,
		EdgeFile =				"Interface\\Tooltips\\UI-Tooltip-Border",
		EdgeSize =				10,
		Padding =				1
	},
	Display = {
		CombatAlpha =				1,
		IdleAlpha =					0.4,
		AlphaFadeDuration =			1,
		AbilitySpacing =			3,
		FrameStrata =				"BACKGROUND",
		FrameLevel =				1,
		Padding =					4,
		Position = 					{ X = 200, Y = 200 }	
	},
	Enabled = true,
	RotationDuration = 9 * 1.5
};
