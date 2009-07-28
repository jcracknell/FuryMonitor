--[[
This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public Liscence, Version 2, as published by Sam Hocevar. See
http://sam.zoy.org/wtpl/COPYING for more details.
]]--

FuryMonitor.Validation = {};

function FuryMonitor.Validation.ValidateAlpha(a)
	a = tonumber(a);
	if not a
	or a < 0 or a > 1
	then
		return false, nil;
	end
	return true, a;
end

function FuryMonitor.Validation.ValidateColor(r, g, b, a)
	r = tonumber(r); b = tonumber(b); g = tonumber(g); a = tonumber(a);
	if not (r and g and b and a)
	or r < 0 or r > 1
	or g < 0 or g > 1
	or b < 0 or b > 1
	or a < 0 or a > 1
	then
		return false, nil, nil, nil, nil;
	end	
	return true, r, g, b, a;
end

function FuryMonitor.Validation.ValidateFontSize(fontSize)
	fontSize = tonumber(fontSize);
	if not fontSize
	or fontSize < 8
	then
		return false, nil;
	end
	return true, fontSize;
end

function FuryMonitor.Validation.ValidateDimension(dim)
	dim = tonumber(dim);
	if not dim
	or dim < 0
	then 
		return false, nil;
	end	
	return true, dim;
end

function FuryMonitor.Validation.ValidateDuration(duration)
	duration = tonumber(duration);
	if not duration
	or duration < 0
	then
		return false, nil;
	end
	return true, duration;
end

function FuryMonitor.Validation.ValidateBit(bit)
	if type(bit) ~= "number" then
		bit = tonumber(bit);
	end	
	if bit ~= 0 and bit ~= 1 then
		return false, nil;
	end	
	return true, bit;
end
