# ConsolePortLK Enhanced

**Controller gameplay for World of Warcraft: Wrath of the Lich King 3.3.5a.**

An enhanced fork of [leoaviana’s ConsolePortLK](https://github.com/leoaviana/ConsolePortLK), based on release **1.5.0-rc2**. It retains the original controller interface and adds improvements to cooldown displays, action-bar layouts, settings navigation, and saved layout preferences. ConsolePortLK itself backports [Sebastian Lindfors’s ConsolePort](https://github.com/seblindfors/ConsolePort) 1.9.17.

This fork is maintained by [SuttonX](https://github.com/SuttonX). Please report Enhanced-specific issues here rather than to the original ConsolePort project. Original authorship and the Artistic License 2.0 are preserved.

> **Publication candidate:** Enhanced 1.0.0-rc1, based on development build v161. The main gameplay improvements were tested in game; v161’s final Orthodox optional-button geometry adjustment has not yet received an in-game test. See [testing status](TESTING.md).

## Controller mapper required

ConsolePortLK Enhanced is **intended to be used with [WoWPadX](https://github.com/leoaviana/WoWpadX)**, the SDL-based controller-to-keyboard/mouse mapper linked by the original ConsolePortLK project. WoW 3.3.5a does not provide the modern native controller input expected by newer addons.

Another mapper, such as Steam Input or GameNative’s keyboard/mouse mapping, may also work if it produces the same inputs and you calibrate the addon accordingly. These alternatives were not independently tested for this release. Run one mapper at a time to avoid duplicate input.

### Tested configuration and compatibility

**Development and in-game testing used an Xbox controller with LT and RT—the rear triggers—configured as the two modifiers.** In the recommended mapping below, LT holds Left Shift and RT holds Left Ctrl.

The improvements use shared addon code and are expected to work with other supported controller presets and WoWPadX modifier selections as well. Other controller hardware and every modifier combination have not been individually tested. If something behaves differently, please [report an issue](https://github.com/SuttonX/ConsolePortLK-Enhanced/issues) and include your controller, selected controller preset, mapper and version, modifier assignments, action-bar layout, client version, and steps to reproduce it. Screenshots and Lua errors help with display or navigation problems.

### Xbox mapping for another input mapper

This table reproduces WoWPadX’s **triggers-as-modifiers** profile, matching the Xbox configuration used during development. It is a physical-input mapping, not a list of the in-game actions assigned to those inputs. Calibrate with `/cp recalibrate` after selecting this profile or changing mapper settings.

| Xbox control | Keyboard or mouse output |
| --- | --- |
| A | F11 |
| B | F10 |
| X | F12 |
| Y | F9 |
| D-pad up | F1 |
| D-pad right | F2 |
| D-pad down | F3 |
| D-pad left | F4 |
| View / Back (SELECT) | F5 |
| Menu / Start (START) | F6 |
| LB, left bumper | F7 |
| RB, right bumper | F8 |
| LT, left rear trigger | Hold **Left Shift** |
| RT, right rear trigger | Hold **Left Ctrl** |
| Left stick movement | WASD |
| Left stick click, L3 | Left mouse button |
| Right stick movement | Mouse movement |
| Right stick click, R3 | Right mouse button |
| Xbox / Guide button, if exposed to the mapper | Numpad multiply (`*`) |
| Share / capture button (newer Xbox controllers), if exposed as Misc1 | Numpad add (`+`) |
| Elite right paddle 1, if exposed independently | Numpad 0 |
| Elite right paddle 2, if exposed independently | Numpad 1 |
| Elite left paddle 1, if exposed independently | Numpad 2 |
| Elite left paddle 2, if exposed independently | Numpad 3 |

Use ordinary held inputs: pressing a trigger sends modifier-down, releasing it sends modifier-up. Holding both triggers must produce **Shift + Ctrl** simultaneously. Avoid toggle or turbo mode for movement, modifiers, and stick clicks. Map the right stick to relative mouse movement and give both sticks an appropriate dead zone.

Numpad multiply and add are distinct from typing `Shift+8` or `Shift+=`. View / Back is the button commonly called SELECT; Menu / Start is START. The Share button is a separate screenshot/video capture button on newer Xbox controllers, not SELECT. Guide/Share availability depends on the controller and operating system. Many Elite configurations expose paddles as duplicates of existing buttons; the separate paddle outputs above apply only when the mapper can see independent paddle inputs. Standard Xbox controllers do not have paddles.

**Optional 16-way movement:** WoWPadX additionally sends H for the horizontal-dominant intermediate diagonal sectors and V for the vertical-dominant sectors. These are supplementary sector outputs, not replacements for WASD. A basic eight-direction WASD setup can omit them; match the addon’s movement configuration to the mapper’s capabilities. WoWPadX’s automatic walk/run handling uses additional feedback logic, so copying the physical mappings does not reproduce every WoWPadX feature.

WoWPadX also supports other modifier profiles:

| Modifier profile | LB | RB | LT | RT |
| --- | --- | --- | --- | --- |
| Left shoulder + left trigger (WoWPadX’s default profile) | Left Shift | F7 | Left Ctrl | F8 |
| **Both triggers: tested/recommended here** | F7 | F8 | Left Shift | Left Ctrl |
| Right shoulder + right trigger | F7 | Left Shift | F8 | Left Ctrl |
| Both shoulders | Left Shift | Left Ctrl | F7 | F8 |

The trigger profile above is our tested configuration; it is **not** WoWPadX’s factory-default modifier selection. Recalibrate whenever changing profiles. Optional L1/R1 bar indicators retain the original addon’s modifier-label behavior; their captions can reflect the configured modifiers rather than literally naming Xbox bumpers.

Mapping sources: [WoWPadX KeybindDefaults.h](https://github.com/leoaviana/WoWpadX/blob/4c435e0c6a9247fe50dc0dac0f23796058393c4a/WoWpadX/KeybindDefaults.h) and [InputMapper.cpp](https://github.com/leoaviana/WoWpadX/blob/4c435e0c6a9247fe50dc0dac0f23796058393c4a/WoWpadX/InputMapper.cpp). These links pin the inspected version so the documented mappings remain traceable.

## Improvements

- Readable cooldown numbers with urgency colors and sizing that follows the action button. Cooldown text and swipes refresh across action pages and modifier layers.
- Minimal-layout cooldown satellites filter short global cooldowns, update when modifier layers change, and restore their normal labels when a cooldown expires.
- Triple-layout wings track their own modifier actions and retain their layout geometry.
- Layout-specific size, scale, and presentation preferences survive switching layouts and logging out.
- Settings opens on General initially, remembers the current subsection within a session, and restores it when returning from Bindings or reopening the panel.
- The integrated Action Bars editor remains populated. Saving settings uses the final difference from the loaded state to decide whether a reload is required; reverting an edit before saving does not itself require a reload.
- Optional bar-button checkbox behavior follows the original addon’s presence/absence contract; optional indicators start unchecked on a fresh configuration.
- Shared fixes apply across controller presets. Controller artwork is retained from the official release.
- Binding updates avoid redundant writes, and callback/nameplate updates avoid unnecessary repeated work. No independent performance benchmark is claimed.
- Optional integration lets ConsolePort’s interface cursor select [FormFreedom](https://github.com/SuttonX/FormFreedom) menu helpers without leaving the displayed bar stuck on a modifier layer.

See [CHANGELOG.md](CHANGELOG.md) for the retained changes and [UPSTREAM-CHANGES.md](UPSTREAM-CHANGES.md) for the complete source-file inventory and review notes.

## Installation

1. Download the install ZIP attached to this fork’s GitHub release. GitHub’s automatic “Source code” ZIP contains a repository parent folder; it is not the ready-to-install archive.
2. Extract the eight addon folders into `World of Warcraft/Interface/AddOns/`: `ConsolePort`, `ConsolePortAdvanced`, `ConsolePortBar`, `ConsolePortHelp`, `ConsolePortKeyboard`, `ConsolePortLoader`, `ConsolePortUI_Loot`, and `ConsolePortUI_Menu`.
3. Install and start [WoWPadX](https://github.com/leoaviana/WoWpadX), connect your controller, and select your modifier profile.
4. Restart the client, enable the modules you need, select your controller preset, and complete calibration.

**Upgrading from our previous development build: keep SavedVariables; restart the client after installing this package.** Keep a backup of your existing settings. This fork replaces the same eight addon folders as ConsolePortLK; do not install a second renamed copy alongside them. The optional on-screen keyboard is disabled by default on a fresh configuration.

### Optional druid form support

Install [FormFreedom](https://github.com/SuttonX/FormFreedom) separately if you want automatic form cancellation for its supported interactions. FormFreedom works independently on desktop and alongside ConsolePortLK. Its cancellation logic is not bundled into Enhanced; the integration here supports controller selection and correct bar-state reconciliation.

## Commands

| Command | Purpose |
| --- | --- |
| `/cp` | List addon commands |
| `/cp config` | Open settings |
| `/cp actionbar` | Configure the controller action bar |
| `/cp help` | Open help and tutorials |
| `/cp recalibrate` | Recalibrate controller inputs |
| `/cp type` | Change controller type |
| `/cp cvar` | Inspect console variables; advanced use |
| `/cp resetall` | Reset addon settings; irreversible |

## Client and platform notes

The tested target is **WotLK 3.3.5a**. A client identifying itself as 3.3.5 may be the normal 3.3.5a client build; compatibility with a separately different 3.3.5 client has not been independently established. Modified client APIs and custom server behavior can affect compatibility.

For Steam Deck/Proton/Wine, consult the [original ConsolePortLK setup guidance](https://github.com/leoaviana/ConsolePortLK#readme). WoWPadX and WoW may need to run in the same Wine/Proton prefix. A Steam keyboard/mouse layout is an alternative when the mapper cannot attach to the game, but the alternative configuration still needs calibration.

## Credits and license

- [Sebastian Lindfors / seblindfors](https://github.com/seblindfors/ConsolePort): original ConsolePort.
- [Leandro Araujo / leoaviana](https://github.com/leoaviana/ConsolePortLK): ConsolePortLK backport and [WoWPadX](https://github.com/leoaviana/WoWpadX).
- dan-schales: binding-update optimization included through the upstream contribution documented in the development history.
- [SuttonX](https://github.com/SuttonX): Enhanced development, runtime testing, and maintenance.

Distributed under the existing [Artistic License 2.0](LICENSE). This fork is not affiliated with Blizzard or the original ConsolePort project.
