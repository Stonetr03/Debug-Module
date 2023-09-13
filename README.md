# Debug Module

Debug Module for Roblox games.

This Module works both for Client and Server.

![Screenshot](/Images/screenshot.png)

The Ui is toggleable via the keybinds `RightShift + p`

> **Note**
> The Keybinds can be changed in the Config.lua file.

# Installation

## Method 1: Wally & Rojo

- Add Debug as a wally dependency
- ex `debug-module = "stonetr03/debug-module@2.0.1"`
- Use a plugin like [Rojo](https://rojo.space/) to sync into Roblox.

## Method 2: rbxlx File (Roblox Studio)

- Download the rbxmx model file from the latest release from the [releases page](https://github.com/Stonetr03/Debug-Module/releases).
- Insert the model into Roblox Studio and place into ReplicatedStorage.

# Usage

Require the Debug Module from a Client or Server script.

> **Warning**
> Server lines are visible to all clients!

> **Note**
> For Server Lines to be visible, the module needs to be loaded/required on the client.

```lua
local Debug = require(path.to.module)
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
