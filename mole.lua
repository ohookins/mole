-- Animation library
require("AnAL")

-- Set up the actor
mole = {
    walk_spritesheet = love.graphics.newImage("images/mole.png"),
    width            = 125, -- hard code due to spritesheet
    height           = 150,
    direction        = "right",
    moving           = false,
    accel            = 0.2,
    speed            = 0,
    sound            = love.audio.newSource("audio/feet.ogg", "static"),
}
mole.sound:setLooping(true)
mole.sound:setPitch(0.4)
mole.walking = newAnimation(mole.walk_spritesheet, mole.width, mole.height, 0.1, 0)

mole.draw = function()
    if mole.direction == "right" then
        mole.walking:draw(mole.x - mole.width/2, mole.y)
    elseif mole.direction == "left" then
        mole.walking:draw(mole.x - mole.width/2, mole.y, 0, -1, 1, mole.width)
    end
end

mole.update = function(dt)
    -- Movement
    if love.keyboard.isDown('left') then
        if mole.direction == "right" then
            mole.speed = mole.speed * 0.2
            mole.direction = "left"
        end
        mole.moving = true
        mole.speed = mole.speed - mole.accel
    elseif love.keyboard.isDown('right') then
        if mole.direction == "left" then
            mole.speed = mole.speed * 0.2
            mole.direction = "right"
        end
        mole.moving = true
        mole.speed = mole.speed + mole.accel
    else
        mole.moving = false
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
    else
        if not mole.sound:isStopped() then
            mole.sound:stop()
        end
    end

    -- Update horizontal position based on speed
    mole.x = new_x
end
