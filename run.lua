------------------------------------------------------------
-- CC:Tweaked Turtle Area Miner
--
-- Requires:
--   - Turtle
--   - Wireless modem
--   - GPS network
--
-- Position format:
--   { x = 100, y = 20, z = -50 }
--
-- Example:
--   minearea(
--       {x = 100, y = 20, z = -50},
--       {x = 110, y = 25, z = -40}
--   )
------------------------------------------------------------


------------------------------------------------------------
-- CONFIG
------------------------------------------------------------

local GPS_TIMEOUT = 5
local MOVE_RETRIES = 10
local FUEL_MINIMUM = 100


------------------------------------------------------------
-- STATE
------------------------------------------------------------

local state = {
    x = nil,
    y = nil,
    z = nil,

    -- 0 = +Z
    -- 1 = +X
    -- 2 = -Z
    -- 3 = -X
    direction = nil
}


------------------------------------------------------------
-- GPS
------------------------------------------------------------

local function getPosition()
    local x, y, z = gps.locate(GPS_TIMEOUT)

    if not x then
        return nil, "GPS location failed"
    end

    return {
        x = math.floor(x + 0.5),
        y = math.floor(y + 0.5),
        z = math.floor(z + 0.5)
    }
end


local function updatePosition()
    local pos, err = getPosition()

    if not pos then
        return false, err
    end

    state.x = pos.x
    state.y = pos.y
    state.z = pos.z

    return true
end


------------------------------------------------------------
-- FUEL
------------------------------------------------------------

local function getFuel()
    return turtle.getFuelLevel()
end


local function refuel()
    if turtle.getFuelLevel() == "unlimited" then
        return true
    end

    if turtle.getFuelLevel() >= FUEL_MINIMUM then
        return true
    end

    for slot = 1, 16 do
        turtle.select(slot)

        if turtle.refuel(0) then
            while turtle.getFuelLevel() < FUEL_MINIMUM do
                if not turtle.refuel(1) then
                    break
                end
            end
        end

        if turtle.getFuelLevel() >= FUEL_MINIMUM then
            return true
        end
    end

    return turtle.getFuelLevel() > 0
end


local function ensureFuel()
    if turtle.getFuelLevel() == "unlimited" then
        return true
    end

    if turtle.getFuelLevel() > 0 then
        return true
    end

    return refuel()
end


------------------------------------------------------------
-- ROTATION
------------------------------------------------------------

local function turnLeft()
    if turtle.turnLeft() then
        state.direction = (state.direction - 1) % 4
        return true
    end

    return false
end


local function turnRight()
    if turtle.turnRight() then
        state.direction = (state.direction + 1) % 4
        return true
    end

    return false
end


local function face(direction)
    local difference = (direction - state.direction) % 4

    if difference == 0 then
        return true

    elseif difference == 1 then
        return turnRight()

    elseif difference == 2 then
        if not turnRight() then
            return false
        end

        return turnRight()

    elseif difference == 3 then
        return turnLeft()
    end

    return false
end


------------------------------------------------------------
-- BLOCK HANDLING
------------------------------------------------------------

local function digFront()
    while turtle.detect() do

        local success, data = turtle.inspect()

        -- Bedrock / unbreakable blocks will cause dig()
        -- to repeatedly fail. Don't get stuck forever.
        if success and data and data.tags then
            if data.tags["minecraft:unbreakable"] then
                return false
            end
        end

        if not turtle.dig() then
            return false
        end

        sleep(0.1)
    end

    return true
end


local function digUp()
    while turtle.detectUp() do
        if not turtle.digUp() then
            return false
        end

        sleep(0.1)
    end

    return true
end


local function digDown()
    while turtle.detectDown() do
        if not turtle.digDown() then
            return false
        end

        sleep(0.1)
    end

    return true
end


------------------------------------------------------------
-- MOVEMENT
------------------------------------------------------------

local function forward()
    if not ensureFuel() then
        return false, "Out of fuel"
    end

    for attempt = 1, MOVE_RETRIES do

        if turtle.forward() then

            -- Update our internal position.
            if state.direction == 0 then
                state.z = state.z + 1

            elseif state.direction == 1 then
                state.x = state.x + 1

            elseif state.direction == 2 then
                state.z = state.z - 1

            elseif state.direction == 3 then
                state.x = state.x - 1
            end

            return true
        end

        -- Something is blocking us.
        digFront()

        sleep(0.1)
    end

    return false, "Unable to move forward"
