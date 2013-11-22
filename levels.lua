levels = {
    {
        name  = "cave",
        image = love.graphics.newImage("images/background.jpg"),
        floor = 470,
        walls = {
            left = 40,
            right = 680
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
