-- Animation library
require("AnAL")

-- Set up the actor
mole = {
    walk_spritesheet      = love.graphics.newImage("images/mole.png"),
    crouch_spritesheet    = love.graphics.newImage("images/crouching.png"),
    lookup_sprite         = love.graphics.newImage("images/lookup.png"),
    gettingup_spritesheet = love.graphics.newImage("images/gettingup.png"),
    width                 = 125, -- hard code due to spritesheet
    height                = 150,
    direction             = "right",
    state                 = "idle",
    accel                 = 0.2,
    speed                 = 0,
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

-- State machine
mole.action = {
    ["looking"]    = function(d, w) love.graphics.draw(mole.lookup_sprite, mole.x - mole.width/2, mole.y, 0, d, 1, w) end,
    ["crouching"]  = function(d, w) mole.crouching:draw(mole.x - mole.width/2, mole.y, 0, d, 1, w) end,
    ["getting_up"] = function(d, w) mole.gettingup:draw(mole.x - mole.width/2, mole.y, 0, d, 1, w) end,
    ["walking"]    = function(d, w) mole.walking:draw(mole.x - mole.width/2, mole.y, 0, d, 1, w) end,
    ["idle"]       = function(d, w) mole.walking:draw(mole.x - mole.width/2, mole.y, 0, d, 1, w) end,
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
        end

    elseif key == "up" then
        if mole.state == "looking" then
            mole.state = "idle"
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
        if mole.state == "idle" then
            mole.state = "walking"
        end
        if mole.direction ~= key then
            mole.speed = 0
        end
        mole.direction = key

    elseif key == "down" then
        if mole.state == "idle" then
            mole.fart:play()
            mole.state = "crouching"
        end

    elseif key == "up" then
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
        mole.speed = mole.speed + (mole.direction == "right" and mole.accel or -mole.accel)

        -- Limit top speed
        if mole.speed > 5 then
            mole.speed = 5
        elseif mole.speed < -5 then
            mole.speed = -5
        end
    else
        if not mole.sound:isStopped() then
            mole.sound:stop()
        end
        mole.speed = 0
    end

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

    -- New possible x position
    new_x = mole.x + mole.speed

    -- Check for collisions with walls
    if current_level.collided(new_x - mole.width/2, mole.y) or current_level.collided(new_x + mole.width/2, mole.y) then
        mole.state = "idle"
        mole.speed = 0
        mole.is_moving = false
        new_x = mole.x
    end

    -- Update horizontal position based on speed
    mole.x = new_x
end
