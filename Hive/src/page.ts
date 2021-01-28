import * as http from "http";

function onConnect(req: http.IncomingMessage, res: http.ServerResponse) {
    res.writeHead(200, {'Content-Type': 'text/plain'});
    res.end('Hello World\n');
}


module.exports = onConnect;
