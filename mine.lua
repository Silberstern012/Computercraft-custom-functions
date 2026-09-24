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

local function goTo(target)

    while true do

        local x, y, z = gps.locate()

        if not x then
            return false, "GPS unavailable"
        end

        -- Target reached
        if x == target.x and y == target.y and z == target.z then
            return true
        end

        ------------------------------------------------
        -- Y
        ------------------------------------------------

        if y < target.y then

            if not turtle.detectUp() then
                if not turtle.up() then
                    return false, "Cannot move up"
                end
            else
                -- Something above, try going around it
                if Rotation == "NORTH" then
                    turtle.turnRight()
                    Rotation = "EAST"
                elseif Rotation == "EAST" then
                    turtle.turnRight()
                    Rotation = "SOUTH"
                elseif Rotation == "SOUTH" then
                    turtle.turnRight()
                    Rotation = "WEST"
                elseif Rotation == "WEST" then
                    turtle.turnRight()
                    Rotation = "NORTH"
                end
            end

        elseif y > target.y then

            if not turtle.detectDown() then
                if not turtle.down() then
                    return false, "Cannot move down"
                end
            else
                -- Something below, try going around it
                if Rotation == "NORTH" then
                    turtle.turnRight()
                    Rotation = "EAST"
                elseif Rotation == "EAST" then
                    turtle.turnRight()
                    Rotation = "SOUTH"
                elseif Rotation == "SOUTH" then
                    turtle.turnRight()
                    Rotation = "WEST"
                elseif Rotation == "WEST" then
                    turtle.turnRight()
                    Rotation = "NORTH"
                end
            end

        ------------------------------------------------
        -- X
        ------------------------------------------------

        elseif x < target.x then

            -- Need EAST
            if Rotation ~= "EAST" then

                if Rotation == "NORTH" then
                    turtle.turnRight()

                elseif Rotation == "SOUTH" then
                    turtle.turnLeft()

                elseif Rotation == "WEST" then
                    turtle.turnRight()
                    turtle.turnRight()
                end

                Rotation = "EAST"

            elseif turtle.detect() then
                -- Blocked: turn and try another direction
                turtle.turnRight()
                Rotation = "SOUTH"

            else
                if not turtle.forward() then
                    return false, "Cannot move forward"
                end
            end

        elseif x > target.x then

            -- Need WEST
            if Rotation ~= "WEST" then

                if Rotation == "NORTH" then
                    turtle.turnLeft()

                elseif Rotation == "SOUTH" then
                    turtle.turnRight()

                elseif Rotation == "EAST" then
                    turtle.turnRight()
                    turtle.turnRight()
                end

                Rotation = "WEST"

            elseif turtle.detect() then
                -- Blocked: turn and try another direction
                turtle.turnRight()
                Rotation = "NORTH"

            else
                if not turtle.forward() then
                    return false, "Cannot move forward"
                end
            end

        ------------------------------------------------
        -- Z
        ------------------------------------------------

        elseif z < target.z then

            -- Need SOUTH
            if Rotation ~= "SOUTH" then

                if Rotation == "NORTH" then
                    turtle.turnRight()
                    turtle.turnRight()

                elseif Rotation == "EAST" then
                    turtle.turnRight()

                elseif Rotation == "WEST" then
                    turtle.turnLeft()
                end

                Rotation = "SOUTH"

            elseif turtle.detect() then
                turtle.turnRight()
                Rotation = "WEST"

            else
                if not turtle.forward() then
                    return false, "Cannot move forward"
                end
            end

        elseif z > target.z then

            -- Need NORTH
            if Rotation ~= "NORTH" then

                if Rotation == "SOUTH" then
                    turtle.turnRight()
                    turtle.turnRight()

                elseif Rotation == "EAST" then
                    turtle.turnLeft()

                elseif Rotation == "WEST" then
                    turtle.turnRight()
                end

                Rotation = "NORTH"

            elseif turtle.detect() then
                turtle.turnRight()
                Rotation = "EAST"

            else
                if not turtle.forward() then
                    return false, "Cannot move forward"
                end
            end
        end

        sleep(0.05)
    end
end
getRotation()
print(Rotation)


target = {x=-3018,y=-5,z=-9688}
goto(target)
