function love.load()
    -- Scale the images down a bit
    scale_factor = 0.65

    -- Set up the background image
    cave = {
        image = love.graphics.newImage("images/background.jpg")
    }
    window_width  = cave["image"]:getWidth()/(1/scale_factor)
    window_height = cave["image"]:getHeight()/(1/scale_factor)
    cave["floor"] = (1.4*window_height)/(1/scale_factor)

    -- Scale the screen to the background image
    love.graphics.setCaption("Mole")
    love.graphics.setMode(window_width, window_height)

    -- Set up the actor
    mole = {
        image = love.graphics.newImage("images/mole.png"),
        facing = 1 -- 1: right, -1: left
    }
    mole["x"] = window_width/2
    mole["height"] = mole["image"]:getHeight()
    mole["width"]  = mole["image"]:getWidth()
    mole["y"] = cave["floor"] - mole["height"]

    objects = {cave, mole}
end

function love.draw()
    -- Movement
    if love.keyboard.isDown('left') then
        mole["x"] = mole["x"] - 5
        mole["facing"] = -1
    elseif love.keyboard.isDown('right') then
        mole["x"] = mole["x"] + 5
        mole["facing"] = 1
    end

    love.graphics.draw(cave["image"], 0, 0, 0, scale_factor, scale_factor)
    love.graphics.draw(mole["image"], mole["x"], mole["y"], 0, mole["facing"]*scale_factor, scale_factor, mole["width"]/2)
end
