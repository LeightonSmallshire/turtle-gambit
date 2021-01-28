menu_lines = {
    '#   # ##### #   # #####',
    '## ##   #   ##  # #',
    '# # #   #   # # # ###',
    '#   #   #   #  ## #',
    '#   # ##### #   # #',
}

decimals = {
    [0] = {
        '#####',
        '#   #',
        '#   #',
        '#   #',
        '#####',
    },
    [1] = {
        '###  ',
        '  #  ',
        '  #  ',
        '  #  ',
        '#####',
    },
    [2] = {
        '#####',
        '    #',
        '#####',
        '#    ',
        '#####',
    },
    [3] = {
        '#####',
        '    #',
        '#####',
        '    #',
        '#####',
    },
    [4] = {
        '#   #',
        '#   #',
        '#####',
        '    #',
        '    #',
    },
    [5] = {
        '#####',
        '#    ',
        '#####',
        '    #',
        '#####',
    },
    [6] = {
        '#####',
        '#    ',
        '#####',
        '#   #',
        '#####',
    },
    [7] = {
        '#####',
        '    #',
        '    #',
        '    #',
        '    #',
    },
    [8] = {
        '#####',
        '#   #',
        '#####',
        '#   #',
        '#####',
    },
    [9] = {
        '#####',
        '#   #',
        '#####',
        '    #',
        '    #',
    },
}

function debug_print(string)
    term.redirect(monitor.restore_to)
    print(string)
    term.redirect(monitor)
end

