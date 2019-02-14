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
-- used to bind scripts and watch status of UI (shown/hidden)
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
local function phis_update_config(self, event)
	if event == 'PLAYER_LOGIN' then
		-- first time loading the addon
		if not phisHideUISavedVars then
			print(GetAddOnMetadata('phisHideUI','Title')..' v'..GetAddOnMetadata('phisHideUI','Version')..' loaded for the first time.')
			phisHideUISavedVars = {}
		end
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
local function phis_auto_restore(self, event)
	if event == 'PLAYER_REGEN_ENABLED' and phis_names_not_restored then
		phis_names_not_restored = false
		phis_toggle_names_on()
	end
end

-------------------------
--    OPTIONS PANEL    --
-------------------------

local phis_options = CreateFrame('Frame', 'phisOptionsFrame', InterfaceOptionsFramePanelContainer)
phis_options.name = GetAddOnMetadata('phisHideUI','Title')
InterfaceOptions_AddCategory(phis_options)
phis_options:SetScript('OnShow', function()

	-- save current vars in case of hitting cancel
	-- local temp_settings = {}
	-- phis_aux_copy_table(phisHideUISavedVars, temp_settings)

	local phis_title_string = phis_options:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	phis_title_string:SetPoint('TOPLEFT', 10, -10)
	phis_title_string:SetText(GetAddOnMetadata('phisHideUI','Title'))
	
	local phis_version_string = phis_options:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	phis_version_string:SetPoint('BOTTOMLEFT', phis_title_string, 'BOTTOMRIGHT', 4, 0)
	phis_version_string:SetText('v'..GetAddOnMetadata('phisHideUI','Version'))
	
	local phis_description_string = phis_options:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	phis_description_string:SetPoint('TOPLEFT', phis_title_string, 'BOTTOMLEFT', 0, -10)
	phis_description_string:SetJustifyH('LEFT')
	phis_description_string:SetWidth(InterfaceOptionsFramePanelContainer:GetWidth() - 40)
	phis_description_string:SetNonSpaceWrap(true)
	phis_description_string:SetText(GetAddOnMetadata('phisHideUI','Notes'))

	local phis_button_pettracking = CreateFrame('CheckButton', 'phisButtonPetTracking', phis_options, 'UICheckButtonTemplate')
	phis_button_pettracking:SetPoint('TOPLEFT', phis_description_string, 'BOTTOMLEFT', 0, -10)
	phis_button_pettracking.tooltip = 'Check to enable automatic hiding of the pet tracking icons on UI hide'
	_G['phisButtonPetTrackingText']:SetText(' Pet tracking icons')
	_G['phisButtonPetTrackingText']:SetFontObject('GameFontNormal')
	
	local phis_button_chatbubbles = CreateFrame('CheckButton', 'phisButtonChatbubbles', phis_options, 'UICheckButtonTemplate')
	phis_button_chatbubbles:SetPoint('TOPLEFT', phis_button_pettracking, 'BOTTOMLEFT', 0, -10)
	phis_button_chatbubbles.tooltip = 'Check to enable automatic hiding of chat bubbles on UI hide'
	_G['phisButtonChatbubblesText']:SetText(' Chat bubbles')
	_G['phisButtonChatbubblesText']:SetFontObject('GameFontNormal')
	
	
	local phis_button_unitnames = CreateFrame('CheckButton', 'phisButtonUnitNames', phis_options, 'UICheckButtonTemplate')
	phis_button_unitnames:SetPoint('TOPLEFT', phis_button_chatbubbles, 'BOTTOMLEFT', 0, -10)
	phis_button_unitnames.tooltip = 'Check to enable automatic hiding of unit names on UI hide'
	_G['phisButtonUnitNamesText']:SetText(' Unit names')
	_G['phisButtonUnitNamesText']:SetFontObject('GameFontNormal')
	
	-- -- save to saved variables on 'Okay'
	-- function phis_options.okay()
		-- phisHideUISavedVars['phis_toggle_pettracking'] = phis_button_pettracking:GetChecked()
		-- print(phis_button_pettracking:GetChecked())
	-- end
	
	-- -- discard changes on 'Cancel' (or Escape)
	-- function phis_options.cancel()
		-- phis_aux_copy_table(temp_settings, phisHideUISavedVars)
	-- end
end)

-------------------------
--        EVENTS       --
-------------------------

-- to check if the player left combat to automatically restore non-restored names
phis_f:RegisterEvent('PLAYER_REGEN_ENABLED')

-- to update the saved variables
phis_f:RegisterEvent('PLAYER_LOGIN')

-- register to OnShow/OnHide handlers
phis_f:SetScript('OnShow', phis_toggle_names_on)
phis_f:SetScript('OnHide', phis_toggle_names_off)
phis_f:SetScript('OnEvent', phis_auto_restore)
phis_f:SetScript('OnEvent', phis_update_config)