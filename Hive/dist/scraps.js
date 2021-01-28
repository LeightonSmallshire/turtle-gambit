"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const assert_1 = __importDefault(require("assert"));
function strip(s, chars = ' \n\t') {
    let j = 0, k = s.length;
    for (let i = 0; i < chars.length; i++) {
        const c = chars[i];
        while (s[j] == c)
            j++;
        while (s[k] == c)
            k--;
    }
    return s.slice(j, k);
}
function parseLua(s) {
    assert_1.default(s.length > 0);
    let str = /^"((?:[^"\\]|\\.)*)"/s.exec(s);
    if (str)
        return str[1];
    let int = /^\d+/s.exec(s);
    if (int)
        return parseInt(int[0]);
    if (s[0] === '{') { // table
        let table = {};
        const re = /\s*({.*?}|"[^,]*"|\[[^,]+|[^{",]+)/sg;
        while (true) {
            let match = re.exec(s.slice(1, s.length - 1));
            if (!match)
                break;
            const substr = strip(match[1]);
            if (!substr)
                break;
            const eq_index = substr.indexOf('=');
            if (eq_index > 0) {
                if (substr[0] == '[') { // [ key ] = value
                    let key = parseLua(strip(substr.slice(1, substr.indexOf(']') - 1)));
                    // @ts-ignore
                    table[key] = parseLua(strip(substr.slice(eq_index + 1)));
                    continue;
                }
                let varName = /[a-zA-Z_]\w*/.exec(substr);
                if (varName) { // key = value
                    table[varName[0]] = parseLua(strip(substr.slice(eq_index + 1)));
                    continue;
                }
            }
            else { // no equals
                table[Object.keys(table).length] = parseLua(substr);
                continue;
            }
            throw "Could not parse lua table";
        }
        return table;
    }
    throw "Could not parse lua data";
}
const a = parseLua('{\na = 2,\n b = {\n 2,\n a = 123,\n },\n}');
console.log(a);
//# sourceMappingURL=scraps.js.map