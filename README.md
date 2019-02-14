# phisHideUI
 A WoW addon which hides all currently displayed unit names, chat bubbles and pet tracking icons when hiding the UI (e.g. with 'Alt-Z'). It also includes an option to automatically switch the graphics settings to high quality (with optional supersampling) when the UI is hidden.

## Usage
This addon does its work automatically when the UIParent frame is hidden. When the UI gets hidden while the player is out of combat and shown again when the player is currently in combat, the names will be restored automatically after the combat ends. The addon provides two slash commands: `/phishideui config` to open the options panel and `/phishideui graphics` to manually toggle between high and default graphics. (The commands `/phide` and `/phui` can be used instead of `/phishideui`.)

## File Description
- **phisHideUI.lua** contains the main code
- **phisHideUI.toc** is the standard WoW table-of-contents file containing addon information
- **phisHideUI_Defaults.lua** contains tables with default values
- **phisHideUI_Utils.lua** contains miscellaneous auxiliary functions

## Changes
- **1.3**: Option to enhance graphics settings on UI hide
- **1.2**: Includes options to change what to toggle on UI hide (stored via WoW's saved variables)
- **1.1.2**: Update Interface number for BfA Tides of Vengeance (8.1)
- **1.1.1**: Update for BfA prepatch
- **1.1**: Only sets cvars out of combat
- **1.0**: Initial upload

## To-Do
- [x] Check if all names are hidden
- [ ] Check if only specific cvars are not settable in combat (so no combat check is needed)
- [x] Automatically change graphics settings
- [x] Options page in Blizzard addons settings (hide/show names, pet tracking, chat bubbles, graphics settings (potentially))
- [ ] Save temporary variables in saved variable (to prevent losing settings on logging out in between hiding/showing UI)