FuryMonitor.Talent = {};
FuryMonitor.Talent.__index = FuryMonitor.Talent;

function FuryMonitor.Talent:new(name)
	local members = {
		_name = name,
		_rank = 0,
		_loaded = false
	};
	return setmetatable(members, FuryMonitor.Talent);
end

function FuryMonitor.Talent:GetRank()
	self:Load();
	return self._rank;
end

function FuryMonitor.Talent:GetName()
	return self._name;
end

function FuryMonitor.Talent:Load()
	if self._loaded == true then
		return;
	end

	-- Iterate through the tabs and talents until we encounter
	-- the talent with the specified name
	local numTabs = GetNumTalentTabs();
	for tab = 1, numTabs do
		local numTalents = GetNumTalents(tab);
		for talent = 1, numTalents do
			local talentName, _, _, _, talentRank, _, _, _
				= GetTalentInfo(tab, talent);
			
			if talentName == self:GetName() then
				self._rank = talentRank;

				self._loaded = true;
			end	
		end
	end

end

function FuryMonitor.Talent:OnTalentsChanged()
	self._loaded = false;
end
