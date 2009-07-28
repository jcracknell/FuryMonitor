FuryMonitor.Main = { _instance = nil };
FuryMonitor.Main.__index = FuryMonitor.Main;
FuryMonitor.Heap = {
	ReadyUsed = {},
	ReadyAbilities = {},
	Available = {},
	RunFrom = {},
	RunUntil = {},
	RunDps = {}
};

function FuryMonitor.Main:GetInstance()
	if (self._instance == nil) then
		local character = FuryMonitor.Character:new();
		local members = {
			_character = character;
			_abilities = FuryMonitor.Abilities(character),
			_abilityIndexMap = nil,
			_abilityNameMap = nil,
			_debug = true,
			_frame = nil,
			_rotationTrayFrame = nil,
			_permutations = {},
			_powerBar = nil,
			_rotation = nil,
			_rotationStabilized = false,
			_subscribers = {
				OnConfigurationChanged = {},
				OnTalentsChanged = {},
				OnEquipmentChanged = {},
				OnStatsChanged = {},
				OnUpdate = {}
			},
			Events = {
				UNIT_RAGE = function(fm) fm:OnStatsChanged() end,
				UNIT_AURA = function(fm) fm:OnStatsChanged() end,
				UNIT_STATS = function(fm) fm:OnStatsChanged() end,
				PLAYER_AURAS_CHANGED = function(fm) fm:OnStatsChanged() end,
				UNIT_INVENTORY_CHANGED = function(fm) fm:OnEquipmentChanged(); fm:OnStatsChanged(); end,
				PLAYER_LEVEL_UP = function(fm) fm:OnStatsChanged() end,
				UNIT_SPELLCAST_SUCCEEDED = function(fm) fm:OnSpellCast() end,
				CHARACTER_POINTS_CHANGED = function(fm) fm:OnTalentsChanged() end,
				UPDATE_SHAPESHIFT_FORM = function(fm) fm:OnStatsChanged() end
			}
		};
		self._instance = setmetatable(members, FuryMonitor.Main);

	end
	return self._instance;
end

-------------------------------------------------
-- BEGIN GETTERS/SETTERS
-------------------------------------------------

function FuryMonitor.Main:GetVersionNumber()
	local version = FuryMonitor.Configuration.Version;
	local major = math.floor(version / 10000);
	local minor = math.floor((version - major * 10000) / 100);
	local mini = version - major * 10000 - minor * 100;
	return major .. "." .. minor .. "." .. mini;
end

function FuryMonitor.Main:GetAbilities()
	return self._abilities;
end

function FuryMonitor.Main:GetAbilityIndex(ability)
	if not self._abilityIndexMap then
		self._abilityIndexMap = {};
		local abilities = self:GetAbilities();
		for i = 1, #abilities do
			if abilities[i]:Exists() then
				self._abilityIndexMap[abilities[i]:GetSpellNumber()] = i;
			end
		end
	end
	return self._abilityIndexMap[ability:GetSpellNumber()];
end

function FuryMonitor.Main:GetAbilityByName(name)
	if not self._abilityNameMap then
		local abilities = self:GetAbilities();
		self._abilityNameMap = {};
		for i = 1, #abilities do
			self._abilityNameMap[abilities[i]:GetName()] = abilities[i];
		end
	end
	return self._abilityNameMap[name];
end

function FuryMonitor.Main:GetCharacter()
	return self._character;
end

function FuryMonitor.Main:GetDebug()
	return self._debug;
end

function FuryMonitor.Main:GetFrame()
	return self._frame;
end

function FuryMonitor.Main:SetFrame(frame)
	self._frame = frame;
	return frame;
end

function FuryMonitor.Main:SetRotationTrayFrame(frame)
	self._rotationTrayFrame = frame;
end

function FuryMonitor.Main:GetRotationTrayFrame(frame)
	return self._rotationTrayFrame;
end

function FuryMonitor.Main:GetPowerBar()
	return self._powerBar;
end

function FuryMonitor.Main:GetRotation()
	return self._rotation;
end

function FuryMonitor.Main:SetRotation(rotation)
	self._rotation = rotation;
end

function FuryMonitor.Main:GetRotationStabilized()
	-- The rotation is not stabilized as long as there are reactive abilities that
	-- are available
	local abilities = self:GetAbilities();
	for i = 1, #abilities do
		if abilities[i]:IsReactive() and abilities[i]:IsAvailable() then
			return false;
		end	
	end
	return self._rotationStabilized;
