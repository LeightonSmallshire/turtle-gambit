"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
function onConnect(req, res) {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Hello World\n');
}
module.exports = onConnect;
//# sourceMappingURL=page.js.map