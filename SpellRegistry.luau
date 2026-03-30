local SpellRegistry = {}

SpellRegistry.Spells = {
	{ name = "Fireball",  seq = {9, 1, 4, 6},                 color = Color3.fromRGB(216, 90,  48)  },
	{ name = "Shield",    seq = {9, 1, 3, 5, 7},              color = Color3.fromRGB(55,  138, 221) },
	{ name = "Blink",     seq = {9, 8, 4},                    color = Color3.fromRGB(127, 119, 221) },
	{ name = "Heal",      seq = {9, 1, 5},                    color = Color3.fromRGB(29,  158, 117) },
	{ name = "Nova",      seq = {9, 1, 2, 3, 4, 5, 6, 7, 8}, color = Color3.fromRGB(212, 83,  126) },
	{ name = "Ice Spear", seq = {9, 1, 2, 4},                 color = Color3.fromRGB(133, 183, 235) },
	{ name = "Thunder",   seq = {9, 2, 5, 6, 1},              color = Color3.fromRGB(250, 199, 117) },
	{ name = "Dark Void", seq = {9, 7, 5, 3, 1},              color = Color3.fromRGB(83,  74,  183) },
	{ name = "Barrier",   seq = {9, 8, 1, 2, 3},              color = Color3.fromRGB(93,  202, 165) },
	{ name = "Summon",    seq = {9, 4, 7, 2, 5, 8, 3, 6},     color = Color3.fromRGB(237, 147, 177) },
	{ name = "oblivion",  seq = {9, 4, 7, 2, 5, 8, 3, 1},     color = Color3.fromRGB(0, 0, 0)}
}

-- Retourne le sort si la s�quence est un match complet
function SpellRegistry.Match(inputSeq)
	for _, spell in ipairs(SpellRegistry.Spells) do
		if #spell.seq == #inputSeq then
			local match = true
			for i, v in ipairs(spell.seq) do
				if inputSeq[i] ~= v then match = false; break end
			end
			if match then return spell end
		end
	end
	return nil
end

-- Retourne true si la s�quence est un pr�fixe valide d'au moins un sort
function SpellRegistry.AnyPartial(inputSeq)
	if #inputSeq == 0 then return false end
	for _, spell in ipairs(SpellRegistry.Spells) do
		if #spell.seq > #inputSeq then
			local match = true
			for i, v in ipairs(inputSeq) do
				if spell.seq[i] ~= v then match = false; break end
			end
			if match then return true end
		end
	end
	return false
end

-- Retourne une table [pointIndex] = { color, remaining }
-- pour chaque prochain point valide depuis la s�quence actuelle
-- Si deux sorts pointent vers le m�me point, garde le plus court restant
function SpellRegistry.GetNextHints(inputSeq)
	local hints = {}
	for _, spell in ipairs(SpellRegistry.Spells) do
		if #spell.seq <= #inputSeq then continue end
		local isPrefix = true
		for i, v in ipairs(inputSeq) do
			if spell.seq[i] ~= v then isPrefix = false; break end
		end
		if not isPrefix then continue end
		local nextIdx   = spell.seq[#inputSeq + 1]
		local remaining = #spell.seq - #inputSeq
		if hints[nextIdx] == nil or remaining < hints[nextIdx].remaining then
			hints[nextIdx] = { color = spell.color, remaining = remaining }
		end
	end
	return hints
end

return SpellRegistry