end

function FuryMonitor.Main:SetRotationStabilized(value)
	self._rotationStabilized = value;
end

function FuryMonitor.Main:GetRotationWidth()
	if self._rotationWidth == nil then
		self._rotationWidth =
			(FuryMonitor.Configuration.RotationDuration
			/ self:GetCharacter():GetGlobalCooldown())
			*
			(FuryMonitor.Configuration.AbilityFrame.Width
			+ FuryMonitor.Configuration.Display.AbilitySpacing)
			+ FuryMonitor.Configuration.Display.AbilitySpacing;
	end
	return self._rotationWidth;
end

-------------------------------------------------
-- END GETTERS/SETTERS
-------------------------------------------------

-------------------------------------------------
-- BEGIN FUNCTIONS
-------------------------------------------------

function FuryMonitor.Main:SubscribeToConfigurationChanges(subscriber)
	self._subscribers.OnConfigurationChanged[subscriber] = true;
end

function FuryMonitor.Main:UnSubscribeToConfigurationChanges(subscriber)
	self._subscribers.OnConfigurationChanged[subscriber] = nil;
end

function FuryMonitor.Main:SubscribeToTalentChanges(subscriber)
	self._subscribers.OnTalentsChanged[subscriber] = true;
end

function FuryMonitor.Main:UnSubscribeToTalentChanges(subscriber)
	self._subscribers.OnTalentsChanged[subscriber] = nil;
end

function FuryMonitor.Main:SubscribeToStatChanges(subscriber)
	self._subscribers.OnStatsChanged[subscriber] = true;
end

function FuryMonitor.Main:UnSubscribeToStatChanges(subscriber)
	self._subscribers.OnStatsChanged[subscriber] = nil;
end

function FuryMonitor.Main:SubscribeToUpdates(subscriber)
	self._subscribers.OnUpdate[subscriber] = true;
end

function FuryMonitor.Main.UnSubscribeToUpdates(subscriber)
	self._subscribers.OnUpdate[subscriber] = nil;
end

function FuryMonitor.Main:LoadFrameConfiguration()
	-- Configure main frame
	self:GetFrame():SetFrameStrata(FuryMonitor.Configuration.Display.FrameStrata);
	self:GetFrame():SetWidth(
		FuryMonitor.Configuration.Tray.BackgroundInset
		+ self:GetRotationWidth()
		+ FuryMonitor.Configuration.Tray.BackgroundInset
	);
	self:GetFrame():SetHeight(
		FuryMonitor.Configuration.PowerBar.Height
		+ FuryMonitor.Configuration.Display.Padding
		+ FuryMonitor.Configuration.Tray.BackgroundInset
		+ FuryMonitor.Configuration.AbilityFrame.Height
		+ FuryMonitor.Configuration.Tray.BackgroundInset
	);	
	self:GetFrame():SetPoint("TOPLEFT", "UIParent", "TOPLEFT",
		FuryMonitor.Configuration.Display.Position.X,
		-FuryMonitor.Configuration.Display.Position.Y
	);	
	if FuryMonitor.Configuration.Enabled then
		self:GetFrame():Show();
	else
		self:GetFrame():Hide();
	end	

	-- Configure tray
	self:GetRotationTrayFrame():SetFrameStrata(FuryMonitor.Configuration.Display.FrameStrata);
	self:GetRotationTrayFrame():SetWidth(
		FuryMonitor.Configuration.Tray.BackgroundInset
		+ FuryMonitor.Configuration.Tray.Padding
		+ self:GetRotationWidth()
		+ FuryMonitor.Configuration.Tray.Padding
		+ FuryMonitor.Configuration.Tray.BackgroundInset
	);	
	self:GetRotationTrayFrame():SetHeight(
		FuryMonitor.Configuration.Tray.BackgroundInset
		+ FuryMonitor.Configuration.Tray.Padding
		+ FuryMonitor.Configuration.AbilityFrame.Height
		+ FuryMonitor.Configuration.Tray.Padding
		+ FuryMonitor.Configuration.Tray.BackgroundInset
	);	
	self:GetRotationTrayFrame():SetBackdrop({
		bgFile = FuryMonitor.Configuration.Tray.BackgroundFile,
		tileSize = FuryMonitor.Configuration.Tray.BackgroundTileSize,
		tile = 1,
		edgeFile = FuryMonitor.Configuration.Tray.EdgeFile,
		edgeSize = FuryMonitor.Configuration.Tray.EdgeSize,
		insets = {
			top = FuryMonitor.Configuration.Tray.BackgroundInset,
			bottom = FuryMonitor.Configuration.Tray.BackgroundInset,
			left = FuryMonitor.Configuration.Tray.BackgroundInset,
			right = FuryMonitor.Configuration.Tray.BackgroundInset
		}		
	});
	self:GetRotationTrayFrame():SetAlpha(
		FuryMonitor.Configuration.Tray.Alpha
		* FuryMonitor.Configuration.Display.Alpha
	);
	self:GetRotationTrayFrame():SetPoint("TOPLEFT", self:GetFrame(), "TOPLEFT",
		0,
		-(FuryMonitor.Configuration.PowerBar.Height
		+ FuryMonitor.Configuration.Display.Padding)
	);	
	if FuryMonitor.Configuration.Enabled then
		self:GetRotationTrayFrame():Show();
	else
		self:GetRotationTrayFrame():Hide();
	end
