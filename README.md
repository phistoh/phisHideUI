# phisHideUI
 A WoW addon which hides all currently displayed unit names, chat bubbles and pet tracking icons when hiding the UI (e.g. with 'Alt-Z'). It also includes an option to automatically switch the graphics settings to high quality (with optional supersampling) when the UI is hidden.

## Usage
This addon does its work automatically when the UIParent frame is hidden. When the UI gets hidden while the player is out of combat and shown again when the player is currently in combat, the names will be restored automatically after the combat ends. Additionally when logging in the first time, the addon saves the values of all relevant CVars in the saved variables file. This makes it possible to restore the CVar values when the game gets closed before showing the UI again. The addon provides multiple slash commands:
- `/phishideui config` opens the options panel
- `/phishideui graphics` toggles between high and default graphics
- `/phishideui backup restore` restores the CVar values (using the backup stored in the saved variables)
- `/phishideui backup overwrite` overwrites the CVar backup with the current CVar values

(The commands `/phide` and `/phui` can be used instead of `/phishideui`.)

## File Description
- **phisHideUI.lua** contains the main code
- **phisHideUI.toc** is the standard WoW table-of-contents file containing addon information
- **phisHideUI_Defaults.lua** contains tables with default values
- **phisHideUI_Utils.lua** contains miscellaneous auxiliary functions

## Changes
- **1.3.8**: Update for Chains of Domination (9.1.0) (new interface number)
- **1.3.7**: Update for Shadowlands (9.0.5) (new interface number)
- **1.3.6**: Setting to toggle ray traced shadows
- **1.3.5**: Update for Shadowlands pre-expansion patch (9.0.1) (new interface number)
- **1.3.4**: Update for BfA Visions of N'Zoth (8.3) (new interface number)
- **1.3.3**: Update for BfA Rise of Azshara (8.2) (new interface number)
- **1.3.2**: Settings for 'anti aliasing' and 'supersampling' are disabled when 'graphics settings' are not set
- **1.3.1**: Includes CVar `graphicsTextureResolution`
- **1.3**: Option to enhance graphics settings on UI hide
- **1.2**: Includes options to change what to toggle on UI hide (stored via WoW's saved variables)
- **1.1.2**: Update Interface number for BfA Tides of Vengeance (8.1)
- **1.1.1**: Update for BfA prepatch
- **1.1**: Only sets CVars out of combat
- **1.0**: Initial upload

## To-Do
- [x] Check if all names are hidden
- [ ] Check if only specific CVars are not settable in combat (so no combat check is needed)
- [x] Automatically change graphics settings
- [x] Options page in Blizzard addons settings (hide/show names, pet tracking, chat bubbles, graphics settings (potentially))
- [x] Save temporary variables in saved variable (to prevent losing settings on logging out in between hiding/showing UI)
- [ ] *(Maybe)* Check on login whether the CVar values correspond to the backup and nag the user about restoring or overwriting them
- [ ] *(Maybe)* Implement `okay` and `cancel` functions in the options panel instead of setting the variables on click