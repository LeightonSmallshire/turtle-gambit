-- Make the turtle track it's position based on its successful movements
turtle.x, turtle.y, turtle.z, turtle.d = 0, 0, 0, 0
turtle.DirectionDeltas = { { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 0 } }

-- misc

detect = { forward = turtle.detect, up = turtle.detectUp, down = turtle.detectDown }
inspect = { forward = turtle.inspect, up = turtle.inspectUp, down = turtle.inspectDown }
dig = { forward = turtle.dig, up = turtle.digUp, down = turtle.digDown }
attack = { forward = turtle.attack, up = turtle.attackUp, down = turtle.attackDown }

-- movements

function locate()
    local x1, y1, z1, x2, z2, _, i
    x1, y1, z1 = gps.locate()
    if turtle.x == nil then
        return print("Could not get position by gps.")
    end
    turtle.x, turtle.y, turtle.z = x1, y1, z1
    i = 0
    while i < 4 do
        if forward() then
            x2, _, z2 = { gps.locate() }
            if z1 - z2 == 1 then
                turtle.d = 0 -- north; z-1
            elseif x2 - x1 == 1 then
                turtle.d = 1 -- east ; x+1
            elseif z2 - z1 == 1 then
                turtle.d = 2 -- south; z+1
            elseif x1 - x2 == 1 then
                turtle.d = 3 -- west ; x-1
            end
            back()
            break
        end
        turnLeft()
        i = i + 1
    end
    if i == 4 then
        return print("Could not move to check orientation; assuming north")
    end
    for _ = 0, i do
        turnRight()
    end
end

local function go(dir, nodig)
    return function()
        if ~nodig and detect[dir]() then
            if ~safedig(dir) then
                return false;
            end
        end

        local r = { turtle[dir]() }
        if r[1] then
            local deltas = turtle.DirectionDeltas[turtle.d + 1]
            if dir == "up" then
                turtle.y = turtle.y + 1
            elseif dir == "down" then
                turtle.y = turtle.y - 1
            elseif dir == "turnLeft" then
                turtle.d = (turtle.d - 1) % 4
            elseif dir == "turnRight" then
                turtle.x = (turtle.d + 1) % 4
            elseif dir == "forward" then
                turtle.x = turtle.x + deltas[1]
                turtle.z = turtle.z + deltas[2]
            elseif dir == "back" then
                turtle.x = turtle.x - deltas[1]
                turtle.z = turtle.z - deltas[2]
            end
        end
        return table.unpack(r)
    end
end

up = go('up')
down = go('down')
back = go('back')
forward = go('forward')
turnLeft = go('turnLeft')
turnRight = go('turnRight')

local _path_map = { u = up, d = down, l = turnLeft, r = turnRight, f = forward, b = back }
function followPath(path)
    for step in path.gmatch '.' do
        if not _path_map[step] then
            return false
        end
    end
    return true
end

function face(dir)
    -- north,east,south,west; 0-3 inclusive
    if dir - turtle.d == 3 then
        return turnRight()
    end
    while dir - turtle.d > 0 do
        if ~turnLeft() then
            return false
        end
    end
    return true
end


--

function safedig(dir)
    dir = dir or 'forward'
    local name = inspect[dir]()[2].name
    if name then
        name = string.lower(name)
        for _, word in pairs(config.dig_disallow) do
            if word:find(name) then
                return false
            end
        end
    end
    return dig[dir]()
end

