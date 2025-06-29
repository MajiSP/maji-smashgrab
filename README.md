# Maji SmashGrab

A FiveM script that allows players to break into vehicles and steal random items with multi-framework support.

## Features

- 🚗 Random item spawning in vehicles
- 🎯 Target system integration (ox_target, qb-target)
- 🎲 Configurable item rewards with chances
- 👮 Police alert system with configurable chance
- ⏰ Cooldown system to prevent spam
- 🎨 Customizable animations and notifications

- 🚨 **Multi-dispatch system support** (ps-dispatch, cd_dispatch, core_dispatch, linden_outlawalert, rcore_dispatch, qs-dispatch)
- 🔄 **Multi-framework support** (QB-Core, QBox, ESX, OX)

## Framework Support

- **QB-Core** - Full support
- **QBox** - Full support  
- **ESX** - Full support
- **OX Core** - Full support
- **Standalone** - Basic functionality

## Dependencies

### Required
- One of the supported frameworks (auto-detected)

## Installation

1. Download and extract to your resources folder
2. Add `ensure maji-smashgrab` to your server.cfg
3. Configure the script in `config.lua`
4. Restart your server

## How It Works

1. **Item Spawning**: Script randomly assigns items to vehicles with configurable chance
2. **Detection**: Players can target vehicles that have items using third-eye
3. **Break-in**: Shows progress bar with animation during the break-in process
4. **Rewards**: Gives random items based on configuration
5. **Police**: May alert police with configurable chance

## Support

For issues or suggestions, please create an issue on the repository, or join our Discord server. [DISCORD](https://discord.gg/yhgdBx7KKF)

## Donations are greatly appreciated
<img src="https://files.fivemerr.com/images/098e75ea-c731-4fa8-963c-7559f63f1e95.png" alt="Support on Ko-fi">

## License

This project is open source and available under the MIT License.
