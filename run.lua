------------------------------------------------------------
-- CC:TWEAKED GPS AREA MINER
--
-- Usage:
--
-- minearea(
--     {x = 100, y = 20, z = -50},
--     {x = 110, y = 25, z = -40}
-- )
--
-- Coordinates are INCLUSIVE.
--
-- Requires:
--   - Turtle
--   - Working GPS network
--   - Fuel
--
------------------------------------------------------------


------------------------------------------------------------
-- CONFIGURATION
------------------------------------------------------------

local GPS_TIMEOUT = 5
local MOVE_RETRIES = 10
local RETRY_DELAY = 0.2

-- How often GPS is checked while mining.
-- Lower = more GPS calls.
local GPS_CHECK_INTERVAL = 5


------------------------------------------------------------
-- DIRECTION CONSTANTS
------------------------------------------------------------
--
-- 0 = +Z
-- 1 = +X
-- 2 = -Z
-- 3 = -X
--
------------------------------------------------------------

local NORTH = 2
local SOUTH = 0
local EAST  = 1
local WEST  = 3


------------------------------------------------------------
-- CURRENT STATE
------------------------------------------------------------

local state = {
    x = nil,
    y = nil,
    z = nil,

    direction = nil,

    moves = 0
}


------------------------------------------------------------
-- PRINT POSITION
------------------------------------------------------------

local function printPosition()
    print(
        "Position: " ..
        tostring(state.x) .. ", " ..
        tostring(state.y) .. ", " ..
        tostring(state.z)
    )
end


------------------------------------------------------------
-- GPS
------------------------------------------------------------

local function gpsPosition()
    local x, y, z = gps.locate(GPS_TIMEOUT)

    if not x then
        return nil, "GPS could not determine position"
    end

    return {
        x = math.floor(x + 0.5),
        y = math.floor(y + 0.5),
        z = math.floor(z + 0.5)
    }
end


local function updateGPS()
    local pos, err = gpsPosition()

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

local function hasUnlimitedFuel()
    return turtle.getFuelLevel() == "unlimited"
end


local function refuel()
    if hasUnlimitedFuel() then
        return true
    end

    if turtle.getFuelLevel() > 0 then
        return true
    end

    print("Out of fuel. Searching inventory...")

    for slot = 1, 16 do

        turtle.select(slot)

        if turtle.refuel(1) then
            print(
                "Refueled. Fuel: " ..
                tostring(turtle.getFuelLevel())
            )

            return true
        end
    end

    return false
end


local function requireFuel()
    if hasUnlimitedFuel() then
        return true
    end

    if turtle.getFuelLevel() > 0 then
        return true
    end

    return refuel()
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
-- DIGGING
------------------------------------------------------------

local function digForward()
    while turtle.detect() do

        local success = turtle.dig()

        if not success then
            return false
        end

        sleep(0.1)
    end

    return true
end


local function digUp()
    while turtle.detectUp() do

        local success = turtle.digUp()

        if not success then
            return false
        end

        sleep(0.1)
    end

    return true
end


local function digDown()
    while turtle.detectDown() do

        local success = turtle.digDown()

        if not success then
            return false
        end

        sleep(0.1)
    end

    return true
end


------------------------------------------------------------
-- FORWARD MOVEMENT
------------------------------------------------------------

local function moveForward()

    if not requireFuel() then
        return false, "Out of fuel"
    end

    for attempt = 1, MOVE_RETRIES do

        ----------------------------------------------------
        -- Try moving normally first.
        ----------------------------------------------------

        if turtle.forward() then

            state.moves = state.moves + 1

            ------------------------------------------------
            -- Update estimated position.
            ------------------------------------------------

            if state.direction == NORTH then
                state.z = state.z - 1

            elseif state.direction == SOUTH then
                state.z = state.z + 1

            elseif state.direction == EAST then
                state.x = state.x + 1

            elseif state.direction == WEST then
                state.x = state.x - 1
            end

            ------------------------------------------------
            -- Occasionally verify with GPS.
            ------------------------------------------------

            if state.moves % GPS_CHECK_INTERVAL == 0 then
                updateGPS()
            end

            return true
        end


        ----------------------------------------------------
        -- Something is blocking us.
        ----------------------------------------------------

        if turtle.detect() then

            if not digForward() then
                return false,
                    "Block in front cannot be mined"
            end

        else
            ------------------------------------------------
            -- No block according to detect(), but movement
            -- failed. This can happen with entities,
            -- unloaded chunks, etc.
            ------------------------------------------------
            sleep(RETRY_DELAY)
        end
    end

    return false, "Unable to move forward"
