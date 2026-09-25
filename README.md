# Untitled Drift Game AFK Mode

A game-specific Roblox Luau utility that keeps the Untitled Drift Game AFK state enabled and preserves its server-side ghost effect.

## Preview

<img width="401" height="402" alt="Untitled Drift Game AFK mode" src="https://github.com/user-attachments/assets/68b92c2f-f8d4-4b57-8f96-94f1fba40fac" />

## Usage

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/zvzt/UntitledDriftGameAFK/refs/heads/main/AFK.lua"))()
```

## Features

- Onyx-style draggable interface
- Active/Disabled switch
- Header-only minimize/restore behavior
- Screen-edge drag clamping with `-57 / 57` vertical offsets
- Sends the game's AFK state on and off through `AFKEvent`
- Blocks game-side attempts to disable AFK while the tool is active
- Disabling the switch explicitly sends `AFKEvent:FireServer(false,0)`
- Closing the UI disables AFK
- Session-based rerun handling prevents duplicate AFK loops

## How it works

While active, the script keeps the game's `AFKEvent` enabled and blocks calls that attempt to switch the AFK state off. When the user disables the tool or closes the UI, it sends the game's AFK event with `false` and stops the active keep-alive session.

## Compatibility

This script is game-specific and depends on the game's current `AFKEvent` implementation. It also uses executor-specific functions including `getgenv`, `hookmetamethod`, `newcclosure`, and `getnamecallmethod`.

Game updates can change or break the behavior.

## Files

- `AFK.lua` — main script
- `README.md` — documentation

## License

MIT — see [LICENSE](LICENSE).
