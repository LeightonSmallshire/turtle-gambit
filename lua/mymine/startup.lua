-- installer script
if fs.exists('/startup.lua') then
    print('Local startup taking precedence over AerWeb.')
    return shell.run('//startup.lua')
end

if turtle then
    if ~fs.exists('hubID') then
        return print('Hub must be installed first.')
    end
    -- add turtle id to the children file
    local f = fs.open('children.lsv', 'a')
    f.writeline(tostring(os.computerID()))
    f.close()
    -- copy files then run locally
    fs.copy('turtle/*', '/')
    fs.copy('hubID', '/hubID')
    shell.run('/startup.lua')
else
    local f = fs.open('hubID', 'w')
    f.write(tostring(os.getComputerID()))
    f.close()
    -- run from disk
    shell.run('./hub/startup.lua')
end

-- todo; pocket installed separately (by hub)
