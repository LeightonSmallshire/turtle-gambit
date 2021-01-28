require('actions')
--pretty = require('cc.pretty')
local proto = "AerWeb"

local f = fs.open('/hubID')
hubID = tonumber(f.read())
f.close()

peripheral.find("modem", rednet.open)

function loop()
    local sender, message, id, fn
    print("    AerWeb Drone")
    while true do
        sender, message = rednet.receive(proto)
        if sender == hubID then
            id, fn = message['id'], loadstring(message['func'])
            if fn then
                setfenv(fn, getfenv()) -- pretty.pretty({ id, pcall(fn) })
                rednet.send(hubID, { id = id, data = pcall(fn) }, proto)
            end
        end
    end
end

rednet.send(hubID, "new", proto)
while true do
    print("Uncaught error:", { pcall(loop) })
    os.sleep(2)
end
