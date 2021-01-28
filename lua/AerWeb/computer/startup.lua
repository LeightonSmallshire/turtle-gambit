os.setComputerLabel("AerWeb Control Hub")
require('config.lua')

proto = "AerWeb"
turtles = {}
tasks = {}

peripheral.find("modem", rednet.open)

multishell.setTitle(multishell.launch({}, 'aer_server.lua'), 'AerServer')
multishell.setTitle(multishell.launch({}, ''), '')
multishell.setTitle(multishell.launch({}, ''), '')
multishell.setTitle(multishell.launch({}, ''), '')
