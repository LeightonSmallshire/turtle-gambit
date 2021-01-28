"use strict";
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const http = __importStar(require("http"));
const websocket = __importStar(require("ws"));
const querystring = require('querystring');
const world = require('./world.js');
const turtle = require('./turtle.js');
const page = require('./page.js');
// Setup web server
const server = http.createServer(page);
// Setup turtle server
const wss = new websocket.Server({ server: server, path: '/hive' });
wss.on('connection', turtle.onConnect);
server.listen(9000);
console.log('Ready');
//# sourceMappingURL=main.js.map