end


------------------------------------------------------------
-- UP
------------------------------------------------------------

local function moveUp()

    if not requireFuel() then
        return false, "Out of fuel"
    end

    for attempt = 1, MOVE_RETRIES do

        if turtle.up() then

            state.y = state.y + 1
            state.moves = state.moves + 1

            return true
        end

        if turtle.detectUp() then

            if not digUp() then
                return false,
                    "Block above cannot be mined"
            end

        else
            sleep(RETRY_DELAY)
        end
    end

    return false, "Unable to move up"
end


------------------------------------------------------------
-- DOWN
------------------------------------------------------------

local function moveDown()

    if not requireFuel() then
        return false, "Out of fuel"
    end

    for attempt = 1, MOVE_RETRIES do

        if turtle.down() then

            state.y = state.y - 1
            state.moves = state.moves + 1

            return true
        end

        if turtle.detectDown() then

            if not digDown() then
                return false,
                    "Block below cannot be mined"
            end

        else
            sleep(RETRY_DELAY)
        end
    end

    return false, "Unable to move down"
end


------------------------------------------------------------
-- ROTATION
------------------------------------------------------------

local function turnLeft()

    if turtle.turnLeft() then
        state.direction =
            (state.direction - 1) % 4

        return true
    end

    return false
end


local function turnRight()

    if turtle.turnRight() then
        state.direction =
            (state.direction + 1) % 4

        return true
    end

    return false
end


------------------------------------------------------------
-- FACE DIRECTION
------------------------------------------------------------

local function face(target)

    local difference =
        (target - state.direction) % 4


    if difference == 0 then
        return true
    end


    if difference == 1 then
        return turnRight()
    end


    if difference == 2 then

        if not turnRight() then
            return false
        end

        return turnRight()
    end


    if difference == 3 then
        return turnLeft()
    end


    return false
end


------------------------------------------------------------
-- DETERMINE INITIAL DIRECTION
------------------------------------------------------------

local function determineDirection()

    print("Determining direction...")


    --------------------------------------------------------
    -- Get starting position.
    --------------------------------------------------------

    local start, err = gpsPosition()

    if not start then
        return false, err
    end


    --------------------------------------------------------
    -- Move forward exactly one block.
    --------------------------------------------------------

    local moved = turtle.forward()

    if not moved then

        ----------------------------------------------------
        -- Try removing a block.
        ----------------------------------------------------

        if turtle.detect() then

            if not turtle.dig() then
                return false,
                    "Cannot clear block while determining direction"
            end

            sleep(0.1)

            moved = turtle.forward()
        end
    end


    if not moved then
        return false,
            "Could not move forward to determine direction"
    end


    sleep(0.2)


    --------------------------------------------------------
    -- Get new GPS position.
    --------------------------------------------------------

    local current, gpsError = gpsPosition()

    if not current then
        return false, gpsError
    end


    local dx = current.x - start.x
    local dz = current.z - start.z


    --------------------------------------------------------
    -- Determine direction.
    --------------------------------------------------------

    if dx == 1 and dz == 0 then
        state.direction = EAST

    elseif dx == -1 and dz == 0 then
        state.direction = WEST

    elseif dx == 0 and dz == 1 then
        state.direction = SOUTH

    elseif dx == 0 and dz == -1 then
        state.direction = NORTH

    else
        return false,
            "GPS movement did not produce a valid direction"
    end


    --------------------------------------------------------
    -- Return to starting position.
    --------------------------------------------------------

    if not turtle.back() then
        return false,
            "Could not return to starting position"
    end


    sleep(0.2)


    --------------------------------------------------------
    -- Reset position from GPS.
    --------------------------------------------------------

    local returned, returnError = gpsPosition()

    if not returned then
        return false, returnError
    end


    state.x = returned.x
    state.y = returned.y
    state.z = returned.z


    print("Direction detected:")

    if state.direction == NORTH then
        print("  NORTH (-Z)")

    elseif state.direction == SOUTH then
        print("  SOUTH (+Z)")

    elseif state.direction == EAST then
        print("  EAST (+X)")

    elseif state.direction == WEST then
        print("  WEST (-X)")
    end


    return true
