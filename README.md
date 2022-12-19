# phisHideUI
 A WoW addon which hides all currently displayed unit names, chat bubbles and pet tracking icons when hiding the UI (e.g. with 'Alt-Z'). It also includes an option to automatically switch the graphics settings to high quality (with optional supersampling) when the UI is hidden.

## Usage
This addon does its work automatically when the UIParent frame is hidden. When the UI gets hidden while the player is out of combat and shown again when the player is currently in combat, the names will be restored automatically after the combat ends. Additionally when logging in the first time, the addon saves the values of all relevant CVars in the saved variables file. This makes it possible to restore the CVar values when the game gets closed before showing the UI again. The addon provides multiple slash commands:
- `/phishideui config` opens the options panel
- `/phishideui graphics` toggles between high and default graphics
- `/phishideui backup restore` restores the CVar values (using the backup stored in the saved variables)
- `/phishideui backup overwrite` overwrites the CVar backup with the current CVar values

(The commands `/phide` and `/phui` can be used instead of `/phishideui`.)

## Screenshots
#### General Behaviour
![Behaviour](.github/phishideui.jpg?raw=true)

#### Enhancing graphics settings
![Enhancing graphics settings](.github/phui2.jpg?raw=true)

#### Options panel
![Options panel](.github/phui3.jpg?raw=true)

## File Description
- **phisHideUI.lua** contains the main code
- **phisHideUI.toc** is the standard WoW table-of-contents file containing addon information
- **phisHideUI_Defaults.lua** contains tables with default values
- **phisHideUI_Utils.lua** contains miscellaneous auxiliary functions

## To-Do
- [ ] Check if only specific CVars are not settable in combat (so no combat check is needed)
- [ ] *(Maybe)* Check on login whether the CVar values correspond to the backup and nag the user about restoring or overwriting them
- [ ] *(Maybe)* Implement `okay` and `cancel` functions in the options panel instead of setting the variables on click
