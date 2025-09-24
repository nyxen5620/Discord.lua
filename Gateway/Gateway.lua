local websocket = require("websocket.client")
local json = require("dkjson")
local socket = require("socket")
local Heartbeat = require("Gateway.Heartbeat")

local Gateway = {}
Gateway.__index = Gateway

function Gateway:new(token, client)
    local self = setmetatable({}, Gateway)
    self.token = token
    self.client = client
    self.ws = websocket.new()
    self.heartbeat_interval = nil
    self.session_id = nil
    self.seq = nil
    return self
end

function Gateway:connect()
    self.ws:connect("wss://gateway.discord.gg/?v=10&encoding=json")

    while true do
        local msg = self.ws:receive()
        if msg then
            local data = json.decode(msg)
            self:handlePayload(data)
        end
    end
end

function Gateway:handlePayload(data)
    local t = data.t
    local op = data.op
    local d = data.d
    self.seq = data.s or self.seq

    if op == 10 then
        self.heartbeat_interval = d.heartbeat_interval / 1000
        Heartbeat:start(self)
        self:identify()
    elseif op == 11 then
        -- heartbeat ACK
    elseif t then
        if t == "READY" then
            self.session_id = d.session_id
        end
        self.client:emit(t, d)
        if t == "MESSAGE_CREATE" then
            self.client.commands:handle(d)
        end
    end
end

function Gateway:identify()
    local payload = {
        op = 2,
        d = {
            token = self.token,
            intents = self.client.intents,
            properties = {
                ["$os"] = "linux",
                ["$browser"] = "Discord.lua",
                ["$device"] = "Discord.lua"
            },
            presence = {
                status = self.client.status,
                activities = self.client.activity and { self.client.activity } or {},
                afk = false
            }
        }
    }
    self.ws:send(json.encode(payload))
end

function Gateway:updatePresence(status, activity)
    local payload = {
        op = 3,
        d = {
            since = nil,
            activities = activity and { activity } or {},
            status = status or "online",
            afk = false
        }
    }
    self.ws:send(json.encode(payload))
end

return Gateway
