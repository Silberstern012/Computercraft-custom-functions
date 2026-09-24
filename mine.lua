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
                
                if num == 1 and pos >-1 and pos2[num] >-1 and pos < pos2[num] then Rotation = "EAST"
                elseif num == 1 and pos >-1 and pos2[num] >-1 and pos > pos2[num] then Rotation = "WEST"
                elseif num == 3 and pos >-1 and pos2[num] >-1 and pos < pos2[num] then Rotation = "SOUTH"
                elseif num == 3 and pos >-1 and pos2[num] >-1 and pos > pos2[num] then Rotation = "NORTH"
                
                elseif num == 1 and pos <0 and pos2[num] <0 and pos < pos2[num] then Rotation = "EAST"
                elseif num == 1 and pos <0 and pos2[num] <0 and pos > pos2[num] then Rotation = "WEST"
                elseif num == 3 and pos <0 and pos2[num] <0 and pos < pos2[num] then Rotation = "SOUTH"
                elseif num == 3 and pos <0 and pos2[num] <0 and pos > pos2[num] then Rotation = "NORTH"
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
                
                if num == 1 and pos >-1 and pos2[num] >-1 and pos > pos2[num] then Rotation = "EAST"
                elseif num == 1 and pos >-1 and pos2[num] >-1 and pos < pos2[num] then Rotation = "WEST"
                elseif num == 3 and pos >-1 and pos2[num] >-1 and pos > pos2[num] then Rotation = "SOUTH"
                elseif num == 3 and pos >-1 and pos2[num] >-1 and pos < pos2[num] then Rotation = "NORTH"
                
                elseif num == 1 and pos <0 and pos2[num] <0 and pos > pos2[num] then Rotation = "EAST"
                elseif num == 1 and pos <0 and pos2[num] <0 and pos < pos2[num] then Rotation = "WEST"
                elseif num == 3 and pos <0 and pos2[num] <0 and pos > pos2[num] then Rotation = "SOUTH"
                elseif num == 3 and pos <0 and pos2[num] <0 and pos < pos2[num] then Rotation = "NORTH"
                end
            end  
        end
    end

end

local function goto(pos)

end

getRotation()
print(Rotation)
