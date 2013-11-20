function love.load()
    -- Scale the images down a bit
    scale_factor = 0.65

    -- Set up the background image
    cave = {
        image = love.graphics.newImage("images/background.jpg"),
    }
    window_width  = cave.image:getWidth()/(1/scale_factor)
    window_height = cave.image:getHeight()/(1/scale_factor)
    cave.floor = (1.4*window_height)/(1/scale_factor)
    cave.left_wall = 0.1*window_width
    cave.right_wall = 0.9*window_width
    cave.draw = function()
        love.graphics.draw(cave.image, 0, 0, 0, scale_factor, scale_factor)
    end
    cave.collided = function(x, y)
        if x < cave.left_wall then
            return true
        elseif x > cave.right_wall then
            return true
        end
        return false
    end

    -- Scale the screen to the background image
    love.graphics.setCaption("Mole")
    love.graphics.setMode(window_width, window_height)

    -- Set up the actor
    mole = {
        image = love.graphics.newImage("images/mole.png"),
        sound = love.audio.newSource("audio/feet.ogg", "static"),
        facing = 1 -- 1: right, -1: left
    }
    mole.sound:setLooping(true)
    mole.x = window_width/2
    mole.height = mole.image:getHeight()
    mole.width  = mole.image:getWidth()
    mole.y = cave.floor - mole.height
    mole.draw = function()
        love.graphics.draw(mole.image, mole.x, mole.y, 0, mole.facing*scale_factor, scale_factor, mole.width/2)
    end
    mole.accel = 0.5
    mole.speed = 0
    mole.update = function()
        -- Movement
        if love.keyboard.isDown('left') then
            mole.speed = mole.speed - mole.accel
            if mole.facing == 1 then
                mole.speed = mole.speed * 0.2
                mole.facing = -1
            end
        elseif love.keyboard.isDown('right') then
            mole.speed = mole.speed + mole.accel
            if mole.facing == -1 then
                mole.speed = mole.speed * 0.2
                mole.facing = 1
            end
        else
            mole.speed = mole.speed * 0.5
        end

        -- Limit top speed
        if mole.speed > 10 then
            mole.speed = 10
        elseif mole.speed < -10 then
            mole.speed = -10
        end

        -- New possible x position
        new_x = mole.x + mole.speed

        -- Check for collisions
        for i,level in pairs(levels) do
            if level.collided(new_x - mole.width/2, mole.y) or level.collided(new_x + mole.width/2, mole.y) then
                mole.speed = 0
                new_x = mole.x
                break
            end
        end

        -- Update horizontal position based on speed
        mole.x = new_x

        -- Set sound playing
        if math.abs(mole.speed) > 0.1 then
            if mole.sound:isStopped() then
                mole.sound:play()
            end
        else
            if not mole.sound:isStopped() then
                mole.sound:stop()
            end
        end
    end

    -- Collections
    levels = {cave}
    objects = {mole}
end

function love.draw()
    -- Draw levels
    for i,level in pairs(levels) do
        level.draw()
    end

    -- Update and draw objects
    for i,object in pairs(objects) do
        object.update()
        object.draw()
    end
end
