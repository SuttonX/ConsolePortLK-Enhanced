# Testing status

The development and runtime tests used an Xbox controller with LT/RT rear-trigger modifiers, on a WotLK 3.3.5a client. Minimal and Triple layouts, cooldown text/swipes, settings navigation, checkbox behavior, layout preference retention including logout/login, and FormFreedom coexistence were confirmed in game during development.

v153 is the locked restore point preceding the druid cancellation experiments. v160 restored that lineage with only the optional FormFreedom cursor/menu-state bridge; the user confirmed the shared setup worked. v161 adds the official Orthodox optional-button first-enable geometry (size 64, offsets 440/9). That last adjustment has source/audit validation but is not yet user-tested in game.

Other controller presets and all WoWPadX modifier choices have been compared against official source and share the changed implementation. This is not a hardware test of every controller or every modifier combination. Steam Input and GameNative configurations have not been independently tested.

A previously observed Prowl/stealth-break cooldown issue could no longer be reproduced. Barkskin cooldown text and swipe were confirmed after breaking stealth from both the base and modifier bar. This does not establish every possible enemy-caused stealth-break scenario.

Before marking this candidate a stable release, check Orthodox’s optional buttons on first enable. Report other-controller issues with controller preset, physical modifier assignments, mapper, bar layout, reproduction steps, and any Lua error.
