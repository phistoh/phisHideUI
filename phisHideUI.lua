-- v1.3: Includes graphics settings
-- v1.2: Includes options to change what to toggle on UI hide
-- v1.1: Only sets cvars out of combat
-- v1.0: Initial upload

local addonName, phis = ...

local names_to_toggle = {}
local graphics_settings = {}
local pettracking = false
local names_not_restored = false
local graphics_quality_flag = false

local DESCRIPTION_LONG = "The addon hides all currently displayed unit names, chat bubbles and pet tracking icons when hiding the UI (e.g. with '|cFF40C7EBAlt-Z|r'). It also includes an option to automatically switch the graphics settings to high quality (with optional supersampling) when the UI is hidden. The addon saves the current CVar values (for unit names, chat bubbles and graphics settings) on first login (or manually via slash command) to make it possible to restore the values even when the game gets closed before showing the UI again.|nUsage: '|cFF40C7EB/phishideui config|r' to open the options panel, '|cFF40C7EB/phishideui graphics|r' to manually toggle between high and default graphics, '|cFF40C7EB/phishideui backup restore|r' to restore the CVar values from the saved variables and '|cFF40C7EB/phishideui backup overwrite|r' to overwrite the backup with the current CVar values.|nAlternative slash commands: '|cFF40C7EB/phide|r' and '|cFF40C7EB/phui|r'"

-- used to bind scripts and watch status of UI (shown/hidden)
local f = CreateFrame('Frame', 'phisCheckFrame', UIParent)

-------------------------
--   ADDON FUNCTIONS   --
-------------------------

-- saves the current state of all relevant cvars in a table and returns it
local function backup_cvars()
	local settings = {}
	for k,v in pairs(phis.unitnames) do
		settings[v] = GetCVar(v)
	end
	for k,v in pairs(phis.graphics) do
		settings[k] = GetCVar(k)
	end
	for k,v in pairs({'chatBubbles','chatBubblesParty'}) do
		settings[v] = GetCVar(v)
	end
	return settings
end

-- overwrites relevant cvars with those stored in the saved variables
local function restore_backup()
	if (phisHideUISavedVars.cvarbackup == nil) then
		print('No backup for CVars found...')
	else
		for k,v in pairs(phisHideUISavedVars.cvarbackup) do
			SetCVar(k,v)
		end
		print('CVar backup restored')
	end
end

-- used in a slash command
local function overwrite_backup()
	phisHideUISavedVars.cvarbackup = backup_cvars()
	print('Backup overwritten with current CVars')
end

-- extra function to implement slash command for a macro
local function toggle_graphics(high_quality)
	if high_quality then
		for k,v in pairs(phis.graphics) do
			graphics_settings[k] = GetCVar(k)
			SetCVar(k,v)
		end
		
		if phisHideUISavedVars.supersampling then
			graphics_settings['renderscale'] = GetCVar('renderscale')
			SetCVar('renderscale', 2)
		end
		
		if phisHideUISavedVars.anti_aliasing then
			graphics_settings['MSAAQuality'] = GetCVar('MSAAQuality')
			graphics_settings['MSAAAlphaTest'] = GetCVar('MSAAAlphaTest')
			graphics_settings['ffxAntiAliasingMode'] = GetCVar('ffxAntiAliasingMode')
			-- don't use MSAA when (SSAA) super sampling is active
			if tonumber(GetCVar('renderscale')) <= 1 then
				SetCVar('MSAAQuality', 3)
				SetCVar('MSAAAlphaTest', 1)
			end
			SetCVar('ffxAntiAliasingMode', 3) -- 3 is CMAA
		end
	else
		for k,v in pairs(phis.graphics) do
			SetCVar(k,graphics_settings[k])
		end
		
		if phisHideUISavedVars.supersampling then
			SetCVar('renderscale', graphics_settings['renderscale'])
		end
		
		if phisHideUISavedVars.anti_aliasing then
			SetCVar('MSAAQuality', graphics_settings['MSAAQuality'])
			SetCVar('MSAAAlphaTest', graphics_settings['MSAAAlphaTest'])
			SetCVar('ffxAntiAliasingMode', graphics_settings['ffxAntiAliasingMode'])
		end
	end
end

