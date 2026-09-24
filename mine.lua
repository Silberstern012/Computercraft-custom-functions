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

local function goto(target)

    local detour = nil
    local detourSteps = 0

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
        -- DETOUR MODE
        ------------------------------------------------

        if detour then

            if detour == "EAST" then

                if not turtle.detect() then
                    turtle.forward()
                    detourSteps = detourSteps + 1
                else
                    detour = nil
                end

            elseif detour == "WEST" then

                if not turtle.detect() then
                    turtle.forward()
                    detourSteps = detourSteps + 1
                else
                    detour = nil
                end

            elseif detour == "NORTH" then

                if not turtle.detect() then
                    turtle.forward()
                    detourSteps = detourSteps + 1
                else
                    detour = nil
                end

            elseif detour == "SOUTH" then

                if not turtle.detect() then
                    turtle.forward()
                    detourSteps = detourSteps + 1
                else
                    detour = nil
                end

            elseif detour == "UP" then

                if not turtle.detectUp() then
                    turtle.up()
                    detourSteps = detourSteps + 1
                else
                    detour = nil
                end

            elseif detour == "DOWN" then

                if not turtle.detectDown() then
                    turtle.down()
                    detourSteps = detourSteps + 1
                else
                    detour = nil
                end
            end

            -- After moving around the obstacle, check
            -- whether we can now resume direct movement.
            if detourSteps >= 1 then
                detour = nil
                detourSteps = 0
            end

        ------------------------------------------------
        -- Y MOVEMENT
        ------------------------------------------------

        elseif y < target.y then

            if not turtle.detectUp() then
                if not turtle.up() then
                    return false, "Cannot move up"
                end
            else
                -- Block above: move horizontally as detour
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

                detour = Rotation
            end

        elseif y > target.y then

            if not turtle.detectDown() then
                if not turtle.down() then
                    return false, "Cannot move down"
                end
            else
                -- Block below: move horizontally as detour
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

                detour = Rotation
            end

        ------------------------------------------------
        -- X MOVEMENT
        ------------------------------------------------

        elseif x < target.x then

            -- Need EAST
            if Rotation == "EAST" then

                if turtle.detect() then

                    -- EAST blocked → SOUTH
                    turtle.turnRight()
                    Rotation = "SOUTH"
                    detour = "SOUTH"

                else
                    turtle.forward()
                end

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

        elseif x > target.x then

            -- Need WEST
            if Rotation == "WEST" then

                if turtle.detect() then

                    -- WEST blocked → NORTH
                    turtle.turnRight()
                    Rotation = "NORTH"
                    detour = "NORTH"

                else
                    turtle.forward()
                end

            elseif Rotation == "EAST" then

                turtle.turnRight()
                turtle.turnRight()
                Rotation = "WEST"

            elseif Rotation == "NORTH" then

                turtle.turnLeft()
                Rotation = "WEST"

            elseif Rotation == "SOUTH" then

                turtle.turnRight()
                Rotation = "WEST"
            end

        ------------------------------------------------
        -- Z MOVEMENT
        ------------------------------------------------

        elseif z < target.z then

            -- Need SOUTH
            if Rotation == "SOUTH" then

                if turtle.detect() then

                    -- SOUTH blocked → WEST
                    turtle.turnRight()
                    Rotation = "WEST"
                    detour = "WEST"

                else
                    turtle.forward()
                end

            elseif Rotation == "NORTH" then

                turtle.turnRight()
                turtle.turnRight()
                Rotation = "SOUTH"

            elseif Rotation == "EAST" then

                turtle.turnRight()
                Rotation = "SOUTH"

            elseif Rotation == "WEST" then

                turtle.turnLeft()
                Rotation = "SOUTH"
            end

        elseif z > target.z then

            -- Need NORTH
            if Rotation == "NORTH" then

                if turtle.detect() then

                    -- NORTH blocked → EAST
                    turtle.turnRight()
                    Rotation = "EAST"
                    detour = "EAST"

                else
                    turtle.forward()
                end

            elseif Rotation == "SOUTH" then

                turtle.turnRight()
                turtle.turnRight()
                Rotation = "NORTH"

            elseif Rotation == "EAST" then

                turtle.turnLeft()
                Rotation = "NORTH"

            elseif Rotation == "WEST" then

                turtle.turnRight()
                Rotation = "NORTH"
            end
        end

        sleep(0.05)
    end
end
getRotation()
print(Rotation)


target = {x=-3018,y=-5,z=-9688}
goto(target)
