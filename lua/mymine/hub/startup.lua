os.setComputerLabel("MasterMine Control Hub")
require('config.lua')

proto = "MMine"
turtles, pockets, input_q = {}, {}, {}
-- os.loadAPI(name) => name = require('name.lua')
os.loadAPI('config.lua')
os.loadAPI('state.lua')
os.loadAPI('basics.lua')

peripheral.find("modem", rednet.open)

-- if updated, update

multishell.setTitle(multishell.launch({}, 'aer_server.lua'), 'AerServer')
multishell.setTitle(multishell.launch({}, ''), '')
multishell.setTitle(multishell.launch({}, ''), '')
multishell.setTitle(multishell.launch({}, ''), '')
