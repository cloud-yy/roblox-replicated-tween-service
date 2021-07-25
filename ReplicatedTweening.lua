--[[
░█████╗░██╗░░░░░░█████╗░██╗░░░██╗██████╗░
██╔══██╗██║░░░░░██╔══██╗██║░░░██║██╔══██╗
██║░░╚═╝██║░░░░░██║░░██║██║░░░██║██║░░██║
██║░░██╗██║░░░░░██║░░██║██║░░░██║██║░░██║
╚█████╔╝███████╗╚█████╔╝╚██████╔╝██████╔╝
░╚════╝░╚══════╝░╚════╝░░╚═════╝░╚═════╝░
]]--
-----------------------------------------

-- Name: Replicated Tweening
-- By: cloud_yy
-- Date: Sunday, July 25 2021

--[[

Description: 
A service similar to TweenService but it runs tweens on both server and client, this helps it play nice with systems ran on the server like NPCs or AntiExploit-
while also looking nice and smooth on the client side. This is not a perfect recreation of TweenService but it is good enough.

Documentation: 
SERVER
local ReplicatedTweening = require(ReplicatedTweening)
Starts ReplicatedTweening on the server.

local Tween = ReplicatedTweening.new(Object, Info, Goal)
    Tween:Play()
    Plays or resumes the tween.

    Tween:Pause()
    Pauses the tween to be played later.

    Tween:Stop()
    Fully cancels and stops the tween.

CLIENT
require(ReplicatedTweening)
Starts Replicated Tweening on the client.

]]--

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Intents = {Play = 1, Pause = 2, Stop = 3}
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

local ReplicatedTweening = {}

if RunService:IsServer() then
    Event = Instance.new("RemoteEvent",script)

    ReplicatedTweening.__index = ReplicatedTweening
    
    function ReplicatedTweening:Create(Object, Info, Goal)
        local self = setmetatable({}, ReplicatedTweening)

        self.Object = Object
        self.Info = Info
        self.Goal = Goal

        self.ServerTween = TweenService:Create(Object, Info, Goal)
        self.ClientTween = {Object, InfoToTable(Info), Goal}

        return self
    end
    
    function ReplicatedTweening:Play()
        self.ServerTween:Play()
        Event:FireAllClients(Intents.Play,self.ClientTween)
    end

    function ReplicatedTweening:Pause()
        self.ServerTween:Pause()
        Event:FireAllClients(Intents.Pause,self.ClientTween)
    end

    function ReplicatedTweening:Stop()
        self.ServerTween:Stop()
        Event:FireAllClients(Intents.Stop,self.ClientTween)
    end
    
    return ReplicatedTweening
else
    local Tweens = {}
    local PausedTweens = {}

    Event = script:WaitForChild("RemoteEvent")
    Event.OnClientEvent:Connect(function(Intent, TweenData)

        local Object, Info, Goal = unpack(TweenData)

        if Intent == Intents.Play then
            if Tweens[Object] then
                local Tween = Tweens[Object]
                
                if PausedTweens[Object] then
                    PausedTweens[Object]:Play()
                    PausedTweens[Object] = nil
                    return
                else
                    Tween[Object]:Cancel()
                    Tween[Object] = nil
                end
            end
            local Tween = TweenService:Create(Object,TableToInfo(Info),Goal)
            Tweens[Object] = Tween
            Tween:Play()
        elseif Intent == Intents.Pause then
            if Tweens[Object] then
                PausedTweens[Object] = Tweens[Object]
                Tweens[Object]:Pause()
            end

        elseif Intent == Intents.Stop then
            if Tweens[Object] then
                Tweens[Object]:Cancel()
                Tweens[Object] = nil
            end

            if PausedTweens[Object] then
                PausedTweens[Object] = nil
            end
        end
    end)

    return ReplicatedTweening
end

-- Replicated Tweening
-- © 2021 cloud_yy