-- initialize variables
local phi_name_cvars = {
		'UnitNameOwn',
		'UnitNameNPC',
		'UnitNameNonCombatCreatureName',
		'UnitNamePlayerGuild',
		'UnitNameGuildTitle',
		'UnitNamePlayerPVPTitle',
		'UnitNameFriendlyPlayerName',
		'UnitNameFriendlyPetName',
		'UnitNameFriendlyGuardianName',
		'UnitNameFriendlyTotemName',
		'UnitNameFriendlyMinionName',
		'UnitNameEnemyPlayerName',
		'UnitNameEnemyPetName',
		'UnitNameEnemyGuardianName',
		'UnitNameEnemyTotemName',
		'UnitNameEnemyMinionName',
		'UnitNameForceHideMinus',
		'UnitNameFriendlySpecialNPCName',
		'UnitNameHostleNPC',
		'UnitNameInteractiveNPC',
		'chatBubbles',
		'chatBubblesParty'
	}
local phi_names_to_toggle = {}
local phi_pettracking = false
local phis_f = CreateFrame("Frame", 'phisCheckFrame', UIParent)
	
-- toggles off all currently displayed names; doesn't change settings of currently hidden names
local function phi_toggle_names_off()
	-- iterate through the table, store all currently displayed names and hide them
	for k,v in pairs(phi_name_cvars) do
		-- GetCVar returns a string and not a number...
		if GetCVar(v) == '1' then
			table.insert(phi_names_to_toggle, v)
			SetCVar(v,0)
		end
	end
	
	-- checks if pet tracking is currently active and disables it
	-- iterates through all trackable things to finde battle pets
	for i=1,GetNumTrackingTypes() do
		n, _, a = GetTrackingInfo(i)
		if n == 'Track Pets' and a then
			phi_pettracking = true
			SetTracking(i, false)
			break
		elseif n == 'Track Pets' and not a then
			phi_pettracking = false
			break
		end
	end
end

-- toggles on all previously displayed names; doesn't change settings of previously hidden names
local function phi_toggle_names_on()
	-- iterate through the stored cvars and show them
	for k,v in pairs(phi_names_to_toggle) do
		SetCVar(v,1)
	end
	phi_names_to_toggle = {}
	
	-- enables pet tracking if it was enabled before
	if phi_pettracking then
		for i=1,GetNumTrackingTypes() do
			n = GetTrackingInfo(i)
			if n == 'Track Pets' then
				SetTracking(i, true)
				phi_pettracking = false
				break
			end
		end
	end
end

-- register to OnShow/OnHide handlers
phis_f:SetScript("OnShow", phi_toggle_names_on)
phis_f:SetScript("OnHide", phi_toggle_names_off)