end


------------------------------------------------------------
-- MOVE TO X
------------------------------------------------------------

local function moveToX(targetX)

    while state.x ~= targetX do

        if state.x < targetX then

            if not face(EAST) then
                return false,
                    "Could not face +X"
            end

        else

            if not face(WEST) then
                return false,
                    "Could not face -X"
            end
        end


        local ok, err = moveForward()

        if not ok then
            return false, err
        end
    end

    return true
end


------------------------------------------------------------
-- MOVE TO Z
------------------------------------------------------------

local function moveToZ(targetZ)

    while state.z ~= targetZ do

        if state.z < targetZ then

            if not face(SOUTH) then
                return false,
                    "Could not face +Z"
            end

        else

            if not face(NORTH) then
                return false,
                    "Could not face -Z"
            end
        end


        local ok, err = moveForward()

        if not ok then
            return false, err
        end
    end

    return true
end


------------------------------------------------------------
-- MOVE TO Y
------------------------------------------------------------

local function moveToY(targetY)

    while state.y ~= targetY do

        local ok
        local err

        if state.y < targetY then
            ok, err = moveUp()
        else
            ok, err = moveDown()
        end


        if not ok then
            return false, err
        end
    end

    return true
end


------------------------------------------------------------
-- MOVE TO COORDINATE
------------------------------------------------------------

local function moveTo(target)

    local ok, err


    --------------------------------------------------------
    -- X
    --------------------------------------------------------

    ok, err = moveToX(target.x)

    if not ok then
        return false, err
    end


    --------------------------------------------------------
    -- Z
    --------------------------------------------------------

    ok, err = moveToZ(target.z)

    if not ok then
        return false, err
    end


    --------------------------------------------------------
    -- Y
    --------------------------------------------------------

    ok, err = moveToY(target.y)

    if not ok then
        return false, err
    end


    return true
end


------------------------------------------------------------
-- MINE ONE X ROW
------------------------------------------------------------

local function mineRow(targetX)

    while state.x ~= targetX do

        if state.x < targetX then
            if not face(EAST) then
                return false, "Could not face east"
            end

        else
            if not face(WEST) then
                return false, "Could not face west"
            end
        end


        ----------------------------------------------------
        -- The block we move into gets mined automatically
        -- by moveForward().
        ----------------------------------------------------

        local ok, err = moveForward()

        if not ok then
            return false, err
        end
    end

    return true
end


------------------------------------------------------------
-- MINE AREA
------------------------------------------------------------

