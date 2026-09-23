-------------------------
------functions.lua------
-- an libary built by Silver (Silberstern012)
-- contains many useful functions,
-- drawing methods, custom characters
-- and more
-------------------------
-- please do not say it is yours
-------------------------
-- built in year 2026 by Silver :3
-------------------------



local function switch(element)
    local Table = {
        ["Value"] = element,
        ["DefaultFunction"] = nil,
        ["Functions"] = {}
    }

    Table.case = function(testElement, callback)
        Table.Functions[testElement] = callback
        return Table
    end

    Table.default = function(callback)
        Table.DefaultFunction = callback
        return Table
    end

    Table.process = function()
        local Case = Table.Functions[Table.Value]
        if Case then
            Case()
        elseif Table.DefaultFunction then
            Table.DefaultFunction()
        end
    end

    return Table
end

--[[
usage of switch

switch(inp)
    .case(1, function()
        print(1)
    end)

    .case(2, function()
        print(2)
    end)

    .default(function()
        print("not allowed")
    end)

    .process()
]]--

local function round(num)
    return math.floor(num + 0.5)
end

local function blit(monitor, str, tc, bgc)
    strlen = #str
    textColor = ""
    bgColor = ""

    for c=1, strlen do
        textColor = textColor..tc
        bgColor = bgColor..bgc
    end
    monitor.blit(str,textColor, bgColor)
end    

local function pixel(monitor, pos, color)
    color = color or 1
    monitor.setCursorPos(pos[1],pos[2])
    monitor.blit("  ", color..color, color..color)
end

