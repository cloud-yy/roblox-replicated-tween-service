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
-- Date: Tuesday, July 27 2021

--[[

Description: 
A service similar to TweenService but it runs tweens on both server and client, this helps it play nice with systems ran on the server like NPCs or AntiExploit-
while also looking nice and smooth on the client side. This is not a perfect recreation of TweenService but it is good enough.

Documentation: 
SERVER
local ReplicatedTweenService = require(ReplicatedTweenService)
    Starts ReplicatedTweenService on the server.

local Tween = ReplicatedTweenService.new(Object, Info, Goal)
    Tween:Play()
        Plays or resumes the tween.

    Tween:Pause()
        Pauses the tween to be played later.

    Tween:Cancel()
        Cancels the tween.

CLIENT
require(ReplicatedTweenService)
Starts Replicated Tweening on the client.

]]--

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Intents = {New = 1, Sync = 2, Play = 3, Pause = 4, Cancel = 5}
local Tweens = {}
local Event

local function InfoToTable(Info)
	local Table = {}
	Table[1] = Info.Time or 1 
	Table[2] = Info.EasingStyle or Enum.EasingStyle.Quad
	Table[3] = Info.EasingDirection or Enum.EasingDirection.Out
	Table[4] = Info.RepeatCount or 0
	Table[5] = Info.Reverses or false
	Table[6] = Info.DelayTime or 0
	return Table
end

local function TableToInfo(Table)
	return TweenInfo.new(unpack(Table))
end

local function CreateLocalTween(Id, Object, Info, Goal)
    local Tween = TweenService:Create(Object, TableToInfo(Info), Goal)
    Tweens[Id] = Tween
end

local ReplicatedTweenService = {}

if RunService:IsServer() then
    Event = Instance.new("RemoteEvent",script)

    Event.OnServerEvent:Connect(function(Player,Intent)
        if Intent == Intents.Sync then
            Event:FireClient(Player,Tweens)
        end
    end)

    ReplicatedTweenService.__index = ReplicatedTweenService
    
    function ReplicatedTweenService:Create(Object, Info, Goal)
        local self = setmetatable({}, ReplicatedTweenService)

        self._id = HttpService:GenerateGUID()
        self._tween = TweenService:Create(Object, Info, Goal)

        Tweens[self._id] = {Object, InfoToTable(Info), Goal}
        Event:FireAllClients(Intents.New, self._id, Object, InfoToTable(Info), Goal)
        return self
    end
    
    function ReplicatedTweenService:Play()
        self._tween:Play()
        Event:FireAllClients(Intents.Play, self._id)
    end

    function ReplicatedTweenService:Pause()
        self._tween:Pause()
        Event:FireAllClients(Intents.Pause, self._id)
    end

    function ReplicatedTweenService:Cancel()
        self._tween:Cancel()
        Event:FireAllClients(Intents.Cancel, self._id)
    end
else
    Event = script:WaitForChild("RemoteEvent")

    Event.OnClientEvent:Connect(function(Intent,...)
        local Args = {...}
        if Intent == Intents.New then
            CreateLocalTween(...)

        elseif Intent == Intents.Sync then
            for Id,Tween in pairs(Args[1]) do
                CreateLocalTween(Id,Tween[1],Tween[2],Tween[3])
            end

        elseif Intent == Intents.Play then
            local Tween = Tweens[Args[1]]
            if Tween then
                Tween:Play()
            end

        elseif Intent == Intents.Pause then
            local Tween = Tweens[Args[1]]
            if Tween then
                Tween:Pause()
            end

        elseif Intent == Intents.Cancel then
            local Tween = Tweens[Args[1]]
            if Tween then
                Tween:Cancel()
            end
        end
    end)

    Event:FireServer(Intents.Sync)
end

return ReplicatedTweenService

-- ReplicatedTweenService
-- © 2021 cloud_yy
