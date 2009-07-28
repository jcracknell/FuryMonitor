--[[
This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public Liscence, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtpl/COPYING for more details.
]]--

FuryMonitor = {};
FuryMonitor.Util = {};
FuryMonitor.Util._time = GetTime();

function FuryMonitor.Util.round(value, decimals)
	if not decimals then
		decimals = 0;
	end
	local mult = 10 ^ decimals;
	local result = math.floor(value * mult);

	-- Get the remainder so we can check if we have to round up or down
	local remainder = value * mult - result;
	if remainder >= 0.5 then
		result = result + 1;
	end

	return result / mult;
end

function FuryMonitor.Util.clear_table(tbl)
	for i in pairs(tbl) do
		tbl[i] = nil;
	end	
	return tbl;
end

function FuryMonitor.Util.copy_table(tbl, destination)
	-- This function does a shallow copy of a table so that we can manipulate
	-- the indices of the elements without fucking up the source table
	-- (See FuryMonitor.Util.permute_table)
	local result = nil;
	if destination then
		result = destination;
	else
		result = {};
	end
	for key, value in pairs(tbl) do
		result[key] = value;
	end
	return result;
end

function FuryMonitor.Util.permute_table(tbl)
	-- This function accepts a table as an argument and returns a table
	-- containing a table for every permutation of the input table's elements.
	local permutations = { FuryMonitor.Util.copy_table(tbl) };

	local numElements = #tbl;
	if numElements <= 1 then
		return permutations;
	end	

	for block_size = 2, numElements do
		local numElements = #permutations[1];
		local numPermutations = #permutations;
		for i = 1, numPermutations do
			local currentPermutation = FuryMonitor.Util.copy_table(permutations[i]);
			local shiftIndex = numElements - block_size + 1;
			for shift_pos = 1, block_size - 1 do
				local shiftedElement = currentPermutation[shiftIndex];
				table.remove(currentPermutation, shiftIndex);
				table.insert(currentPermutation, shiftedElement);
				table.insert(permutations, FuryMonitor.Util.copy_table(currentPermutation));
			end
		end	
	end

	return permutations;
end


-- These two functions are used to temporarily fix the time to a specific value
-- while performing computations. Otherwise the time changes constantly (duh)
-- and you get really wierd results when trying to build a rotation.
function FuryMonitor.Util.UpdateTime()
	FuryMonitor.Util._time = GetTime();
end

function FuryMonitor.Util.GetTime()
	return FuryMonitor.Util._time;
end

function FuryMonitor.Util.GetUIScale()
	if GetCVar("useUiScale") == 1 then
		return GetCVar("UIScale");
	end
	return 1;
end

function FuryMonitor.Util.str_contains(haystack, needle)
	local start = string.find(haystack, needle, 1, true);
	if start then
		return true;
	end
	return false;
end
