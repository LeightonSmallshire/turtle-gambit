-- 0.0.1

function diffieHandshake(g, p, A)
    local B, S
    B = math.fmod(g ^ key, p)
    S = math.fmod(A ^ key, p)
    return B, S
end

local f = fs.open('key', 'r')
local key = (f and f.readAll()) or math.random(0, 2 ^ 32)

local ws, err = http.websocket("ws://localhost:5757")

if err then
    return print(err)
end

ws.send(os.getComputerLabel())

while true do
    local f = tostring('return ' .. ws.receive())
    setfenv(f, getfenv()) -- share locals
    ws.send(f())
end

-- 0.0.2

local fn, ws, label
label = os.getComputerLabel() or ''

print("Connecting...")
while not ws do
    ws = http.websocket("ws://localhost:5757/" .. label)
end
print('ready')

if label == '' then
    label = ws.receive()
    print('New name:', label)
    os.setComputerLabel(label)
end

while true do
    local s = "return " .. ws.receive()
    print(s)
    fn = tostring(s)
    if fn then
        setfenv(fn, getfenv()) -- share locals
        ws.send(fn())
    end
end