-- toggles off all currently displayed names; doesn't change settings of currently hidden names
-- also stores all currently displayed options before hiding to restore them later on
local function toggle_names_off()
	-- don't change cvars in combat (because of potential taint)
	-- don't toggle names off which are still hidden (because this would overwrite the user's settings)
	if UnitAffectingCombat('player') or names_not_restored then
		return
	end
	
	--- UNIT NAMES ---
	if phisHideUISavedVars.unitnames then
		for k,v in pairs(phis.unitnames) do
			-- GetCVar returns a string and not a number
			if GetCVar(v) == '1' then
				table.insert(names_to_toggle, v)
				SetCVar(v,0)
			end
		end
	end
	
	--- CHAT BUBBLES ---
	if phisHideUISavedVars.chatbubbles then
		for k,v in pairs({'chatBubbles','chatBubblesParty'}) do
			-- GetCVar returns a string and not a number
			if GetCVar(v) == '1' then
				table.insert(names_to_toggle, v)
				SetCVar(v,0)
			end
		end
	end
	
	--- PET TRACKING ICONS ---
	if phisHideUISavedVars.pettracking_icons then
		-- iterates through all trackable things to find battle pet tracking
		for i=1,GetNumTrackingTypes() do
			-- a is 1 if the tracking is active, else it is nil
			n, _, a = GetTrackingInfo(i)
			if n == 'Track Pets' and a then
				pettracking = true
				SetTracking(i, false)
				break
			elseif n == 'Track Pets' and not a then
				pettracking = false
				break
			end
		end
	end
	
	--- GRAPHICS SETTINGS -- 
	if phisHideUISavedVars.graphics_settings then
		toggle_graphics(true)
	end
end

-- toggles on all previously displayed names; doesn't change settings of previously hidden names
local function toggle_names_on()
	-- don't change cvars in combat (because of potential taint) but remember to restore them after combat
	if UnitAffectingCombat('player') then
		names_not_restored = true
		return
	end

	--- UNIT NAMES & CHAT BUBBLES ---
	for k,v in pairs(names_to_toggle) do
		SetCVar(v,1)
	end
	names_to_toggle={}
	
	--- PET TRACKING ICONS ---
	if phisHideUISavedVars.pettracking_icons and pettracking then
		for i=1,GetNumTrackingTypes() do
			n = GetTrackingInfo(i)
			if n == 'Track Pets' then
				SetTracking(i, true)
				pettracking = false
				break
			end
		end
	end
	
	--- GRAPHICS SETTINGS -- 
	if phisHideUISavedVars.graphics_settings then
		toggle_graphics(false)
	end
end

-- makes sure that all valid entries (see phis.defaults) are present in the saved variables
local function update_config(self, event)
	if event == 'PLAYER_LOGIN' then
		-- first time loading the addon
		if not phisHideUISavedVars then
			print(GetAddOnMetadata(addonName,'Title')..' v'..GetAddOnMetadata(addonName,'Version')..' loaded for the first time.')
			phisHideUISavedVars = {}
			phisHideUISavedVars.cvarbackup = backup_cvars()
		end
		for k,v in pairs(phis.defaults) do
			if phisHideUISavedVars[k] == nil then
				-- deep copy instead of copying the reference
				if type(v) == 'table' then
					phisHideUISavedVars[k] = {}
					phisHideUISavedVars[k] = phis.deep_copy(v, phisHideUISavedVars[k])
				else
					phisHideUISavedVars[k] = v
				end
			end
		end
	end
end

-- restores all names after combat ends and clears the names_not_restored flag
local function auto_restore(self, event)
	if event == 'PLAYER_REGEN_ENABLED' and names_not_restored then
		names_not_restored = false
		toggle_names_on()
	end
end

-------------------------
--    OPTIONS PANEL    --
-------------------------

-- creates a checkbox 10 px below 'anchor' and stores its state in phisHideUISavedVars[k]
local function create_checkbox(k, parent, anchor, text)
	local checkbox = CreateFrame('CheckButton', k..'CheckButton', parent, 'UICheckButtonTemplate')
	checkbox:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, -10)
	checkbox:SetChecked(phisHideUISavedVars[k])
	_G[k..'CheckButtonText']:SetText(' '..text)
	_G[k..'CheckButtonText']:SetFontObject('GameFontNormal')
	checkbox:SetScript('OnClick', function()
		-- when 'OnClick' runs, GetChecked() already returns the new status
		checked = checkbox:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		phisHideUISavedVars[k] = checked
	end)
	
	return checkbox
end

