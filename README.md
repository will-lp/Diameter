# Diameter

A lightweight DPS meter addon for World of Warcraft.

- You can navigate between Modes, Group and Breakdown using right and left clicks.
- Multiple windows support. On version v2.3.0, with 4 open windows it was consuming 210 KB of memory and 0.3% CPU during a dungeon run.
- You can look at your spell breakdown at all times; if you want to look at your most damaging spells or someone's healing spells or the tank damage taken, Diameter got you.
- Access player breakdowns during combat via a two-step selection process: by clicking on a player you will be prompted to select the player from a second list and then you can see the breakdown. This is due to a Blizzard restriction on their API.
- It's written from scratch with Blizzard's new C_DamageMeter API in mind, so no legacy code with CLEU parsing.

Inspired by an addon called Skada.

## New in v2.4.0 

- Header is now a bit more explicative:
  - when on modes, header text is "Diameter: Modes";
  - when on group, header text keeps the usual "Diameter: $Mode";
  - when on player selection mode, header text is "$Mode: Select player";
  - when on breakdown, header text is "DPS: $PlayerName".
- Modules refactored to avoid the "Diameter." boilerplate on every function.
- Added a small optimization: when a group change happens (player join/leave) we flag the PlayerList as "needsRefresh" and, if needed, we build the PlayerList only when the Player Selection Mode is necessary.
- Fixed a mismatch between Class and Color fields concerning the data transitioning between the pages.

## New in v2.3.0

- Bar pool: replaced fixed-size bar arrays with a bar pool using CreateFramePool.
- Visual polish: header got a thin border and refreshed the menu icons.
- Bar's gradient was disappearing sometimes after the bar pool was implemented. This was fixed with sub-layers.
- Refactoring: modules Presenter and UI were creeping to >250 lines of code. New module UIBars abstracted logic.
- A memory testing report was added to validate the bar pool. So far so good, but will keep an eye on it.

## New in v2.2.0

- Removed the player selection button. It is integrated into the natural page navigation.
- Linear gradient added to the bars' texture instead of that weird bottle lighting.

## New in v2.1.1

- Added WoW Interface integration.
- Fixed the packaging of the addon, useless stuff was being packaged before.

## New in v2.1.0

- Fixed "account wide windows".
- New coloring on bars! 
  - Damage taken is a nice purple
  - Damage and healing use the class colors
  - Absorbs and interrupts are a cold steel-like color
  - Avoidable damage taken is an awful tone of bluish-brown. An intentionally ugly tone for an ugly metric.

## New in v2.0.0

- Multiple windows feature is now available. This was a huge refactor with a lot of singletons moving to instances.

