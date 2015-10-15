--CHANGE LOG----------------
--Creates random input arrays based on set probability ratios.
--Has a reset function that resets the whole game.
--Inputs the array to the emulator so Mario moves.
--Jumps are always fully charged.
 
 
--math.random(1,10) Does include 1, does include 10.
--print(tonumber("AF20", 16))
-- 30 frames to jump
--0x071A Current screen
--[[
 * unit -> string *)
            | 1 -> "down "
            | 2 -> "left "
            | 3 -> "right "
            | 4 -> "A "
            | 5 -> "START " *)]]--
------------------------------------------------------------------------------------------------DECLARATIONS
arrayLength = 11000
t = {} --Our table for inputs. Going by frames. ["TIME"] ["pixelWorld"] ["WORLD"] will be set to time it took to get to the X pixel. pixelWorld is screen*1000 + X on screen.
t1 = {} --Other table for inputs.
 
t["t"] = true --Used for determining which array we're on. t or t1.
t1["t"] = false
 
cT = t --Current table that we're testing./Table to test.
 
mRate = 5 --mutation rate percent.
 
tC = 0 --Counts on what array we're testing. So with each test it increases by 1.
 
wW = 0 --Which array to mutate.
 
jF = 0 --Number of frame we're jumping.
p = 1 --Frame number the input array is on.
 
l1 = memory.readbyte(0x075A) --Lives --l1 sets every odd frame
l2 = memory.readbyte(0x075A) --l2 sets every even frame
 
x1 = 0 --x --x1 sets every odd frame
x2 = 0 --x2 sets every even frame.
------------------------------------------------------------------------------------------------DECLARATIONS
 
function generateInputs(inp) --inp is how many inputs we generate for our array.
                             --Cannot have both left and right pressed.    
                             --Holds jump for maximum time.
    inpts = {};
    for y = 1, inp, 1 do
        r = math.random(1,100);
        
        if r >= 0 and r <= 5 then
            inpts["down"] = true;
        else
            inpts["down"] = false;
        end
        
        if r >= 6 and r <= 15 then
            if not inpts["right"] == true then
                inpts["left"] = true;
            end
        else
            inpts["left"] = false;
        end
        
        if r >= 16 and r <= 75 then
            if not inpts["left"] == true then
                inpts["right"] = true;
            end
        else
            inpts["right"] = false;
        end
        
        if jF > 30 then
            inpts["A"] = false;
            jF = 0;
            if r >= 76 and r <= 100 then
                inpts["A"] = true;
            else
                inpts["A"] = false;
            end
        else
            inpts["A"] = true;
        end
    end
    return inpts;
end
            
function generateArray(arr)
    local inputs = {};
    inputs["START"] = true;
    arr[1] = inputs;
    
    for x = 2, arrayLength, 1 do --Includes 1 and arrayLength
        jF = jF + 1;
        arr[x] = generateInputs(math.random(1,5));
    end
end
 
 
function checkForReset()
    if memory.readbyte(0x000E) == 11 then return true end --player's state is Dying.
    
    if p % 2 == 1 then --If we're on an odd frame.
        if l2 - l1 >= 1 then return true end --And if our life that was updated this frame went one down from the one we updated last frame.
    else --If we're on an even frame
        if l1 - l2 >= 1 then return true end
    end
end    
 
