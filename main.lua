-- using Lua Löve 11.4 64b
-- using Lua 5.3.6 win32

----------------------------------------------------------------
airplane = {
    src = "images/airplane.png",
    w = 0, h = 0,
    x = 0,  y = 0,
    life = 3,

    move = function()
        if love.keyboard.isDown('w', 'up') then
            if airplane.h / 3 + (airplane.y - AIRPLANE_VELOCITY) > 0 then
                airplane.y = airplane.y - AIRPLANE_VELOCITY
            end
        end
        if love.keyboard.isDown('s', 'down') then
            if airplane.h + (airplane.y + AIRPLANE_VELOCITY) < window_height then
                airplane.y = airplane.y + AIRPLANE_VELOCITY
            end
        end
        if love.keyboard.isDown('a', 'left') then
            -- middle of airplane on screen
            if (airplane.x - AIRPLANE_VELOCITY + airplane.w/2) > 0 then
                airplane.x = airplane.x - AIRPLANE_VELOCITY
            end
        end
        if love.keyboard.isDown('d', 'right') then
            -- middle of airplane on screen
            if airplane.w/2 + (airplane.x + AIRPLANE_VELOCITY) < window_width then
                airplane.x = airplane.x + AIRPLANE_VELOCITY
            end
        end
    end
}
----------------------------------------------------------------
meteorsArray = {}
MAX_OF_METEOR_ARRAY = 8
METEOR_VELOCITY = 1

function createMeteors(_x, _y)
    -- not spawn more meteors if all of MAX_OF_METEOR_ARRAY are still visible 
    if #meteorsArray > MAX_OF_METEOR_ARRAY then
        return
    end
    local l_weight = math.random(0.5, 1.5)

    meteor = {
        weight = l_weight, --= math.random(0.5, 1.5), --creating meteors with different sizes
        w = l_weight * meteorImage:getWidth()   -3,
        h = l_weight * meteorImage:getHeight()  -3,
        x = _x,  y = _y,
        angle = math.random(-0.785398, 0.785398) -- -45º to +45º to rotate meteor image and define (x,y) direction

    }
    table.insert(meteorsArray, meteor)
end

function moveMeteors()
    for k,localMeteor in pairs(meteorsArray) do
        localMeteor.y = localMeteor.y + METEOR_VELOCITY + 1/localMeteor.weight
        if localMeteor.angle >= 0 then
            localMeteor.x = localMeteor.x - METEOR_VELOCITY/2 -- localMeteor.weight --localMeteor.angle
        else
            localMeteor.x = localMeteor.x + METEOR_VELOCITY/2 -- localMeteor.weight --localMeteor.angle
        end
    end
end

function removeNotVisibleMeteors()
    for i=#meteorsArray, 1, -1 do
        if meteorsArray[i].y > window_height then
            table.remove(meteorsArray, i)
        end 
    end
end
----------------------------------------------------------------
-- velocity of airplane
AIRPLANE_VELOCITY = 3
GAME_OVER = false
----------------------------------------------------------------
function detectColision()
    a = airplane
    for i=#meteorsArray, 1, -1 do
        m = meteorsArray[i]
         
        ret =   m.x < a.x + a.w and
                a.x < m.x + m.w and
                a.y < m.y + m.h and
                m.y < a.y + a.h

        if ret then
            table.remove(meteorsArray, i)
            a.life = a.life - 1
        end 
    end
end
---------------- LOVE stuffs ------------------------------------
function love.load()
    math.randomseed(os.time())

    window_width, window_height = 320, 480
    love.window.setMode(window_width, window_height, {resizable=false})
    love.window.setTitle("joguinho")
    airplane.img = love.graphics.newImage(airplane.src)
    airplane.w = airplane.img:getWidth()    -3
    airplane.h = airplane.img:getHeight()   -3
    
    -- spawn airplane in botton and center of the window
    airplane.x, airplane.y = (window_width/2 - airplane.w/2), (window_height - airplane.h)

    background = love.graphics.newImage("images/background.png")
    
    meteorImage = love.graphics.newImage("images/meteor.png")
end

function love.update(dt)
    
    if love.keyboard.isDown('escape') then
        love.window.close()
    end

    if love.keyboard.isDown('kpenter',  'return') then
        meteorsArray = {}
        GAME_OVER =  false
        airplane.life = 3
    end

    if GAME_OVER then
        -- love.graphics.print("MORREU", 0, 0, 0, 2, 2)
        love.graphics.setColor(1, 1, 1, 0.6)
        return
    end

    if love.keyboard.isDown('w', 'up', 's', 'down', 'a', 'left', 'd', 'right') then
        airplane.move()
    end

    createMeteors(math.random(window_width), -200)
    moveMeteors()
    removeNotVisibleMeteors()
    detectColision()
    
    if airplane.life <= 0 then
        GAME_OVER = true
    end
end


function love.draw()
    -- order of draw is importante because of 'Z-index'. Eg.: background is behind airplane
    love.graphics.draw(background, 0, 0)
    
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("LIFE: ["..airplane.life.."]", 0, 0, 0, 5)
    love.graphics.setColor(1, 1, 1)

    love.graphics.draw(airplane.img, airplane.x, airplane.y)
    
    for k, meteor in pairs(meteorsArray) do
        love.graphics.draw(meteorImage, meteor.x, meteor.y, 0--[[meteor.angle--]], meteor.weight)
    end

    if GAME_OVER then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.print("FAIL",               0.20*(window_width/2), window_height/4, 0, 5)
        love.graphics.print("ENTER to continue!",   0.10*(window_width/2), window_height/1.5, 0, 2)
        
        love.graphics.setColor(1, 1, 1)
        return
    end
end