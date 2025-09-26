local json = require("dkjson")
local socket = require("socket")

local Heartbeat = {}

function Heartbeat:start(gateway)
    coroutine.wrap(function()
        while true do
            local payload = {
                op = 1,
                d = gateway.seq
            }
            gateway.ws:send(json.encode(payload))
            socket.sleep(gateway.heartbeat_interval)
        end
    end)()
end

return Heartbeat