local options = CreateFrame('Frame', 'phisOptionsFrame', InterfaceOptionsFramePanelContainer)
options.name = GetAddOnMetadata(addonName,'Title')
InterfaceOptions_AddCategory(options)
options:SetScript('OnShow', function()

	--- HEADER --
	local title_string = options:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	title_string:SetPoint('TOPLEFT', 10, -10)
	title_string:SetText(GetAddOnMetadata(addonName,'Title'))
	
	local version_string = options:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	version_string:SetPoint('BOTTOMLEFT', title_string, 'BOTTOMRIGHT', 4, 0)
	version_string:SetText('v'..GetAddOnMetadata(addonName,'Version'))
	
	local description_string = options:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	description_string:SetPoint('TOPLEFT', title_string, 'BOTTOMLEFT', 0, -10)
	description_string:SetJustifyH('LEFT')
	description_string:SetWidth(InterfaceOptionsFramePanelContainer:GetWidth() - 40)
	description_string:SetNonSpaceWrap(true)
	description_string:SetText(DESCRIPTION_LONG)
	
	--- CHECKBOXES ---
	local checkboxes = {}
	checkboxes.unitnames = create_checkbox('unitnames', options, description_string, 'Unit names')
	checkboxes.chatbubbles = create_checkbox('chatbubbles', options, checkboxes.unitnames, 'Chat bubbles')
	checkboxes.pettracking_icons = create_checkbox('pettracking_icons', options, checkboxes.chatbubbles, 'Battle pet tracking icons')
	checkboxes.graphics_settings = create_checkbox('graphics_settings', options, checkboxes.pettracking_icons, 'High quality graphics settings')
	checkboxes.anti_aliasing = create_checkbox('anti_aliasing', options, checkboxes.graphics_settings, 'Anti aliasing (MSAA + CMAA)')
	checkboxes.supersampling = create_checkbox('supersampling', options, checkboxes.anti_aliasing, 'Supersampling (2x)')
	
	function options.default()
		for k,v in pairs(phis.defaults) do
			phisHideUISavedVars[k] = v
			checkboxes[k]:SetChecked(phisHideUISavedVars[k])
		end
	end
	
	function options.refresh()
		for k in pairs(phis.defaults) do
			checkboxes[k]:SetChecked(phisHideUISavedVars[k])
		end
		if not phisHideUISavedVars.graphics_settings then
			checkboxes.anti_aliasing:Disable()
			checkboxes.anti_aliasing:SetAlpha(0.5)
			checkboxes.supersampling:Disable()
			checkboxes.supersampling:SetAlpha(0.5)
		else
			checkboxes.anti_aliasing:Enable()
			checkboxes.anti_aliasing:SetAlpha(1)
			checkboxes.supersampling:Enable()
			checkboxes.supersampling:SetAlpha(1)
		end
	end
	
	options:SetScript('OnShow', nil)
	options.refresh()
end)

-------------------------
--    SLASH COMMANDS   --
-------------------------

SLASH_PHUI1 = '/phishideui'
SLASH_PHUI2 = '/phide'
SLASH_PHUI3 = '/phui'

SlashCmdList['PHUI'] = function(msg)
	if msg:lower() == 'options' or msg:lower() == 'config' then
		-- first call opens addon options menu, second call switches to the actual panel
		InterfaceOptionsFrame_OpenToCategory(addonName)
		InterfaceOptionsFrame_OpenToCategory(addonName)
	elseif msg:lower() == 'graphics' then
		graphics_quality_flag = not graphics_quality_flag
		toggle_graphics(graphics_quality_flag)
		print('Graphics set to '..(graphics_quality_flag and 'high' or 'default')..'.')
	elseif msg:lower() == 'backup restore' then
		restore_backup()
	elseif msg:lower() == 'backup overwrite' then
		overwrite_backup()
	else
		print(GetAddOnMetadata(addonName,'Title')..' v'..GetAddOnMetadata(addonName,'Version'))
		print('Toggle between graphics settings with /phui graphics')
	end	
end

-------------------------
--        EVENTS       --
-------------------------

-- to check if the player left combat to automatically restore non-restored names
f:RegisterEvent('PLAYER_REGEN_ENABLED')

-- to update the saved variables
f:RegisterEvent('PLAYER_LOGIN')

-- register to OnShow/OnHide handlers
f:SetScript('OnShow', toggle_names_on)
f:SetScript('OnHide', toggle_names_off)
f:SetScript('OnEvent', auto_restore)
f:SetScript('OnEvent', update_config)