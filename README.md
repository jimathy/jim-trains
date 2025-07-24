# Jim-Trains

- This is a is a script to make trains spawn in your server
- It uses client sided natives to attempt to make them spawn, but not forcibly

## What does it do?

- First of foremost this is not a script to allow players to ride trains, it does its best to prevent that
- This script enables the natives to make trains spawn natrually in your server
  - When the players load in, it preloads the models and lets the game engine do its work
- It also allows for blips for the stations to be created
- (Optional) Makes trains also require a ticket before entering it, purchasable from ticket machines at stations
- (Optional) Allows players to sit in the trains when travelling, making "G" the key to press to get off at next station
- It also makes freight trains spawn in your server and attempts to control stopping them at certain stations

## What does it need?
- Requires `jim_bridge` v2.0+
- I'm hoping with the use of `jim_bridge`, it allows it to be used on all frameworks

## Known issues

- After testing in a high population 150+ player server, the syncing can start to become and issue
  - For example out of no where a metro train will go 100mph, I believe its "trying to catch up" for that player
  - If anyone knows how to integrate a fix into the script, I'm not sure if its server lag or player lag or both, feel free to pull request a fix for it

  ---

# Installation and Previews:
## [JixelPatterns GitBook Documentation](https://jixelpatterns.gitbook.io/docs)

### If you need support I have a discord server available, it helps me keep track of issues and give better support.
## [JixelPatterns Discord](https://discord.gg/9pCDHmjYwd)

### If you think I did a good job here, consider donating as it keeps by lights on and my cat round:
## [JixelPatterns Kofi](https://ko-fi.com/jixelpatterns)