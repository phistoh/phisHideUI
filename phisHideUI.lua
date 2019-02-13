-- v1.2: Includes options to change what to toggle on UI hide
-- v1.1: Only sets cvars out of combat
-- v1.0: Initial upload

-- default options
local phis_defaults = {
	phis_toggle_chatbubbles = true,
	phis_toggle_pettracking = true,
	phis_toggle_unitnames = true
}

-- initialize variables
local phis_name_cvars = {
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
		'UnitNameInteractiveNPC'
	}
local phis_names_to_toggle = {}
local phis_pettracking = false
local phis_names_not_restored = false
local phis_f = CreateFrame('Frame', 'phisCheckFrame', UIParent)

-------------------------
-- AUXILIARY FUNCTIONS --
-------------------------

-- copies the key-value pairs of table 'src' to table 'dst' (deep copy)
local function phis_aux_copy_table(src, dst)
	for k,v in pairs(src) do
		-- if the table contains a table call the function recursively
		if type(v) == 'table' then
			dst[k] = {}
			phis_aux_copy_table(v, dst[k])
		else
			dst[k] = v
		end
	end
end

-------------------------
--   ADDON FUNCTIONS   --
-------------------------

-- toggles off all currently displayed names; doesn't change settings of currently hidden names
local function phis_toggle_names_off()
	-- test if the user is in combat and don't do anything if so
	-- also don't do anything if the phis_names_not_restored flag isn't cleared because all names are still hidden
	if UnitAffectingCombat('player') or phis_names_not_restored then
		-- print("Cannot change CVars in combat")
		return
	end
	
	-- toggle unit names if the option is enabled
	if phisHideUISavedVars['phis_toggle_unitnames'] then
		-- iterate through the table, store all currently displayed names and hide them
		for k,v in pairs(phis_name_cvars) do
			-- GetCVar returns a string and not a number...
			if GetCVar(v) == '1' then
				table.insert(phis_names_to_toggle, v)
				SetCVar(v,0)
			end
		end
	end
	
	-- toggle the chat bubbles if the option is enabled
	if phisHideUISavedVars['phis_toggle_chatbubbles'] then
		for k,v in pairs({'chatBubbles','chatBubblesParty'}) do
			-- GetCVar returns a string and not a number...
			if GetCVar(v) == '1' then
				table.insert(phis_names_to_toggle, v)
				SetCVar(v,0)
			end
		end
	end
	
	-- if pet tracking should be toggled check if pet tracking is currently active and disable it
	if phisHideUISavedVars['phis_toggle_pettracking'] then
		-- iterates through all trackable things to finde battle pets
		for i=1,GetNumTrackingTypes() do
			-- a is 1 if the tracking is active, else it is nil
			n, _, a = GetTrackingInfo(i)
			if n == 'Track Pets' and a then
				phis_pettracking = true
				SetTracking(i, false)
				break
			elseif n == 'Track Pets' and not a then
				phis_pettracking = false
				break
			end
		end
	end
end

-- toggles on all previously displayed names; doesn't change settings of previously hidden names
local function phis_toggle_names_on()
	-- test if the user is in combat and don't do anything if so
	-- remember to restore CVars after combat
	if UnitAffectingCombat('player') then
		-- print("Cannot change CVars in combat")
		phis_names_not_restored = true
		return
	end

	-- iterate through the stored cvars and show them
	for k,v in pairs(phis_names_to_toggle) do
		SetCVar(v,1)
	end
	phis_names_to_toggle={}
	
	-- enables pet tracking if it should be toggled and was enabled before
	if phisHideUISavedVars['phis_toggle_pettracking'] and phis_pettracking then
		for i=1,GetNumTrackingTypes() do
			n = GetTrackingInfo(i)
			if n == 'Track Pets' then
				SetTracking(i, true)
				phis_pettracking = false
				break
			end
		end
	end
end

-- iterates over the default options table and inserts any not yet saved option into the saved variables
local function phis_update_config(self, event, ...)
	-- when ADDON_LOADED is fired the relevant saved variables are also loaded
	if event == 'ADDON_LOADED' then
		for k,v in pairs(phis_defaults) do
			if phisHideUISavedVars[k] == nil then
				-- deep copy instead of copying the reference
				if type(v) == 'table' then
					phisHideUISavedVars[k] = {}
					phis_aux_copy_table(v, phisHideUISavedVars[k])
				else
					phisHideUISavedVars[k] = v
				end
			end
		end
	end
end

-- restores all names after combat ends and clears the phis_names_not_restored flag
local function phis_auto_restore(self, event, ...)
	if event == 'PLAYER_REGEN_ENABLED' and phis_names_not_restored then
		phis_names_not_restored = false
		phis_toggle_names_on()
	end
end

-- to check if the player left combat to automatically restore non-restored names
phis_f:RegisterEvent('PLAYER_REGEN_ENABLED')

-- to update the saved variables
phis_f:RegisterEvent('ADDON_LOADED')

-- register to OnShow/OnHide handlers
phis_f:SetScript('OnShow', phis_toggle_names_on)
phis_f:SetScript('OnHide', phis_toggle_names_off)
phis_f:SetScript('OnEvent', phis_auto_restore)
phis_f:SetScript('OnEvent', phis_update_config)