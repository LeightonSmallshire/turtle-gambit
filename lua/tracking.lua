-- Make the turtle track it's position based on its successful movements
turtle.x, turtle.y, turtle.z, turtle.d = 0, 0, 0, 0
turtle.DirectionDeltas = { { 0, -1 }, { 1, 0 }, { 0, 1 }, { -1, 0 } }

turtle._up = turtle.up
turtle._down = turtle.down
turtle._turnLeft = turtle.turnLeft
turtle._turnRight = turtle.turnRight
turtle._forward = turtle.forward
turtle._back = turtle.back

function turtle.locate()
    local x1, y1, z1 = gps.locate()
    if turtle.x == nil then
        return print("Could not get position by gps.")
    end
    if turtle.forward() then
        local x2, _, z2 = { gps.locate() }

        if z1 - z2 == 1 then
            turtle.d = 0 -- north; z-1
        elseif x2 - x1 == 1 then
            turtle.d = 1 -- east ; x+1
        elseif z2 - z1 == 1 then
            turtle.d = 2 -- south; z+1
        elseif x1 - x2 == 1 then
            turtle.d = 3 -- west ; x-1
        end
        turtle.back()
        turtle.x, turtle.y, turtle.z = x1, y1, z1
    else
        -- could check other directions but lazy...
        print("Could not move to check orientation; assuming north")
    end
end

function turtle.move(dir)
    print(1, dir, turtle[dir], turtle["_" .. dir])
    local a = "_" .. dir
    print(2, a)
    local b = turtle[a]
    print(3, b)
    local c = { b() }
    print(4, c)
    local r = { turtle["_" .. dir]() }
    print(5, r)
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

for _, v in ipairs(moveCommands) do
    turtle[v] = loadstring("return {turtle.move('" .. v .. "')}")
end

turtle.turnLeft()
-- todo; infinite recursion somewhere...