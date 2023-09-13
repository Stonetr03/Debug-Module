# Debug Module

Debug Module for Roblox games.

This Module works both for Client and Server.

![Screenshot](/Images/screenshot.png)

The Ui is toggleable via the keybinds `RightShift + p`

> **Note**
> The Keybinds can be changed in the Config.lua file.

# Installation

## Method 1: rbxlx File (Roblox Studio)

- Download the rbxmx model file from the latest release from the [releases page](https://github.com/Stonetr03/Debug-Module/releases).
- Insert the model into Roblox Studio and place into ReplicatedStorage.

## Method 2: Rojo Sync

- Copy the [Debug Folder](https://github.com/Stonetr03/Debug-Module/tree/master/src/debug) into your codebase.
- Use a plugin like [Rojo](https://rojo.space/) to sync into Roblox.

# Usage

Require the Debug Module from a Client or Server script.

> **Warning**
> Server Debugs are visible to all clients!

```lua
local Debug = require(game.ReplicatedStorage.debug)
```

## Add a line
To add a line to the debug menu use, an call on server or client.
```lua
local Line = Debug:addLine("Name","Value")
```
> **Note**
> The Value does not have to be a string.

## Change Line's Text
To change a lines text use,
```lua
Line:Update("New Value")
```

## Remove a Line
To remove a line use,
```lua
Line:Destroy()
```
