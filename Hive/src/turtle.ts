import {WebSocket} from 'ws';
import {randomBytes} from 'crypto';
import {EventEmitter} from 'events';
import * as http from "http";
import * as querystring from "querystring";

const fs = require('fs');
const names = fs.readFileSync('./src/names.txt').toString().split('\n');
const DirectionDeltas = [[0, -1], [1, 0], [0, 1], [-1, 0]]

enum Direction { NORTH, EAST, SOUTH, WEST }

const nonces = new Set();
let turtles = {};

interface Stack {
    count: number;
    name: string;
    damage: number;
}

interface Position {
    x: number
    y: number
    z: number
    d: Direction
}

// in order NESW

// function lua2json(lua) {
//     return JSON.parse(lua
//         .replace(/\[([^\[\]]+)]\s*=/g, (s, k) => `${k} :`) // convert [ key ] = value
//         .replace(/,(\s*)}/gm, (s, k) => `${k}}`) // remove trailing commas?
//     )
// } // Could use, but only if all values have keys

function pickName() {
    while (true) { // todo; names now a property of the values
        let name = names[Math.floor(Math.random() * names.length)]
        if (!(name in turtles)) return name
    }
}

function getNonce(): string {
    let nonce;
    while (!nonce || nonce in nonces)
        nonce = randomBytes(2).toString('hex');
    nonces.add(nonce);
    return nonce;
}

export class Turtle extends EventEmitter {
    ws: WebSocket;
    // Turtle data
    id: number = -1;
    name: string = null;
    fuel: number = 0;
    maxFuel: number = 0;
    selectedSlot: number = 0;
    inventory: (Stack | null)[] = [];
    pos: Position = {x: 0, y: 0, z: 0, d: null};

    constructor(ws: WebSocket, name: string) {
        super()
        turtles[ws] = this;
        this.ws = ws;
        this.name = name;

        if (!this.name || this.name === '_') {
            this.name = pickName()
            ws.send(this.name)
        }
        console.log("Turtle connected:", this.name)
    }

    exec<T>(code: string, taskName?: string): Promise<T> {
        taskName = taskName || code;
        return new Promise((resolve, reject) => {
            const nonce = getNonce();
            const handler = (res: string) => {
                try {
                    let [r_nonce, success, ...data] = JSON.parse(res);
                    if (r_nonce === nonce) {
                        if (data.length === 1) data = data[0] as T;
                        this.ws.off('message', handler)
                        if (success) return resolve(data as T)
                        else return reject(`${this.name} failed task "${taskName}" with reason: ${data}`);
                    }
                } catch (e) {
                    this.ws.off('message', handler)
                    console.error(`${this.name} caused server error:\n${e}`);
                }
            }
            this.ws.on('message', handler)
            this.ws.send(`${nonce}${code}`)
        })
    }

    protected simpleExec<T>(code): Promise<T> {
        return this.exec<T>(`return ${code}()`, code)
    }

    // ------   Info   ------
    getFuelLevel = () => this.simpleExec("turtle.getFuelLevel")
    getFuelLimit = () => this.simpleExec("turtle.getFuelLimit")

    // ------ Actions  ------
    dig = () => this.simpleExec("turtle.dig")
    digUp = () => this.simpleExec("turtle.digUp")
    digDown = () => this.simpleExec("turtle.digDown")

    place = () => this.simpleExec("turtle.place")
    placeUp = () => this.simpleExec("turtle.placeUp")
    placeDown = () => this.simpleExec("turtle.placeDown")

    drop = () => this.simpleExec("turtle.drop")
    dropUp = () => this.simpleExec("turtle.dropUp")
    dropDown = () => this.simpleExec("turtle.dropDown")

    detect = () => this.simpleExec("turtle.detect")
    detectUp = () => this.simpleExec("turtle.detectUp")
    detectDown = () => this.simpleExec("turtle.detectDown")

    attack = () => this.simpleExec("turtle.attack")
    attackUp = () => this.simpleExec("turtle.attackUp")
    attackDown = () => this.simpleExec("turtle.attackDown")

    suck = () => this.simpleExec("turtle.suck")
    suckUp = () => this.simpleExec("turtle.suckUp")
    suckDown = () => this.simpleExec("turtle.suckDown")

    inspect = () => this.simpleExec("turtle.inspect")
    inspectUp = () => this.simpleExec("turtle.inspectUp")
    inspectDown = () => this.simpleExec("turtle.inspectDown")

    // ------ movement ------
    protected async move(dir: string): Promise<boolean> {
        const r = await this.exec<boolean>(`turtle.${dir}()`);
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
        return r
    }

    up = () => this.move('up');
    down = () => this.move('down');
    back = () => this.move('back');
    forward = () => this.move('forward');
    turnLeft = () => this.move('turnLeft');
    turnRight = () => this.move('turnRight');
}

function onConnect(ws: WebSocket, request: http.IncomingMessage) {
    const query = request.url.split('?').pop();
    const params = querystring.parse(query);
    let name = <string>params['l'];

    let t = new Turtle(ws, name);

    (async () => { // init turtle
        // let err = t.exec('error');
        await t.exec('print("HiveMind V0.1\\n\\tInspired by @Ottomated_")');
        let pos = await t.exec<[number, number, number]>('return gps.locate()');
        if (pos) [t.pos.x, t.pos.y, t.pos.z] = pos;
        let a = 1;
    })();

    setInterval((async () => t.exec('')), 1000);

    ws.on('message', function incoming(message) {
        console.log('received: %s', message);
    });

    ws.on('close', function () {
        delete turtles[ws];
        console.log("Turtle disconnected:", name)
    })
}


module.exports = {
    Turtle,
    turtleList: turtles,
    onConnect
}
