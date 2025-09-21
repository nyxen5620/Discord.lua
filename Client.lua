local config = require("config")
local Gateway = require("Gateway.Gateway")
local REST = require("REST.REST")
local Commands = require("Commands.CommandHandler")
local Collection = require("Utils.Collection")

local Client = {}
Client.__index = Client

function Client:new(token, options)
    options = options or {}
    local self = setmetatable({}, Client)

    self.token = token
    self.intents = options.intents or 513
    self.status = options.status or config.default_status
    self.activity = options.activity or config.default_activity

    self.users = Collection:new()
    self.guilds = Collection:new()
    self.channels = Collection:new()
    self.messages = Collection:new()
    self.roles = Collection:new()

    self.rest = REST:new(token)
    self.commands = Commands:new(self)
    self.gateway = Gateway:new(token, self)

    self._events = {}

    return self
end

function Client:on(event, callback)
    self._events[event] = callback
end

function Client:once(event, callback)
    self._events[event] = function(data)
        callback(data)
        self._events[event] = nil
    end
end

function Client:emit(event, data)
    if self._events[event] then
        self._events[event](data)
    end
end

function Client:command(name, callback)
    self.commands:add(name, callback)
end

function Client:setPresence(status, activity)
    self.status = status or self.status
    self.activity = activity or self.activity
    self.gateway:updatePresence(self.status, self.activity)
end

function Client:login()
    self.gateway:connect()
end

return Client
