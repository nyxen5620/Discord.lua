local http = require("http.request")
local json = require("dkjson")
local socket = require("socket")
local Endpoints = require("REST.Endpoints")

local REST = {}
REST.__index = REST

function REST:new(token)
    local self = setmetatable({}, REST)
    self.token = token
    return self
end

function REST:request(method, url, body)
    local req_body = body and json.encode(body) or nil
    local request = http.new_from_uri(url)
    request.headers:upsert(":method", method)
    request.headers:upsert("Authorization", "Bot "..self.token)
    if body then
        request.headers:upsert("Content-Type", "application/json")
        request:set_body(req_body)
    end

    local headers, stream = request:go()
    local response = stream:get_body_as_string()

    if headers:get("retry-after") then
        local wait_time = tonumber(headers:get("retry-after")) or 10
        print("ℹ️ Rate limit atingido. Aguardando "..wait_time.."s")
        socket.sleep(wait_time)
        return self:request(method, url, body)
    end

    return json.decode(response)
end

function REST:sendMessage(channel_id, content)
    local url = Endpoints.CHANNEL_MESSAGES(channel_id)
    return self:request("POST", url, {content = content})
end

function REST:getChannel(channel_id)
    local url = Endpoints.CHANNEL(channel_id)
    return self:request("GET", url)
end

function REST:getGuild(guild_id)
    local url = Endpoints.GUILD(guild_id)
    return self:request("GET", url)
end

return REST