function turtle_viewer(turtle_ids)
    term.redirect(monitor)
    
    local selected = 1
    
    while true do
        local turtle_id = turtle_ids[selected]
        local turtle = state.turtles[turtle_id]
        
        -- RESOLVE MONITOR TOUCHES, EITHER BY AFFECTING THE DISPLAY OR INSERTING INTO USER_INPUT TABLE
        while #state.monitor_touches > 0 do
            local monitor_touch = table.remove(state.monitor_touches)
            if monitor_touch.x == elms.left.x and monitor_touch.y == elms.left.y then
                selected = math.max(selected - 1, 1)
            elseif monitor_touch.x == elms.right.x and monitor_touch.y == elms.right.y then
                selected = math.min(selected + 1, #turtle_ids)
            elseif monitor_touch.x == elms.viewer_exit.x and monitor_touch.y == elms.viewer_exit.y then
                term.redirect(monitor.restore_to)
                return
            elseif monitor_touch.x == elms.turtle_return.x and monitor_touch.y == elms.turtle_return.y then
                table.insert(state.user_input, 'return ' .. turtle_id)
            elseif monitor_touch.x == elms.turtle_update.x and monitor_touch.y == elms.turtle_update.y then
                table.insert(state.user_input, 'update ' .. turtle_id)
            elseif monitor_touch.x == elms.turtle_reboot.x and monitor_touch.y == elms.turtle_reboot.y then
                table.insert(state.user_input, 'reboot ' .. turtle_id)
            elseif monitor_touch.x == elms.turtle_halt.x and monitor_touch.y == elms.turtle_halt.y then
                table.insert(state.user_input, 'halt ' .. turtle_id)
            elseif monitor_touch.x == elms.turtle_clear.x and monitor_touch.y == elms.turtle_clear.y then
                table.insert(state.user_input, 'clear ' .. turtle_id)
            elseif monitor_touch.x == elms.turtle_reset.x and monitor_touch.y == elms.turtle_reset.y then
                table.insert(state.user_input, 'reset ' .. turtle_id)
            elseif monitor_touch.x == elms.turtle_find.x and monitor_touch.y == elms.turtle_find.y then
                monitor_location.x = turtle.data.location.x
                monitor_location.z = turtle.data.location.z
                monitor_zoom_level = 0
                for level_index, level_and_chance in pairs(config.mine_levels) do
                    if turtle.strip and level_and_chance.level == turtle.strip.y then
                        monitor_level_index = level_index
                        select_mine_level()
                        break
                    end
                end
                term.redirect(monitor.restore_to)
                return
            elseif monitor_touch.x == elms.turtle_forward.x and monitor_touch.y == elms.turtle_forward.y then
                table.insert(state.user_input, 'turtle ' .. turtle_id .. ' go forward')
            elseif monitor_touch.x == elms.turtle_back.x and monitor_touch.y == elms.turtle_back.y then
                table.insert(state.user_input, 'turtle ' .. turtle_id .. ' go back')
            elseif monitor_touch.x == elms.turtle_up.x and monitor_touch.y == elms.turtle_up.y then
                table.insert(state.user_input, 'turtle ' .. turtle_id .. ' go up')
            elseif monitor_touch.x == elms.turtle_down.x and monitor_touch.y == elms.turtle_down.y then
                table.insert(state.user_input, 'turtle ' .. turtle_id .. ' go down')
            elseif monitor_touch.x == elms.turtle_left.x and monitor_touch.y == elms.turtle_left.y then
                table.insert(state.user_input, 'turtle ' .. turtle_id .. ' go left')
            elseif monitor_touch.x == elms.turtle_right.x and monitor_touch.y == elms.turtle_right.y then
                table.insert(state.user_input, 'turtle ' .. turtle_id .. ' go right')
            end
        end
        
        turtle_id = turtle_ids[selected]
        turtle = state.turtles[turtle_id]
        
        background_color = colors.black
        term.setBackgroundColor(background_color)
        monitor.clear()
        
        if turtle.last_update + config.turtle_timeout < os.clock() then
            term.setCursorPos(elms.turtle_lost.x, elms.turtle_lost.y)
            term.setTextColor(colors.red)
            term.write('CONNECTION LOST')
        end
        
        local x_position = elms.turtle_id.x
        for decimal_string in string.format('%04d', turtle_id):gmatch"." do
            for y_offset, line in pairs(decimals[tonumber(decimal_string)]) do
                term.setCursorPos(x_position, elms.turtle_id.y + y_offset - 1)
                for char in line:gmatch"." do
                    if char == '#' then
                        term.setBackgroundColor(colors.green)
                    else
                        term.setBackgroundColor(colors.black)
                    end
                    term.write(' ')
                end
            end
            x_position = x_position + 6
        end
        
        term.setCursorPos(elms.turtle_face.x + 1, elms.turtle_face.y)
        term.setBackgroundColor(colors.yellow)
        term.write('       ')
        term.setCursorPos(elms.turtle_face.x + 1, elms.turtle_face.y + 1)
        term.setBackgroundColor(colors.yellow)
        term.write(' ')
        term.setBackgroundColor(colors.gray)
        term.write('     ')
        term.setBackgroundColor(colors.yellow)
        term.write(' ')
        term.setCursorPos(elms.turtle_face.x + 1, elms.turtle_face.y + 2)
        term.setBackgroundColor(colors.yellow)
        term.write('       ')
        term.setCursorPos(elms.turtle_face.x + 1, elms.turtle_face.y + 3)
        term.setBackgroundColor(colors.yellow)
        term.write('       ')
        term.setCursorPos(elms.turtle_face.x + 1, elms.turtle_face.y + 4)
        term.setBackgroundColor(colors.yellow)
        term.write('       ')
        
        if turtle.data.peripheral_right == 'modem' then
            term.setBackgroundColor(colors.lightGray)
            term.setCursorPos(elms.turtle_face.x, elms.turtle_face.y + 1)
            term.write(' ')
            term.setCursorPos(elms.turtle_face.x, elms.turtle_face.y + 2)
            term.write(' ')
            term.setCursorPos(elms.turtle_face.x, elms.turtle_face.y + 3)
            term.write(' ')
        elseif turtle.data.peripheral_right == 'pick' then
            term.setBackgroundColor(colors.cyan)
            term.setCursorPos(elms.turtle_face.x, elms.turtle_face.y + 1)
            term.write(' ')
            term.setCursorPos(elms.turtle_face.x, elms.turtle_face.y + 2)
            term.write(' ')
            term.setBackgroundColor(colors.brown)
            term.setCursorPos(elms.turtle_face.x, elms.turtle_face.y + 3)
            term.write(' ')
        elseif turtle.data.peripheral_right == 'chunkLoader' then
            term.setBackgroundColor(colors.gray)
            term.setCursorPos(elms.turtle_face.x, elms.turtle_face.y + 1)
            term.write(' ')
            term.setCursorPos(elms.turtle_face.x, elms.turtle_face.y + 3)
            term.write(' ')
            term.setBackgroundColor(colors.blue)
            term.setCursorPos(elms.turtle_face.x, elms.turtle_face.y + 2)
            term.write(' ')
        end
        
        if turtle.data.peripheral_left == 'modem' then
            term.setBackgroundColor(colors.lightGray)
            term.setCursorPos(elms.turtle_face.x + 8, elms.turtle_face.y + 1)
            term.write(' ')
            term.setCursorPos(elms.turtle_face.x + 8, elms.turtle_face.y + 2)
            term.write(' ')
            term.setCursorPos(elms.turtle_face.x + 8, elms.turtle_face.y + 3)
            term.write(' ')
        elseif turtle.data.peripheral_left == 'pick' then
            term.setBackgroundColor(colors.cyan)
            term.setCursorPos(elms.turtle_face.x + 8, elms.turtle_face.y + 1)
            term.write(' ')
            term.setCursorPos(elms.turtle_face.x + 8, elms.turtle_face.y + 2)
            term.write(' ')
            term.setBackgroundColor(colors.brown)
            term.setCursorPos(elms.turtle_face.x + 8, elms.turtle_face.y + 3)
            term.write(' ')
        elseif turtle.data.peripheral_left == 'chunkLoader' then
            term.setBackgroundColor(colors.gray)
            term.setCursorPos(elms.turtle_face.x + 8, elms.turtle_face.y + 1)
            term.write(' ')
            term.setCursorPos(elms.turtle_face.x + 8, elms.turtle_face.y + 3)
            term.write(' ')
            term.setBackgroundColor(colors.blue)
            term.setCursorPos(elms.turtle_face.x + 8, elms.turtle_face.y + 2)
            term.write(' ')
        end
        
        term.setBackgroundColor(background_color)
        
        term.setCursorPos(elms.turtle_data.x, elms.turtle_data.y)
        term.setTextColor(colors.white)
        term.write('State: ')
        term.setTextColor(colors.green)
        term.write(turtle.state)
        
        term.setCursorPos(elms.turtle_data.x, elms.turtle_data.y + 1)
        term.setTextColor(colors.white)
        term.write('X: ')
        term.setTextColor(colors.green)
        if turtle.data.location then
            term.write(turtle.data.location.x)
        end
        
        term.setCursorPos(elms.turtle_data.x, elms.turtle_data.y + 2)
        term.setTextColor(colors.white)
        term.write('Y: ')
        term.setTextColor(colors.green)
        if turtle.data.location then
            term.write(turtle.data.location.y)
        end
        
        term.setCursorPos(elms.turtle_data.x, elms.turtle_data.y + 3)
        term.setTextColor(colors.white)
        term.write('Z: ')
        term.setTextColor(colors.green)
        if turtle.data.location then
            term.write(turtle.data.location.z)
        end
        
        term.setCursorPos(elms.turtle_data.x, elms.turtle_data.y + 4)
        term.setTextColor(colors.white)
        term.write('Facing: ')
        term.setTextColor(colors.green)
        term.write(turtle.data.orientation)
        
        term.setCursorPos(elms.turtle_data.x, elms.turtle_data.y + 5)
        term.setTextColor(colors.white)
        term.write('Fuel: ')
        term.setTextColor(colors.green)
        term.write(turtle.data.fuel_level)
        
        term.setCursorPos(elms.turtle_data.x, elms.turtle_data.y + 6)
        term.setTextColor(colors.white)
        term.write('Items: ')
        term.setTextColor(colors.green)
        term.write(turtle.data.item_count)
        
--        term.setCursorPos(elements.turtle_data.x, elements.turtle_data.y + 7)
--        term.setTextColor(colors.white)
--        term.write('Dist: ')
--        term.setTextColor(colors.green)
--        term.write(turtle.data.distance)
        
        term.setTextColor(colors.white)
        
        term.setCursorPos(elms.turtle_return.x, elms.turtle_return.y)
        term.setBackgroundColor(colors.green)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.write('-RETURN')
        
        term.setCursorPos(elms.turtle_update.x, elms.turtle_update.y)
        term.setBackgroundColor(colors.green)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.write('-UPDATE')
        
        term.setCursorPos(elms.turtle_reboot.x, elms.turtle_reboot.y)
        term.setBackgroundColor(colors.green)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.write('-REBOOT')
        
        term.setCursorPos(elms.turtle_halt.x, elms.turtle_halt.y)
        term.setBackgroundColor(colors.green)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.write('-HALT')
        
        term.setCursorPos(elms.turtle_clear.x, elms.turtle_clear.y)
        term.setBackgroundColor(colors.green)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.write('-CLEAR')
        
        term.setCursorPos(elms.turtle_reset.x, elms.turtle_reset.y)
        term.setBackgroundColor(colors.green)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.write('-RESET')
        
        term.setCursorPos(elms.turtle_find.x, elms.turtle_find.y)
        term.setBackgroundColor(colors.green)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.write('-FIND')
        
        term.setCursorPos(elms.turtle_forward.x, elms.turtle_forward.y)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.green)
        term.write('^')
        term.setTextColor(colors.gray)
        term.setBackgroundColor(background_color)
        term.write('-FORWARD')
        
        term.setCursorPos(elms.turtle_back.x, elms.turtle_back.y)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.green)
        term.write('V')
        term.setTextColor(colors.gray)
        term.setBackgroundColor(background_color)
        term.write('-BACK')
        
        term.setCursorPos(elms.turtle_up.x, elms.turtle_up.y)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.green)
        term.write('^')
        term.setTextColor(colors.gray)
        term.setBackgroundColor(background_color)
        term.write('-UP')
        
        term.setCursorPos(elms.turtle_down.x, elms.turtle_down.y)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.green)
        term.write('V')
        term.setTextColor(colors.gray)
        term.setBackgroundColor(background_color)
        term.write('-DOWN')
        
        term.setCursorPos(elms.turtle_left.x, elms.turtle_left.y)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.green)
        term.write('<')
        term.setTextColor(colors.gray)
        term.setBackgroundColor(background_color)
        term.write('-LEFT')
        
        term.setCursorPos(elms.turtle_right.x, elms.turtle_right.y)
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.green)
        term.write('>')
        term.setTextColor(colors.gray)
        term.setBackgroundColor(background_color)
        term.write('-RIGHT')
        
        term.setTextColor(colors.white)
        if selected == 1 then
            term.setBackgroundColor(colors.gray)
        else
            term.setBackgroundColor(colors.green)
        end
        term.setCursorPos(elms.left.x, elms.left.y)
        term.write('<')
        if selected == #turtle_ids then
            term.setBackgroundColor(colors.gray)
        else
            term.setBackgroundColor(colors.green)
        end
        term.setCursorPos(elms.right.x, elms.right.y)
        term.write('>')
        term.setBackgroundColor(colors.red)
        term.setCursorPos(elms.viewer_exit.x, elms.viewer_exit.y)
        term.write('x')
        
        monitor.setVisible(true)
        monitor.setVisible(false)
        
        sleep(sleep_len)
    end
