function loop()
    local ws, message, nonce, fn
    ws = http.websocket("ws://localhost:9000/hive?l=" .. (os.getComputerLabel() or '_'))
    while true do
        message = ws.receive()
        fn = loadstring(message:sub(5))
        setfenv(fn, getfenv())
        ws.send(textutils.serializeJSON({ message:sub(1, 4), pcall(fn) }))
    end
end

while true do
    error = { pcall(loop) }
    print("error:", error)
    os.sleep(2)
    term.clear()
    term.setCursorPos(1, 1)
end
