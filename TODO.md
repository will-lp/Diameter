Stuff to do:

## highest priority
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
- [ ] attaching the Name of the player being inspected to UIHeader (this will look epic cute)
  - the class color can be obtained with UnitClass and RAID_CLASS_COLOR
- [ ] Menu.lua has a weird parameter being passed, I think it's ID and it's not being used. Ponder removal
- [ ] when clicking to see a dps breakdown of a secret GUID, fill a bar saying Player Selection Mode should be selected
- [ ] Z-index shenanigans when Diameter windows are hovering each other.

## medium priority
- [ ] refactor Presenter, it is managing state, managing database, handling events and printing bars. Want it to brew coffee too? soft-serve ice cream?
  - [x] remove Database handling responsibility from Presenter
  - [ ] remove Bar updating from Presenter, this is almost a View concern
- [ ] refactor UI, I think ScrollFrame could move into its own module
- [ ] ponder the orb: unit testing. Do we even have those in wow lua addon development?
- [ ] customization: for starters, allow users to set bar height
- [ ] in Presenter, obj.playerList is instanced, but maybe it could be class-wide OR it could consider the data without secrets
- [ ] disable Player Selection toggle when looking at historical data
- [ ] more viewState data could be persisted into the DB. this might cause problems on Reset Data or Addon Boot
- [ ] Diameter.lua is starting to do a lot of window management that could move into its own module
- [ ] spell tooltip

## low priority
- [ ] a few tooltips would be nice
- [ ] EventBus has now Diameter.EventBus for global and Diameter.EventBusClass to create instances. I don't like it :-(
- [ ] change all the "Diameter.Module" into only "Module."
- [ ] UI improvements: it is a bit ugly now, specially the bar colors
- [ ] i18n; if English was good enough for Jesus then it's good enough for me, too
- [x] check memory usage with the new windows
  - check memory_2026-02-22_v2.0.0.md report