end


function menu()
    term.redirect(monitor)
    
    while true do
        while #state.monitor_touches > 0 do
            local monitor_touch = table.remove(state.monitor_touches)
            if monitor_touch.x == elms.viewer_exit.x and monitor_touch.y == elms.viewer_exit.y then
                term.redirect(monitor.restore_to)
                return
            elseif monitor_touch.x == elms.menu_toggle.x and monitor_touch.y == elms.menu_toggle.y then
                if state.on then
                    table.insert(state.user_input, 'off')
                else
                    table.insert(state.user_input, 'on')
                end
            elseif monitor_touch.x == elms.menu_update.x and monitor_touch.y == elms.menu_update.y then
                table.insert(state.user_input, 'update')
            elseif monitor_touch.x == elms.menu_return.x and monitor_touch.y == elms.menu_return.y then
                table.insert(state.user_input, 'return')
            elseif monitor_touch.x == elms.menu_reboot.x and monitor_touch.y == elms.menu_reboot.y then
                table.insert(state.user_input, 'reboot')
            elseif monitor_touch.x == elms.menu_halt.x and monitor_touch.y == elms.menu_halt.y then
                table.insert(state.user_input, 'halt')
            elseif monitor_touch.x == elms.menu_clear.x and monitor_touch.y == elms.menu_clear.y then
                table.insert(state.user_input, 'clear')
            elseif monitor_touch.x == elms.menu_reset.x and monitor_touch.y == elms.menu_reset.y then
                table.insert(state.user_input, 'reset')
            end
        end
        
        term.setBackgroundColor(colors.black)
        monitor.clear()
        
        term.setTextColor(colors.white)
        term.setCursorPos(elms.menu_title.x, elms.menu_title.y)
        term.write('MASTER')
        
        for y_offset, line in pairs(menu_lines) do
            term.setCursorPos(elms.menu_title.x, elms.menu_title.y + y_offset)
            for char in line:gmatch"." do
                if char == '#' then
                    if state.on then
                        term.setBackgroundColor(colors.lime)
                    else
                        term.setBackgroundColor(colors.red)
                    end
                else
                    term.setBackgroundColor(colors.black)
                end
                term.write(' ')
            end
        end
        
        term.write('.lua')
        
        term.setBackgroundColor(colors.red)
        term.setCursorPos(elms.viewer_exit.x, elms.viewer_exit.y)
        term.write('x')
        term.setBackgroundColor(colors.green)
        term.setCursorPos(elms.menu_toggle.x, elms.menu_toggle.y)
        term.write('*')
        term.setCursorPos(elms.menu_return.x, elms.menu_return.y)
        term.write('*')
        term.setCursorPos(elms.menu_update.x, elms.menu_update.y)
        term.write('*')
        term.setCursorPos(elms.menu_reboot.x, elms.menu_reboot.y)
        term.write('*')
        term.setCursorPos(elms.menu_halt.x, elms.menu_halt.y)
        term.write('*')
        term.setCursorPos(elms.menu_clear.x, elms.menu_clear.y)
        term.write('*')
        term.setCursorPos(elms.menu_reset.x, elms.menu_reset.y)
        term.write('*')
        term.setBackgroundColor(colors.brown)
        term.setCursorPos(elms.menu_toggle.x + 1, elms.menu_toggle.y)
        term.write('-TOGGLE POWER')
        term.setCursorPos(elms.menu_update.x + 1, elms.menu_update.y)
        term.write('-UPDATE')
        term.setCursorPos(elms.menu_return.x + 1, elms.menu_return.y)
        term.write('-RETURN')
        term.setCursorPos(elms.menu_reboot.x + 1, elms.menu_reboot.y)
        term.write('-REBOOT')
        term.setCursorPos(elms.menu_halt.x + 1, elms.menu_halt.y)
        term.write('-HALT')
        term.setCursorPos(elms.menu_clear.x + 1, elms.menu_clear.y)
        term.write('-CLEAR')
        term.setCursorPos(elms.menu_reset.x + 1, elms.menu_reset.y)
        term.write('-RESET')
        
        monitor.setVisible(true)
        monitor.setVisible(false)
        
        sleep(sleep_len)
    end
