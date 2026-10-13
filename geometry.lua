-- Silberstern012 (Silver) 
function drawCircle(cx, cy, r, char, bg, fg)
    char = char or " "
    if bg then term.setBackgroundColor(bg) end
    if fg then term.setTextColor(fg) end

    local x = r
    local y = 0
    local err = 0

    while x >= y do
        -- 8 points mirrored
        term.setCursorPos(cx + x, cy + y) term.write(char)
        term.setCursorPos(cx + y, cy + x) term.write(char)
        term.setCursorPos(cx - y, cy + x) term.write(char)
        term.setCursorPos(cx - x, cy + y) term.write(char)
        term.setCursorPos(cx - x, cy - y) term.write(char)
        term.setCursorPos(cx - y, cy - x) term.write(char)
        term.setCursorPos(cx + y, cy - x) term.write(char)
        term.setCursorPos(cx + x, cy - y) term.write(char)

        y = y + 1
        err = err + 1 + 2*y
        if 2*(err-x) + 1 > 0 then
            x = x - 1
            err = err + 1 - 2*x
        end
    end
end


function drawFilledCircle(cx, cy, r, char, bg, fg)
    char = char or " "
    if bg then term.setBackgroundColor(bg) end
    if fg then term.setTextColor(fg) end

    for dy = -r, r do
        for dx = -r, r do
            if dx*dx + dy*dy <= r*r + r*0.4 then -- +0.4 makes small circles rounder
                term.setCursorPos(cx + dx, cy + dy)
                term.write(char)
            end
        end
    end
end

return {
    drawCircle = drawCircle, 
    drawFilledCircle = drawFilledCircle
} 