function minearea(pos1, pos2)

    --------------------------------------------------------
    -- Validate input
    --------------------------------------------------------

    if type(pos1) ~= "table" then
        error("pos1 must be a table")
    end

    if type(pos2) ~= "table" then
        error("pos2 must be a table")
    end


    if not pos1.x or not pos1.y or not pos1.z then
        error("pos1 requires x, y and z")
    end

    if not pos2.x or not pos2.y or not pos2.z then
        error("pos2 requires x, y and z")
    end


    --------------------------------------------------------
    -- Normalize coordinates.
    --------------------------------------------------------

    local minX = math.min(pos1.x, pos2.x)
    local maxX = math.max(pos1.x, pos2.x)

    local minY = math.min(pos1.y, pos2.y)
    local maxY = math.max(pos1.y, pos2.y)

    local minZ = math.min(pos1.z, pos2.z)
    local maxZ = math.max(pos1.z, pos2.z)


    --------------------------------------------------------
    -- Calculate dimensions.
    --------------------------------------------------------

    local sizeX = maxX - minX + 1
    local sizeY = maxY - minY + 1
    local sizeZ = maxZ - minZ + 1

    local totalBlocks =
        sizeX * sizeY * sizeZ


    --------------------------------------------------------
    -- Header
    --------------------------------------------------------

    print("")
    print("========================================")
    print("          CC:TWEAKED AREA MINER")
    print("========================================")

    print(
        "Corner 1: " ..
        minX .. ", " ..
        minY .. ", " ..
        minZ
    )

    print(
        "Corner 2: " ..
        maxX .. ", " ..
        maxY .. ", " ..
        maxZ
    )

    print(
        "Size: " ..
        sizeX .. " x " ..
        sizeY .. " x " ..
        sizeZ
    )

    print(
        "Volume: " ..
        totalBlocks ..
        " blocks"
    )

    print("")


    --------------------------------------------------------
    -- GPS
    --------------------------------------------------------

    local ok, err = updateGPS()

    if not ok then
        error("GPS error: " .. err)
    end

    printPosition()


    --------------------------------------------------------
    -- Direction
    --------------------------------------------------------

    if not state.direction then

        ok, err = determineDirection()

        if not ok then
            error(
                "Direction detection failed: " ..
                err
            )
        end
    end


    --------------------------------------------------------
    -- Fuel
    --------------------------------------------------------

    if not requireFuel() then
        error(
            "Turtle has no fuel. Put fuel into the inventory."
        )
    end


    --------------------------------------------------------
    -- Go to starting corner
    --------------------------------------------------------

    print("")
    print("Moving to starting corner...")

    ok, err = moveTo({
        x = minX,
        y = minY,
        z = minZ
    })

    if not ok then
        error(
            "Could not reach starting corner: " ..
            err
        )
    end


    print("Starting position reached.")
    printPosition()


    --------------------------------------------------------
    -- MAIN MINING LOOP
    --------------------------------------------------------

    local layer = 0

    for y = minY, maxY do

        layer = layer + 1

        print("")
        print(
            "========== LAYER " ..
            layer ..
            "/" ..
            sizeY ..
            " =========="
        )

        ----------------------------------------------------
        -- Determine Z traversal direction.
        --
        -- This prevents huge unnecessary turns.
        ----------------------------------------------------

        local zDirection

        if layer % 2 == 1 then
            zDirection = 1
        else
            zDirection = -1
        end


        ----------------------------------------------------
        -- Determine starting Z.
        ----------------------------------------------------

        local startZ

        if zDirection == 1 then
            startZ = minZ
        else
            startZ = maxZ
        end


        ----------------------------------------------------
        -- Make sure we're at the correct Z.
        ----------------------------------------------------

        ok, err = moveToZ(startZ)

        if not ok then
            error(
                "Could not reach layer start: " ..
                err
            )
        end


        ----------------------------------------------------
        -- Mine every Z row.
        ----------------------------------------------------

        for row = 0, sizeZ - 1 do

            local targetX

            ------------------------------------------------
            -- Alternate X direction every row.
            ------------------------------------------------

            if row % 2 == 0 then

                if zDirection == 1 then
                    targetX = maxX
                else
                    targetX = minX
                end

            else

                if zDirection == 1 then
                    targetX = minX
                else
                    targetX = maxX
                end
            end


            ------------------------------------------------
            -- Mine this row.
            ------------------------------------------------

            ok, err = mineRow(targetX)

            if not ok then
                error(
                    "Mining failed at " ..
                    state.x .. ", " ..
                    state.y .. ", " ..
                    state.z ..
                    ": " ..
                    err
                )
            end


            ------------------------------------------------
            -- Move to next Z row.
            ------------------------------------------------

            if row < sizeZ - 1 then

                local nextZ =
                    startZ +
                    (row + 1) * zDirection


                if nextZ > state.z then

                    if not face(SOUTH) then
                        error("Could not turn south")
                    end

                else

                    if not face(NORTH) then
                        error("Could not turn north")
                    end
                end


                local moved, moveError =
                    moveForward()

                if not moved then
                    error(
                        "Could not move to next row: " ..
                        moveError
                    )
                end
            end
        end


        ----------------------------------------------------
        -- Next Y layer.
        ----------------------------------------------------

        if y < maxY then

            print(
                "Layer complete. Moving to Y=" ..
                (y + 1)
            )

            ok, err = moveUp()

            if not ok then
                error(
                    "Could not move to next layer: " ..
                    err
                )
            end
        end
    end


    --------------------------------------------------------
    -- FINISHED
    --------------------------------------------------------

    print("")
    print("========================================")
    print("          MINING COMPLETE")
    print("========================================")

    updateGPS()

    printPosition()

    print(
        "Fuel remaining: " ..
        tostring(turtle.getFuelLevel())
    )

    print("")
end


------------------------------------------------------------
-- EXAMPLE
------------------------------------------------------------

-- Uncomment to run automatically:
--
-- minearea(
--     {x = 100, y = 20, z = -50},
--     {x = 110, y = 25, z = -40}
-- )

minearea(
    {x = -3011, y = 1, z = -9689},
    {x = -3015, y = -3, z = -9646}
)