function reset()--Resets/updates the lua logic. x1 odd frame
    if p % 2 == 1 then --Used to update the pixelWorld. If we're on an odd frame.
        cT["pixelWorld"] = x1
    else --If we're on an even frame
        cT["pixelWorld"] = x2
    end
    
    cT["pixelWorld"] = (memory.readbyte(0x071A) * 10000) + cT["pixelWorld"]
    print(cT["pixelWorld"])
    print(cT["t"])
    
    if tC == 2 then --This is where we compare the 2 results, taking the best and mutating it.
        if t["pixelWorld"] > t1["pixelWorld"] then --cT is always t1 here.
            print("t won t1.")
            print("cT is now t1.")
            print(t["pixelWorld"])
            print(t1["pixelWorld"])
            t1 = clone(cT); --t1 becomes a record of this best array.
            wW = "t";
            cT = t;
            gameReset();
        else--If t1 won then t becomes a record.
            print("t1 won t.")
            print("cT is now t1.")
            print(t["pixelWorld"])
            print(t1["pixelWorld"])
            t = clone(cT); --t becomes a record of this best array since it was worse.
            wW = "t1"
            cT = t1
            gameReset();
        end
    end--t was best, mutated t, t1 is now a record of t. tC is 3.
    
    if tC > 2 then  
        if wW == "t" then --if t won and t1 is the record.
            if t["pixelWorld"] > t1["pixelWorld"] then --If t(the one we just tested) scored better than the record which is t1, we'll replace the record and mutate t.
                t1 = clone(t); --t1 becomes a record of this best array.
                wW = "t"
                cT = t
                print("t won t1(Record)")
                print("cT is now t1.")
                print(t["pixelWorld"])
                print(t1["pixelWorld"])
                gameReset();
            else--if t won last round but t was worse than record which is t1. Then we revert to the record and mutate t again.
                t = clone(t1);
                wW = "t"
                cT = t
                print("t lost t1(Record) Reverting back to record which is t1.")
                print("cT is now t.")
                print(t["pixelWorld"])
                print(t1["pixelWorld"])
                gameReset();
            end
        else--if t1 won and t is the record.
            if t1["pixelWorld"] > t["pixelWorld"] then --If t1(the one we just tested) scored better than the record which is t, we'll replace the record and mutate t1.
                t = clone(t1); --t becomes a record of this best array.
                wW = "t1"
                cT = t1
                print("t1 won t(Record)")
                print("cT is now t1.")
                print(t["pixelWorld"])
                print(t1["pixelWorld"])
                gameReset();
            else--if t1 won last round but t1 was worse than record which is t. Then we revert to the record and mutate t again.
                t1 = clone(t);
                wW = "t1"
                cT = t1
                print("t1 lost t(Record) Reverting back to record which is t.")
                print("cT is now t1.")
                print(t["pixelWorld"])
                print(t1["pixelWorld"])
                gameReset();
            end
        end
    end
    --THIS HERE ONLY FOR THE FIRST RUN.
    if(cT["t"]) then cT = t1 else cT = t end--Changes between 2 arrays. We start with t.
    
    emu.softreset();
    gameReset();
end
 
function gameReset()--Leads to mainLoop.
    emu.softreset();
    
    for x = 0, 45, 1 do --Skip 45 frames, waiting for game to load.
        emu.frameadvance();
    end
    joypad.set(1,{["start"] = true});--Presses on start to start game.
    emu.frameadvance();
    
    p = 1;
    print("RESET");
    mainLoop();
end
 
function executeInputs()--Executes the inputs and checks if player died.
    --print(memory.readbyte(0x0086))
    if p % 2 == 1 then x1 = memory.readbyte(0x0086) else x2 = memory.readbyte(0x0086) end--Updates the x.
    if p % 2 == 1 then l1 = memory.readbyte(0x075A) else l2 = memory.readbyte(0x075A) end--Updates the lives.
            
    if checkForReset() then reset() end--Checks if Mario died and resets if needed.
            
    p = p + 1 --Frame number the input array is on.
 
    joypad.set(1, cT[p]);
    emu.frameadvance();
end
 
function mutate(qq)
    for m = 10 , ((arrayLength * mRate / 100) - 1), 1 do
        qq[math.random(2, arrayLength)] = generateInputs(math.random(1,5))
    end
end
 
function mainLoop()--Main loop.
    tC = tC + 1;
    if tC > 2 then--mutate winner
        if wW == "t" then
            print("mutating t")
            mutate(t)
        else
            print("mutating t1")
            mutate(t1)
        end
    else
        generateArray(cT);
    end
    while (true) do  
        emu.unpause()
        emu.speedmode("maximum");
    
        executeInputs();
        
        gui.drawtext(50, 50, "Current X: " .. memory.readbyte(0x0086))
    end
end
 
 
function clone(tt) -- deep-copy a table
    if type(tt) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(tt) do
        if type(v) == "table" then
            target[k] = clone(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end
 
gameReset(); --EXECUTION STARTS HERE----------------- 