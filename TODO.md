Stuff to do:

## highest priority
- [x] windows must be persisted into database per toon
- [x] check memory usage after destroying windows; is EventBus holding references?
- [x] EventBus:Unregister is doing nothing
- [x] test if reset data is global and acting upon all windows
- [x] validate DiameterDB and make sure there's no stray data
- [x] DiameterDB migration: we need to clear the database for people still in v1.x.x
- [x] ponder the orb: is GetTime() a good identifier for windows?
- [x] do not allow to close window if only one window remain
- [x] I don't think DiameterDB should straight up have indexes for windows because it might have settings in the future
  - DiameterDB.Windows

## high priority
- [x] deploying Diameter into WowInterface 
- [x] adding a "Releases" folder on git for people who like to do it manually
- [ ] there's still something off about the borders of header's buttons.
- [x] new prints for the new version, let's get over with the bottle texture for bars
- [x] Bar pool needs to be dynamic; I already bugged it with a tank's Damage Taken after a dungeon run
- [ ] attaching the Name of the player being inspected to UIHeader (this will look epic cute)
  - the class color can be obtained with UnitClass and RAID_CLASS_COLOR
- [x] Menu.lua has a weird parameter being passed, I think it's ID and it's not being used. Ponder removal
  - it is needed.
- [x] when clicking to see a dps breakdown of a secret GUID, fill a bar saying Player Selection Mode should be selected
  - better yet: automatic navigation into Player Selection Mode.
- [ ] Z-index shenanigans when Diameter windows are hovering each other.


## medium priority
- [ ] deploy into Wago.io
- [x] refactor Presenter, it is managing state, managing database, handling events and printing bars. Want it to brew coffee too? soft-serve ice cream?
  - [x] remove Database handling responsibility from Presenter
  - [x] remove Bar updating from Presenter
- [x] refactor UI:
  - [x] ScrollFrame could move into its own module
  - [x] Bar creation could move
- [ ] ponder the orb: unit testing. Do we even have those in wow lua addon development?
- [ ] customization: for starters, allow users to set bar height
- [ ] in Presenter, obj.playerList is instanced, but maybe it could be class-wide OR it could consider the data without secrets
- [x] disable Player Selection toggle when looking at historical data
- [ ] more viewState data could be persisted into the DB. But this might cause problems on Reset Data or Addon Boot
- [ ] Diameter.lua is starting to do a lot of window management that could move into its own module
- [ ] spell tooltip
- [ ] group data has two values that should be shown, like blizz addon meter does: totalAmount and amountPerSecond.
- [ ] dialog positioning sometimes reset. We might have to persist those in the DB

## low priority
- [ ] a few tooltips would be nice
- [x] paint bars different color per mode; we healing? maybe green bars. absorbs? cyan. damage taken? red/yellow.
- [ ] EventBus has now Diameter.EventBus for global and Diameter.EventBusClass to create instances. I don't like it :-(
- [ ] change all the "Diameter.Module" into only "Module."
- [x] UI improvements: it is a bit ugly now, specially the bar colors
  - the gradient is cute! it's not perfect, but hey! At some point we could look at some presets, maybe

## unprioritized
- [ ] i18n; if English was good enough for Jesus then it's good enough for me, too
- [x] check memory usage with the new windows
  - check memory_2026-02-22_v2.0.0.md report

