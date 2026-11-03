# 3.3.5a compatibility audit, 2026-11-03

Base: origin/master ee6c61a179b101b898c99708ded2f368961b7052.  Includes all pending layout changes.

## Fixed in this test build

- Existing Crossbar Triple profiles migrate LB/RB and enabled L1/R1 to the requested shoulder coordinates once.  Unchecked buttons remain unchecked; fresh defaults supply their revised coordinates when enabled.

- Equipped-item indicators now follow square button geometry in square layouts.  Round layouts restore their original indicator texture.
- Empty action slots clear main and Triple shim checked overlays.
- Simulated UI presses release the original pressed widget when focus changes.  Hiding or clearing the input button also releases that visual state.
- Bag quick-bind exclusions compare inventory tokens rather than localized labels.  Uncached stack information no longer causes a nil comparison.
- Direct spell buttons resolve spellbook slots on stock Wrath without relying on FindSpellBookSlotBySpellID.  Missing GetSpellCount returns zero rather than calling nil.
- Level-cap menu color fallback returns RGB numbers instead of a color table.
- Loot menu animation uses the addon-local CPAPI reference.  Loot quality styling uses the bundled mask instead of retail SetAtlas and loot atlas globals.  The disenchant hint uses the circle binding that actually performs that action.
- Talent menu event registration uses Wrath talent/group/point events instead of retail specialization, honor, and character-upgrade events.

## Automated checks

- All 128 Lua files compile with Lua 5.1, including the existing Lua tests.
- All 19 XML files are well-formed.  All 141 declared TOC/XML script/include paths exist.
- Existing callback, UI tracking, cursor geometry, and talent lookup regressions pass.
- tests/audit-compat.py exercises production code chunks for input cancellation, item tokens/cache misses, spellbook lookup, empty overlays, square/round equipped indicators, class-bar offsets, every Minimal migration version, RGB fallback, and loot menu animation/quality updates.
- ZIP CRC, eight top-level addon directories, and packaged bytes are checked against the working source.
- Native reference: tekkub/wow-ui-source tag 3.3.5, especially MultiCastActionBarFrame.lua, Constants.lua, Blizzard_TalentUI, and UI.xsd.

## Limits and follow-up validation

This is a source audit with mocked regressions, not execution inside the WoW client.  It does not establish that every gameplay path is error-free.

The original Wrath XML schema still flags existing retail-era template metadata, including mixin, textureSubLevel, atlas, MaskTexture, and animation/script attributes.  Well-formed XML is not equivalent to full Wrath schema compliance.  These were recorded rather than mechanically deleted: several templates have Lua-side initialization or replacement rendering, and wholesale removal could change working visuals.  Their actual load warnings and unused animation paths need client verification before a broad template conversion.

Priority in-game checks: engineering cloak/boots in Minimal LB/RB, square-to-round layout switching, hover/click release while changing focus/modifiers, removing an active action, bag menu on uncached items, level-80 menu, group loot need/greed/disenchant/pass, druid forms with LT held, and shaman native totem flyouts/pages plus vehicle/combat transitions.  Combat taint and secure execution cannot be established by these mocks.

SavedVariables: KEEP.  Client: /reload.  Packaged for release 1.0.8.
