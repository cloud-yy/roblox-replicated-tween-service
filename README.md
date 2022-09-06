# RbxReplicatedTweenService
A service similar to TweenService but it runs tweens on both server and client, this helps it play nice with systems ran on the server like NPCs or AntiExploit while also looking nice and smooth on the client side. This is not a perfect recreation of TweenService but it is good enough.

## Setup
Require Replicated Tweening on both server and client with ```require(Path.To.ReplicatedTweenService)```.

## Tween Methods:
Create a tween object:
```lua
local Tween = Module:Create(object, tweenInfo, goal)
```
Play or resumes the tween:
```lua
Tween:Play()
```
Pause a tween unless overrided:
```lua
Tween:Pause()
```
Cancel the tween:
```lua
Tween:Cancel()
```
Destroy the tween:
```lua
Tween:Destroy()
```

## Example
Creating, playing, pausing and resuming a tween:
```lua
local Module = require(Path.To.ReplicatedTweenService)
local Tween = Module:Create(game.Workspace.Part, TweenInfo.new(2), {Position = Vector3.new(0,0,0))

Tween:Play()
task.wait(1)
Tween:Pause()
task.wait(1)
Tween:Play()
task.wait(2)
Tween:Destroy()
```
