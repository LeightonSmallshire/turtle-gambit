"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result["default"] = mod;
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
const crypto_1 = require("crypto");
const events_1 = require("events");
const querystring = __importStar(require("querystring"));
const fs = require('fs');
const names = fs.readFileSync('./src/names.txt').toString().split('\n');
const DirectionDeltas = [[0, -1], [1, 0], [0, 1], [-1, 0]];
var Direction;
(function (Direction) {
    Direction[Direction["NORTH"] = 0] = "NORTH";
    Direction[Direction["EAST"] = 1] = "EAST";
    Direction[Direction["SOUTH"] = 2] = "SOUTH";
    Direction[Direction["WEST"] = 3] = "WEST";
})(Direction || (Direction = {}));
const nonces = new Set();
let turtles = {};
// in order NESW
// function lua2json(lua) {
//     return JSON.parse(lua
//         .replace(/\[([^\[\]]+)]\s*=/g, (s, k) => `${k} :`) // convert [ key ] = value
//         .replace(/,(\s*)}/gm, (s, k) => `${k}}`) // remove trailing commas?
//     )
// } // Could use, but only if all values have keys
function pickName() {
    while (true) { // todo; names now a property of the values
        let name = names[Math.floor(Math.random() * names.length)];
        if (!(name in turtles))
            return name;
    }
}
function getNonce() {
    let nonce;
    while (!nonce || nonce in nonces)
        nonce = crypto_1.randomBytes(2).toString('hex');
    nonces.add(nonce);
    return nonce;
}
class Turtle extends events_1.EventEmitter {
    constructor(ws, name) {
        super();
        // Turtle data
        this.id = -1;
        this.name = null;
        this.fuel = 0;
        this.maxFuel = 0;
        this.selectedSlot = 0;
        this.inventory = [];
        this.pos = { x: 0, y: 0, z: 0, d: null };
        // ------   Info   ------
        this.getFuelLevel = () => this.simpleExec("turtle.getFuelLevel");
        this.getFuelLimit = () => this.simpleExec("turtle.getFuelLimit");
        // ------ Actions  ------
        this.dig = () => this.simpleExec("turtle.dig");
        this.digUp = () => this.simpleExec("turtle.digUp");
        this.digDown = () => this.simpleExec("turtle.digDown");
        this.place = () => this.simpleExec("turtle.place");
        this.placeUp = () => this.simpleExec("turtle.placeUp");
        this.placeDown = () => this.simpleExec("turtle.placeDown");
        this.drop = () => this.simpleExec("turtle.drop");
        this.dropUp = () => this.simpleExec("turtle.dropUp");
        this.dropDown = () => this.simpleExec("turtle.dropDown");
        this.detect = () => this.simpleExec("turtle.detect");
        this.detectUp = () => this.simpleExec("turtle.detectUp");
        this.detectDown = () => this.simpleExec("turtle.detectDown");
        this.attack = () => this.simpleExec("turtle.attack");
        this.attackUp = () => this.simpleExec("turtle.attackUp");
        this.attackDown = () => this.simpleExec("turtle.attackDown");
        this.suck = () => this.simpleExec("turtle.suck");
        this.suckUp = () => this.simpleExec("turtle.suckUp");
        this.suckDown = () => this.simpleExec("turtle.suckDown");
        this.inspect = () => this.simpleExec("turtle.inspect");
        this.inspectUp = () => this.simpleExec("turtle.inspectUp");
        this.inspectDown = () => this.simpleExec("turtle.inspectDown");
        this.up = () => this.move('up');
        this.down = () => this.move('down');
        this.back = () => this.move('back');
        this.forward = () => this.move('forward');
        this.turnLeft = () => this.move('turnLeft');
        this.turnRight = () => this.move('turnRight');
        turtles[ws] = this;
        this.ws = ws;
        this.name = name;
        if (!this.name || this.name === '_') {
            this.name = pickName();
            ws.send(this.name);
        }
        console.log("Turtle connected:", this.name);
    }
    exec(code, taskName) {
        taskName = taskName || code;
        return new Promise((resolve, reject) => {
            const nonce = getNonce();
            const handler = (res) => {
                try {
                    let [r_nonce, success, ...data] = JSON.parse(res);
                    if (r_nonce === nonce) {
                        if (data.length === 1)
                            data = data[0];
                        this.ws.off('message', handler);
                        if (success)
                            return resolve(data);
                        else
                            return reject(`${this.name} failed task "${taskName}" with reason: ${data}`);
                    }
                }
                catch (e) {
                    this.ws.off('message', handler);
                    console.error(`${this.name} caused server error:\n${e}`);
                }
            };
            this.ws.on('message', handler);
            this.ws.send(`${nonce}${code}`);
        });
    }
    simpleExec(code) {
        return this.exec(`return ${code}()`, code);
    }
    // ------ movement ------
    move(dir) {
        return __awaiter(this, void 0, void 0, function* () {
            const r = yield this.exec(`turtle.${dir}()`);
            if (r) {
                this.fuel--;
                const delta = DirectionDeltas[this.pos.d];
                switch (dir) {
                    case 'up':
                        this.pos.y++;
                        break;
                    case 'down':
                        this.pos.y--;
                        break;
                    case 'turnLeft':
                        this.pos.d = (this.pos.d - 1) % 4;
                        break;
                    case 'turnRight':
                        this.pos.d = (this.pos.d + 1) % 4;
                        break;
                    case 'forward':
                        this.pos.x += delta[0];
                        this.pos.z += delta[1];
                        break;
                    case 'back':
                        this.pos.x -= delta[0];
                        this.pos.z -= delta[1];
                        break;
                }
                // todo; update world data
            }
            return r;
        });
    }
}
exports.Turtle = Turtle;
function onConnect(ws, request) {
    const query = request.url.split('?').pop();
    const params = querystring.parse(query);
    let name = params['l'];
    let t = new Turtle(ws, name);
    (() => __awaiter(this, void 0, void 0, function* () {
        // let err = t.exec('error');
        yield t.exec('print("HiveMind V0.1\\n\\tInspired by @Ottomated_")');
        let pos = yield t.exec('return gps.locate()');
        if (pos)
            [t.pos.x, t.pos.y, t.pos.z] = pos;
        let a = 1;
    }))();
    setInterval((() => __awaiter(this, void 0, void 0, function* () { return t.exec(''); })), 1000);
    ws.on('message', function incoming(message) {
        console.log('received: %s', message);
    });
    ws.on('close', function () {
        delete turtles[ws];
        console.log("Turtle disconnected:", name);
    });
}
module.exports = {
    Turtle,
    turtleList: turtles,
    onConnect
};
//# sourceMappingURL=turtle.js.map