end


local function up()
    if not ensureFuel() then
        return false, "Out of fuel"
    end

    for attempt = 1, MOVE_RETRIES do

        if turtle.up() then
            state.y = state.y + 1
            return true
        end

        digUp()

        sleep(0.1)
    end

    return false, "Unable to move up"
end


local function down()
    if not ensureFuel() then
        return false, "Out of fuel"
    end

    for attempt = 1, MOVE_RETRIES do

        if turtle.down() then
            state.y = state.y - 1
            return true
        end

        digDown()

        sleep(0.1)
    end

    return false, "Unable to move down"
end


------------------------------------------------------------
-- MOVE TO COORDINATE
------------------------------------------------------------

local function moveTo(target)
    --------------------------------------------------------
    -- X
    --------------------------------------------------------

    while state.x ~= target.x do

        if state.x < target.x then
            if not face(1) then
                return false, "Failed to face +X"
            end

            local ok, err = forward()

            if not ok then
                return false, err
            end

        else
            if not face(3) then
                return false, "Failed to face -X"
            end

            local ok, err = forward()

            if not ok then
                return false, err
            end
        end
    end


    --------------------------------------------------------
    -- Z
    --------------------------------------------------------

    while state.z ~= target.z do

        if state.z < target.z then
            if not face(0) then
                return false, "Failed to face +Z"
            end

            local ok, err = forward()

            if not ok then
                return false, err
            end

        else
            if not face(2) then
                return false, "Failed to face -Z"
            end

            local ok, err = forward()

            if not ok then
                return false, err
            end
        end
    end


    --------------------------------------------------------
    -- Y
    --------------------------------------------------------

    while state.y ~= target.y do

        if state.y < target.y then
            local ok, err = up()

            if not ok then
                return false, err
            end

        else
            local ok, err = down()

            if not ok then
                return false, err
            end
        end
    end

    return true
end


------------------------------------------------------------
-- DETERMINE TURTLE ROTATION USING GPS
------------------------------------------------------------

local function determineDirection()
    print("Determining turtle direction...")

    local original, err = getPosition()

    if not original then
        return false, err
    end

    --------------------------------------------------------
    -- Try moving forward.
    --------------------------------------------------------

    if not turtle.forward() then

        -- Something is blocking the turtle.
        -- Try digging it.
        if not turtle.dig() then
            return false,
                "Cannot determine direction: block in front cannot be removed"
        end

        if not turtle.forward() then
            return false,
                "Cannot determine direction: unable to move forward"
        end
    end

    sleep(0.2)

    local moved, gpsError = getPosition()

    if not moved then
        return false, gpsError
    end

    --------------------------------------------------------
    -- Determine direction from GPS delta.
    --------------------------------------------------------

    local dx = moved.x - original.x
    local dz = moved.z - original.z

    if dx == 1 and dz == 0 then
        state.direction = 1       -- +X

    elseif dx == -1 and dz == 0 then
        state.direction = 3       -- -X

    elseif dx == 0 and dz == 1 then
        state.direction = 0       -- +Z

    elseif dx == 0 and dz == -1 then
        state.direction = 2       -- -Z

    else
        return false,
            "GPS returned an invalid movement direction"
    end


    --------------------------------------------------------
    -- Return to original position.
    --------------------------------------------------------

    if not turtle.back() then
        return false,
            "Could not return after determining direction"
    end

    sleep(0.2)

    local returned, returnError = getPosition()

    if not returned then
        return false, returnError
    end

    state.x = returned.x
    state.y = returned.y
    state.z = returned.z

    print(
        "Direction detected: " ..
        tostring(state.direction)
    )

    return true
end


------------------------------------------------------------
-- INVENTORY
------------------------------------------------------------

local function inventoryFull()
    for slot = 1, 16 do
        if turtle.getItemCount(slot) == 0 then
            return false
        end
    end

    return true
end


------------------------------------------------------------
-- MINE CURRENT BLOCK
------------------------------------------------------------

local function mineCurrentLayerBlock()
    -- The turtle occupies the current block, so the block
    -- that gets mined is the block BELOW/IN FRONT depending
    -- on the mining strategy.
    --
    -- Our strategy is:
    --   stand in the block immediately before the target
    --   and dig forward.
    --
    -- The actual layer traversal is handled below.
end


------------------------------------------------------------
-- MINE AREA
------------------------------------------------------------

