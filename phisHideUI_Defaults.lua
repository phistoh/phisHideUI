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
	['graphicsTextureFiltering'] = 5, -- 16x anisotropic texture filtering
	['graphicsTextureResolution'] = 3, -- High texture resolution
	['graphicsProjectedTextures'] = 1, -- Enable projected textures
	['graphicsViewDistance'] = 9, -- Maximum view distance
	['graphicsEnvironmentDetail'] = 9, -- Maximum environment detail
	['graphicsGroundClutter'] = 9, -- Maximum ground clutter (corresponds to groundEffectDist = 320; in theory could be up to 500)
	['graphicsShadowQuality'] = 5, -- Ultra high shadows
	['graphicsLiquidDetail'] = 3, -- Ultra liquid detail
	['graphicsParticleDensity'] = 5, -- Ultra particle density
	['graphicsSpellDensity'] = 5, -- Spell density: Everything
	['physicsLevel'] = 2, -- Player and NPC physics
	['graphicsSSAO'] = 2, -- FidelityFX CACAO
	['graphicsDepthEffects'] = 3, -- High depth effects
	['graphicsLightingQuality'] = 3, -- High lighting quality
	['graphicsComputeEffects'] = 4, -- Compute-based effects such as volumetric fog
	['ffxGlow'] = 1, -- Enable special effects (bloom, fog, ...)
	['sunShafts'] = 2, -- Sun shafts (no longer accesible in UI)
}