local function writeSmolChar(monitor, pos, character, color1, color2)
    character = character or " "
    color1 = color1 or 1
    color2 = color2 or 7
    b = "f"
    p = color1
    s = color2
    if pos[1] == nil then return
    elseif pos[2] == nil then return
    else
        monitor.setCursorPos(pos[1],pos[2])
        switch(character)
            .case("a", function() 
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("b", function() 
                monitor.blit("     ",p..p..s..b..b,p..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..s..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("c", function() 
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..b..b..b,p..s..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..b..b..b,p..s..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("d", function() 
                monitor.blit("     ",p..p..s..b..b,p..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..s..b..b,p..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("e", function() 
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..b..b..b,p..s..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..p..s..b..b,p..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("f", function() 
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..b..b..b,p..s..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..p..s..b..b,p..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..s..b..b..b,p..s..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("g", function() 
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..b..b..b,p..s..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("h", function() 
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("i", function() 
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..s..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("j", function() 
                monitor.blit("     ",b..p..p..s..b,b..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..b..p..s..b,b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("k", function() 
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..p..s..b..b,p..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("l", function() 
                monitor.blit("     ",p..s..b..b..b,p..s..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..b..b..b,p..s..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..b..b..b,p..s..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("m", function() 
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("n", function() 
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("o", function() 
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("p", function() 
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..s..b..b..b,p..s..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("q", function() 
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..p..p..s..b,b..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("r", function() 
                monitor.blit("     ",p..p..s..b..b,p..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..p..s..b..b,p..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("s", function() 
                monitor.blit("     ",p..p..s..b..b,p..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..b..b..b,p..s..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..s..b..b,p..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("t", function() 
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("u", function() 
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("v", function() 
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("w", function() 
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("x", function() 
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("y", function() 
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..b..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..b..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+5)
            end)

            .case("z", function() 
                monitor.blit("     ",p..p..s..b..b,p..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..b..b..b,p..s..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..s..b..b,p..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case(".", function() 
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("_", function() 
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("-", function() 
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("1", function() 
                monitor.blit("     ",b..b..p..s..b,b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..p..p..s..b,b..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..b..p..s..b,b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..b..p..s..b,b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("2", function() 
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..b..p..s..b,b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..p..s..b..b,p..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("3", function() 
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..b..p..s..b,b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..p..p..s..b,b..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("4", function() 
                monitor.blit("     ",b..b..p..s..b,b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..p..p..s..b,b..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..p..b..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..b..p..s..b,b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("5", function() 
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..b..b..b,p..s..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..p..p..s..b,b..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("6", function() 
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..b..b..b,p..s..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("7", function() 
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..b..p..s..b,b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..b..p..s..b,b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..b..p..s..b,b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("8", function() 
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("9", function() 
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..b..p..s..b,b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",p..p..p..s..b,p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("0", function() 
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",p..s..p..s..b,p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case(":", function()
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case(";", function()
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case(",", function()
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("?", function()
                monitor.blit("     ",p..p..s..b..b,p..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..b..p..s..b,b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..p..p..s..b,b..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("!", function()
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..p..s..b..b,b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case(" ", function()
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("     ",b..b..b..b..b,b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            --Special Characters

            .case("up", function()
                monitor.blit("      ",b..b..p..s..b..b,b..b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("      ",b..p..s..p..s..b,b..p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("      ",p..s..b..b..p..s,p..s..b..b..p..s)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("      ",b..b..b..b..b..b,b..b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("down", function()
                monitor.blit("      ",p..s..b..b..p..s,p..s..b..b..p..s)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("      ",b..p..s..p..s..b,b..p..s..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("      ",b..b..p..s..b..b,b..b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("      ",b..b..b..b..b..b,b..b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("left", function()
                monitor.setCursorPos(pos[1],pos[2]-1)
                monitor.blit("      ",b..b..b..p..s..b,b..b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2])
                monitor.blit("      ",b..b..p..s..b..b,b..b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("      ",b..p..s..b..b..b,b..p..s..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("      ",b..b..p..s..b..b,b..b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("      ",b..b..b..p..s..b,b..b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("right", function()
                monitor.setCursorPos(pos[1],pos[2]-1)
                monitor.blit("      ",b..b..p..s..b..b,b..b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2])
                monitor.blit("      ",b..b..b..p..s..b,b..b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("      ",b..b..b..b..p..s,b..b..b..b..p..s)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("      ",b..b..b..p..s..b,b..b..b..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("      ",b..b..p..s..b..b,b..b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("plus", function()
                monitor.setCursorPos(pos[1],pos[2]-1)
                monitor.blit("      ",b..b..b..b..b..b,b..b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2])
                monitor.blit("      ",b..b..p..s..b..b,b..b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("      ",p..p..p..p..p..s,p..p..p..p..p..s)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("      ",b..b..p..s..b..b,b..b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("      ",b..b..b..b..b..b,b..b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("minus", function()
                monitor.setCursorPos(pos[1],pos[2]-1)
                monitor.blit("      ",b..b..b..b..b..b,b..b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("      ",p..p..p..p..p..s,p..p..p..p..p..s)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("      ",b..b..b..b..b..b,b..b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("      ",b..b..b..b..b..b,b..b..b..b..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .case("select", function()
                monitor.setCursorPos(pos[1],pos[2]-1)
                monitor.blit("      ",b..b..p..s..b..b,b..b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2])
                monitor.blit("      ",b..p..p..p..s..b,b..p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+1)
                monitor.blit("      ",p..p..s..p..p..s,p..p..s..p..p..s)
                monitor.setCursorPos(pos[1],pos[2]+2)
                monitor.blit("      ",b..p..p..p..s..b,b..p..p..p..s..b)
                monitor.setCursorPos(pos[1],pos[2]+3)
                monitor.blit("      ",b..b..p..s..b..b,b..b..p..s..b..b)
                monitor.setCursorPos(pos[1],pos[2]+4)
            end)

            .default(function() print("symbol not supported: ".. character)
                --x,y = monitor.getCursorPos()
                --monitor.setCursorPos(x-10, y)
            end)

            .process()

    end

end

local function writeSmolText(monitor, pos, str, color1, color2)
    str = str:lower()
    characters = {}
    for char in string.gmatch(str, ".") do
        table.insert(characters, char)
    end
    len = #characters
    for i=1, len do 
        writeSmolChar(monitor, pos, characters[i], color1, color2)
        pos = {pos[1]+5, pos[2]}
    end
end

local function writeSlowSmolText(monitor, pos, str, time, color1, color2)
    str = str:lower()
    time = time or 0
    characters = {}
    for char in string.gmatch(str, ".") do
        table.insert(characters, char)
    end
    len = #characters
    for i=1, len do 
        writeSmolChar(monitor, pos, characters[i], color1, color2)
        pos = {pos[1]+5, pos[2]}
        sleep(time)
    end
end

local function writeSmol(monitor,startPos, str, mode, color1, color2)
    str = str:lower()
    ot = term.current()
    term.redirect(monitor)
    sizex,sizey = term.getSize()
    term.redirect(ot)
    mode = mode or "none"

    characters = {}
    for char in string.gmatch(str, ".") do
        table.insert(characters, char)
    end
    len = #characters

    blank = ""
    for amt=1, len+2 do
        blank = blank.." "
    end

    cpos = {}
    cpos[1] = (sizex+1) - startPos[1]
    cpos[2] = sizey - startPos[2]
    long = false
    if (len*5) > cpos[1] then 
        long = true
        for charpos=1, len do
            table.remove(characters)
        end
        --if mode == "scolling" then
        str = str.."   "
        --end 

        for char in string.gmatch(str, ".") do
            table.insert(characters, char)
        end

        len = #characters

        tl = ((len*5) - cpos[1]) + (len*5)
    else
        tl = 1
        mode = "none"
    end

    switch(mode)
        .case("scrolling", function()
            npos = {}
            npos[1] = startPos[1]
            npos[2] = startPos[2]
            writeSmolText(monitor, {npos[1]-5,npos[2]}, blank, color1, color2)
            writeSmolText(monitor, npos, str, color1, color2)
            for t=1, tl/2 do
                npos[1] = startPos[1] -t*2
                npos[1] = npos[1] +1
                writeSmolText(monitor, {npos[1]-5,npos[2]}, blank, color1, color2)
                writeSmolText(monitor, npos, str, color1, color2)
                
                pos = {(npos[1])+(len*5), npos[2]}
                writeSmolText(monitor, pos, str, color1, color2)
                if pos[1] <= startPos[1] then
                    if pos[1] < startPos[1] then
                        writeSmolText(monitor, {npos[1]-5,npos[2]}, blank, color1, color2)
                        writeSmolText(monitor, startPos, str, color1, color2)
                        pos = startPos
                    end
                    sleep(2)
                    return
                end
                
                sleep(0.25)
            end

        end)

        .case("edging", function() 
            writeSmolText(monitor, startPos, str, color1, color2)
            sleep(1)

            if long == true then
                npos = {}
                npos[1] = startPos[1]
                npos[2] = startPos[2]
                
                if(len*5) > cpos[1] then
                    to = ((len*5) - cpos[1]) +1
                end



                for t=1, round(to/2) do
                    npos[1] = (startPos[1]+2) -t*2
                    writeSmolText(monitor, {npos[1]-5,npos[2]}, blank, color1, color2)
                    writeSmolText(monitor, npos, str, color1, color2)
                    sleep(0.25)
                end

                sleep(2)
                for c=1, (-npos[1]/2)+1 do
                    out = npos[1] + c*2
                    writeSmolText(monitor, {npos[1]-5,npos[2]}, blank, color1, color2)
                    writeSmolText(monitor, {out,npos[2]}, str, color1, color2)
                    sleep(0.25)
                end
                writeSmolText(monitor, {npos[1]-5,npos[2]}, blank, color1, color2)
                writeSmolText(monitor, {out,npos[2]}, str, color1, color2)
                sleep(2)
            end
            sleep(0.1)
        end)

        .case("none", function()
            writeSmolText(monitor, startPos, str, color1, color2)
            sleep(0.1)
        end)

        .default(function()print("DEF")end)
        .process()
    
    if long == false then
        sleep(0.1)
    end
end

local function writeNextLine(inputpos)
    pos = {inputpos[1], inputpos[2]+5}
    do return pos end
end

local function getPlayerData(link)
    local link = link or "https://projectcrowbar.com/bluemap/maps/s3_overworld/live/players.json"
    playerData = http.get(link)
    if not playerData then return end
    data = playerData.readAll()
    playerData.close()
    return data

end

--"https://projectcrowbar.com/bluemap/maps/s3_overworld/tiles/1/x0/z0.png"

local function requestImage(ws, imageUrl, options, max_width, max_height)
    options = options or {}

    local cmd = "getImage " .. imageUrl

    if options.crop then
        cmd = cmd .. " /" .. options.crop
    end

    if max_width then
        cmd = cmd .. " /w:" .. max_width
    end

    if max_height then
        cmd = cmd .. " /h:" .. max_height
    end

    if options.dither ~= false then
        cmd = cmd .. " /dither"
    end

    if options.name then
        cmd = cmd .. " /outName:" .. options.name
    end

    ws.send(cmd)

    local meta, binary = ws.receive(60)
    if not meta then error("server closed") end
    if binary then error("invalid metadata") end
    if not meta:match("^NFP:") then error(meta) end

    local name = meta:sub(5)

    local data, isBinary = ws.receive(60)
    if not data then error("no NFP data") end
    if not isBinary then error(data) end

    local file = assert(fs.open(name, "wb"))
    file.write(data)
    file.close()

    return assert(paintutils.loadImage(name)), name
end

local function numberSpacing(inp, spacer)
    spacer = spacer or " "
    out = string.reverse(string.gsub(string.reverse(tostring(inp)),"...","%0"..spacer))
    
    chars = {}
    for char in string.gmatch(out, ".") do
        table.insert(chars, char)
    end
    if chars[1] == " " then
        table.remove(chars,1)
    end
    out = table.concat(chars)
    return out
end

return { 
    round = round, 
    pixel = pixel, 
    switch = switch,
    blit = blit, 
    writeSmolChar = writeSmolChar, 
    writeSmolText = writeSmolText,
    writeSlowSmolText = writeSlowSmolText,
    writeNextLine = writeNextLine,
    writeSmol = writeSmol,
    getPlayerData = getPlayerData,
    --getMap = getMap,
    requestImage = requestImage,
    numberSpacing = numberSpacing

}