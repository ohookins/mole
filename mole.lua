-- Animation library
require("AnAL")

-- Set up the actor
mole = {
    walk_spritesheet      = love.graphics.newImage("images/mole.png"),
    crouch_spritesheet    = love.graphics.newImage("images/crouching.png"),
    lookup_sprite         = love.graphics.newImage("images/lookup.png"),
    gettingup_spritesheet = love.graphics.newImage("images/gettingup.png"),
    climbing_spritesheet  = love.graphics.newImage("images/climbing.png"),
    width                 = 125, -- hard code due to spritesheet
    height                = 150,
    direction             = "right",
    state                 = "idle",
    accel                 = 250,
    vel_x                 = 0,
    vel_y                 = 0,
    max_speed             = 5,
    sound                 = love.audio.newSource("audio/feet.ogg", "static"),
    fart                  = love.audio.newSource("audio/fart.ogg", "static"),
}
mole.sound:setLooping(true)
mole.sound:setPitch(0.4)
mole.fart:setLooping(false)
mole.fart:setPitch(1.3)
mole.walking = newAnimation(mole.walk_spritesheet, mole.width, mole.height, 0.1, 0)
mole.crouching = newAnimation(mole.crouch_spritesheet, mole.width, mole.height, 0.1, 0)
mole.crouching:setMode("once")
mole.gettingup = newAnimation(mole.gettingup_spritesheet, mole.width, mole.height, 0.1, 0)
mole.gettingup:setMode("once")
-- FIXME: Have to use the height of the spritesheet here because it is a bit longer.
mole.climbing = newAnimation(mole.climbing_spritesheet, mole.width, mole.climbing_spritesheet:getHeight(), 0.2, 0)

-- State machine
mole.action = {
    ["looking"]       = function(d, w) love.graphics.draw(mole.lookup_sprite, mole.x - mole.width/2, mole.y, 0, d, 1, w) end,
    ["crouching"]     = function(d, w) mole.crouching:draw(mole.x - mole.width/2, mole.y, 0, d, 1, w) end,
    ["getting_up"]    = function(d, w) mole.gettingup:draw(mole.x - mole.width/2, mole.y, 0, d, 1, w) end,
    ["walking"]       = function(d, w) mole.walking:draw(mole.x - mole.width/2, mole.y, 0, d, 1, w) end,
    ["climbing_up"]   = function(d, w) mole.climbing:draw(mole.x - mole.width/2, mole.y, 0, d, 1, w) end,
    ["on_ladder"]     = function(d, w) mole.climbing:draw(mole.x - mole.width/2, mole.y, 0, d, 1, w) end,
    ["climbing_down"] = function(d, w) mole.climbing:draw(mole.x - mole.width/2, mole.y, 0, d, 1, w) end,
    ["idle"]          = function(d, w) mole.walking:draw(mole.x - mole.width/2, mole.y, 0, d, 1, w) end,
}

mole.draw = function()
    local direction_flip = (mole.direction == "right") and 1 or -1
    local width_comp = (mole.direction == "right") and 0 or mole.width

    mole.action[mole.state](direction_flip, width_comp)
end

function love.keyreleased(key)
    -- State machine transitions
    if key == "down" then
        if mole.state == "crouching" then
            mole.state = "getting_up"
        elseif mole.state == "climbing_down" then
            for i,obj in ipairs(current_level.level.objects) do
                if obj.collided(mole.x, mole.y) and obj.isClimbable then
                    mole.state = "on_ladder"
                    return
                end
            end
        end

    elseif key == "up" then
        if mole.state == "looking" then
            mole.state = "idle"
        elseif mole.state == "climbing_up" then
            for i,obj in ipairs(current_level.level.objects) do
                if obj.collided(mole.x, mole.y) and obj.isClimbable then
                    mole.state = "on_ladder"
                    return
                end
            end
        end

    elseif key == "right" or key == "left" then
        if mole.state == "walking" and mole.direction == key then
            mole.state = "idle"
        end
    end
end

