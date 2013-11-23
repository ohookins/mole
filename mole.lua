-- Animation library
require("AnAL")

-- Set up the actor
mole = {
    walk_spritesheet   = love.graphics.newImage("images/mole.png"),
    crouch_spritesheet = love.graphics.newImage("images/crouching.png"),
    lookup_sprite      = love.graphics.newImage("images/lookup.png"),
    width              = 125, -- hard code due to spritesheet
    height             = 150,
    direction          = "right",
    is_looking         = false,
    is_crouching       = false,
    moving             = false,
    accel              = 0.2,
    speed              = 0,
    sound              = love.audio.newSource("audio/feet.ogg", "static"),
}
mole.sound:setLooping(true)
mole.sound:setPitch(0.4)
mole.walking = newAnimation(mole.walk_spritesheet, mole.width, mole.height, 0.1, 0)
mole.crouching = newAnimation(mole.crouch_spritesheet, mole.width, mole.height, 0.1, 0)
mole.crouching:setMode("once")

mole.draw = function()
    local direction_flip = (mole.direction == "right") and 1 or -1
    local width_comp = (mole.direction == "right") and 0 or mole.width

    if mole.is_looking then
        love.graphics.draw(mole.lookup_sprite, mole.x - mole.width/2, mole.y, 0, direction_flip, 1, width_comp)
    elseif mole.is_crouching then
        mole.crouching:draw(mole.x - mole.width/2, mole.y, 0, direction_flip, 1, width_comp)
    else
        mole.walking:draw(mole.x - mole.width/2, mole.y, 0, direction_flip, 1, width_comp)
    end
end

-- FIXME: Move all the keyboard handle-y stuff here
function love.keyreleased(key)
    if key == "down" then
        mole.crouching:reset()
        mole.crouching:play()
    end
end

mole.update = function(dt)
    -- Movement
    if love.keyboard.isDown('left') then
        if mole.direction == "right" then
            mole.speed = mole.speed * 0.2
        end
        mole.is_looking = false
        mole.is_crouching = false
        mole.direction = "left"
        mole.moving = true
        mole.speed = mole.speed - mole.accel
    elseif love.keyboard.isDown('right') then
        if mole.direction == "left" then
            mole.speed = mole.speed * 0.2
        end
        mole.is_looking = false
        mole.is_crouching = false
        mole.direction = "right"
        mole.moving = true
        mole.speed = mole.speed + mole.accel
    elseif love.keyboard.isDown('up') then
        mole.is_looking = true
        mole.is_crouching = false
        mole.speed = 0
        mole.moving = false
    elseif love.keyboard.isDown('down') then
        mole.is_looking = false
        mole.speed = 0
        mole.moving = false
        mole.is_crouching = true
    else
        mole.moving = false
        mole.is_crouching = false
        mole.is_looking = false
        mole.speed = mole.speed * 0.5
    end

    -- Limit top speed
    if mole.speed > 5 then
        mole.speed = 5
    elseif mole.speed < -5 then
        mole.speed = -5
    end

    -- New possible x position
    new_x = mole.x + mole.speed

    -- Check for collisions with walls
    if current_level.collided(new_x - mole.width/2, mole.y) or current_level.collided(new_x + mole.width/2, mole.y) then
        mole.speed = 0
        mole.moving = false
        new_x = mole.x
    end

    -- Update animation and sound
    if mole.moving then
        mole.walking:update(dt)
        if mole.sound:isStopped() then
            mole.sound:play()
        end
    elseif mole.is_crouching then
        mole.crouching:update(dt)
    else
        if not mole.sound:isStopped() then
            mole.sound:stop()
        end
    end

    -- Update horizontal position based on speed
    mole.x = new_x
end
