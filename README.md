# DO NOT USE!
Currently being rewritten!

## RbxReplicatedTweening
A service similar to TweenService but it runs tweens on both server and client, this helps it play nice with systems ran on the server like NPCs or AntiExploit while also looking nice and smooth on the client side. This is not a perfect recreation of TweenService but it is good enough.

## Setup
Require Replicated Tweening on both server and client with ```require(Path.To.ReplicatedTweening)```.

## Tween Methods:
Create a tween object:
```lua
local Tween = Module:Create(Object, TweenInfo, Goal)
```
Play or resumes a tween:
```lua
Tween:Play()
```
Pause a tween unless overrided:
```lua
Tween:Pause()
```
Fully cancel and stop a tween:
```lua
Tween:Stop()
```

## Example
Creating, playing, pausing and resuming a tween:
```lua
local Module = require(Path.To.ReplicatedTweening)
local Tween = Module:Create(game.Workspace.Part, TweenInfo.new(2), {Position = Vector3.new(0,0,0))

Tween:Play()
wait(1)
Tween:Pause()
wait(1)
Tween:Play()
```