function love.keypressed(key)
    -- State machine transitions
    if key == "right" or key == "left" then
        if mole.direction ~= key then
            mole.vel_x = 0
        end
        if mole.state == "idle" then
            mole.state = "walking"
            mole.direction = key
        end

    elseif key == "down" then
        -- Ladder stuff
        for i,obj in ipairs(current_level.level.objects) do
            if obj.collided(mole.x, mole.y) and obj.isClimbable then
                if mole.state == "idle" or mole.state == "on_ladder" then
                    mole.state = "climbing_down"
                    return
                end
            end
        end

        -- Crouching down to relieve the pressure
        if mole.state == "idle" then
            mole.fart:play()
            mole.state = "crouching"
        end

    elseif key == "up" then
        -- Ladder stuff
        for i,obj in ipairs(current_level.level.objects) do
            if obj.collided(mole.x, mole.y) and obj.isClimbable then
                if mole.state == "idle" or mole.state == "on_ladder" then
                    mole.state = "climbing_up"
                    mole.x = obj.centre_x
                    -- FIXME: Fudge factor due to mismatched animation heights
                    mole.y = mole.y - 20
                    return
                end
            end
        end

        -- Just looking
        if mole.state == "idle" then
            mole.state = "looking"
        end
    end
end

mole.update = function(dt)
    -- Movement
    if mole.state == "walking" then
        -- Update animation and sound
        mole.walking:update(dt)
        if mole.sound:isStopped() then
            mole.sound:play()
        end

        -- Update velocity
        mole.vel_x = dt * (mole.vel_x + (mole.direction == "right" and mole.accel or -mole.accel))

        -- Limit top horizontal velocity
        if mole.vel_x > mole.max_speed then
            mole.vel_x = mole.max_speed
        elseif mole.vel_x < -mole.max_speed then
            mole.vel_x = -mole.max_speed
        end
    else
        -- Don't stop the sound if we are climbing
        if (mole.state ~= "climbing_up" and mole.state ~= "climbing_down") and not mole.sound:isStopped() then
            mole.sound:stop()
        end
        mole.vel_x = 0
    end

    -- Stationary activities
    if mole.state == "crouching" then
        mole.crouching:update(dt)
    end

    if mole.state == "getting_up" then
        mole.crouching:reset()
        mole.crouching:play()
        mole.gettingup:update(dt)
        if mole.gettingup:getCurrentFrame() == 2 then
            mole.state = "idle"
            mole.gettingup:reset()
            mole.gettingup:play()
        end
    end

    -- Climbing
    if mole.state == "climbing_up" then
        mole.climbing:setMode("loop")
        mole.climbing:update(dt)
        mole.vel_y = -mole.max_speed/3

        if mole.sound:isStopped() then
            mole.sound:play()
            mole.sound:setPitch(0.2)
        end
    elseif mole.state == "climbing_down" then
        mole.climbing:setMode("reverse")
        mole.climbing:update(dt)
        mole.vel_y = mole.max_speed/3

        if mole.sound:isStopped() then
            mole.sound:play()
            mole.sound:setPitch(0.2)
        end
    elseif mole.state == "on_ladder" then
        if not mole.sound:isStopped() then
            mole.sound:stop()
            mole.sound:setPitch(0.4)
        end

        mole.vel_y = 0
    end

    -- New possible position
    new_x = mole.x + mole.vel_x
    new_y = mole.y + mole.vel_y

    -- Check for collisions with walls
    if current_level.collided(new_x - mole.width/2, mole.y) or current_level.collided(new_x + mole.width/2, mole.y) then
        mole.state = "idle"
        mole.vel_x = 0
        mole.is_moving = false
        new_x = mole.x
    end

    -- Check for collision with floor on ladder
    -- FIXME: Some fudge factor required here due to climbing animation being
    -- taller than the regular animation
    if mole.state == "climbing_down" and (mole.y + mole.height + 20) > current_level.level.floor then
        mole.state = "idle"
        mole.vel_y = 0
        new_y = current_level.level.floor - mole.height
        mole.sound:setPitch(0.4)
    end

    -- Update position
    mole.x = new_x
    mole.y = new_y
end
