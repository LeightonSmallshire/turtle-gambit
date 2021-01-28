-- load children's ids
function loadIds()
    local f = fs.open('children.lsv')
    local line = f.readline()
    while line do
        if ~turtles[tonumber(line)] then
            turtles[tonumber(line)] = {}
        end
        line = f.readline()
    end
    f.close()
end

-- start hosting
rednet.host(proto, 'Control Hub ID' .. os.computerID())
while true do
    local sender, message, info, id, data, success, status, callback
    sender, message = rednet.receive(proto)
    info = turtles[sender]

    if info then
        info['connected'] = true;
        if message == nil then
            info['connected'] = false;
        else
            id, data = message['id'], message['data']
            callback = tasks[id]
            if callback then
                success, status = pcall(callback, data)
                tasks[id] = nil;
                if ~success then
                    print("Callback failed with reason: " .. status)
                end
            else
                -- todo; actions & reporting (not just responses)
                print("Not expecting response")
            end
        end
    elseif message == 'new' then
        -- todo; make the turtle placing the new one send the 'new' signal?
        loadIds()
    else
        rednet.send(sender, nil, proto);
    end
end
