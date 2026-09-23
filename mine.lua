local function getRotation()
    startPos.x,startPos.y,startPos.z = gps.locate()
    if turtle.detect() then
        turtle.back()
        Pos2 = gps.locate()
        turtle.forward()
        
        neg_1 = {}
        print(startPos)
        for num, pos in pairs(startPos) do
            if number<0 then neg_1[num] = true
            else neg_1[num] = false end  
        end

    else
        turtle.forward()
        Pos2 = gps.locate()
        turtle.back()
    
    
    
    end

end

local function goto(pos)

end
