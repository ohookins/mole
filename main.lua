function round(n, mult)
    mult = mult or 1
    return math.floor((n + mult/2)/mult) * mult
end

function love.load()
    -- Set up the background image
    cave = {
        image = love.graphics.newImage("images/background.jpg"),
    }
    window_width  = cave.image:getWidth()
    window_height = cave.image:getHeight()
    cave.floor = 470
    cave.left_wall = 40
    cave.right_wall = 680
    cave.draw = function()
        love.graphics.draw(cave.image)
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
        width = 125, -- hard code due to spritesheet
        height = 150,
        current_frame = 0,
        sound = love.audio.newSource("audio/feet.ogg", "static"),
        facing = 1 -- 1: right, -1: left
    }
    mole.sound:setLooping(true)
    mole.x = window_width/2
    mole.y = cave.floor - mole.height
    mole.draw = function()
        local image_frame = round(mole.current_frame / 2) % 8
        quad = love.graphics.newQuad(mole.width*image_frame, 0, mole.width, mole.height, mole.image:getWidth(), mole.image:getHeight())
        if mole.facing == -1 then
            quad:flip(true, false)
        else
            quad:flip(false, false)
        end
        love.graphics.drawq(mole.image, quad, mole.x - mole.width/2, mole.y)
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

        -- Set sound playing and increment frame_counter
        if math.abs(mole.speed) > 0.1 then
            mole.current_frame = mole.current_frame + 1
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