end


function draw_location(location, color)
    if location then
        local pixel = {
            -- x = monitor_width  - math.floor((location.x - min_location.x) / zoom_factor),
            -- y = monitor_height - math.floor((location.z - min_location.z) / zoom_factor),
            x = math.floor((location.x - min_location.x) / zoom_factor),
            y = math.floor((location.z - min_location.z) / zoom_factor),
        }
        if pixel.x >= 1 and pixel.x <= monitor_width and pixel.y >= 1 and pixel.y <= monitor_height then
            if color then
                paintutils.drawPixel(pixel.x, pixel.y, color)
            end
            return pixel
        end
    end
end
    

function draw_monitor()
    
    term.redirect(monitor)
    term.setBackgroundColor(colors.black)
    monitor.clear()
    
    zoom_factor = math.pow(2, monitor_zoom_level)
    min_location = {
        x = monitor_location.x - math.floor(monitor_width  * zoom_factor / 2) - 1,
        z = monitor_location.z - math.floor(monitor_height * zoom_factor / 2) - 1,
    }
    
    local mined = {}
    local xz
    for x = min_location.x - ((min_location.x - config.locations.mine_enter.x) % config.grid_width), min_location.x + (monitor_width * zoom_factor), config.grid_width do
        for z = min_location.z, min_location.z + (monitor_height * zoom_factor), zoom_factor do
            xz = x .. ',' .. z
            if not mined[xz] then
                if z > config.locations.mine_enter.z then
                    if monitor_level[x] and monitor_level[x].south.z > z then
                        mined[xz] = true
                        draw_location({x = x, z = z}, colors.lightGray)
                    else
                        draw_location({x = x, z = z}, colors.gray)
                    end
                else
                    if monitor_level[x] and monitor_level[x].north.z < z then
                        mined[xz] = true
                        draw_location({x = x, z = z}, colors.lightGray)
                    else
                        draw_location({x = x, z = z}, colors.gray)
                    end
                end
            end
        end
    end
    
    for x = min_location.x, min_location.x + (monitor_width * zoom_factor), zoom_factor do
        if x > monitor_level.main_shaft.west.x and x < monitor_level.main_shaft.east.x then
            draw_location({x = x, z = config.locations.mine_enter.z}, colors.lightGray)
        else
            draw_location({x = x, z = config.locations.mine_enter.z}, colors.gray)
        end
    end
    
    local pixel
    local special = {}
    
    pixel = draw_location(config.locations.mine_exit, colors.blue)
    if pixel then
        special[pixel.x .. ',' .. pixel.y] = colors.blue
    end
    
    pixel = draw_location(config.locations.mine_enter, colors.blue)
    if pixel then
        special[pixel.x .. ',' .. pixel.y] = colors.blue
    end
    
    -- DRAW STRIP ENDINGS
    for name, strip in pairs(monitor_level) do
        if name ~= 'y' then
            for _, strip_end in pairs(strip) do
                if strip_end.turtles then
                    pixel = draw_location(strip_end, colors.green)
                    if pixel then
                        special[pixel.x .. ',' .. pixel.y] = colors.green
                    end
                end
            end
        end
    end
    
    term.setTextColor(colors.black)
    turtles = {}
    local str_pixel
    for _, turtle in pairs(state.turtles) do
        if turtle.data then
            local location = turtle.data.location
            if location and location.x and location.y then
                pixel = draw_location(location)
                if pixel then
                    term.setCursorPos(pixel.x, pixel.y)
                    str_pixel = pixel.x .. ',' .. pixel.y
                    if special[str_pixel] then
                        term.setBackgroundColor(special[str_pixel])
                    elseif turtle.last_update + config.turtle_timeout < os.clock() then
                        term.setBackgroundColor(colors.red)
                    else
                        term.setBackgroundColor(colors.yellow)
                    end
                    if not turtles[str_pixel] then
                        turtles[str_pixel] = {turtle.id}
                        term.write('-')
                    else
                        table.insert(turtles[str_pixel], turtle.id)
                        if #turtles[str_pixel] <= 9 then
                            term.write(#turtles[str_pixel])
                        else
                            term.write('+')
                        end
                    end
                end
            end
        end
    end
    
    for _, pocket in pairs(state.pockets) do
        local location = pocket.data.location
        if location and location.x and location.y then
            pixel = draw_location(location)
            if pixel then
                term.setCursorPos(pixel.x, pixel.y)
                str_pixel = pixel.x .. ',' .. pixel.y
                if pocket.last_update + config.pocket_timeout < os.clock() then
                    term.setBackgroundColor(colors.red)
                else
                    term.setBackgroundColor(colors.green)
                end
                term.write('M')
            end
        end
    end
    
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.green)
    term.setCursorPos(elms.menu.x, elms.menu.y)
    term.write('*')
    term.setCursorPos(elms.all_turtles.x, elms.all_turtles.y)
    term.write('*')
    term.setCursorPos(elms.mining_turtles.x, elms.mining_turtles.y)
    term.write('*')
    term.setCursorPos(elms.center.x, elms.center.y)
    term.write('*')
    term.setCursorPos(elms.up.x, elms.up.y)
    term.write('N')
    term.setCursorPos(elms.down.x, elms.down.y)
    term.write('S')
    term.setCursorPos(elms.left.x, elms.left.y)
    term.write('W')
    term.setCursorPos(elms.right.x, elms.right.y)
    term.write('E')
    term.setCursorPos(elms.level_up.x, elms.level_up.y)
    term.write('+')
    term.setCursorPos(elms.level_down.x, elms.level_down.y)
    term.write('-')
    term.setCursorPos(elms.zoom_in.x, elms.zoom_in.y)
    term.write('+')
    term.setCursorPos(elms.zoom_out.x, elms.zoom_out.y)
    term.write('-')
    term.setBackgroundColor(colors.brown)
    term.setCursorPos(elms.level_indicator.x, elms.level_indicator.y)
    term.write(string.format('LEVEL: %3d', monitor_level.y))
    term.setCursorPos(elms.zoom_indicator.x, elms.zoom_indicator.y)
    term.write('ZOOM: ' .. monitor_zoom_level)
    term.setCursorPos(elms.x_indicator.x, elms.x_indicator.y)
    term.write('X: ' .. monitor_location.x)
    term.setCursorPos(elms.z_indicator.x, elms.z_indicator.y)
    term.write('Z: ' .. monitor_location.z)
    term.setCursorPos(elms.center_indicator.x, elms.center_indicator.y)
    term.write('-CENTER')
    term.setCursorPos(elms.menu_indicator.x, elms.menu_indicator.y)
    term.write('-MENU')
    term.setCursorPos(elms.all_indicator.x, elms.all_indicator.y)
    term.write('ALL-')
    term.setCursorPos(elms.mining_indicator.x, elms.mining_indicator.y)
    term.write('MINING-')
    
    term.redirect(monitor.restore_to)
