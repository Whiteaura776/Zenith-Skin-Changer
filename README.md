# Zenith Skin Changer

**by ZenithDev** · Rivals (Roblox) · cosmetic only · no key · v7.00

A skin changer and wrap changer for **Rivals**. It only changes how your weapons look **on your own screen**. Nobody else sees it.

> **No aimbot, no auto-damage, no speed / jump / fly, no teleport, no kill aura.**
> **No key system, no account, no webhooks, no telemetry.** It never sends anything anywhere.

## What it does

- **Skin changer.** Pick any skin for the weapon in your hand, even skins from another weapon of the same kind. 3D preview, opacity slider, original sounds of the skin.
- **Wrap changer.** Put any wrap on your weapon (materials and animated wraps), with a preview. You can also invert the wrap.
- **Custom skins made by hand** (they do not exist in the game):

| Weapon | Custom skin |
|---|---|
| Assault Rifle | **SCAR** (with its own sight and sound) |
| Wildcat | **Combat SMG** (double magazine) |
| Shotgun | **Pump Shotgun** |
| Uzi | **Mac-10** |
| Energy Pistols / Revolver | **Golden Desert Eagles** |
| Scythe | **Death Sickle** |
| Katana | **Terra Blade**, **Diamond Sword** |
| Spear | **Diamond Spear** |
| Battle Axe | **Stormbreaker** |
| Daggers | **Loki's Daggers** |
| Riot Shield | **Captain America's Shield** |
| Grappler | **Web Shooter** (red wrist device and a web rope) |
| Molotov | **Potion of Harming** (Minecraft style, with red swirl particles and glass sounds) |

More custom skins are planned: suggest yours on Discord.

## How it works

It runs **only on your client**. When you pick a skin, the script hides the weapon model that the game gave you and puts the skin model in its place, using the animations and sounds of the game. Your choices are saved on your PC and come back the next time.

## Install

You need **Xeno** (or any executor with `writefile`, `readfile`, `getcustomasset` and `request`). Join Rivals and run this line:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Whiteaura776/Zenith-Skin-Changer/main/zenith_skin_changer_loader.lua"))()
```

The first time it downloads its files (about 50, ~2 MB) into your executor's `ZenithSkins/` folder. After that it only checks for updates. The window opens with the **`-`** key (press it again to shrink it to a small icon). It is a separate window from Zenith Sky Changer, so you can run both.

## Notes

- Use it at your own risk. Using an executor is against Roblox's rules, and Rivals can change what it detects. This only changes visuals, but **there is no guarantee**.
- The code is open and **not obfuscated**. Read it, it is all here.
- Kept **on your PC** (`ZenithSkins/` folder): your window position, the skins and wraps you chose, and debug logs (`*_log.txt`). Nothing leaves your computer.
- The skins are fan recreations of items from other games and shows (Fortnite, Terraria, Minecraft, Marvel...). The rights to those works belong to their owners, and so do their sounds. If a rights holder asks, it will be removed.
- Code under the MIT license (see `LICENSE`). Third-party audio, images and models are not covered by it.

Questions, bugs, skin ideas: **Discord** (link in the profile).
