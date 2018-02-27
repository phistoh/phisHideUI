# phiHideUI
WoW addon which hides names/chat bubbles/pet tracking icons when hiding the interface

## Usage
This addon automatically hides (and restores) names/chat bubbles/pet tracking icons when the UIParent frame is hidden. When the UI gets hidden out of combat and shown again in combat, the names will be restored automatically after the combat ends.

## File Description
- **phiHideUI.lua** contains the main code
- **phiHideUI.toc** is the standard WoW table-of-contents file containing addon information

## Changes
- **1.1**: Only sets cvars out of combat
- **1.0**: Initial upload

## To-Do
- [x] Check if all names are hidden
- [ ] Check if only specific cvars are not settable in combat (so no combat check is needed)
- [ ] Automatically change graphics settings
- [ ] Options page in Blizzard addons settings (hide/show names, pet tracking, chat bubbles, graphics settings (potentially))