module scripts.hbsscene;

import system.debugwriteln;
import system.uintreader;
import variables;

int currentByte = 0;

void executerMainLoop(ref ubyte[] loadedScript) {
    debugWriteln("currentByte: ", currentByte);
    switch (loadedScript[currentByte]) {
        case OpCodes.SET:
            debugWriteln("opcode SET mainloop");
            ushort varIndex = readUInt16(loadedScript, currentByte + 1);
            ushort value = readUInt16(loadedScript, currentByte + 3);
            debugWriteln("values: ", varIndex, value);
            scriptVariables[varIndex] = cast(int)value;
            currentByte += 5;
            break;
            
        case OpCodes.ADD:
            debugWriteln("opcode ADD mainloop");
            ushort varIndex = readUInt16(loadedScript, currentByte + 1);
            ushort value = readUInt16(loadedScript, currentByte + 3);
            debugWriteln("values: ", varIndex, value);
            scriptVariables[varIndex] += cast(int)value;
            currentByte += 5;
            break;
            
        case OpCodes.SUB:
            debugWriteln("opcode SUB mainloop");
            ushort varIndex = readUInt16(loadedScript, currentByte + 1);
            ushort value = readUInt16(loadedScript, currentByte + 3);
            debugWriteln("values: ", varIndex, value);
            scriptVariables[varIndex] -= cast(int)value;
            currentByte += 5;
            break;
            
        case OpCodes.MUL:
            debugWriteln("opcode MUL mainloop");
            ushort varIndex = readUInt16(loadedScript, currentByte + 1);
            ushort value = readUInt16(loadedScript, currentByte + 3);
            debugWriteln("values: ", varIndex, value);
            scriptVariables[varIndex] *= cast(int)value;
            currentByte += 5;
            break;
            
        case OpCodes.DIV:
            debugWriteln("opcode DIV mainloop");
            ushort varIndex = readUInt16(loadedScript, currentByte + 1);
            ushort value = readUInt16(loadedScript, currentByte + 3);
            debugWriteln("values: ", varIndex, value);
            scriptVariables[varIndex] /= cast(int)value;
            currentByte += 5;
            break;
            
        case OpCodes.PRINT:
            debugWriteln("PRINT: ", scriptVariables[cast(int)readUInt16(loadedScript, currentByte + 1)]);
            currentByte += 3;
            break;

        case OpCodes.GOTO:
            currentByte = readUInt32(loadedScript, currentByte + 1);
            debugWriteln("goto to: ", currentByte);
            break;

        case OpCodes.ENDLOOP:
            debugWriteln("endloop");
            currentByte += 1;
            currentCommandIndex += 1;
            mainLoopScript = false;
            break;
        
        case OpCodes.DIALOGBOX:
            break;

        case OpCodes.IF:
            debugWriteln("IF without vars");
            int firstValue = readUInt16(loadedScript, currentByte+1);
            int secondValue = readUInt16(loadedScript, currentByte+3);
            int equality = cast(int)loadedScript[currentByte+5];
            debugWriteln("values to compare: ", firstValue, " ", secondValue);
            if (equality == 0) { // <
                debugWriteln("< op");
                if (firstValue < secondValue) {
                    currentByte += 6;
                    break;
                } else {
                    while (loadedScript[currentByte] != OpCodes.ENDIF) {
                        currentByte += 1;
                    }
                }
            }
            if (equality == 1) { // >
                debugWriteln("> op");
                if (firstValue > secondValue) {
                    currentByte += 6;
                    break;
                } else {
                    while (loadedScript[currentByte] != OpCodes.ENDIF) {
                        currentByte += 1;
                    }
                }
            }
            if (equality == 2) { // ==
                debugWriteln("== op");
                if (firstValue == secondValue) {
                    currentByte += 6;
                    break;
                } else {
                    while (loadedScript[currentByte] != OpCodes.ENDIF) {
                        currentByte += 1;
                    }
                }
            }
            if (equality == 3) { // !=
                debugWriteln("!= op");
                if (firstValue != secondValue) {
                    currentByte += 6;
                    break;
                } else {
                    while (loadedScript[currentByte] != OpCodes.ENDIF) {
                        currentByte += 1;
                    }
                }
            }
            break;

        case OpCodes.VARIABLESIF:
            debugWriteln("IF with variables");
            int firstValue = scriptVariables[cast(int)readUInt16(loadedScript, currentByte + 1)];
            int secondValue = scriptVariables[cast(int)readUInt16(loadedScript, currentByte + 3)];
            int equality = cast(int)loadedScript[currentByte+5];
            debugWriteln("values to compare: ", firstValue, " ", secondValue);
            if (equality == 0) { // <
                if (firstValue < secondValue) {
                    currentByte += 6;
                    break;
                } else {
                    while (loadedScript[currentByte] != OpCodes.ENDIF) {
                        currentByte += 1;
                    }
                }
            }
            if (equality == 1) { // >
                if (firstValue > secondValue) {
                    currentByte += 6;
                    break;
                } else {
                    while (loadedScript[currentByte] != OpCodes.ENDIF) {
                        currentByte += 1;
                    }
                }
            }
            if (equality == 2) { // ==
                if (firstValue == secondValue) {
                    currentByte += 6;
                    break;
                } else {
                    while (loadedScript[currentByte] != OpCodes.ENDIF) {
                        currentByte += 1;
                    }
                }
            }
            if (equality == 3) { // !=
                if (firstValue != secondValue) {
                    currentByte += 6;
                    break;
                } else {
                    while (loadedScript[currentByte] != OpCodes.ENDIF) {
                        currentByte += 1;
                    }
                }
            }
            break;
        
        case OpCodes.ENDIF:
            currentByte += 1;
            break;
        
        default:
            debugWriteln("unknown opcode in main loop: ", loadedScript[currentByte]);
            currentByte += 1;
            break;
    }
}