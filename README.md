# Untitled Drift Game AFK Mode

A game-specific Roblox Luau utility that keeps the Untitled Drift Game AFK state enabled and preserves its server-side ghost effect.

## Preview

<img width="401" height="402" alt="Untitled Drift Game AFK mode" src="https://github.com/user-attachments/assets/68b92c2f-f8d4-4b57-8f96-94f1fba40fac" />

## Usage

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/zvzt/UntitledDriftGameAFK/refs/heads/main/AFK.lua"))()
```

## How it works

The script keeps the game's `AFKEvent` enabled and blocks calls that attempt to switch the AFK state off while the script is active.

## Compatibility

This script is game-specific and depends on the game's current `AFKEvent` implementation. It also uses executor-specific functions including `getgenv`, `hookmetamethod`, `newcclosure`, and `getnamecallmethod`.

Game updates can change or break the behavior.

## Files

- `AFK.lua` — main script
- `README.md` — documentation

## License

MIT — see [LICENSE](LICENSE).