function minearea(pos1, pos2)

    --------------------------------------------------------
    -- Validate positions
    --------------------------------------------------------

    if not pos1 or not pos2 then
        error("minearea requires pos1 and pos2")
    end

    if not pos1.x or not pos1.y or not pos1.z then
        error("pos1 must contain x, y and z")
    end

    if not pos2.x or not pos2.y or not pos2.z then
        error("pos2 must contain x, y and z")
    end


    --------------------------------------------------------
    -- Normalize coordinates
    --------------------------------------------------------

    local minX = math.min(pos1.x, pos2.x)
    local maxX = math.max(pos1.x, pos2.x)

    local minY = math.min(pos1.y, pos2.y)
    local maxY = math.max(pos1.y, pos2.y)

    local minZ = math.min(pos1.z, pos2.z)
    local maxZ = math.max(pos1.z, pos2.z)


    print("================================")
    print("       TURTLE AREA MINER")
    print("================================")

    print(
        "Area: (" ..
        minX .. "," ..
        minY .. "," ..
        minZ .. ") -> (" ..
        maxX .. "," ..
        maxY .. "," ..
        maxZ .. ")"
    )


    --------------------------------------------------------
    -- GPS
    --------------------------------------------------------

    local ok, err = updatePosition()

    if not ok then
        error("GPS error: " .. err)
    end


    --------------------------------------------------------
    -- Determine rotation
    --------------------------------------------------------

    if state.direction == nil then
        ok, err = determineDirection()

        if not ok then
            error("Direction error: " .. err)
        end
    end


    --------------------------------------------------------
    -- fuel request
    --------------------------------------------------------

    if not ensureFuel() then
        error("No fuel available")
    end


    --------------------------------------------------------
    -- Move to starting position
    --------------------------------------------------------

    print("Moving to starting position...")

    ok, err = moveTo({
        x = minX,
        y = minY,
        z = minZ
    })

    if not ok then
        error("Could not reach starting position: " .. err)
    end


    for y = minY, maxY do

        print("Mining Y level " .. y)

        local forwardDirection

        if (y - minY) % 2 == 0 then
            forwardDirection = 1 -- +X
        else
            forwardDirection = 3 -- -X
        end


        ----------------------------------------------------
        -- Start of row
        ----------------------------------------------------

        local startX

        if forwardDirection == 1 then
            startX = minX
        else
            startX = maxX
        end


        -- Make sure we're at the correct X.
        ok, err = moveTo({
            x = startX,
            y = y,
            z = minZ
        })

        if not ok then
            error("Navigation failed: " .. err)
        end


        ----------------------------------------------------
        -- Z rows
        ----------------------------------------------------

        local z = minZ
        local reverseZ = false

        while z <= maxZ do

            ------------------------------------------------
            -- Mine along X
            ------------------------------------------------

            local targetX

            if forwardDirection == 1 then
                targetX = maxX
            else
                targetX = minX
            end


            ------------------------------------------------
            -- Mine the row
            ------------------------------------------------

            while state.x ~= targetX do

                if forwardDirection == 1 then
                    face(1)
                else
                    face(3)
                end

                local moved, moveError = forward()

                if not moved then
                    error(
                        "Mining stopped at " ..
                        state.x .. "," ..
                        state.y .. "," ..
                        state.z ..
                        ": " .. moveError
                    )
                end
            end


            ------------------------------------------------
            -- Next Z row
            ------------------------------------------------

            if z < maxZ then

                if reverseZ then
                    face(2)
                else
                    face(0)
                end

                local moved, moveError = forward()

                if not moved then
                    error(
                        "Could not move to next row: " ..
                        moveError
                    )
                end

                z = z + 1
                reverseZ = not reverseZ
            else
                break
            end

        end


        ----------------------------------------------------
        -- Next Y level
        ----------------------------------------------------

        if y < maxY then

            ok, err = up()

            if not ok then
                error(
                    "Could not move to next layer: " ..
                    err
                )
            end

        end

    end


    --------------------------------------------------------
    -- Finished
    --------------------------------------------------------

    print("")
    print("================================")
    print("        MINING COMPLETE")
    print("================================")

    print(
        "Final position: " ..
        state.x .. ", " ..
        state.y .. ", " ..
        state.z
    )

    return true
end


------------------------------------------------------------
-- EXAMPLE
------------------------------------------------------------

-- Uncomment this to run automatically.

-- minearea(
--     {x = 100, y = 20, z = -50},
--     {x = 110, y = 25, z = -40}
-- )