end


function touch_monitor(monitor_touch)
    if monitor_touch.x == elms.up.x and monitor_touch.y == elms.up.y then
        monitor_location.z = monitor_location.z - zoom_factor
    elseif monitor_touch.x == elms.down.x and monitor_touch.y == elms.down.y then
        monitor_location.z = monitor_location.z + zoom_factor
    elseif monitor_touch.x == elms.left.x and monitor_touch.y == elms.left.y then
        monitor_location.x = monitor_location.x - zoom_factor
    elseif monitor_touch.x == elms.right.x and monitor_touch.y == elms.right.y then
        monitor_location.x = monitor_location.x + zoom_factor
    elseif monitor_touch.x == elms.level_up.x and monitor_touch.y == elms.level_up.y then
        monitor_level_index = math.min(monitor_level_index + 1, #config.mine_levels)
        select_mine_level()
    elseif monitor_touch.x == elms.level_down.x and monitor_touch.y == elms.level_down.y then
        monitor_level_index = math.max(monitor_level_index - 1, 1)
        select_mine_level()
    elseif monitor_touch.x == elms.zoom_in.x and monitor_touch.y == elms.zoom_in.y then
        monitor_zoom_level = math.max(monitor_zoom_level - 1, 0)
    elseif monitor_touch.x == elms.zoom_out.x and monitor_touch.y == elms.zoom_out.y then
        monitor_zoom_level = math.min(monitor_zoom_level + 1, config.monitor_max_zoom_level)
    elseif monitor_touch.x == elms.menu.x and monitor_touch.y == elms.menu.y then
        menu()
    elseif monitor_touch.x == elms.center.x and monitor_touch.y == elms.center.y then
        monitor_location = {x = config.default_monitor_location.x, z = config.default_monitor_location.z}
    elseif monitor_touch.x == elms.all_turtles.x and monitor_touch.y == elms.all_turtles.y then
        local turtle_ids = {}
        for _, turtle in pairs(state.turtles) do
            if turtle.data then
                table.insert(turtle_ids, turtle.id)
            end
        end
        if #turtle_ids then
            turtle_viewer(turtle_ids)
        end
    elseif monitor_touch.x == elms.mining_turtles.x and monitor_touch.y == elms.mining_turtles.y then
        local turtle_ids = {}
        for _, turtle in pairs(state.turtles) do
            if turtle.data and turtle.data.turtle_type == 'mining' then
                table.insert(turtle_ids, turtle.id)
            end
        end
        if #turtle_ids then
            turtle_viewer(turtle_ids)
        end
    else
        local str_pos = monitor_touch.x .. ',' .. monitor_touch.y
        if turtles[str_pos] then
            turtle_viewer(turtles[str_pos])
        end
    end
end


function init_elements()
    elms = {
        up               = {x = math.ceil(monitor_width / 2), y = 1                            },
        down             = {x = math.ceil(monitor_width / 2), y = monitor_height               },
        left             = {x = 1,                            y = math.ceil(monitor_height / 2)},
        right            = {x = monitor_width,                y = math.ceil(monitor_height / 2)},
        level_up         = {x = monitor_width, y =  1},
        level_down       = {x = monitor_width - 11, y =  1},
        level_indicator  = {x = monitor_width - 10, y =  1},
        zoom_in          = {x = monitor_width, y =  2},
        zoom_out         = {x = monitor_width - 8, y = 2},
        zoom_indicator   = {x = monitor_width - 7, y = 2},
        all_turtles      = {x = monitor_width, y = monitor_height-1},
        all_indicator    = {x = monitor_width - 4, y = monitor_height-1},
        mining_turtles   = {x = monitor_width, y = monitor_height},
        mining_indicator = {x = monitor_width - 7, y = monitor_height},
        menu             = {x =  1, y = monitor_height},
        menu_indicator   = {x =  2, y = monitor_height},
        center           = {x =  1, y =  1},
        center_indicator = {x =  2, y =  1},
        x_indicator      = {x =  1, y =  2},
        z_indicator      = {x =  1, y =  3},
        viewer_exit      = {x =  1, y =  1},
        turtle_face      = {x =  5, y =  2},
        turtle_id        = {x = 16, y =  2},
        turtle_lost      = {x = 13, y =  1},
        turtle_data      = {x =  4, y =  8},
        turtle_return    = {x = 26, y =  8},
        turtle_update    = {x = 26, y =  9},
        turtle_reboot    = {x = 26, y = 10},
        turtle_halt      = {x = 26, y = 11},
        turtle_clear     = {x = 26, y = 12},
        turtle_reset     = {x = 26, y = 13},
        turtle_find      = {x = 26, y = 14},
        turtle_forward   = {x = 14, y = 16},
        turtle_back      = {x = 14, y = 18},
        turtle_up        = {x = 27, y = 16},
        turtle_down      = {x = 27, y = 18},
        turtle_left      = {x = 10, y = 17},
        turtle_right     = {x = 18, y = 17},
        menu_title       = {x =  9, y =  3},
        menu_toggle      = {x = 10, y = 11},
        menu_update      = {x = 10, y = 13},
        menu_return      = {x = 10, y = 14},
        menu_reboot      = {x = 10, y = 15},
        menu_halt        = {x = 10, y = 16},
        menu_clear       = {x = 10, y = 17},
        menu_reset       = {x = 10, y = 18},
    }
end


function select_mine_level()
    monitor_level = state.mine[config.mine_levels[monitor_level_index].level]
end


function step()
    while #state.monitor_touches > 0 do
        touch_monitor(table.remove(state.monitor_touches))
    end
    draw_monitor()
    monitor.setVisible(true)
    monitor.setVisible(false)
    sleep(sleep_len)
end


function main()
    sleep_len = 0.3
    
    local attached = peripheral.find('monitor')
    
    if not attached then
        error('No monitor connected.')
    end
    
    monitor_size = {attached.getSize()}
    monitor_width = monitor_size[1]
    monitor_height = monitor_size[2]
    
    if monitor_width < 29 or monitor_height < 12 then -- Must be at least that big
        return
    end
    
    monitor = window.create(attached, 1, 1, monitor_width, monitor_height)
    monitor.restore_to = term.current()
    monitor.clear()
    monitor.setVisible(false)
    monitor.setCursorPos(1, 1)
    
    monitor_location = {x = config.locations.mine_enter.x, z = config.locations.mine_enter.z}
    monitor_zoom_level = config.default_monitor_zoom_level
    
    init_elements()
    
    while not state.mine do
        sleep(0.5)
    end
    
    monitor_level_index = 1
    select_mine_level()
    
    state.monitor_touches = {}
    while true do
        local status, caught_error = pcall(step)
        if not status then
            term.redirect(monitor.restore_to)
            error(caught_error)
        end
    end
end


main()