end

function FuryMonitor.Main:BuildRotation()

	FuryMonitor.Ability.EnableTheoreticalUse();

	local abilities = self:GetAbilities();
	local gcd = self:GetCharacter():GetGlobalCooldown();
	local currentTime = FuryMonitor.Util.GetTime();
	local time = 0;
	local rage = self:GetCharacter():GetRage();

	local stabilized = true;

	if not self:BuildRotation_AbilitiesExist(abilities) then
		return nil, true, 0;
	end	
	
	-- Get the available time of each ability in a table
	local available = FuryMonitor.Util.clear_table(FuryMonitor.Heap.Available);
	for i = 1, #abilities do
		available[i] = abilities[i]:GetCooldownRemaining();
		if (available[i] ~= 0 and abilities[i]:IsAvailable())
			or (available[i] == 0 and abilities[i]:IsReactive()) then
			-- If all of the abilities are ready to be used, then the rotation
			-- is "stabilized", and does not need to be recomputed until the
			-- player state changes
			stabilized = false;
		end	
	end

	local rotation = nil;

	local rageAvailableUntil = nil;
	while true do
		time = time + self:BuildRotation_ToTheNow(available);
		if time > FuryMonitor.Configuration.RotationDuration then
			do break end;
		end

		-- Get a list of all of the abilities available to us
		local readyAbilities = self:BuildRotation_GetReadyAbilities(abilities, available);

		if #readyAbilities > 1 then
			readyAbilities
				= self:BuildRotation_GetBestReadyAbilityOrder(readyAbilities, available);
		end

		-- We now have the next ability to be added to the rotation
		local ability = readyAbilities[1];

		-- Determine whether or not our current rage will carry us this far into
		-- the rotation.
		rage = rage - ability:GetRageCost();
		local rageAvailable = rage >= 0;

		-- Inflict the GCD on abilities that would otherwise be ready inside the GCD
		local availableTime = available[self:GetAbilityIndex(ability)];
		time = time + availableTime;
		for i = 1, #abilities do
			available[i] = available[i] - availableTime;
			if available[i] < gcd then
				available[i] = gcd;
			end
		end

		-- If this is the first ability we don't have rage for, then mark this
		-- as the time rage is available until
		if not rageAvailableUntil and not rageAvailable then
			rageAvailableUntil = time;
		end

		local rotationItem = FuryMonitor.RotationItem:new(
			ability,
			currentTime + time,
			rageAvailable
		);
		if not rotation then
			rotation = rotationItem;
		else
			rotation:Append(rotationItem);
		end

		-- Pretend we used the ability to increment its UseCount
		ability:Used();
		-- Set the cooldown for the ability
		available[self:GetAbilityIndex(ability)] = ability:GetCooldownDuration();
	end

	FuryMonitor.AbilityFrame.RecycleUnusedAbilityFrames();
	FuryMonitor.Ability.DisableTheoreticalUse();
	FuryMonitor.AbilityFrame.RecycleOldAbilityFrames();

	if not rageAvailableUntil then
		rageAvailableUntil = 0;
	end

	return rotation, stabilized, rageAvailableUntil;
