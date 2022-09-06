--!strict

--[[
░█████╗░██╗░░░░░░█████╗░██╗░░░██╗██████╗░
██╔══██╗██║░░░░░██╔══██╗██║░░░██║██╔══██╗
██║░░╚═╝██║░░░░░██║░░██║██║░░░██║██║░░██║
██║░░██╗██║░░░░░██║░░██║██║░░░██║██║░░██║
╚█████╔╝███████╗╚█████╔╝╚██████╔╝██████╔╝
░╚════╝░╚══════╝░╚════╝░░╚═════╝░╚═════╝░
]]--
-----------------------------------------

-- Name: ReplicatedTweenService
-- By: cloud_yy
-- Date: Tuesday, September 6 2022

--[[
Description: 
A service similar to TweenService but it runs tweens on both server and client, this helps it play nice with systems ran on the server like NPCs or AntiExploit-
while also looking nice and smooth on the client side. This is not a perfect recreation of TweenService but it is good enough.

Documentation: 
SERVER
local ReplicatedTweenService = require(ReplicatedTweenService)
    Starts ReplicatedTweenService on the server.
local Tween = ReplicatedTweenService.new(object, info, goal)
    Tween:Play()
        Plays or resumes the tween.
    Tween:Pause()
        Pauses the tween to be played later.
    Tween:Cancel()
        Cancels the tween.
    Tween:Destroy()
        Cleans up/destroys the tween. Should use once a tween is done.
CLIENT
require(ReplicatedTweenService)
Starts Replicated Tweening on the client.
]]--

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Tweens = {}
local Event: RemoteEvent

local INTENTS = {
    New = 1,
    Sync = 2,
    Play = 3,
    Pause = 4,
    Cancel = 5,
    Destroy = 6
}

local function infoToTable(info: TweenInfo): table
	local table: table = {}
	table[1] = info.Time or 1 
	table[2] = info.EasingStyle or Enum.EasingStyle.Quad
	table[3] = info.EasingDirection or Enum.EasingDirection.Out
	table[4] = info.RepeatCount or 0
	table[5] = info.Reverses or false
	table[6] = info.DelayTime or 0
	return table
end

local function tableToInfo(table): TweenInfo
	return TweenInfo.new(unpack(table))
end

local function createLocalTween(id, object, info, goal)
    local tween = TweenService:Create(object, TableToInfo(info), goal)
    Tweens[id] = tween
end

local ReplicatedTweenService = {}

if RunService:IsServer() then
    Event = Instance.new("RemoteEvent",script)

    Event.OnServerEvent:Connect(function(player: Player, intent: String)
        if intent == INTENTS.Sync then
            Event:FireClient(player, Tweens)
        end
    end)

    ReplicatedTweenService.__index = ReplicatedTweenService
    
    function ReplicatedTweenService:Create(object: Instance, info: TweenInfo, goal: Table)
        local self = setmetatable({}, ReplicatedTweenService)

        self._id: String = HttpService:GenerateGUID()
        self._tween: Tween = TweenService:Create(Object, Info, Goal)

        Tweens[self._id] = {object, InfoToTable(info), goal}
        Event:FireAllClients(INTENTS.New, self._id, object, infoToTable(info), goal)

        return self
    end
    
    function ReplicatedTweenService:Play()
        self._tween:Play()
        Event:FireAllClients(INTENTS.Play, self._id)
    end

    function ReplicatedTweenService:Pause()
        self._tween:Pause()
        Event:FireAllClients(INTENTS.Pause, self._id)
    end

    function ReplicatedTweenService:Cancel()
        self._tween:Cancel()
        Event:FireAllClients(INTENTS.Cancel, self._id)
    end

    function ReplicatedTweenService:Destroy()
        Event:FireAllClients(INTENTS.Destroy, self._id)
        Tweens[self._id] = nil
    end
else
    Event = script:WaitForChild("RemoteEvent")

    Event.OnClientEvent:Connect(function(Intent: number, ...)
        local args: table = {...}

        if intent == INTENTS.New then
            createLocalTween(...)

        elseif intent == INTENTS.Sync then
            for id, tween in pairs(args[1]) do
                createLocalTween(id, tween[1], tween[2], tween[3])
            end

        elseif intent == INTENTS.Play then
            local tween = Tweens[Args[1]]
            if tween then
                tween:Play()
            end

        elseif intent == INTENTS.Pause then
            local tween = Tweens[Args[1]]
            if tween then
                tween:Pause()
            end

        elseif intent == INTENTS.Cancel then
            local tween = Tweens[Args[1]]
            if tween then
                tween:Cancel()
            end

        elseif intent == INTENTS.Destroy then
            if tweens[Args[1]] then
                tweens[Args[1]] = nil
            end
        end
    end)

    Event:FireServer(INTENTS.Sync)
end

return ReplicatedTweenService

-- ReplicatedTweenService
-- © 2022 cloud_yy
