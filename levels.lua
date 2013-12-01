levels = {
    {
        name  = "cave",
        image = love.graphics.newImage("images/background.jpg"),
        floor = 470,
        walls = {
            left = 40,
            right = 680
        },
        objects = {
            {
                name = "ladder",
                x1 = 550,
                x2 = 590,
                y1 = 0,
                y2 = 600,
                -- TODO: Somehow abstract objects in rooms out
                draw = function() end,
                isClimbable = true,
                collided = function(x, y) return x >= 550 and x <= 590 end,
                centre_x = (590 + 550)/2
            }
        }
    }
}

current_level = {
    level = levels[1]
}

current_level.draw = function()
    love.graphics.draw(current_level.level.image)
end

current_level.collided = function(x, y)
    if x < current_level.level.walls.left then
        return true
    elseif x > current_level.level.walls.right then
        return true
    end
    return false
end
