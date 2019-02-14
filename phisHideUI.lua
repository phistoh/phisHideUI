-- v1.3: Includes graphics settings
-- v1.2: Includes options to change what to toggle on UI hide
-- v1.1: Only sets cvars out of combat
-- v1.0: Initial upload

local addonName, phis = ...

local names_to_toggle = {}
local graphics_settings = {}
local pettracking = false
local names_not_restored = false

-- used to bind scripts and watch status of UI (shown/hidden)
local f = CreateFrame('Frame', 'phisCheckFrame', UIParent)

-------------------------
--   ADDON FUNCTIONS   --
-------------------------

-- extra function to implement slash command for a macro
local function toggle_graphics(high_quality)
	if high_quality then
		for k,v in pairs(phis.graphics) do
			graphics_settings[k] = GetCVar(k)
			-- phisHideUISavedVars['Backup graphics'] = phis.deep_copy(graphics_settings, phisHideUISavedVars['Backup graphics'])
			SetCVar(k,v)
		end
		
		if phisHideUISavedVars['Supersampling'] then
			graphics_settings['renderscale'] = GetCVar('renderscale')
			SetCVar('renderscale', 2)
		end
		
		if phisHideUISavedVars['Anti aliasing'] then
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
			SetCVar(k,v) = graphics_settings[k]
		end
		
		if phisHideUISavedVars['Supersampling'] then
			SetCVar('renderscale', graphics_settings['renderscale'])
		end
		
		if phisHideUISavedVars['Anti aliasing'] then
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
	if phisHideUISavedVars['Unit names'] then
		for k,v in pairs(phis.unitnames) do
			-- GetCVar returns a string and not a number
			if GetCVar(v) == '1' then
				table.insert(names_to_toggle, v)
				SetCVar(v,0)
			end
		end
	end
	
	--- CHAT BUBBLES ---
	if phisHideUISavedVars['Chat bubbles'] then
		for k,v in pairs({'chatBubbles','chatBubblesParty'}) do
			-- GetCVar returns a string and not a number
			if GetCVar(v) == '1' then
				table.insert(names_to_toggle, v)
				SetCVar(v,0)
			end
		end
	end
	
	--- PET TRACKING ICONS ---
	if phisHideUISavedVars['Pet tracking icons'] then
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
	if phisHideUISavedVars['Graphics settings'] then
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
	if phisHideUISavedVars['Pet tracking icons'] and pettracking then
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
	if phisHideUISavedVars['Graphics settings'] then
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

local options = CreateFrame('Frame', 'phisOptionsFrame', InterfaceOptionsFramePanelContainer)
options.name = GetAddOnMetadata(addonName,'Title')
InterfaceOptions_AddCategory(options)
options:SetScript('OnShow', function()

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
	description_string:SetText(GetAddOnMetadata(addonName,'Notes'))
	
	local checkboxes = {}
	local current_anchor = description_string
	for k in pairs(phis.defaults) do
		local checkbox = CreateFrame('CheckButton', k..'CheckButton', options, 'UICheckButtonTemplate')
		checkbox:SetPoint('TOPLEFT', current_anchor, 'BOTTOMLEFT', 0, -10)
		checkbox:SetChecked(phisHideUISavedVars[k])
		_G[k..'CheckButtonText']:SetText(k)
		_G[k..'CheckButtonText']:SetFontObject('GameFontNormal')
		checkbox:SetScript('OnClick', function()
			-- when 'OnClick' runs, GetChecked() already returns the new status
			checked = checkbox:GetChecked()
			PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
			phisHideUISavedVars[k] = checked
		end)
		
		current_anchor = checkbox
		checkboxes[k] = checkbox
	end
	
	function options.default()
		for k in pairs(phis.defaults) do
			checkboxes[k]:SetChecked(phisHideUISavedVars[k])
		end
	end
	
	-- -- save to saved variables on 'Okay'
	-- function options.okay()
		-- phisHideUISavedVars['toggle_pettracking'] = button_pettracking:GetChecked()
		-- print(button_pettracking:GetChecked())
	-- end
	
	-- -- discard changes on 'Cancel' (or Escape)
	-- function options.cancel()
		-- aux_copy_table(temp_settings, phisHideUISavedVars)
	-- end
	
	-- -- 
	-- function options.refresh()
	
	-- end
end)

-------------------------
--    SLASH COMMANDS   --
-------------------------

SLASH_PHUI1 = '/phishideui'
SLASH_PHUI2 = '/phide'
SLASH_PHUI3 = '/phui'

SlashCmdList['PHUI'] = function(msg)
	graphics_quality_flag = false
	if msg:lower() == 'options' or msg:lower() == 'config' then
		-- first call opens addon options menu, second call switches to the actual panel
		InterfaceOptionsFrame_OpenToCategory(addonName)
		InterfaceOptionsFrame_OpenToCategory(addonName)
	elseif msg:lower() == 'graphics' then
		graphics_quality_flag = not graphics_quality_flag
		toggle_graphics(graphics_quality_flag)
		print('Graphics set to '..(graphics_quality_flag and 'high' or 'default')..'.')
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