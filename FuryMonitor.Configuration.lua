FuryMonitor.Configuration = {
	Version = 				000203,
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
		FrameStrata =		"LOW",
		RageIndicator = {
			Alpha = 			1,
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
		Alpha =				1,
		AbilitySpacing =	3,
		FrameStrata =		"BACKGROUND",
		Padding =			4,
		Position = 			{ X = 1, Y = 1 }	
	},
	Enabled = true,
	RotationDuration = 9 * 1.5
};
