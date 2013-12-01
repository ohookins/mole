function round(n, mult)
    mult = mult or 1
    return math.floor((n + mult/2)/mult) * mult
end

function love.load()
    require "levels"
    require "mole"

    -- Scale the screen to the background image
    window_width  = current_level.level.image:getWidth()
    window_height = current_level.level.image:getHeight()
    love.graphics.setCaption("Mole")
    love.graphics.setMode(window_width, window_height)

    -- Set the mole's initial position
    mole.x = window_width/2
    mole.y = current_level.level.floor - mole.height

    -- Collections
    objects = {mole}
end

function love.update(dt)
    for i, object in pairs(objects) do
        object.update(dt)
    end
end

function love.draw()
    -- Draw level
    current_level.draw()

    for i,object in pairs(current_level.level.objects) do
        object.draw()
    end

    -- Update and draw objects
    for i,object in pairs(objects) do
        object.draw()
    end
end
