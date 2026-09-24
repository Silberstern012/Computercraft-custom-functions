local Rotation = ""


local function getRotation()
    x, y, z = gps.locate()
    pos1 = {x, y, z}
    if turtle.detect() then
        turtle.back()
        x2, y2, z2 = gps.locate()
        pos2 = {x2, y2, z2}
        turtle.forward()
        

        for num, pos in pairs(pos1) do
            if pos ~= pos2[num] then
                
                if num == 1 and pos >-1 and pos2[num] >-1 and pos < pos2[num] then Rotation = "WEST"
                elseif num == 1 and pos >-1 and pos2[num] >-1 and pos > pos2[num] then Rotation = "EAST"
                elseif num == 3 and pos >-1 and pos2[num] >-1 and pos < pos2[num] then Rotation = "NORTH"
                elseif num == 3 and pos >-1 and pos2[num] >-1 and pos > pos2[num] then Rotation = "SOUTH"
                
                elseif num == 1 and pos <0 and pos2[num] <0 and pos < pos2[num] then Rotation = "WEST"
                elseif num == 1 and pos <0 and pos2[num] <0 and pos > pos2[num] then Rotation = "EAST"
                elseif num == 3 and pos <0 and pos2[num] <0 and pos < pos2[num] then Rotation = "NORTH"
                elseif num == 3 and pos <0 and pos2[num] <0 and pos > pos2[num] then Rotation = "SOUTH"
                end
            end  
        end

    else
        turtle.forward()
        x2, y2, z2 = gps.locate()
        pos2 = {x2, y2, z2}
        turtle.back()
    

        for num, pos in pairs(pos1) do
            if pos ~= pos2[num] then
                
                if num == 1 and pos >-1 and pos2[num] >-1 and pos > pos2[num] then Rotation = "WEST"
                elseif num == 1 and pos >-1 and pos2[num] >-1 and pos < pos2[num] then Rotation = "EAST"
                elseif num == 3 and pos >-1 and pos2[num] >-1 and pos > pos2[num] then Rotation = "NORTH"
                elseif num == 3 and pos >-1 and pos2[num] >-1 and pos < pos2[num] then Rotation = "SOUTH"
                
                elseif num == 1 and pos <0 and pos2[num] <0 and pos > pos2[num] then Rotation = "WEST"
                elseif num == 1 and pos <0 and pos2[num] <0 and pos < pos2[num] then Rotation = "EAST"
                elseif num == 3 and pos <0 and pos2[num] <0 and pos > pos2[num] then Rotation = "NORTH"
                elseif num == 3 and pos <0 and pos2[num] <0 and pos < pos2[num] then Rotation = "SOUTH"
                end
            end  
        end
    end
end

local function goto(goPos)

    local x, y, z = goPos

    while true do

        local gx, gy, gz = gps.locate()

        if not gx then
            return false, "GPS unavailable"
        end

        ------------------------------------------------
        -- We reached the destination
        ------------------------------------------------

        if gx == x and gy == y and gz == z then
            return true
        end


        ------------------------------------------------
        -- X
        ------------------------------------------------
        print(gx.." "..x)
        if gx < x then

            if Rotation == "EAST" then
                turtle.forward()
            elseif Rotation == "WEST" then
                turtle.turnLeft()
                turtle.turnLeft()
                Rotation = "EAST"
            elseif Rotation == "NORTH" then
                turtle.turnRight()
                Rotation = "EAST"
            elseif Rotation == "SOUTH" then
                turtle.turnLeft()
                Rotation = "EAST"
            end

        elseif gx > x then
            if Rotation == "WEST" then
                turtle.forward()
            elseif Rotation == "EAST" then
                turtle.turnLeft()
                turtle.turnLeft()
                Rotation = "WEST"
            elseif Rotation == "NORTH" then
                turtle.turnLeft()
                Rotation = "WEST"
            elseif Rotation == "SOUTH" then
                turtle.turnRight()
                Rotation = "WEST"
            end

        elseif gz < z then
            if Rotation == "SOUTH" then
                turtle.forward()
            elseif Rotation == "NORTH" then
                turtle.turnLeft()
                turtle.turnLeft()
                Rotation = "SOUTH"
            elseif Rotation == "EAST" then
                turtle.turnRight()
                Rotation = "SOUTH"
            elseif Rotation == "WEST" then
                turtle.turnLeft()
                Rotation = "SOUTH"
            end

        elseif gz > z then
            if Rotation == "NORTH" then
                turtle.forward()
            elseif Rotation == "SOUTH" then
                turtle.turnLeft()
                turtle.turnLeft()
                Rotation = "NORTH"
            elseif Rotation == "EAST" then
                turtle.turnLeft()
                Rotation = "NORTH"
            elseif Rotation == "WEST" then
                turtle.turnRight()
                Rotation = "NORTH"
            end

        elseif gy < y then
            turtle.down()
        elseif gy > y then
            turtle.up()
        end
    end
end

getRotation()
print(Rotation)

sleep(2)
target = -3018,-5,-9688
goto(target)
