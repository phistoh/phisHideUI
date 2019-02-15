local addonName, phis = ...

-- default options
phis.defaults = {
	-- ['Chat bubbles'] = true,
	-- ['Pet tracking icons'] = true,
	-- ['Unit names'] = true,
	-- ['Graphics settings'] = false,
	-- ['Supersampling'] = false,
	-- ['Anti aliasing'] = false,
	chatbubbles = true,
	pettracking_icons = true,
	unitnames = true,
	graphics_settings = false,
	supersampling = false,
	anti_aliasing = false,
}

phis.unitnames = {
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
}

phis.graphics = {
	['graphicsTextureFiltering'] = 6, -- 16x anisotropic texture filtering
	['graphicsProjectedTextures'] = 2, -- Enable projected textures
	['graphicsViewDistance'] = 10, -- Maximum view distance
	['graphicsEnvironmentDetail'] = 10, -- Maximum environment detail
	['graphicsGroundClutter'] = 10, -- Maximum ground clutter (corresponds to groundEffectDist = 320; in theory could be up to 500)
	['graphicsShadowQuality'] = 6, -- Ultra high shadows
	['graphicsLiquidDetail'] = 4, -- Ultra liquid detail
	['graphicsParticleDensity'] = 5, -- Ultra particle density
	['graphicsSSAO'] = 5, -- Ultra screen space ambient occlusion (SSAO)
	['graphicsDepthEffects'] = 4, -- High depth effects
	['graphicsLightingQuality'] = 3, -- High lighting quality
	['ffxGlow'] = 1, -- Enable special effects (bloom, fog, ...)
}