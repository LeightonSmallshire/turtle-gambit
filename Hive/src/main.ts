import * as http from "http";
import * as websocket from "ws";

const querystring = require('querystring');

const world = require('./world.js');
const turtle = require('./turtle.js');
const page = require('./page.js')

// Setup web server
const server = http.createServer(page);

// Setup turtle server
const wss = new websocket.Server({server: server, path: '/hive'});
wss.on('connection', turtle.onConnect);

server.listen(9000);
console.log('Ready');