end

	function FuryMonitor.Main:BuildRotation_AbilitiesExist(abilities)
		for _, ability in pairs(abilities) do
			if ability:Exists() then
				return true;
			end	
		end
		return false;
	end

	function FuryMonitor.Main:BuildRotation_GetReadyAbilities(abilities, available)
		-- For this purpose we have a table that we recycle
		local ready = FuryMonitor.Util.clear_table(FuryMonitor.Heap.ReadyAbilities);
		local readyUsed = FuryMonitor.Util.clear_table(FuryMonitor.Heap.ReadyUsed);
		local gcd = self:GetCharacter():GetGlobalCooldown();
		
		local added = true;
		local fake = nil;
		while added do
			added = false;
			for i, ability in pairs(abilities) do
				if (not readyUsed[i])
					and ability:IsAvailable()
					and not ability:IsFake()
					and available[i] < gcd * (#ready + 1)
				then
					readyUsed[i] = true;
					table.insert(ready, ability);
					added = true;
				end
				if ability:IsFake() then
					fake = ability;
				end
			end
		end
		if #ready == 0 and fake then
			table.insert(ready, fake);
		end
		return ready;
	end

	function FuryMonitor.Main:BuildRotation_GetBestReadyAbilityOrder(readyAbilities, available)
		local currentTime = FuryMonitor.Util.GetTime();

		-- Get all of the possible orderings of abilities
		local readyAbilityPermutations
			= self:BuildRotation_GetAbilityPermutations(readyAbilities);
		local bestOrder = readyAbilityPermutations[1];

		-- Determine which ordering of abilities produces the highest dps, and set
		-- readyAbilities to that ordering
		local gcd = self:GetCharacter():GetGlobalCooldown();
		local bestDps = -1;
		for i = 1, #readyAbilityPermutations do
			local permutation = readyAbilityPermutations[i];
			-- Set the initial shift value to the rotation delay caused by
			-- the remaining cooldown on the first ability in the proposed
			-- rotation
			local timeShift = available[self:GetAbilityIndex(permutation[1])];
			-- Do not consider an ordering of abilities that wastes an entire GCD
			if timeShift < gcd then

				-- Clear out the tables we will be using
				local runFrom = FuryMonitor.Util.clear_table(FuryMonitor.Heap.RunFrom);
				local runUntil = FuryMonitor.Util.clear_table(FuryMonitor.Heap.RunUntil);
				local runDps = FuryMonitor.Util.clear_table(FuryMonitor.Heap.RunDps);

				local timeStep = 0;
				local damage = 0;
				local dps = 0;
				for j = 1, #permutation do
					local ability = permutation[j];

					timeStep = math.max(timeShift, available[self:GetAbilityIndex(ability)])
								- timeStep;

					-- Do not include infeasible uses of reactive abilities in the rotation
					if	not ability:IsReactive() -- Short circuit
						or (ability:IsReactive()
						and ability:GetReactiveUsesRemaining() > 0
						and ability:GetAvailableUntil() > currentTime + timeShift + timeStep) then
					
						-- Adjust the timeshift to the start of this ability's availability
						timeShift = math.max(timeShift, available[self:GetAbilityIndex(ability)]);

						runDps[j] = ability:GetDamage() / ability:GetCooldownDuration();
						runFrom[j] = timeShift;
						runUntil[j] = timeShift + ability:GetCooldownDuration();

						-- Adjust the timeshift to the end of this ability's global cooldown
						timeShift = timeShift + math.max(gcd, ability:GetCastTime());
					end
				end

				-- Calculate the dps produced by this ordering
				for j = 1, #permutation do
					if runDps[j] then
						dps = dps + runDps[j] * (math.min(timeShift, runUntil[j]) - runFrom[j]);
					end
				end
				dps = dps / timeShift;

				if dps > bestDps then
					bestOrder = permutation;
					bestDps = dps;
				end
			end
		end	
		return bestOrder;
	end

	function FuryMonitor.Main:BuildRotation_GetAbilityPermutations(abilities)
		-- CACHE PERMUTATIONS FOR PERFORMANCE GAINS
		local key = 0;
		for i, ability in pairs(abilities) do
			key = key + ability:GetSpellNumber() ^ 2;
		end
		if not self._permutations[key] then
			-- THIS CALL IS INCREDIBLY EXPENSIVE
			-- O(n!) on the number of abilities in both runtime and storage
			self._permutations[key] = FuryMonitor.Util.permute_table(abilities);
		end
	
		return self._permutations[key];
	end

	function FuryMonitor.Main:BuildRotation_ToTheNow(available)
		-- This function "advances" the time of our rotation-building simulation
		-- by shifting the available times so that the next available ability is
		-- available. The time shift is returned.
		local nxt = 10000;
		for i = 1, #available do
			if available[i] == 0 then
				return 0;
			end
			if available[i] < nxt then
				nxt = available[i];
			end
		end
		for i = 1, #available do
			available[i] = available[i] - nxt;
		end
		return nxt;
	end

function FuryMonitor.Main:PrintMessage(message)
	if string.byte(message, 1) then
		-- Only bother with concatenation if this isn't the empty string
		message = "|cB3FFAABB" .. message;
	end
	DEFAULT_CHAT_FRAME:AddMessage(message);
end

function FuryMonitor.Main:Redraw()
	if self:GetRotationStabilized() then
		return;
	end

	local newRotation, newRotationStabilized, rageAvailableUntil
		= self:BuildRotation();
	if newRotationStabilized then
		-- Set the stabilized flag to true so we aren't needlessly thrashing
		-- the processor
		self:SetRotationStabilized(true);
	end

	local rotationAxisUnit =
		(self:GetRotationWidth()
		- FuryMonitor.Configuration.AbilityFrame.Width)
		/ FuryMonitor.Configuration.RotationDuration;

	local rotation = newRotation;
	while rotation do
		-- Check if there is already an AbilityFrame for the current
		-- RotationItem
		local af = FuryMonitor.AbilityFrame:GetAbilityFrame(
			rotation:GetAbility():GetSpellNumber(),
			rotation:GetUseId()
		);	
		if not af then
			af = FuryMonitor.AbilityFrame:new(
				rotation:GetAbility(),
				rotation:GetUseId(),
				rotation:GetTime(),
				self:GetRotationTrayFrame(),
				rotation:GetRageAvailable()
			);
		else
			af:SetRageAvailable(rotation:GetRageAvailable());
		end	

		af:SetY(
			FuryMonitor.Configuration.Tray.BackgroundInset
			+ FuryMonitor.Configuration.Tray.Padding
		);
		af:SetX(
			FuryMonitor.Configuration.Tray.BackgroundInset
			+ FuryMonitor.Configuration.Tray.Padding
			+ rotationAxisUnit
				* (rotation:GetTime() - FuryMonitor.Util.GetTime())
		);
		-- Move to the next item in the rotation
		rotation = rotation:GetNextItem();
	end

	self:SetRotationStabilized(newRotationStabilized);
	-- Recycle the RotationItem instances so we aren't thrashing the shit out of
	-- the heap.
	if newRotation ~= nil then
		newRotation:recycle();
	end
end

-------------------------------------------------
-- END FUNCTIONS
-------------------------------------------------

-------------------------------------------------
-- BEGIN EVENT HANDLERS
-------------------------------------------------

function FuryMonitor.Main:OnLoad()
	FuryMonitor.Util.UpdateTime();
	self:OnLoad_CreateFrames();

	self:OnLoad_RegisterEvents();
	self:OnLoad_RegisterSlashCommands();

	self:OnConfigurationChanged();

	self:PrintMessage("FuryMonitor v" .. self:GetVersionNumber() .. " loaded. (/fm)")
end

function FuryMonitor.Main:OnConfigurationChanged()
	FuryMonitor.Util.UpdateTime();
	-- Reset cached values dependant on configuration
	self._rotationWidth = nil;

	-- Update frames
	self:LoadFrameConfiguration();

	-- Notify subscribers of configuration changes
	for subscriber, _ in pairs(self._subscribers.OnConfigurationChanged) do
		subscriber:OnConfigurationChanged();
	end
	FuryMonitor_SavedConfiguration = FuryMonitor.Configuration;

	-- Mark the rotation as unstable, so we have to recalculate and redraw it
	self:SetRotationStabilized(false);
end



function FuryMonitor.Main:OnLoad_CreateFrames()

	self:SetFrame(CreateFrame("Frame"));

	self:SetRotationTrayFrame(CreateFrame("Frame", nil, self:GetFrame()));

	self._powerBar
		= FuryMonitor.PowerBar:GetInstance(self:GetCharacter(), self:GetFrame());
end

function FuryMonitor.Main:OnLoad_RegisterEvents()

	-- Hook up the OnEvent event handler
	self:GetFrame():SetScript(
		"OnEvent",
		function(frame, event)
			FuryMonitor.Main:GetInstance().Events[event](FuryMonitor.Main:GetInstance());
		end
	);	
	
	-- Hook up the OnUpdate event
	self:GetFrame():SetScript(
		"OnUpdate",
		function(frame, event)
			FuryMonitor.Main:GetInstance():OnUpdate();
		end	
	);
	
	for eventName, handler in pairs(self.Events) do
		self:GetFrame():RegisterEvent(eventName);
	end
end

function FuryMonitor.Main:OnLoad_RegisterSlashCommands()
	-- Set up the slash commands for the mod (found in FuryMonitor.Commands.lua)
	SlashCmdList["FuryMonitor"] = FuryMonitor.Commands.SlashCommandHandler;
	SLASH_FuryMonitor1 = "/fm";
end

function FuryMonitor.Main:OnSpellCast()
	local unitName = arg1;
	if unitName ~= "player" then
		return;
	end	

	self:SetRotationStabilized(false);
	local spellName = arg2;
	local ability = self:GetAbilityByName(arg2);
	if ability then
		FuryMonitor.Util.UpdateTime();
		ability:Used();
	end
end

function FuryMonitor.Main:OnStatsChanged()
	FuryMonitor.Util.UpdateTime();

	-- The rotation may have changed as a result of different
	-- damage values for abilities
	self:SetRotationStabilized(false);

	for subscriber, _ in pairs(self._subscribers.OnStatsChanged) do
		subscriber:OnStatsChanged();
	end
end

function FuryMonitor.Main:OnUpdate()
	-- Do nothing if the mod is not enabled
	if not FuryMonitor.Configuration.Enabled then
		return;
	end

	FuryMonitor.Util.UpdateTime();

	-- Animation handling goes here eventually
	self:Redraw();

	-- Update the powerbar
	for subscriber, _ in pairs(self._subscribers.OnUpdate) do
		subscriber:OnUpdate();
	end
end

function FuryMonitor.Main:OnEquipmentChanged()
	FuryMonitor.Util.UpdateTime();
	-- Update character details to reflect the change in equipment
	self:GetCharacter():OnEquipmentChanged();
end

function FuryMonitor.Main:OnTalentsChanged()
	FuryMonitor.Util.UpdateTime();

	-- Clear the ability index so that abilities aquired through talents are
	-- indexed
	-- This can't be done on load because if the ability doesn't exist then we
	-- don't know its spell number to key the map
	self._abilityIndexMap = nil;

	for subscriber, _ in pairs(self._subscribers.OnTalentsChanged) do
		subscriber:OnTalentsChanged();
	end

	self:OnStatsChanged();
end

-------------------------------------------------
-- END EVENT HANDLERS
-------------------------------------------------

-- Set up a useless frame to handle startup
FuryMonitor.Main._loadFrame = CreateFrame("Frame");
FuryMonitor.Main._loadFrame:Hide();
FuryMonitor.Main._loadFrame:SetScript(
	"OnEvent",
	function(frame, event)
		frame:UnregisterEvent(event);
		if event ~= "VARIABLES_LOADED" then
			return;
		end
		if FuryMonitor_SavedConfiguration
		and FuryMonitor_SavedConfiguration.Version == FuryMonitor.Configuration.Version then
			FuryMonitor.Configuration = FuryMonitor_SavedConfiguration;
		else
			FuryMonitor.Main:GetInstance():PrintMessage(
				"FuryMonitor: Old configuration overwritten with new defaults.");
			FuryMonitor.Main:GetInstance():PrintMessage(
				"To change configuration options, type /fm.");	
		end
		if UnitClass("PLAYER") == "Warrior" then
			FuryMonitor.Main:GetInstance():OnLoad();
		end
	end
);	
FuryMonitor.Main._loadFrame:RegisterEvent("VARIABLES_LOADED");
