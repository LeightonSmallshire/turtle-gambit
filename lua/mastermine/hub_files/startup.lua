-- SET LABEL
os.setComputerLabel('Hub')

-- INITIALIZE APIS
os.loadAPI('/apis/config')
os.loadAPI('/apis/state')
os.loadAPI('/apis/basics')


-- OPEN REDNET
peripheral.find("modem", rednet.open)

-- IF UPDATED PRINT "UPDATED"
if fs.exists('/updated') then
    fs.delete('/updated')
    print('UPDATED')
    state.updated = true
end


-- LAUNCH PROGRAMS AS SEPARATE THREADS
multishell.setTitle(multishell.launch({}, '/user.lua'), 'user') -- queue pseudo-shell's inputs?
multishell.setTitle(multishell.launch({}, '/report.lua'), 'report') -- constantly send hub_report messages
multishell.setTitle(multishell.launch({}, '/monitor.lua'), 'monitor') -- controls monitor, adds actions to state
multishell.setTitle(multishell.launch({}, '/events.lua'), 'events') -- handles rednet & monitor events
multishell.setTitle(multishell.launch({}, '/whosmineisitanyway.lua'), 'whosmine')
